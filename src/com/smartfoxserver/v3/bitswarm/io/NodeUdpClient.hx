package com.smartfoxserver.v3.bitswarm.io;

#if nodejs
import com.smartfoxserver.v3.bitswarm.BitSwarmClient;
import com.smartfoxserver.v3.bitswarm.BitSwarmEvent;
import com.smartfoxserver.v3.bitswarm.SocketState;
import com.smartfoxserver.v3.bitswarm.TransportType;
import com.smartfoxserver.v3.bitswarm.TransportType.TransportTypeTools;
import com.smartfoxserver.v3.bitswarm.rdp.RDPTransport;
import com.smartfoxserver.v3.bitswarm.rdp.TxpMode;
import com.smartfoxserver.v3.bitswarm.rdp.data.EndPoint;
import com.smartfoxserver.v3.controllers.SystemController;
import com.smartfoxserver.v3.core.ApiEvent;
import com.smartfoxserver.v3.core.EventParam;
import com.smartfoxserver.v3.core.IEventListener;
import com.smartfoxserver.v3.entities.data.PlatformStringMap;
import com.smartfoxserver.v3.requests.UdpInitRequest;
import com.smartfoxserver.v3.util.ClientDisconnectionReason;
import haxe.Exception;
import haxe.Timer;
import haxe.io.Bytes;
import js.node.Buffer;
import com.smartfoxserver.v3.bitswarm.rdp.TransportConfig;

class NodeUdpClient extends BaseUdpSocketClient {
	private static final MAX_RETRY:Int = 3;
	private static final RESPONSE_TIMEOUT:Float = 3.0;
	private static final KEEP_ALIVE_SECONDS:Float = 4.0;

	private var socket:Dynamic;
	private var serverHost:String;
	private var serverPort:Int;
	private var connectionAttemptCount:Int;
	private var maxUdpIdleSecs:Float;
	private var udpKeepAlive:Bool;
	private var lastUdpPacketTime:Float;
	private var udpHandEventListener:IEventListener<ApiEvent>;
	private var rdpTx:RDPTransport;
	private var serverEndPoint:EndPoint;
	private var timeoutTimer:Null<Timer>;
	private var keepAliveTimer:Null<Timer>;

	public function new(bitSwarm:BitSwarmClient) {
		super(bitSwarm);
		connectionAttemptCount = 1;
		maxUdpIdleSecs = 10;
		udpKeepAlive = false;
		lastUdpPacketTime = 0;

		udpHandEventListener = function(evt:ApiEvent) {
			onUdpHandshake(evt);
		};
		bitSwarm.addEventListener(SocketEvent.UdpHandshake, udpHandEventListener);
	}

	override public function connect(host:String, port:Int, timeoutMillis:Int = 0):Void {
		if (socketState != SocketState.Disconnected)
			throw new Exception("Can't connect now, current state is: " + Std.string(socketState));

		this.serverHost = host;
		this.serverPort = port;
		socketState = SocketState.Connecting;

		try {
			var dgram:Dynamic = js.Lib.require("dgram");
			socket = dgram.createSocket("udp4");

			socket.on("message", function(msg:Dynamic, rinfo:Dynamic) {
				onData(msg);
			});

			socket.on("error", function(err:Dynamic) {
				log.warn("UDP socket error: " + Std.string(err));
				disconnect(ClientDisconnectionReason.UNKNOWN, Std.string(err));
			});

			sendInitializationRequest();
		} catch (ex:Exception) {
			log.warn("I/O Error while initializing UDP: " + ex.message);
		}
	}

	override public function disconnect(reason:String = "Manual", errMessage:String = null):Void {
		closeSocketAndCleanUp();

		var params = new PlatformStringMap<Dynamic>();
		params.set(EventParam.DisconnectionReason, reason);
		params.set(EventParam.ErrorMessage, errMessage);
		evtDispatcher.dispatchEvent(new SocketEvent(SocketEvent.Disconnected, params));
	}

	override public function destroy(params:Dynamic):Void {
		if (socketState != SocketState.Disconnected)
			throw new Exception("destroy() should be called only when disconnected.");

		if (rdpTx != null) {
			rdpTx.destroy();
			rdpTx = null;
		}
		bitSwarm.removeEventListener(SocketEvent.UdpHandshake, udpHandEventListener);
		evtDispatcher.removeAll();
	}

	override public function kill():Void {
		throw new Exception("kill() is not supported for UDP");
	}

	override public function write(data:Bytes, txType:TransportType = null):Void {
		if (txType == null) {
			sendRaw(data);
		} else {
			if (rdpTx != null)
				rdpTx.sendData(data, TransportTypeTools.toRdpMode(txType), serverEndPoint);
			else
				sendRaw(data);
		}
	}

	public function isUdpInited():Bool {
		return rdpTx != null;
	}

	override public function init(params:Dynamic):Void {}

	// ---------------------------------------------------------------------------

	private function sendRaw(data:Bytes):Void {
		if (socket == null) return;
		var buf = Buffer.from(data.getData());
		socket.send(buf, 0, buf.length, serverPort, serverHost);
	}

