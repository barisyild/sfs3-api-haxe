package sfs3.client.bitswarm.io;

// WARNING: AI Generated and Not Tested
#if nodejs
import sfs3.client.ConfigData;
import sfs3.client.bitswarm.BitSwarmClient;
import sfs3.client.bitswarm.SocketState;
import sfs3.client.bitswarm.TransportType;
import sfs3.client.core.EventParam;
import sfs3.client.util.ClientDisconnectionReason;
import sfs3.client.bitswarm.io.SocketEvent as SFSocketEvent;
import haxe.Exception;
import haxe.io.Bytes;
import js.node.Buffer;
import js.node.Net;
import js.node.net.Socket;
import sfs3.client.entities.data.Queue;
import sfs3.client.entities.data.PlatformStringMap;

/**
 * TCP client for Node.js using hxnodejs (async, non-blocking).
 * Event-driven like FlashTcpClient; uses Net.Socket and write queue with drain handling.
 */
class NodeTcpClient extends BaseSocketClient {
	private var outPacketQ:Queue<Bytes>;
	private var tcpSocket:Socket;
	private var serverHost:String;
	private var serverPort:Int;
	private var cfg:ConfigData;
	private var writeInProgress:Bool = false;

	public function new(bitSwarm:BitSwarmClient) {
		super(bitSwarm);
		outPacketQ = new Queue<Bytes>();
		cfg = bitSwarm.getSmartFox().getConfig();
	}

	override public function connect(host:String, port:Int, timeoutMillis:Int = 0):Void {
		if (socketState != SocketState.Disconnected)
			throw new Exception("Can't connect now, current state is: " + Std.string(socketState));

		serverHost = host;
		serverPort = port;
		socketState = SocketState.Connecting;

		try {
			tcpSocket = Net.connect(serverPort, serverHost, onConnect);
			tcpSocket.on("data", onData);
			tcpSocket.on("close", onClose);
			tcpSocket.on("error", onError);
			tcpSocket.on("drain", onDrain);

			if (timeoutMillis > 0)
				tcpSocket.setTimeout(timeoutMillis);
		} catch (ex:Dynamic) {
			handleError(Std.string(ex));
		}
	}

	private function onConnect():Void {
		socketState = SocketState.Connected;
		var evt = new SFSocketEvent(SFSocketEvent.Connected);
		evtDispatcher.dispatchEvent(evt);
		tryFlushWriteQueue();
	}

	private function onData(chunk:Dynamic):Void {
		if (socketState != SocketState.Connected || tcpSocket == null)
			return;
		try {
			var data:Bytes = null;
			if (Std.isOfType(chunk, Buffer)) {
				data = (cast chunk : Buffer).hxToBytes();
			} else if (Std.isOfType(chunk, String)) {
				data = Bytes.ofString(cast chunk);
			} else {
				return;
			}
			if (data.length > 0) {
				var evt = new SFSocketEvent(SFSocketEvent.DataReceived);
				evt.getParams().set(EventParam.Data, data);
				evtDispatcher.dispatchEvent(evt);
			}
		} catch (ex:Dynamic) {
			log.warn("Node TCP Read Error: " + Std.string(ex));
			if (socketState != SocketState.Disconnected)
				disconnect(ClientDisconnectionReason.UNKNOWN, Std.string(ex));
		}
	}

	private function onClose(hadError:Bool):Void {
		if (socketState != SocketState.Disconnected)
			disconnect(ClientDisconnectionReason.UNKNOWN, hadError ? "Connection closed with error" : "Connection closed by remote host");
	}

	private function onError(err:Dynamic):Void {
		var msg = (err != null && Reflect.hasField(err, "message")) ? Reflect.field(err, "message") : Std.string(err);
		handleError(msg);
	}

	private function onDrain():Void {
		writeInProgress = false;
		tryFlushWriteQueue();
	}

	private function handleError(msg:String):Void {
		socketState = SocketState.Disconnected;
		log.warn("Connection to " + serverHost + ":" + serverPort + " failed -- Cause: " + msg);
		var evt = new SFSocketEvent(SFSocketEvent.Error);
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
		evtDispatcher.dispatchEvent(new SFSocketEvent(SFSocketEvent.Disconnected, params));
	}

	override public function kill():Void {
		try {
			if (tcpSocket != null)
				tcpSocket.destroy();
		} catch (ex:Dynamic) {
			log.warn("Unexpected socket error: " + Std.string(ex));
		}
	}

	override public function write(data:Bytes, txType:TransportType = null):Void {
		outPacketQ.push(data);
		tryFlushWriteQueue();
	}

	private function tryFlushWriteQueue():Void {
		if (tcpSocket == null || socketState != SocketState.Connected || writeInProgress)
			return;
		var packet:Null<Bytes> = outPacketQ.peek();
		if (packet == null)
			return;
		if (packet.length == 0) {
			outPacketQ.dequeue();
			return;
		}
		writeInProgress = true;
		var nodeBuf = Buffer.hxFromBytes(packet);
		tcpSocket.write(nodeBuf, function(err:Dynamic) {
			writeInProgress = false;
			if (err != null) {
				log.warn("Node TCP Write Error: " + Std.string(err));
				if (socketState != SocketState.Disconnected)
					disconnect(ClientDisconnectionReason.UNKNOWN, Std.string(err));
				return;
			}
			outPacketQ.dequeue();
			tryFlushWriteQueue();
		});
	}

	private function closeSocket():Void {
		socketState = SocketState.Disconnected;
		try {
			if (tcpSocket != null) {
				tcpSocket.removeAllListeners();
				tcpSocket.destroy();
				tcpSocket = null;
				log.info("Node TCP Socket closed");
			}
		} catch (ex:Dynamic) {
			log.warn("Error closing Node TCP socket: " + Std.string(ex));
		}
	}
}
#end
