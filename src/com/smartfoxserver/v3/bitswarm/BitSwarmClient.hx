package com.smartfoxserver.v3.bitswarm;

import haxe.Exception;
import haxe.io.Bytes;
import hx.concurrent.executor.Executor;
import hx.concurrent.executor.Schedule;
import com.smartfoxserver.v3.ConfigData;
import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.bitswarm.bbox.BlueBoxClient;
import com.smartfoxserver.v3.bitswarm.bbox.BlueBoxEvent;
import com.smartfoxserver.v3.bitswarm.io.BaseSocketClient;
import com.smartfoxserver.v3.bitswarm.io.BaseUdpSocketClient;
import com.smartfoxserver.v3.bitswarm.io.ClientCoreConfig;
import com.smartfoxserver.v3.bitswarm.io.IRequest;
import com.smartfoxserver.v3.bitswarm.io.SocketEvent;
import com.smartfoxserver.v3.bitswarm.io.SysParam;
import com.smartfoxserver.v3.bitswarm.io.TcpClient;
import com.smartfoxserver.v3.bitswarm.io.UdpClient;
import com.smartfoxserver.v3.bitswarm.io.WebSocketClient;
import com.smartfoxserver.v3.controllers.ExtensionController;
import com.smartfoxserver.v3.controllers.SystemController;
import com.smartfoxserver.v3.core.ApiEvent;
import com.smartfoxserver.v3.core.EventDispatcher;
import com.smartfoxserver.v3.core.EventParam;
import com.smartfoxserver.v3.core.IEventListener;
import com.smartfoxserver.v3.requests.BaseRequest;
import com.smartfoxserver.v3.util.ClientDisconnectionReason;
import com.smartfoxserver.v3.util.NetDebugLevel;

class BitSwarmClient implements IBitSwarmClient {
	private var controllersById:Map<Int, IController>;
	private var connSettings:ConnSettings;
	private var smartFox:ISmartFox;

	private var ioHandler:IOHandler;
	private var dispatcher:EventDispatcher;
	private var threadPool:Executor;
	private var scheduler:Executor;

	private var tcpClient:BaseSocketClient;
	private var wsClient:WebSocketClient;
	private var udpClient:BaseUdpSocketClient;
	private var bbClient:BlueBoxClient;

	private var connMode:ConnectionMode;

	private var cryptoInitializer:CryptoInitializer;
	private var cryptoKey:CryptoKey;
	private var cfgData:ConfigData;
	private var reconState:ReconnectionState;

	public function new(smartFox:ISmartFox) {
		dispatcher = new EventDispatcher(this);
		controllersById = new Map<Int, IController>();
		connSettings = new ConnSettings();
		this.smartFox = smartFox;
		connMode = ConnectionMode.SOCKET;
		cryptoKey = null;
	}

	public function init(cfg:ClientCoreConfig):Void {
		this.threadPool = cfg.threadPool;
		this.scheduler = cfg.scheduler;
		this.ioHandler = cfg.ioHandler;

		initControllers();
	}

	public function getThreadPool():Executor {
		return threadPool;
	}

	public function getScheduler():Executor {
		return scheduler;
	}

	public function addEventListener(eventType:String, listener:IEventListener):Void {
		dispatcher.addEventListener(eventType, listener);
	}

	public function removeEventListener(eventType:String, listener:IEventListener):Void {
		dispatcher.removeEventListener(eventType, listener);
	}

	public function connect(cfgData:ConfigData):Void {
		this.cfgData = cfgData;

		if (connMode == ConnectionMode.SOCKET)
			connectTcp(cfgData.host, cfgData.port, cfgData.tcpConnectionTimeout);
		else if (connMode == ConnectionMode.WEBSOCKET)
			connectWs(cfgData.host, cfgData.useSSL ? cfgData.httpsPort : cfgData.httpPort);
		else
			connectBlueBox(cfgData.host, cfgData.httpPort);
	}

