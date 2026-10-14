package sfs3.client.bitswarm.io;

import haxe.io.Bytes;
import haxe.Timer;
import sfs3.client.bitswarm.TransportType;
import sfs3.client.bitswarm.io.protocol.PacketHeader;
import sfs3.client.bitswarm.io.protocol.PacketReadState;
import sfs3.client.bitswarm.io.protocol.PendingPacket;
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
		if (data.length == 0)
			throw new IllegalStateException("Got empty TCP packet: no readable bytes available!");

		#if !no_traces
		var dbgLvl = ioHandler.getBitSwarm().getNetDebugLevel();
		if (dbgLvl == NetDebugLevel.PACKET || dbgLvl == NetDebugLevel.PROTOCOL) {
			if (data.length > hexDumpMaxSize)
				log.info('Incoming, TCP, Size: ${data.length}, Dump omitted');
			else
				log.info('Incoming, TCP, \n${ByteUtils.hexDump(data.getData())}');
		}
		#end

		try {
			var pos = 0;
			var end = data.length;
			while (pos < end) {
				if (Logger.isDebugEnabled())
					log.debug("ReadState: " + readState);

				switch (readState) {
					case WaitNewPacket:
						pos = handleNewPacket(data, pos);

					case WaitDataSize:
						pos = handleDataSize(data, pos, end);

					case WaitDataSizeFragment:
						pos = handleDataSizeFragment(data, pos, end);

					case WaitData:
						pos = handlePacketData(data, pos, end);
				}
			}
		} catch (ex:Dynamic) {
			log.warn("Error handling TCP packet: " + ex);
			readState = PacketReadState.WaitNewPacket;
		}
	}

	private function handleNewPacket(data:Bytes, pos:Int):Int {
		var header = ProtocolUtils.decodePacketHeader(data.get(pos));

		pendingPacket = new PendingPacket(header);
		readState = PacketReadState.WaitDataSize;

		return pos + 1;
	}

	private function handleDataSize(data:Bytes, pos:Int, end:Int):Int {
		var available = end - pos;
		var dataSize:Int = -1;
		var sizeBytes:Int = ProtocolUtils.INT16_BYTE_SIZE;

		if (pendingPacket.getHeader().isBigSized()) {
			sizeBytes = ProtocolUtils.INT32_BYTE_SIZE;
			if (available >= sizeBytes)
				dataSize = readInt32(data, pos);

			if (Logger.isDebugEnabled())
				log.debug('Big Sized Packet: ${dataSize == -1 ? "Unknown" : Std.string(dataSize)}');
		} else {
			if (available >= sizeBytes)
				dataSize = readUInt16(data, pos);

			if (Logger.isDebugEnabled())
				log.debug('Small Sized Packet: ${dataSize == -1 ? "Unknown" : Std.string(dataSize)}');
		}

		if (dataSize > -1) {
			pendingPacket.getHeader().setExpectedLen(dataSize);
			readState = PacketReadState.WaitData;
			return pos + sizeBytes;
		}

		var sizeBuffer = new TcpBuffer(4);
		sizeBuffer.put(data, pos, available);
		pendingPacket.setBuffer(sizeBuffer);
		readState = PacketReadState.WaitDataSizeFragment;

		return end;
	}

	private function handleDataSizeFragment(data:Bytes, pos:Int, end:Int):Int {
		if (Logger.isDebugEnabled())
			log.debug("Handling DataSize fragment");

		var available = end - pos;
		var sizeBuffer = cast(pendingPacket.getBuffer(), TcpBuffer);
		var sizeBytes = pendingPacket.getHeader().isBigSized() ? ProtocolUtils.INT32_BYTE_SIZE : ProtocolUtils.INT16_BYTE_SIZE;
		var remaining = sizeBytes - sizeBuffer.position;

		if (available < remaining) {
			sizeBuffer.put(data, pos, available);
			return end;
		}

		sizeBuffer.put(data, pos, remaining);
		var sizeData = Bytes.ofData(sizeBuffer.bytes);
		var dataSize:Int = pendingPacket.getHeader().isBigSized() ? readInt32(sizeData, 0) : readUInt16(sizeData, 0);

		if (Logger.isDebugEnabled())
			log.debug('DataSize found: $dataSize');

		pendingPacket.getHeader().setExpectedLen(dataSize);
		pendingPacket.setBuffer(null);
		readState = PacketReadState.WaitData;

		return pos + remaining;
	}

	private function handlePacketData(data:Bytes, pos:Int, end:Int):Int {
		var header:PacketHeader = pendingPacket.getHeader();
		var available = end - pos;
		var dataBuffer:TcpBuffer = cast pendingPacket.getBuffer();
		var readLen = dataBuffer == null ? header.getExpectedLen() : dataBuffer.getRemaining();

		if (available < readLen) {
			if (dataBuffer == null) {
				dataBuffer = new TcpBuffer(header.getExpectedLen());
				pendingPacket.setBuffer(dataBuffer);
			}
			dataBuffer.put(data, pos, available);

			if (Logger.isDebugEnabled())
				log.debug("Not enough data, store and wait fore more");

			return end;
		}

		if (Logger.isDebugEnabled())
			log.debug("<<< PACKET COMPLETE >>>");

		readState = PacketReadState.WaitNewPacket;

		if (dataBuffer == null && !header.isEncrypted() && !header.isCompressed()) {
			getCodec().onPacketReadAt(data, pos, readLen, TransportType.TCP, header.isRaw());
			return pos + readLen;
		}

		if (dataBuffer == null) {
			dataBuffer = new TcpBuffer(header.getExpectedLen());
			pendingPacket.setBuffer(dataBuffer);
		}
		dataBuffer.put(data, pos, readLen);

		if (header.getExpectedLen() != dataBuffer.capacity) {
			throw new IllegalStateException('Expected data size differs from the buffer capacity! Expected: ${header.getExpectedLen()}, Buffer size: ${dataBuffer.capacity}');
		}

		var completedBytesData:BytesData = dataBuffer.bytes;

		if (header.isEncrypted()) {
			completedBytesData = ioHandler.getPacketEncrypter().decrypt(completedBytesData);
		}

		if (header.isCompressed()) {
			var t1 = haxe.Timer.stamp();
			var deflatedData = ioHandler.getPacketCompressor().uncompress(completedBytesData);
			var t2 = haxe.Timer.stamp();

			if (Logger.isDebugEnabled()) {
				var deflatedLength = Bytes.ofData(deflatedData).length;
				var compRatio = 100 - Std.int((dataBuffer.capacity * 100) / deflatedLength);
				var timeMs = (t2 - t1) * 1000;
				log.debug('Original: ${dataBuffer.capacity}, Deflated: ${deflatedLength}, Comp. Ratio: $compRatio%, Time: ${timeMs}ms.');
			}

			completedBytesData = deflatedData;
		}

		getCodec().onPacketRead(completedBytesData, TransportType.TCP, header.isRaw());

		return pos + readLen;
	}

	private static inline function readUInt16(data:Bytes, pos:Int):Int {
		return ((data.get(pos) & 0xff) << 8) | (data.get(pos + 1) & 0xff);
	}

	private static inline function readInt32(data:Bytes, pos:Int):Int {
		return ((data.get(pos) & 0xff) << 24) | ((data.get(pos + 1) & 0xff) << 16) | ((data.get(pos + 2) & 0xff) << 8) | (data.get(pos + 3) & 0xff);
	}
}
