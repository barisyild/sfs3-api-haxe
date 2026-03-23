package com.smartfoxserver.v3.bitswarm.io;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.Timer;
import com.smartfoxserver.v3.bitswarm.TransportType;
import com.smartfoxserver.v3.bitswarm.util.ByteUtils;
import com.smartfoxserver.v3.bitswarm.io.protocol.ProtocolUtils;
import com.smartfoxserver.v3.util.NetDebugLevel;

class UdpIOHandler extends SpecializedIOHandler {
	public function new(ioHandler:SFSIOHandler) {
		super(ioHandler);
	}
	
	public function handleRead(byteData:Bytes, txType:TransportType):Void {
		var dataBuffer = new BytesInput(byteData);
		var headerByte = dataBuffer.readByte();
		var header = ProtocolUtils.decodePacketHeader(headerByte);
		
		var remainingDataBytes = byteData.sub(dataBuffer.position, byteData.length - dataBuffer.position);
		var remainingData = remainingDataBytes.getData();
		
		var dbgLvl = ioHandler.getBitSwarm().getNetDebugLevel();
		if (dbgLvl == NetDebugLevel.PACKET || dbgLvl == NetDebugLevel.PROTOCOL) {
			if (remainingDataBytes.length > hexDumpMaxSize)
				log.info('Incoming, $txType, Size: ${remainingDataBytes.length}, Dump omitted');
			else 
				log.info('Incoming, $txType, \n${ByteUtils.hexDump(remainingData)}');
		}
		
		if (header.isEncrypted()) {
			remainingData = ioHandler.getPacketEncrypter().decrypt(remainingData);
		}
		remainingDataBytes = Bytes.ofData(remainingData);
		
		if (header.isCompressed()) {
			var t1 = haxe.Timer.stamp();
			var deflatedData = ioHandler.getPacketCompressor().uncompress(remainingData);
			var deflatedDataBytes:Bytes = Bytes.ofData(deflatedData);
			var t2 = haxe.Timer.stamp();
			
			if (log.isDebugEnabled()) {
				var compRatio = 100 - Std.int((remainingDataBytes.length * 100) / deflatedDataBytes.length);
				var timeMs = (t2 - t1) * 1000;
				log.debug('Original: ${remainingDataBytes.length}, Deflated: ${deflatedDataBytes.length}, Comp. Ratio: $compRatio%, Time: ${timeMs}ms.');
			}
			
			remainingData = deflatedData;
		}
		
		getCodec().onPacketRead(remainingData, txType, header.isRaw());
	}
}
