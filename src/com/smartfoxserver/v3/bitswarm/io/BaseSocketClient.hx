package com.smartfoxserver.v3.bitswarm.io;

import com.smartfoxserver.v3.bitswarm.BitSwarmClient;
import com.smartfoxserver.v3.bitswarm.SocketState;
import com.smartfoxserver.v3.core.EventDispatcher;
import com.smartfoxserver.v3.core.IEventListener;
import com.smartfoxserver.v3.core.Logger;
import com.smartfoxserver.v3.core.LoggerFactory;
import hx.concurrent.executor.Executor;

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

	public function addEventListener(eventType:String, listener:IEventListener):Void {
		evtDispatcher.addEventListener(eventType, listener);
	}

	public function removeEventListener(eventType:String, listener:IEventListener):Void {
		evtDispatcher.removeEventListener(eventType, listener);
	}

	public function removeAllEventListeners():Void {
		evtDispatcher.removeAll();
	}

	public function getDispatcher():EventDispatcher {
		return evtDispatcher;
	}

	public function isConnected():Bool {
		return socketState == SocketState.Connected;
	}

	public function getSocketState():SocketState {
		return socketState;
	}
}
