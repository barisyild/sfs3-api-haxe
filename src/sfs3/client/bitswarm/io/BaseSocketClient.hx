package sfs3.client.bitswarm.io;

import sfs3.client.bitswarm.BitSwarmClient;
import sfs3.client.bitswarm.SocketState;
import sfs3.client.bitswarm.TransportType;
import sfs3.client.core.EventDispatcher;
import sfs3.client.core.IEventListener;
import sfs3.client.core.Logger;
import sfs3.client.core.LoggerFactory;
import haxe.io.Bytes;
import hx.concurrent.executor.Executor;
import sfs3.client.core.ApiEvent;

abstract class BaseSocketClient implements ISocketClient {
	private var log:Logger;
	private var socketState:SocketState = SocketState.Disconnected;

	private var evtDispatcher:EventDispatcher;
	private var threadPool:Executor;
	private var bitSwarm:BitSwarmClient;

	public function new(bitSwarm:BitSwarmClient) {
		this.log = LoggerFactory.getLogger(Type.getClass(this));
		this.bitSwarm = bitSwarm;
		this.threadPool = bitSwarm.getThreadPool();
		evtDispatcher = new EventDispatcher(this);
	}

	public function init(params:Dynamic):Void {}

	public function destroy(params:Dynamic):Void {}

	public function addEventListener<T:ApiEvent>(eventType:String, listener:IEventListener<T>):Void {
		evtDispatcher.addEventListener(eventType, listener);
	}

	public function removeEventListener<T:ApiEvent>(eventType:String, listener:IEventListener<T>):Void {
		evtDispatcher.removeEventListener(eventType, listener);
	}

	public function removeAllEventListeners():Void {
		evtDispatcher.removeAll();
	}

	public function getDispatcher():EventDispatcher {
		return evtDispatcher;
	}

	public function connect(host:String, port:Int, timeValue:Int = 0):Void {}

	public function disconnect(reason:String = "Manual", errMessage:String = null):Void {}

	public function kill():Void {}

	public function write(data:Bytes, txType:TransportType = null):Void {}

	public function isConnected():Bool {
		return socketState == SocketState.Connected;
	}

	public function getSocketState():SocketState {
		return socketState;
	}
}