	private function sendInitializationRequest():Void {
		try {
			var req = new UdpInitRequest(bitSwarm.getSmartFox().getMySelf());
			req.setTargetController(SystemController.CONTROLLER_ID);
			req.setTransportType(TransportType.UDP);
			bitSwarm.send(req.getRequest());
			startTimer();
		} catch (ex:Exception) {
			log.warn("UDP INIT ERROR: " + ex.message);
		}
	}

	private function onData(msg:Dynamic):Void {
		var buf:Buffer = msg;
		var data = Bytes.ofData(buf.buffer.slice(buf.byteOffset, buf.byteOffset + buf.length));

		if (rdpTx == null) {
			triggerOnDataEvent(data, TransportType.UDP);
		} else {
			lastUdpPacketTime = Timer.stamp();
			rdpTx.dataReceived(data, serverEndPoint);
		}
	}

	private function onUdpHandshake(evt:ApiEvent):Void {
		if (socketState != SocketState.Connecting)
			throw new Exception("UdpHandshake received in wrong state: " + Std.string(socketState));

		stopTimer();
		socketState = SocketState.Connected;

		this.maxUdpIdleSecs = evt.getParam(SysParam.MaxUdpIdleSecs);
		this.udpKeepAlive = evt.getParam(SysParam.UdpKeepAlive);

		var rdpTxCfg:TransportConfig = evt.getParam(SysParam.RdpCfg);
		rdpTxCfg.threadPool = bitSwarm.getThreadPool();
		rdpTx = new RDPTransport(rdpTxCfg);
		rdpTx.setIncomingDataHandler(function(data:Bytes, sender:EndPoint, mode:TxpMode) {
			triggerOnDataEvent(data, TransportTypeTools.fromRdpMode(mode));
		});
		rdpTx.setOutgoingDataHandler(function(data:Bytes, recipient:EndPoint, mode:TxpMode) {
			sendRaw(data);
		});
		rdpTx.setReliableErrorCallback(function() {
			log.warn("Reliable UDP error!");
			disconnect(ClientDisconnectionReason.UDP_TIMEOUT, "Reliable error");
		});
		rdpTx.init();

		serverEndPoint = new EndPoint(socket, serverHost);

		var params = new PlatformStringMap<Dynamic>();
		params.set(EventParam.Success, true);
		var initEvt = new BitSwarmEvent(BitSwarmEvent.UDP_CONNECT, params);
		bitSwarm.getDispatcher().dispatchEvent(initEvt);

		lastUdpPacketTime = Timer.stamp();

		keepAliveTimer = new Timer(Std.int(KEEP_ALIVE_SECONDS * 1000));
		keepAliveTimer.run = function() {
			timeoutCheckRunner();
		};
	}

	private function startTimer():Void {
		timeoutTimer = new Timer(Std.int(RESPONSE_TIMEOUT * 1000));
		timeoutTimer.run = function() {
			timeoutTimer.stop();
			timeoutTimer = null;
			onTimeout();
		};
	}

	private function stopTimer():Void {
		if (timeoutTimer != null) {
			timeoutTimer.stop();
			timeoutTimer = null;
		}
	}

	private function onTimeout():Void {
		if (socketState != SocketState.Connecting)
			return;

		if (connectionAttemptCount < MAX_RETRY) {
			connectionAttemptCount++;
			log.debug("UDP Init Attempt: " + connectionAttemptCount);
			sendInitializationRequest();
		} else {
			socketState = SocketState.Disconnected;
			connectionAttemptCount = 0;

			var params = new PlatformStringMap<Dynamic>();
			params.set(EventParam.Success, false);
			var initEvt = new BitSwarmEvent(BitSwarmEvent.UDP_CONNECT, params);
			bitSwarm.getDispatcher().dispatchEvent(initEvt);
		}
	}

	private function triggerOnDataEvent(data:Bytes, txType:TransportType):Void {
		var evt = new SocketEvent(SocketEvent.DataReceived);
		evt.getParams().set(EventParam.Data, data);
		evt.getParams().set(EventParam.TxType, txType);
		evtDispatcher.dispatchEvent(evt);
	}

	private function timeoutCheckRunner():Void {
		try {
			var elapsed = Timer.stamp() - lastUdpPacketTime;
			if (elapsed > maxUdpIdleSecs) {
				disconnect(ClientDisconnectionReason.UDP_TIMEOUT, null);
				return;
			}
			if (udpKeepAlive && rdpTx != null) {
				rdpTx.sendPing(serverEndPoint);
			}
		} catch (ex:Exception) {
			log.warn(ex.message);
		}
	}

	private function closeSocketAndCleanUp():Void {
		socketState = SocketState.Disconnected;

		stopTimer();
		if (keepAliveTimer != null) {
			keepAliveTimer.stop();
			keepAliveTimer = null;
		}

		try {
			if (socket != null) {
				socket.close();
				socket = null;
				log.info("UDP Socket closed");
			}
		} catch (ex:Exception) {
			log.warn("Error closing UDP socket: " + ex.message);
		}
	}
}
#end
