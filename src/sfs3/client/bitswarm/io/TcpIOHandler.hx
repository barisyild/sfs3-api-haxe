package sfs3.client.bitswarm.io;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import haxe.Timer;
import sfs3.client.bitswarm.TransportType;
import sfs3.client.bitswarm.io.protocol.PacketHeader;
import sfs3.client.bitswarm.io.protocol.PacketReadState;
import sfs3.client.bitswarm.io.protocol.PendingPacket;
import sfs3.client.bitswarm.io.protocol.ProcessedPacket;
import sfs3.client.bitswarm.io.protocol.ProtocolUtils;
import sfs3.client.bitswarm.util.ByteUtils;
import sfs3.client.util.NetDebugLevel;
import sfs3.client.exceptions.IllegalStateException;
import haxe.io.BytesData;
import sfs3.client.core.Logger;

class TcpBuffer {
    public var bytes:BytesData;
    public var position:Int;
    public var capacity:Int;
    
    public function new(capacity:Int) {
        this.capacity = capacity;
        this.bytes = Bytes.alloc(capacity).getData();
        this.position = 0;
    }
    
    public function put(data:Bytes, offset:Int, length:Int):Void {
        Bytes.ofData(this.bytes).blit(this.position, data, offset, length);
        this.position += length;
    }
    
    public function getRemaining():Int {
        return capacity - position;
    }
}

class TcpIOHandler extends SpecializedIOHandler {
	private var readState:PacketReadState = PacketReadState.WaitNewPacket;
	private var pendingPacket:PendingPacket;
	
	public function new(ioHandler:SFSIOHandler) {
		super(ioHandler);
	}
	
	public function handleRead(data:Bytes):Void {
		var process:ProcessedPacket;
		
		if (data.length == 0) 
			throw new IllegalStateException("Got empty TCP packet: no readable bytes available!");

		var dbgLvl = ioHandler.getBitSwarm().getNetDebugLevel();
		if (dbgLvl == NetDebugLevel.PACKET || dbgLvl == NetDebugLevel.PROTOCOL) {
			if (data.length > hexDumpMaxSize) 
				log.info('Incoming, TCP, Size: ${data.length}, Dump omitted');
			else 
				log.info('Incoming, TCP, \n${ByteUtils.hexDump(data.getData())}');
		}
		
		try {
			while (data.length > 0) {
				if (Logger.isDebugEnabled())
					log.debug("ReadState: " + readState);
				
				switch (readState) {
					case WaitNewPacket:
						process = handleNewPacket(data);
						readState = process.getState();
						data = process.getData();
						
					case WaitDataSize:
						process = handleDataSize(data);
						readState = process.getState();
						data = process.getData();
						
					case WaitDataSizeFragment:
						process = handleDataSizeFragment(data);
						readState = process.getState();
						data = process.getData();
						
					case WaitData:
						process = handlePacketData(data);
						readState = process.getState();
						data = process.getData();
				}
			}
		} catch (ex:Dynamic) {
			log.warn("Error handling TCP packet: " + ex);
			readState = PacketReadState.WaitNewPacket;
		}
	}
	
	private function handleNewPacket(data:Bytes):ProcessedPacket {
		var header = ProtocolUtils.decodePacketHeader(data.get(0));
		
		pendingPacket = new PendingPacket(header);
		
		data = ByteUtils.resizeByteArray(data, 1, data.length - 1);
		
		return new ProcessedPacket(WaitDataSize, data);
	}
	
	private function handleDataSize(data:Bytes):ProcessedPacket {
		var state:PacketReadState = WaitData;
		var dataSize:Int = -1;
		var sizeBytes:Int = ProtocolUtils.INT16_BYTE_SIZE;
		
		if (pendingPacket.getHeader().isBigSized()) {
			if (data.length >= ProtocolUtils.INT32_BYTE_SIZE) {
				var buff = new BytesInput(data);
				buff.bigEndian = true;
				dataSize = buff.readInt32();
			}
			sizeBytes = ProtocolUtils.INT32_BYTE_SIZE;
			
			if (Logger.isDebugEnabled())
				log.debug('Big Sized Packet: ${dataSize == -1 ? "Unknown" : Std.string(dataSize)}');
		} else {
			if (data.length >= ProtocolUtils.INT16_BYTE_SIZE) {
				var msb = data.get(0) & 0xff;
				var lsb = data.get(1) & 0xff;
				dataSize = (msb * 256) + lsb;
			}
			if (Logger.isDebugEnabled())
				log.debug('Small Sized Packet: ${dataSize == -1 ? "Unknown" : Std.string(dataSize)}');
		}
		
		if (dataSize > -1) {
			pendingPacket.getHeader().setExpectedLen(dataSize);
			
			var buffer = new TcpBuffer(dataSize);
			pendingPacket.setBuffer(buffer);
			data = ByteUtils.resizeByteArray(data, sizeBytes, data.length - sizeBytes);
		} else {
			state = WaitDataSizeFragment;
			
			var sizeBuffer = new TcpBuffer(4);
			sizeBuffer.put(data, 0, data.length);
			
			pendingPacket.setBuffer(sizeBuffer);
			
			data = Bytes.alloc(0);
		}	
		
		return new ProcessedPacket(state, data);
	}
	