	/*
	 * Handles the outcome of a reconnection handshake and closes the reconnection loop
	 * started by invoking attemptReconnection():
	 * 
	 * 	+ reset the reconnectionState
	 * 	+ signal a reconnection event to the top level
	 * 
	 */
	public function completeReconnection(success:Bool):Void {
		// reset state
		reconState = null;
		var evt:ApiEvent = null;

		if (success)
			evt = new BitSwarmEvent(BitSwarmEvent.CONNECTION_RESUME);
		else {
			getActiveSocketClient().destroy(null);
			var params = new Map<String, Dynamic>();
			params.set(EventParam.DisconnectionReason, ClientDisconnectionReason.RECONNECTION_FAILURE);
			evt = new BitSwarmEvent(BitSwarmEvent.DISCONNECT, params);
		}

		dispatcher.dispatchEvent(evt);
	}

	private function connectTcp(host:String, port:Int, timeoutMillis:Int):Void {
		if (tcpClient != null) {
			if (tcpClient.isConnected())
				throw new Exception("An active connection already exists");
			else
				throw new Exception("The connection cannot be reused. Please create a new instance");
		}

		tcpClient = new TcpClient(this);
		tcpClient.addEventListener(SocketEvent.Connected, onTcpConnect);
		tcpClient.addEventListener(SocketEvent.Disconnected, onTcpDisconnect);
		tcpClient.addEventListener(SocketEvent.DataReceived, onTcpData);
		tcpClient.addEventListener(SocketEvent.Error, onTcpError);

		tcpClient.connect(host, port, timeoutMillis);
	}

	private function connectBlueBox(host:String, port:Int):Void {
		if (bbClient != null) {
			if (bbClient.isConnected())
				throw new Exception("An active connection already exists");
			else
				throw new Exception("The connection cannot be reused. Please create a new instance");
		}

		bbClient = new BlueBoxClient(threadPool, scheduler, this);
		bbClient.addEventListener(BlueBoxEvent.Connected, onBBConnect);
		bbClient.addEventListener(BlueBoxEvent.Disconnected, onBBDisconnect);
		bbClient.addEventListener(BlueBoxEvent.DataReceived, onBBData);
		bbClient.addEventListener(BlueBoxEvent.Error, onBBError);

		bbClient.setPollSpeed(getConfigData().blueBox.pollingRateMs);

		bbClient.connect(host, port);
	}

	private function connectWs(host:String, port:Int):Void {
		if (wsClient != null) {
			if (wsClient.isConnected())
				throw new Exception("An active connection already exists");
			else
				throw new Exception("The connection cannot be reused. Please create a new instance");
		}

		wsClient = new WebSocketClient(this);
		wsClient.addEventListener(SocketEvent.Connected, onWsConnect);
		wsClient.addEventListener(SocketEvent.Disconnected, onWsDisconnect);
		wsClient.addEventListener(SocketEvent.DataReceived, onWsData);
		wsClient.addEventListener(SocketEvent.Error, onWsError);

		wsClient.connect(host, port);
	}

	public function connectUdp(udpHost:String, udpPort:Int):Void {
		if (udpClient != null)
			throw new Exception("A UDP client instance already exists");

		udpClient = new UdpClient(this);
		udpClient.addEventListener(SocketEvent.DataReceived, onUdpData);
		udpClient.addEventListener(SocketEvent.Disconnected, onUdpDisconnect);

		udpClient.connect(udpHost, udpPort);
	}

	public function getSmartFox():ISmartFox {
		return smartFox;
	}

	public function getIOHandler():IOHandler {
		return ioHandler;
	}

	public function useEncryption():Bool {
		return cryptoKey != null;
	}

	public function getCryptoKey():CryptoKey {
		return cryptoKey;
	}

	public function setCryptoKey(cryptoKey:CryptoKey):Void {
		this.cryptoKey = cryptoKey;
	}

	/*
	 * Returns the state of the active connection based on the current connection mode.
	 * If bluebox is enabled and a BBClient instance exists we return the state of BBClient.
	 */
	public function isConnected():Bool {
		if (cfgData == null)
			return false;

		if (cfgData.blueBox.isActive && bbClient != null)
			return bbClient.isConnected();

		return hasActiveSocketClient() && getActiveSocketClient().isConnected();
	}

	public function isUdpConnected():Bool {
		if (cfgData == null)
			return false;

		if (udpClient != null)
			return udpClient.isConnected();

		return false;
	}

	public function getNetDebugLevel():NetDebugLevel {
		return smartFox.getNetDebugLevel();
	}

