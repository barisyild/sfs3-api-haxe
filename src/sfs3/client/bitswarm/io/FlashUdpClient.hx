package sfs3.client.bitswarm.io;

#if (flash || (openfl && !html5))
import sfs3.client.bitswarm.BitSwarmClient;
import sfs3.client.bitswarm.BitSwarmEvent;
import sfs3.client.bitswarm.SocketState;
import sfs3.client.bitswarm.TransportType;
import sfs3.client.core.ApiEvent;
import sfs3.client.core.EventParam;
import sfs3.client.core.IEventListener;
import sfs3.client.requests.UdpInitRequest;
import sfs3.client.controllers.SystemController;
import sfs3.client.util.ClientDisconnectionReason;
import haxe.Exception;
import haxe.io.Bytes;
import haxe.Timer;
import flash.events.DatagramSocketDataEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.DatagramSocket;
import sfs3.client.bitswarm.rdp.TransportConfig;

import sfs3.client.bitswarm.rdp.RDPTransport;
import sfs3.client.bitswarm.rdp.data.EndPoint;
import sfs3.client.bitswarm.rdp.TxpMode;
import sfs3.client.bitswarm.TransportType.TransportTypeTools;
import sfs3.client.entities.data.PlatformStringMap;

class FlashUdpClient extends BaseUdpSocketClient {
	private static final MAX_RETRY:Int = 3;
	private static final RESPONSE_TIMEOUT:Int = 3000; // ms
	private static final KEEP_ALIVE_SECONDS:Float = 4.0;

	private var udpSocket:DatagramSocket;
	private var serverHost:String;
	private var serverPort:Int;
	private var connectionAttemptCount:Int;
	private var maxUdpIdleSecs:Int;
	private var udpKeepAlive:Bool;
	private var lastUdpPacketTime:Float;

	private var udpTimeoutTimer:Timer;
	private var timeoutCheckTimer:Timer;

	private var udpHandEventListener:IEventListener<ApiEvent>;

	private var rdpTx:RDPTransport;
	private var serverEndPoint:EndPoint;

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
			udpSocket = new DatagramSocket();
			udpSocket.addEventListener(DatagramSocketDataEvent.DATA, onData);
			udpSocket.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			udpSocket.bind(); // bind to any local port
			udpSocket.receive(); // start listening

			sendInitializationRequest();
		} catch (ex:Dynamic) {
			handleError(Std.string(ex));
		}
	}

	private function onData(e:DatagramSocketDataEvent):Void {
		try {
			var ba = e.data;
			var data = Bytes.ofData(ba);
			lastUdpPacketTime = Timer.stamp();

			if (rdpTx == null) {
				triggerOnDataEvent(data, TransportType.UDP);
			} else {
				rdpTx.dataReceived(data, serverEndPoint);
			}
		} catch (ex:Dynamic) {
			log.warn("Flash UDP Read Error: " + Std.string(ex));
		}
	}

	private function onIOError(e:IOErrorEvent):Void {
		handleError(e.text);
	}

	private function handleError(msg:String):Void {
		socketState = SocketState.Disconnected;
		log.warn("UDP connection to " + serverHost + ":" + serverPort + " failed -- Cause: " + msg);

		var evt = new SocketEvent(SocketEvent.Error);
		evt.getParams().set(EventParam.ErrorMessage, msg);
		evtDispatcher.dispatchEvent(evt);
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
			throw new Exception("destroy() should only be called when disconnected. Current state: " + Std.string(socketState));

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

	/*
	 * For Flash, write() sends directly via DatagramSocket (event-driven, no queue needed)
	 */
	override public function write(data:Bytes, txType:TransportType = null):Void {
		if (udpSocket == null)
			return;

		if (txType == null) {
			if (socketState != SocketState.Connected && socketState != SocketState.Connecting)
				return;
			try {
				udpSocket.send(data.getData(), 0, data.length, serverHost, serverPort);
			} catch (ex:Dynamic) {
				log.warn("Flash UDP Write Error: " + Std.string(ex));
				if (socketState != SocketState.Disconnected)
					disconnect(ClientDisconnectionReason.UNKNOWN, Std.string(ex));
			}
		} else {
			if (socketState != SocketState.Connected)
				return;
			if (rdpTx != null) {
				rdpTx.sendData(data, TransportTypeTools.toRdpMode(txType), serverEndPoint);
			} else {
				write(data, null);
			}
		}
	}

	public function isUdpInited():Bool {
		return rdpTx != null;
	}

	// ---------------------------------------------------------------------------

	private function sendInitializationRequest():Void {
		try {
			var req = new UdpInitRequest(bitSwarm.getSmartFox().getMySelf());
			req.setTargetController(SystemController.CONTROLLER_ID);
			req.setTransportType(TransportType.UDP);

			bitSwarm.send(req.getRequest());
			startTimer();
		} catch (ex:Dynamic) {
			log.warn("UDP INIT ERROR: " + Std.string(ex));
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
			write(data, null); // Send natively via Flash socket
		});
		rdpTx.setReliableErrorCallback(function() {
			log.warn("Reliable UDP error!");
			disconnect(ClientDisconnectionReason.UDP_TIMEOUT, "Reliable error");
		});
		rdpTx.init();

		serverEndPoint = new EndPoint(udpSocket, serverHost);

        var params = new PlatformStringMap<Dynamic>();
        params.set(EventParam.Success, true);
		var initEvt = new BitSwarmEvent(BitSwarmEvent.UDP_CONNECT, params);
		bitSwarm.getDispatcher().dispatchEvent(initEvt);

		lastUdpPacketTime = Timer.stamp();

		// Periodic timeout / keep-alive check using haxe.Timer (Flash-friendly)
		timeoutCheckTimer = new Timer(Std.int(KEEP_ALIVE_SECONDS * 1000));
		timeoutCheckTimer.run = function() {
			timeoutCheckRunner();
		};
	}

	private function startTimer():Void {
		udpTimeoutTimer = Timer.delay(function() {
			try {
				onTimeout();
			} catch (ex:Dynamic) {
				log.warn(Std.string(ex));
			}
		}, RESPONSE_TIMEOUT);
	}

	private function stopTimer():Void {
		if (udpTimeoutTimer != null) {
			udpTimeoutTimer.stop();
			udpTimeoutTimer = null;
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
			var elapsed = (haxe.Timer.stamp() - lastUdpPacketTime);

			if (elapsed > maxUdpIdleSecs) {
				disconnect(ClientDisconnectionReason.UDP_TIMEOUT, null);
				return;
			}

			if (udpKeepAlive && rdpTx != null) {
				rdpTx.sendPing(serverEndPoint);
			}
		} catch (ex:Dynamic) {
			log.warn(Std.string(ex));
		}
	}

	private function closeSocketAndCleanUp():Void {
		socketState = SocketState.Disconnected;

		stopTimer();

		if (timeoutCheckTimer != null) {
			timeoutCheckTimer.stop();
			timeoutCheckTimer = null;
		}

		try {
			if (udpSocket != null) {
				udpSocket.removeEventListener(DatagramSocketDataEvent.DATA, onData);
				udpSocket.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
				udpSocket.close();
				log.info("UDP Socket closed");
			}
		} catch (ex:Dynamic) {
			log.warn("Error closing UDP socket: " + Std.string(ex));
		}
	}
}
#end