	private function handleDataSizeFragment(data:Bytes):ProcessedPacket {
		if (Logger.isDebugEnabled())
			log.debug("Handling DataSize fragment");
		
		var state:PacketReadState = WaitDataSizeFragment;
		var sizeBuffer = cast(pendingPacket.getBuffer(), TcpBuffer);
		
		var remaining = pendingPacket.getHeader().isBigSized() ? 
			ProtocolUtils.INT32_BYTE_SIZE - sizeBuffer.position : 
			ProtocolUtils.INT16_BYTE_SIZE - sizeBuffer.position;
		
		if (data.length >= remaining) {
			sizeBuffer.put(data, 0, remaining);
			
			var bi = new BytesInput(Bytes.ofData(sizeBuffer.bytes));
			bi.bigEndian = true;
			var dataSize:Int = pendingPacket.getHeader().isBigSized() ? bi.readInt32() : bi.readUInt16();
			
			if (Logger.isDebugEnabled())
				log.debug('DataSize found: $dataSize');
			
			pendingPacket.getHeader().setExpectedLen(dataSize);
			pendingPacket.setBuffer(new TcpBuffer(dataSize));
			
			state = WaitData;
			
			if (data.length > remaining)
				data = ByteUtils.resizeByteArray(data, remaining, data.length - remaining);
			else
				data = Bytes.alloc(0);
		} else {
			sizeBuffer.put(data, 0, data.length);
			data = Bytes.alloc(0);
		}
		
		return new ProcessedPacket(state, data);
	}
	
	private function handlePacketData(data:Bytes):ProcessedPacket {
		var state:PacketReadState = WaitData;
		var dataBuffer = cast(pendingPacket.getBuffer(), TcpBuffer);
		
		var readLen = dataBuffer.getRemaining();
		
		var isThereMore = data.length > readLen;
		
		if (data.length >= readLen) {
			dataBuffer.put(data, 0, readLen);
			
			if (pendingPacket.getHeader().getExpectedLen() != dataBuffer.capacity) {
				throw new IllegalStateException('Expected data size differs from the buffer capacity! Expected: ${pendingPacket.getHeader().getExpectedLen()}, Buffer size: ${dataBuffer.capacity}');
			}
			
			if (Logger.isDebugEnabled())
				log.debug("<<< PACKET COMPLETE >>>");
			
			var completedBytesData:BytesData = dataBuffer.bytes;
			var completedBytes:Bytes = Bytes.ofData(completedBytesData);
			
			if (pendingPacket.getHeader().isEncrypted()) {
				completedBytesData = ioHandler.getPacketEncrypter().decrypt(completedBytesData);
			}
			
			if (pendingPacket.getHeader().isCompressed()) {
				var t1 = haxe.Timer.stamp();
				var deflatedData = ioHandler.getPacketCompressor().uncompress(completedBytesData);
				var deflatedBytes:Bytes = Bytes.ofData(deflatedData);
				var t2 = haxe.Timer.stamp();
				
				if (Logger.isDebugEnabled()) {
					var compRatio = 100 - Std.int((completedBytes.length * 100) / deflatedBytes.length);
					var timeMs = (t2 - t1) * 1000;
					log.debug('Original: ${completedBytes.length}, Deflated: ${deflatedBytes.length}, Comp. Ratio: $compRatio%, Time: ${timeMs}ms.');
				}

				completedBytesData = deflatedData;
			}
			
			state = WaitNewPacket;
			
			getCodec().onPacketRead(completedBytesData, TransportType.TCP, pendingPacket.getHeader().isRaw());
		} else {
			dataBuffer.put(data, 0, data.length);
			
			if (Logger.isDebugEnabled())
				log.debug("Not enough data, store and wait fore more");
		}
		
		if (isThereMore)
			data = ByteUtils.resizeByteArray(data, readLen, data.length - readLen);
		else
			data = Bytes.alloc(0);
		
		return new ProcessedPacket(state, data);
	}
}
