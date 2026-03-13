package com.smartfoxserver.v3.bitswarm.io;
import com.smartfoxserver.v3.core.IDispatchable;
import haxe.io.Bytes;
import com.smartfoxserver.v3.util.ClientDisconnectionReason;

interface ISocketClient extends IDispatchable
{

    /*
	 * NOTE:
	 * the third parameter is used differently by the TCP and UDP implementations
	 * See the respective classes for the details
	 */
    public function connect(adr:String, port:Int, timeValue:Int = 0):Void;
    public function isConnected():Bool;

    public function disconnect(reason:String = "Manual", errMessage:String = null):Void;

    public function kill():Void;
    public function write(data:Bytes, txType:TransportType = null):Void;

    public function getSocketState():SocketState;

    // Allows to custom init the implementation
    public function init(params:Dynamic):Void;

    // Release internal resources
    public function destroy(params:Dynamic):Void;
}
