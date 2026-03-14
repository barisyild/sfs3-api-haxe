package com.smartfoxserver.v3.bitswarm.io;

// WARNING: AI Generated and Not Tested
#if nodejs
import com.smartfoxserver.v3.bitswarm.BitSwarmClient;
import com.smartfoxserver.v3.bitswarm.TransportType;
import haxe.io.Bytes;

/**
 * Stub UDP client for Node.js. UDP is not implemented; use TCP only on nodejs.
 */
class NodeUdpClient extends BaseUdpSocketClient {
	public function new(bitSwarm:BitSwarmClient) {
		super(bitSwarm);
	}

	public function connect(host:String, port:Int, timeoutMillis:Int = 0):Void {}

	public function disconnect(reason:String = "Manual", errMessage:String = null):Void {}

	public function kill():Void {}

	public function write(data:Bytes, txType:TransportType = null):Void {}

	override public function init(params:Dynamic):Void {}

	override public function destroy(params:Dynamic):Void {
		super.destroy(params);
	}

	public function isUdpInited():Bool {
		return false;
	}
}
#end
