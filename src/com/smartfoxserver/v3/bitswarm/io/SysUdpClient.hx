package com.smartfoxserver.v3.bitswarm.io;

#if !flash
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
import hx.concurrent.executor.Schedule;
import sys.net.Host;
import sys.net.UdpSocket;
import com.smartfoxserver.v3.bitswarm.rdp.RDPTransport;
import com.smartfoxserver.v3.bitswarm.rdp.data.EndPoint;
import com.smartfoxserver.v3.bitswarm.rdp.TxpMode;
import com.smartfoxserver.v3.bitswarm.TransportType.TransportTypeTools;
import sys.net.UdpSocket;
import sys.net.Address;
import com.smartfoxserver.v3.entities.data.Queue;

class SysUdpClient extends BaseUdpSocketClient {
	// MTU is ~1500 bytes, 2KB buffer is enough
	private static final READ_BUFF_SIZE:Int = 2000;
	private static final MAX_RETRY:Int = 3; // Retry max 3 times
	private static final RESPONSE_TIMEOUT:Int = 3000; // Wait response for max 3 seconds (ms)
	private static final KEEP_ALIVE_SECONDS:Int = 4; // Keep-alive interval

	private var outPacketQ:Queue<Bytes>;

	// private var udpSocket:DatagramSocket; // TODO: RDP-backed socket
	private var udpSocket:UdpSocket;

	private var udpTimeoutTaskId:Null<hx.concurrent.Future.Future<Dynamic>>;
	private var timeoutCheckTaskId:Null<hx.concurrent.Future.Future<Dynamic>>;

	private var serverAddr:Address;
	private var serverHost:String;
	private var serverPort:Int;
	private var connectionAttemptCount:Int;
	private var maxUdpIdleSecs:Int;
	private var udpKeepAlive:Bool;
	private var lastUdpPacketTime:Float;

	private var udpHandEventListener:IEventListener;

	private var rdpTx:RDPTransport;
	private var serverEndPoint:EndPoint;

	public function new(bitSwarm:BitSwarmClient) {
		super(bitSwarm);
		outPacketQ = new Queue<Bytes>();
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
			udpSocket = new UdpSocket();
			udpSocket.setBlocking(true);

			serverAddr = new Address();
			serverAddr.host = new Host(serverHost).ip;
			serverAddr.port = serverPort;

			// Start reader / writer via thread pool executor
			threadPool.submit(function():Void {
				readLoop();
			});
			threadPool.submit(function():Void {
				writeLoop();
			});

			sendInitializationRequest();
		} catch (ex:Exception) {
			log.warn("I/O Error while initializing UDP: " + ex.message);
		}
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
			throw new Exception("destroy() should be called only when disconnected. Current state is: " + Std.string(socketState));

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
	 * Bypasses RDP entirely — raw UDP write
	 */
	public function write(data:Bytes, txType:TransportType = null):Void {
		if (txType == null) {
			// Direct queue push (bypass RDP)
			outPacketQ.enqueue(data);
		} else {
			if (rdpTx != null) {
				rdpTx.sendData(data, TransportTypeTools.toRdpMode(txType), serverEndPoint);
			} else {
				outPacketQ.enqueue(data);
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

			// Start the handshake timeout timer
			startTimer();
		} catch (ex:Exception) {
			log.warn("UDP INIT ERROR: " + ex.message);
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
			outPacketQ.push(data);
		});
		rdpTx.setReliableErrorCallback(function() {
			log.warn("Reliable UDP error!");
			disconnect(ClientDisconnectionReason.UDP_TIMEOUT, "Reliable error");
		});
		rdpTx.init();

		serverEndPoint = new EndPoint(udpSocket, serverHost);

		var initEvt = new BitSwarmEvent(BitSwarmEvent.UDP_CONNECT, [EventParam.Success => true]);
		bitSwarm.getDispatcher().dispatchEvent(initEvt);

		// Update timestamp
		lastUdpPacketTime = haxe.Timer.stamp();

		// Periodic timeout / keep-alive check
		timeoutCheckTaskId = threadPool.submit(function():Void {
			while (socketState == SocketState.Connected) {
				Sys.sleep(KEEP_ALIVE_SECONDS);
				timeoutCheckRunner();
			}
		});
	}

	private function startTimer():Void {
		// Schedule a one-shot timeout task via Executor
		udpTimeoutTaskId = threadPool.submit(function():Void {
			Sys.sleep(RESPONSE_TIMEOUT / 1000.0);
			try {
				onTimeout();
			} catch (ex:Exception) {
				log.warn(ex.message);
			}
		});
	}

	private function stopTimer():Void {
		// The running task will see socketState != Connecting and exit,
		// but we can at least null the reference.
		udpTimeoutTaskId = null;
	}

	private function onTimeout():Void {
		// Only act if still waiting for handshake
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

	/*
	 * Blocking I/O — runs in dedicated thread via thread pool
	 */
	private function readLoop():Void {
		var readBuff = Bytes.alloc(READ_BUFF_SIZE);

		while (true) {
			try {
				var result = udpSocket.readFrom(readBuff, 0, READ_BUFF_SIZE, serverAddr);
				var readBytes = result;

				if (readBytes <= 0)
					break;

				var data = readBuff.sub(0, readBytes);

				if (rdpTx == null) {
					triggerOnDataEvent(data, TransportType.UDP);
				} else {
					lastUdpPacketTime = haxe.Timer.stamp();
					rdpTx.dataReceived(data, serverEndPoint);
				}
			} catch (ex:Exception) {
				log.warn("UDP Read Error: " + ex.message + ", State: " + Std.string(socketState));
				break;
			}
		}

		log.info("Exiting UDP Read Loop");
	}

	/*
	 * Blocking I/O — runs in dedicated thread via thread pool
	 */
	private function writeLoop():Void {
		while (true) {
			try {
				// Blocks up to 100ms; retry on null
				var packet:Null<Bytes> = outPacketQ.pop();

				if (packet == null)
					continue;

				// Empty bytes = shutdown signal
				if (packet.length == 0)
					break;

				udpSocket.sendTo(packet, 0, packet.length, serverAddr);
			} catch (ex:Exception) {
				log.warn("UDP Write Error: " + ex.message + ", State: " + Std.string(socketState));
				break;
			}
		}

		log.info("Exiting UDP Write Loop");
	}

	private function triggerOnDataEvent(data:Bytes, txType:TransportType):Void {
		var evt = new SocketEvent(SocketEvent.DataReceived);
		evt.getParams().set(EventParam.Data, data);
		evt.getParams().set(EventParam.TxType, txType);
		evtDispatcher.dispatchEvent(evt);
	}

	/*
	 * Periodic check: disconnect if server has been idle too long,
	 * and send keep-alive ping if requested.
	 */
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
		} catch (ex:Exception) {
			log.warn(ex.message);
		}
	}

	/*
	 * Close socket and cancel all scheduled tasks.
	 * The read-loop exits on exception from the closed socket.
	 * The write-loop is woken up via an empty packet sentinel.
	 */
	private function closeSocketAndCleanUp():Void {
		socketState = SocketState.Disconnected;

		// Cancel scheduled tasks (they check socketState in their loops)
		udpTimeoutTaskId = null;
		timeoutCheckTaskId = null;

		try {
			if (udpSocket != null) {
				udpSocket.close();
				log.info("UDP Socket closed");
			}

			// Sentinel: empty bytes wakes up blocking writeLoop
			outPacketQ.push(Bytes.alloc(0));
		} catch (ex:Exception) {
			log.warn("Error closing UDP socket: " + ex.message);
		}
	}
}
#end
