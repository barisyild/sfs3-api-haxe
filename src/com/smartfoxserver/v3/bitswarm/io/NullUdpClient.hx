package com.smartfoxserver.v3.bitswarm.io;

import com.smartfoxserver.v3.bitswarm.BitSwarmClient;
import com.smartfoxserver.v3.bitswarm.TransportType;
import haxe.io.Bytes;

/**
 * No-op UDP client for platforms or situations where UDP is not available.
 * All operations are safe no-ops; isUdpInited() always returns false.
 */
class NullUdpClient extends BaseUdpSocketClient {
	public function new(bitSwarm:BitSwarmClient) {
		super(bitSwarm);
	}

	override public function connect(host:String, port:Int, timeoutMillis:Int = 0):Void {}

	override public function disconnect(reason:String = "Manual", errMessage:String = null):Void {}

	override public function kill():Void {}

	override public function write(data:Bytes, txType:TransportType = null):Void {}

	override public function init(params:Dynamic):Void {}

	override public function destroy(params:Dynamic):Void {
		super.destroy(params);
	}

	public function isUdpInited():Bool {
		return false;
	}
}
