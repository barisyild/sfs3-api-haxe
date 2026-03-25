package com.smartfoxserver.v3.bitswarm.io;

#if (flash || openfl)
import com.smartfoxserver.v3.ConfigData;
import com.smartfoxserver.v3.bitswarm.BitSwarmClient;
import com.smartfoxserver.v3.bitswarm.SocketState;
import com.smartfoxserver.v3.bitswarm.TransportType;
import com.smartfoxserver.v3.core.EventParam;
import com.smartfoxserver.v3.util.ClientDisconnectionReason;
import haxe.Exception;
import haxe.io.Bytes;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.Socket;
import com.smartfoxserver.v3.entities.data.PlatformStringMap;

class FlashTcpClient extends BaseSocketClient {
	private var tcpSocket:Socket;
	private var serverHost:String;
	private var serverPort:Int;
	private var cfg:ConfigData;

	public function new(bitSwarm:BitSwarmClient) {
		super(bitSwarm);
		cfg = bitSwarm.getSmartFox().getConfig();
	}

	override public function connect(host:String, port:Int, timeoutMillis:Int = 0):Void {
		if (socketState != SocketState.Disconnected)
			throw new Exception("Can't connect now, current state is: " + Std.string(socketState));

		this.serverHost = host;
		this.serverPort = port;

		socketState = SocketState.Connecting;

		try {
			tcpSocket = new Socket();
			tcpSocket.addEventListener(Event.CONNECT, onConnect);
			tcpSocket.addEventListener(Event.CLOSE, onClose);
			tcpSocket.addEventListener(ProgressEvent.SOCKET_DATA, onData);
			tcpSocket.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			tcpSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);

			tcpSocket.connect(host, port);
		} catch (ex:Dynamic) {
			handleError(Std.string(ex));
		}
	}

	private function onConnect(e:Event):Void {
		socketState = SocketState.Connected;
		var evt = new SocketEvent(SocketEvent.Connected);
		evtDispatcher.dispatchEvent(evt);
	}

	private function onClose(e:Event):Void {
		if (socketState != SocketState.Disconnected)
			disconnect(ClientDisconnectionReason.UNKNOWN, "Connection closed by remote host");
	}

	private function onData(e:ProgressEvent):Void {
		try {
			if (tcpSocket.bytesAvailable > 0) {
				var bytes = Bytes.alloc(tcpSocket.bytesAvailable);
				tcpSocket.readBytes(bytes.getData(), 0, tcpSocket.bytesAvailable);

				var evt = new SocketEvent(SocketEvent.DataReceived);
				evt.getParams().set(EventParam.Data, bytes);
				evtDispatcher.dispatchEvent(evt);
			}
		} catch (ex:Dynamic) {
			log.warn("Flash TCP Read Error: " + Std.string(ex));
		}
	}

	private function onIOError(e:IOErrorEvent):Void {
		handleError(e.text);
	}

	private function onSecurityError(e:SecurityErrorEvent):Void {
		handleError(e.text);
	}

	private function handleError(msg:String):Void {
		socketState = SocketState.Disconnected;
		log.warn("Connection to " + serverHost + ":" + serverPort + " failed -- Cause: " + msg);

		var evt = new SocketEvent(SocketEvent.Error);
		evt.getParams().set(EventParam.ErrorMessage, msg);
		evtDispatcher.dispatchEvent(evt);
	}

	override public function destroy(params:Dynamic):Void {
		super.destroy(params);

		closeSocket();
		evtDispatcher.removeAll();
	}

	override public function disconnect(reason:String = "Manual", errMessage:String = null):Void {
		if (socketState == SocketState.Disconnected)
			throw new Exception("TCP connection is already closed");

		closeSocket();

		var params = new PlatformStringMap<Dynamic>();
		params.set(EventParam.DisconnectionReason, reason);
		params.set(EventParam.ErrorMessage, errMessage);

		evtDispatcher.dispatchEvent(new SocketEvent(SocketEvent.Disconnected, params));
	}

	override public function kill():Void {
		try {
			if (tcpSocket != null && tcpSocket.connected)
				tcpSocket.close();
		} catch (ex:Dynamic) {
			log.warn("Unexpected socket error: " + Std.string(ex));
		}
	}

	override public function write(data:Bytes, txType:TransportType = null):Void {
		if (socketState == SocketState.Connected && tcpSocket != null) {
			try {
				tcpSocket.writeBytes(data.getData());
				tcpSocket.flush();
			} catch (ex:Dynamic) {
				log.warn("Flash TCP Write Error: " + Std.string(ex));
				if (socketState != SocketState.Disconnected)
					disconnect(ClientDisconnectionReason.UNKNOWN, Std.string(ex));
			}
		}
	}

	private function closeSocket():Void {
		socketState = SocketState.Disconnected;

		if (tcpSocket != null) {
			try {
				tcpSocket.removeEventListener(Event.CONNECT, onConnect);
				tcpSocket.removeEventListener(Event.CLOSE, onClose);
				tcpSocket.removeEventListener(ProgressEvent.SOCKET_DATA, onData);
				tcpSocket.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
				tcpSocket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);

				if (tcpSocket.connected)
					tcpSocket.close();
			} catch (ex:Dynamic) {
				log.warn("Error closing TCP socket: " + Std.string(ex));
			}
		}
	}
}
#end