	public function isBBoxDebug():Bool {
		if (cfgData != null)
			return cfgData.blueBox.debug;
		else
			return false;
	}

	public function isReconnecting():Bool {
		return reconState != null && reconState.isPending();
	}

	/*
	 * Tells SmartFox that a TCP connection was established
	 */
	private function onTcpConnect(evt:ApiEvent):Void {
		var reconAttempt = (reconState != null && reconState.isPending());

		var params = new Map<String, Dynamic>();
		params.set(EventParam.Success, true);
		params.set(SysParam.IsReconnection, reconAttempt);

		dispatchEvent(new BitSwarmEvent(BitSwarmEvent.CONNECT, params));
	}

	private function onTcpDisconnect(evt:ApiEvent):Void {
		handleDisconnectionEvent(new BitSwarmEvent(BitSwarmEvent.DISCONNECT, evt.getParams()));
	}

	private function onTcpData(evt:ApiEvent):Void {
		try {
			ioHandler.onDataRead(cast evt.getParams().get(EventParam.Data), TransportType.TCP);
		} catch (ex:Exception) {
			trace("TCP Read Error: " + ex.message);
		}
	}

	private function onTcpError(evt:ApiEvent):Void {
		// If there's an ongoing reconnection attempt, keep trying until it fails
		if (reconState != null && reconState.isPending())
			attemptReconnection();
		else {
			// If we are allowed to use BlueBox try to connect
			if (cfgData.blueBox.isActive) {
				connMode = ConnectionMode.HTTP;
				connect(cfgData);
			}
			// Nothing else to do, just notify the error at the top level
			else
				notifyConnectionError();
		}
	}

	// ---------------------------------------------------------------------------------------

	private function onWsConnect(evt:ApiEvent):Void {
		var reconAttempt = (reconState != null && reconState.isPending());

		var params = new Map<String, Dynamic>();
		params.set(EventParam.Success, true);
		params.set(SysParam.IsReconnection, reconAttempt);

		dispatchEvent(new BitSwarmEvent(BitSwarmEvent.CONNECT, params));
	}

	private function onWsDisconnect(evt:ApiEvent):Void {
		handleDisconnectionEvent(new BitSwarmEvent(BitSwarmEvent.DISCONNECT, evt.getParams()));
	}

	private function onWsData(evt:ApiEvent):Void {
		try {
			ioHandler.onDataRead(cast evt.getParams().get(EventParam.Data), TransportType.TCP);
		} catch (ex:Exception) {
			trace("WebSocket Read Error: " + ex.message);
		}
	}

	private function onWsError(evt:ApiEvent):Void {
		if (reconState != null && reconState.isPending())
			attemptReconnection();
		else
			notifyConnectionError();
	}

	// ---------------------------------------------------------------------------------------

	private function notifyConnectionError():Void {
		var params = new Map<String, Dynamic>();
		params.set(EventParam.Success, false);
		var bse = new BitSwarmEvent(BitSwarmEvent.CONNECT, params);
		dispatcher.dispatchEvent(bse);
	}

	/*
	 * -----
	 * NOTE:
	 * -----
	 * This is where the reconnection loop begins, if reconnection is supported by the current Zone
	 * The next connection failure (during the same loop) will be handled in --> onTcpError() which will re-trigger the loop
	 * until it times out.
	 * 
	 */
	private function handleDisconnectionEvent(evt:ApiEvent):Void {
		/*
		 * If the cause is unknown and reconnection is available
		 * start the reconnection phase
		 */
		var reason:String = cast evt.getParam(EventParam.DisconnectionReason);

		if (reason == ClientDisconnectionReason.UNKNOWN && connSettings.reconnectionSeconds > 0 && hasActiveSocketClient())
			attemptReconnection();
		// If we lost the main TCP connection, UDP has to go down as well
		else {
			if (udpClient != null && udpClient.isConnected())
				udpClient.disconnect();

			dispatcher.dispatchEvent(evt);
		}
	}

	/*
	 * Initialize the SSL/TLS cryptography
	 */
	public function initCrypto():Void {
		cryptoInitializer = new CryptoInitializer(this);
		cryptoInitializer.getDispatcher().addEventListener(CryptoEvent.Init, onCryptoInit);
		cryptoInitializer.init();
	}

