package com.smartfoxserver.v3.bitswarm.io;

// WARNING: AI Generated and Not Tested
import com.smartfoxserver.v3.ConfigData;
import com.smartfoxserver.v3.bitswarm.BitSwarmClient;
import com.smartfoxserver.v3.bitswarm.SocketState;
import com.smartfoxserver.v3.bitswarm.TransportType;
import com.smartfoxserver.v3.core.EventParam;
import com.smartfoxserver.v3.util.ClientDisconnectionReason;
import com.smartfoxserver.v3.util.WebServices;
import haxe.Exception;
import haxe.io.Bytes;
import haxe.net.WebSocket;

class WebSocketClient extends BaseSocketClient {
	private var ws:WebSocket = null;
	private var serverHost:String;
	private var serverPort:Int;
	private var cfg:ConfigData;

	public function new(bitSwarm:BitSwarmClient) {
		super(bitSwarm);
		cfg = bitSwarm.getSmartFox().getConfig();
	}

	public function connect(host:String, port:Int, timeoutMillis:Int = 0):Void {
		if (socketState != SocketState.Disconnected)
			throw new Exception("Can't connect now, current state is: " + Std.string(socketState));

		this.serverHost = host;
		this.serverPort = port;
		socketState = SocketState.Connecting;

		try {
			if (ws != null) {
				ws.onopen = function() {};
				ws.onmessageBytes = function(bytes:Bytes) {};
				ws.onclose = function(?e:Dynamic) {};
				ws.onerror = function(error:String) {};
			}

			var url = buildUrl();
			log.info("WebSocket connecting to: " + url);

			ws = WebSocket.create(url, null, null, false);

			ws.onopen = function() {
				socketState = SocketState.Connected;
				evtDispatcher.dispatchEvent(new SocketEvent(SocketEvent.Connected));
			};

			ws.onmessageBytes = function(bytes:Bytes) {
				var evt = new SocketEvent(SocketEvent.DataReceived);
				evt.getParams().set(EventParam.Data, bytes);
				evtDispatcher.dispatchEvent(evt);
			};

			ws.onclose = function(?e:Dynamic) {
				if (socketState != SocketState.Disconnected)
					disconnect(ClientDisconnectionReason.UNKNOWN, "Connection closed by remote host");
			};

			ws.onerror = function(error:String) {
				handleError(error);
			};

			#if (flash || openfl)
			flash.Lib.current.addEventListener(flash.events.Event.ENTER_FRAME, onEnterFrame);
			#elseif (target.threaded)
			threadPool.submit(function():Void {
				processLoop();
			});
			#end
		} catch (ex:Dynamic) {
			handleError(Std.string(ex));
		}
	}

	override public function destroy(params:Dynamic):Void {
		super.destroy(params);
		closeSocket();
		evtDispatcher.removeAll();
	}

	public function disconnect(reason:String = "Manual", errMessage:String = null):Void {
		if (socketState == SocketState.Disconnected)
			throw new Exception("WebSocket connection is already closed");

		closeSocket();

		var params = new Map<String, Dynamic>();
		params.set(EventParam.DisconnectionReason, reason);
		params.set(EventParam.ErrorMessage, errMessage);

		evtDispatcher.dispatchEvent(new SocketEvent(SocketEvent.Disconnected, params));
	}

	public function kill():Void {
		try {
			closeSocket();
		} catch (ex:Dynamic) {
			log.warn("Unexpected WebSocket error: " + Std.string(ex));
		}
	}

	public function write(data:Bytes, txType:TransportType = null):Void {
		if (socketState == SocketState.Connected && ws != null) {
			try {
				ws.sendBytes(data);
			} catch (ex:Dynamic) {
				log.warn("WebSocket Write Error: " + Std.string(ex));
				if (socketState != SocketState.Disconnected)
					disconnect(ClientDisconnectionReason.UNKNOWN, Std.string(ex));
			}
		}
	}

	// -------------------------------------------------------------------------

	private function buildUrl():String {
		var protocol = cfg.useSSL ? "wss://" : "ws://";
		return protocol + serverHost + ":" + serverPort + "/" + WebServices.BASE_SERVLET + "/" + WebServices.WEBSOCKET;
	}

	private function handleError(msg:String):Void {
		socketState = SocketState.Disconnected;
		log.warn("WebSocket connection to " + serverHost + ":" + serverPort + " failed -- Cause: " + msg);

		var evt = new SocketEvent(SocketEvent.Error);
		evt.getParams().set(EventParam.ErrorMessage, msg);
		evtDispatcher.dispatchEvent(evt);
	}

	#if (openfl || flash)
	private function onEnterFrame(e:flash.events.Event):Void {
		if (ws != null)
			ws.process();
	}
	#end

	private function processLoop():Void {
		while (ws != null && socketState != SocketState.Disconnected) {
			ws.process();
		}
		log.info("Exiting WebSocket process loop");
	}

	private function closeSocket():Void {
		socketState = SocketState.Disconnected;

		#if (openfl && !js)
		flash.Lib.current.removeEventListener(flash.events.Event.ENTER_FRAME, onEnterFrame);
		#end

		if (ws != null) {
			try {
				ws.onopen = function() {};
				ws.onmessageBytes = function(bytes:Bytes) {};
				ws.onclose = function(?e:Dynamic) {};
				ws.onerror = function(error:String) {};
				ws.close();
			} catch (ex:Dynamic) {
				log.warn("Error closing WebSocket: " + Std.string(ex));
			}
			ws = null;
		}
	}
}
