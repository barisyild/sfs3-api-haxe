package com.smartfoxserver.v3.bitswarm.io;

#if flash
import com.smartfoxserver.v3.bitswarm.BitSwarmClient;
import com.smartfoxserver.v3.bitswarm.BitSwarmEvent;
import com.smartfoxserver.v3.bitswarm.SocketState;
import com.smartfoxserver.v3.bitswarm.TransportType;
import com.smartfoxserver.v3.core.ApiEvent;
import com.smartfoxserver.v3.core.EventParam;
import com.smartfoxserver.v3.core.IEventListener;
import com.smartfoxserver.v3.requests.UdpInitRequest;
import com.smartfoxserver.v3.controllers.SystemController;
import com.smartfoxserver.v3.util.ClientDisconnectionReason;
import haxe.Exception;
import haxe.io.Bytes;
import haxe.Timer;
import flash.events.DatagramSocketDataEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.DatagramSocket;

import com.smartfoxserver.v3.bitswarm.rdp.RDPTransport;
import com.smartfoxserver.v3.bitswarm.rdp.data.EndPoint;
import com.smartfoxserver.v3.bitswarm.rdp.TxpMode;
import com.smartfoxserver.v3.bitswarm.TransportType.TransportTypeTools;

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

	private var udpHandEventListener:IEventListener;

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

	public function connect(host:String, port:Int, timeoutMillis:Int = 0):Void {
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

	public function disconnect(reason:String = "Manual", errMessage:String = null):Void {
		closeSocketAndCleanUp();

		var params = new Map<String, Dynamic>();
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

	public function kill():Void {
		throw new Exception("kill() is not supported for UDP");
	}

	/*
	 * For Flash, write() sends directly via DatagramSocket (event-driven, no queue needed)
	 */
	public function write(data:Bytes, txType:TransportType = null):Void {
		if (socketState != SocketState.Connected || udpSocket == null)
			return;

		if (txType == null) {
			try {
				udpSocket.send(data.getData(), 0, data.length, serverHost, serverPort);
			} catch (ex:Dynamic) {
				log.warn("Flash UDP Write Error: " + Std.string(ex));
				if (socketState != SocketState.Disconnected)
					disconnect(ClientDisconnectionReason.UNKNOWN, Std.string(ex));
			}
		} else {
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

		var rdpTxCfg = evt.getParam(SysParam.RdpCfg);
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

		var initEvt = new BitSwarmEvent(BitSwarmEvent.UDP_CONNECT, [EventParam.Success => true]);
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

			var initEvt = new BitSwarmEvent(BitSwarmEvent.UDP_CONNECT, [EventParam.Success => false]);
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