	/*
	 * Here we start a reconnection loop.
	 * At every failed attempt this method is called again until a timeout is reached.
	 * The timeout value is determined by the server and send to the client via the initial Handshake request.
	 */
	private function attemptReconnection():Void {
		if (connSettings.reconnectionSeconds <= 0)
			throw new Exception("Reconnection is not enabled in the current Zone");

		// Ditch previous connection
		getActiveSocketClient().destroy(null);
		if (connMode == ConnectionMode.WEBSOCKET)
			wsClient = null;
		else
			tcpClient = null;

		// Handle the start of the reconnection loop
		if (reconState == null) {
			dispatchEvent(new BitSwarmEvent(BitSwarmEvent.CONNECTION_RETRY));
			reconState = new ReconnectionState();
		}

		// Calculate time left before the reconnection loop times out
		var reconnectionMillis:Float = connSettings.reconnectionSeconds * 1000;
		var nowMs:Float = Date.now().getTime();
		var timeLeft:Float = (reconState.firstAttemptTime() + reconnectionMillis) - nowMs;

		if (timeLeft > 0) {
			trace("Reconnection attempt:" + reconState.counter() + " - time left:" + (timeLeft / 1000) + " sec.");

			// Retry connection: pause and retry
			#if (flash || js)
			haxe.Timer.delay(function() {
				connect(cfgData);
				reconState.incCounter();
			}, Std.int(connSettings.reconnectionDelayMillis));
			#else
			try {
				Sys.sleep(connSettings.reconnectionDelayMillis / 1000);
			} catch (e:Dynamic) {};
			connect(cfgData);
			reconState.incCounter();
			#end
		}
		/*
		 *  Reconnection time is expired
		 *  Since we were never able to talk to the server the cause of disconnection is indeed 'Unknown'
		 */
		else {
			reconState = null;

			var params = new Map<String, Dynamic>();
			params.set(EventParam.DisconnectionReason, ClientDisconnectionReason.UNKNOWN);
			params.set(EventParam.ErrorMessage, "All reconnection attempts failed");

			dispatchEvent(new BitSwarmEvent(BitSwarmEvent.DISCONNECT, params));
		}
	}

	// ---------------------------------------------------------------------------------------

	private function onBBConnect(evt:ApiEvent):Void {
		var connEvt = new BitSwarmEvent(BitSwarmEvent.CONNECT, evt.getParams());
		dispatchEvent(connEvt);
	}

	private function onBBDisconnect(evt:ApiEvent):Void {
		handleDisconnectionEvent(new BitSwarmEvent(BitSwarmEvent.DISCONNECT, evt.getParams()));
	}

	private function onBBData(evt:ApiEvent):Void {
		try {
			var buffer:Bytes = cast evt.getParam(EventParam.Data);

			// BlueBox "emulates" TCP
			ioHandler.onDataRead(buffer, TransportType.TCP);
		} catch (ex:Exception) {
			trace("Bluebox Data Error: " + ex.message);
		}
	}

	// We received an HTTP error event upon connection --> notify failure
	private function onBBError(evt:ApiEvent):Void {
		notifyConnectionError();
	}

	// ---------------------------------------------------------------------------------------

	private function onUdpData(evt:ApiEvent):Void {
		try {
			ioHandler.onDataRead(cast evt.getParams().get(EventParam.Data), cast evt.getParams().get(EventParam.TxType));
		} catch (ex:Exception) {
			trace("UDP Read Error: " + ex.message);
		}
	}

	private function onUdpDisconnect(evt:ApiEvent):Void {
		// destroy and remove the UdpClient instance
		udpClient.destroy(null);
		udpClient = null;

		dispatcher.dispatchEvent(new BitSwarmEvent(BitSwarmEvent.UDP_DISCONNECT, evt.getParams()));
	}

	// ---------------------------------------------------------------------------------------
	// Bubble up to the top
	private function onCryptoInit(evt:ApiEvent):Void {
		dispatcher.dispatchEvent(new BitSwarmEvent(BitSwarmEvent.INIT_CRYPTO, evt.getParams()));
	}

	// ---------------------------------------------------------------------------------------

	/*
	 * Send through protocol pipeline
	 */
	public function send(request:IRequest):Void {
		var proceed = true;

		// In this state UDP packets cannot be sent
		var udpFail = request.getTransport().isUDP() && !isUdpConnected();

		// Check for exceptions to the above state
		if (udpFail) {
			if (request.getId() != BaseRequest.UdpInit) {
				if (cfgData.useTcpFallback)
					request.setTransport(TransportType.TCP);
				else
					proceed = false;
			}
		}

		if (proceed)
			this.ioHandler.getCodec().onPacketWrite(request);
		else
			trace("Can't send UDP request without an active UDP connection: " + request);
	}

	public function setCompressionThreshold(value:Int):Void {
		connSettings.compressionThreshold = value;
	}

	public function getMaxMessageSize():Int {
		return connSettings.maxMessageSize;
	}

	public function setMaxMessageSize(value:Int):Void {
		connSettings.maxMessageSize = value;
	}

	/*
	 * We have 6 different routes for a packet to take:
	 * 
	 * 		TCP 			-> via the main connection
	 * 		HTTP			-> if TCP failed
	 * 		UDP				-> standard UDP is used only for the initial handshake
	 * 		UDP_RAW 		-> standard UDP via RDP
	 * 		UDP_RELIABLE	-> reliable/ordered UDP via RDP
	 * 		UDP_UNRELIABLE	-> unreliable/ordered UDP via RDP
	 */
	public function writeToSocket(byteData:Bytes, txType:TransportType):Void {
		if (txType == TransportType.TCP) {
			if (bbClient != null && bbClient.isConnected())
				bbClient.send(byteData);
			else
				getActiveSocketClient().write(byteData);
		}
		// Bypass RDP (used only for initial UDP handshake)
		else if (txType == TransportType.UDP && !udpClient.isUdpInited())
			udpClient.write(byteData);
		// Send via one of the RDP modes
		else
			udpClient.write(byteData, txType);
	}

	public function disconnect(?reason:String = null):Void {
		if (reason == null)
			reason = ClientDisconnectionReason.MANUAL;

		var caughtException:Exception = null;

		try {
			if (!isConnected())
				throw new Exception("Client is already disconnected");

			if (hasActiveSocketClient())
				getActiveSocketClient().disconnect(reason, null);
			else
				bbClient.disconnect(reason, null);
		} catch (ex:Exception) {
			caughtException = ex;
		}

		// finally equivalent
		if (udpClient != null)
			udpClient.disconnect();

		if (caughtException != null)
			throw caughtException;
	}

	public function disconnectUdp():Void {
		udpClient.disconnect();
	}

	public function getDispatcher():EventDispatcher {
		return dispatcher;
	}

	public function getConnectionState():SocketState {
		if (hasActiveSocketClient())
			return getActiveSocketClient().getSocketState();
		return SocketState.Disconnected;
	}

	public function getConnSettings():ConnSettings {
		return connSettings;
	}

	public function getController(ctrlId:Int):IController {
		return controllersById.get(ctrlId);
	}

	public function getConnectionMode():ConnectionMode {
		return connMode;
	}

	public function getConfigData():ConfigData {
		return cfgData;
	}

	public function killConnection():Void {
		if (hasActiveSocketClient())
			getActiveSocketClient().kill();
		else
			throw new Exception("killConnection() does not work in " + connMode + " mode");
	}

	private function getActiveSocketClient():BaseSocketClient {
		return switch (connMode) {
			case ConnectionMode.SOCKET: tcpClient;
			case ConnectionMode.WEBSOCKET: wsClient;
			default: null;
		};
	}

	private function hasActiveSocketClient():Bool {
		return getActiveSocketClient() != null;
	}

	private function dispatchEvent(evt:BitSwarmEvent):Void {
		dispatcher.dispatchEvent(evt);
	}

	private function initControllers():Void {
		var sysController = new SystemController(this);
		var extController = new ExtensionController(this);

		addController(sysController.getId(), sysController);
		addController(extController.getId(), extController);
	}

	private function addController(id:Int, controller:IController):Void {
		if (controller == null)
			throw new Exception("Controller is null");

		if (controllersById.exists(id))
			throw new Exception("A controller with id: " + id + " already exists");

		controllersById.set(id, controller);
	}
}
