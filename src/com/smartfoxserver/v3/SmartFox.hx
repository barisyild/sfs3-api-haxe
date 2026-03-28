package com.smartfoxserver.v3;

import com.smartfoxserver.v3.util.ApiVersion;
import com.smartfoxserver.v3.entities.data.AtomicBool;
import com.smartfoxserver.v3.core.EventDispatcher;
import com.smartfoxserver.v3.bitswarm.io.ClientCoreConfig;
import com.smartfoxserver.v3.bitswarm.BitSwarmEvent;
import com.smartfoxserver.v3.util.LagMonitor;
import com.smartfoxserver.v3.core.IDispatchable;
import com.smartfoxserver.v3.core.Logger;
import com.smartfoxserver.v3.core.LoggerFactory;
import com.smartfoxserver.v3.util.WebServices;
import com.smartfoxserver.v3.util.NetDebugLevel;
import com.smartfoxserver.v3.core.IEventListener;
import com.smartfoxserver.v3.exceptions.UnsupportedOperationException;
import com.smartfoxserver.v3.core.ApiEvent;
import com.smartfoxserver.v3.exceptions.IllegalStateException;
import com.smartfoxserver.v3.exceptions.IllegalArgumentException;
import com.smartfoxserver.v3.exceptions.SFSValidationException;
import haxe.Exception;
import com.smartfoxserver.v3.core.EventParam;
import com.smartfoxserver.v3.core.SFSEvent;
import com.smartfoxserver.v3.util.SFSErrorCodes;
import hx.concurrent.executor.Executor;
import hx.concurrent.executor.Schedule;
import com.smartfoxserver.v3.requests.HandshakeRequest;
import com.smartfoxserver.v3.requests.BaseRequest;
import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.bitswarm.BitSwarmClient;
import com.smartfoxserver.v3.entities.User;
import com.smartfoxserver.v3.entities.Room;
import com.smartfoxserver.v3.bitswarm.io.SFSIOHandler;
import com.smartfoxserver.v3.entities.managers.IRoomManager;
import com.smartfoxserver.v3.entities.managers.IUserManager;
import com.smartfoxserver.v3.entities.managers.IBuddyManager;
import com.smartfoxserver.v3.requests.IClientRequest;
import com.smartfoxserver.v3.requests.JoinRoomRequest;
import com.smartfoxserver.v3.bitswarm.io.SysParam;
import com.smartfoxserver.v3.entities.managers.SFSGlobalUserManager;
import com.smartfoxserver.v3.entities.managers.SFSRoomManager;
import com.smartfoxserver.v3.entities.managers.SFSBuddyManager;
import haxe.CallStack;
import com.smartfoxserver.v3.entities.data.PlatformStringMap;

using StringTools;

/**
 * The main class of the <b>SmartFoxServer 3 API</b>: it is responsible for connecting the client to a SmartFoxServer instance and
 * dispatching all asynchronous events. Developers always interact with the remote server via this object.
 * <p><b>NOTE</b>: in all the examples in this documentation, <code>sfs</code> always refers to a <em>SmartFox</em> instance.</p>
 *
 * <p><b>Example of usage:</b></p>
 * <pre>
 * {@code
 *     import com.smartfoxserver.v3.*;
 *     import com.smartfoxserver.v3.requests.*;
 *     import com.smartfoxserver.v3.ConfigData;
 *
 *     public class SFS3Connector
 *     {
 *         SmartFox sfs;
 *         ConfigData cfg;
 *
 *         public SFS3Connector()
 *         {
 *             // Configure client connection settings
 *             cfg = new ConfigData();
 *             cfg.host = "localhost";
 *             cfg.zone = "Playground";
 *
 *             // Set up event handlers
 *             sfs = new SmartFox();
 *             sfs.addEventListener(SFSEvent.CONNECTION, this.onConnection);
 *             sfs.addEventListener(SFSEvent.CONNECTION_LOST, this.onConnectionLost);
 *             sfs.addEventListener(SFSEvent.LOGIN, this.onLogin);
 *             sfs.addEventListener(SFSEvent.LOGIN_ERROR, this.onLoginError);
 *
 *             System.out.println("API Ver: " + sfs.getVersion());
 *
 *             // Connect to the server
 *             sfs.connect(cfg);
 *         }
 *
 *         // ----------------------------------------------------------------------
 *         // Event Handlers
 *         // ----------------------------------------------------------------------
 *
 *         private void onConnection(ApiEvent evt)
 *         {
 *             var success = (Boolean) evt.getParam(EventParam.Success);
 *
 *             if (success)
 *             {
 *                 System.out.println("Connection success");
 *
 *                 // Login as guest: the user name will be auto-assigned by the server
 *                 sfs.send(new LoginRequest(""));
 *             }
 *             else
 *                 System.out.println("Connection Failed. Is the server running?");
 *         }
 *
 *         private void onConnectionLost(ApiEvent evt)
 *         {
 *             System.out.println("Connection was lost");
 *         }
 *
 *         private void onLogin(ApiEvent evt)
 *         {
 *         	   var me = (User) evt.getParam(EventParam.User);
 *             System.out.println("Logged in as: " + me.getName());
 *         }
 *
 *         private void onLoginError(ApiEvent evt)
 *         {
 * 			  var message = (String) evt.getParam(EventParam.ErrorMessage);
 * 			  System.out.println("Login failed. Error: " + message);
 *         }
 *     }
 * }
 * </pre>
 *
 * @author The gotoAndPlay() Team<br>
 *         http://www.smartfoxserver.com<br>
 *
 * @see		<a href="https://www.smartfoxserver.com">www.smartfoxserver.com</a>
 */
@:expose("SFS3.SmartFox")
class SmartFox implements ISmartFox implements IDispatchable {
	private final MIN_PORT_VALUE:Int = 0;
	private final MAX_PORT_VALUE:Int = 65535;
	private final PORT_VALID_RANGE:String;

	private final version:ApiVersion = new ApiVersion(3, 0, 16, "beta");
	private final CLIENT_TYPE_SEPARATOR:String = ':';
	private var log:Logger;
	private var dispatcher:EventDispatcher;

	private var eventThreadPool:Executor;
	private var scheduler:Executor;

	private var _isJoining:AtomicBool;

	private var sessionToken:String;
	private var cfgData:ConfigData;
	private var mySelf:User;
	private var lastJoinedRoom:Room;
	private var roomManager:IRoomManager;
	private var userManager:IUserManager;
	private var buddyManager:IBuddyManager;

	private var lagMonitor:LagMonitor;

	// Stores the custom client details about the runtime platform
	private var clientDetails:String =
	#if js "JavaScript";
	#elseif cpp "C++";
	#elseif python "Python";
	#elseif flash "Flash";
	#else "Unknown";
	#end
	private var bitSwarm:BitSwarmClient;

	// keep track of the connection status flags
	private var handshakeComplete:Bool = false;
	private var encryptionComplete:Bool = false;

	// Cluster only
	private var nodeId:String = null;

	public function new() {
		#if flash
		if(flash.Lib.current == null)
			throw new Exception("Please call haxe.initSwc(); before instantiating the SmartFox class in Flash.");

		haxe.Log.trace = function(v:Dynamic, ?infos:haxe.PosInfos):Void {
			flash.Lib.trace(v);
		};
		#end

		Logger.setLevel(LogLevel.DEBUG);
		Logger.setShowPosition(true);

		this.log = LoggerFactory.getLogger(Type.getClass(this));
		PORT_VALID_RANGE = 'Valid range is $MIN_PORT_VALUE..$MAX_PORT_VALUE';

		eventThreadPool = Executor.create(3); // General tasks
		scheduler = Executor.create(2); // Scheduled tasks

		init();
	}

	private final function init():Void {
		_isJoining = new AtomicBool(false);

		dispatcher = new EventDispatcher(this);
		bitSwarm = new BitSwarmClient(this);

		// Configure BitSwarmClient
		var cfg = new ClientCoreConfig();
		cfg.threadPool = eventThreadPool;
		cfg.scheduler = scheduler;
		cfg.ioHandler = new SFSIOHandler(bitSwarm);

		bitSwarm.init(cfg);

		bitSwarm.addEventListener(BitSwarmEvent.CONNECT, this.onTcpConnect);
		bitSwarm.addEventListener(BitSwarmEvent.DISCONNECT, this.onTcpDisconnect);
		bitSwarm.addEventListener(BitSwarmEvent.CONNECTION_RETRY, this.onTcpConnectionRetry);
		bitSwarm.addEventListener(BitSwarmEvent.CONNECTION_RESUME, this.onTcpConnectionResume);
		bitSwarm.addEventListener(BitSwarmEvent.UDP_CONNECT, this.onUdpInit);
		bitSwarm.addEventListener(BitSwarmEvent.UDP_DISCONNECT, this.onUdpDisconnect);
		bitSwarm.addEventListener(BitSwarmEvent.INIT_CRYPTO, this.onInitCrypto);

		userManager = new SFSGlobalUserManager(this);
		roomManager = new SFSRoomManager(this);
		buddyManager = new SFSBuddyManager(this);

		// Remove previous lag monitor, if any.
		if (lagMonitor != null)
			lagMonitor.stop();

		lastJoinedRoom = null;
		sessionToken = null;
		mySelf = null;
	}

	/** @internal */
	public function getBitSwarm():BitSwarmClient {
		return bitSwarm;
	}

	/**
	 * Returns the <em>User</em> object representing the client when connected to a SmartFoxServer instance.
	 * This object is generated upon successful login, so it is <code>null</code> before the login or if the login request failed.
	 * <p/>
	 *
	 * @see		com.smartfoxserver.v3.entities.User#isItMe()
	 * @see		com.smartfoxserver.v3.requests.LoginRequest
	 */
	public function getMySelf():User {
		return mySelf;
	}

	/** @internal */
	public function setMySelf(mySelf:User):Void {
		this.mySelf = mySelf;
	}

	/** @internal */
	public function isJoining():Bool {
		return this._isJoining.load();
	}

	/** @internal */
	public function setJoining(value:Bool) {
		this._isJoining.store(value);
	}

	/**
	 * Returns the current version of the SmartFoxServer 3 Client API.
	 * <p/>
	 * <p/><b>Example</b><br/> The following example traces the SmartFoxServer API version to the console:
	 * <pre>
	 * trace("Current API version:" + sfs.getVersion());
	 * </pre>
	 */
	public function getVersion():String {
		return version.toString();
	}

	/**
	 * Get the client configuration details.
	 *
	 * @see ConfigData
	 * @return the client configuration details.
	 */
	public function getConfig():ConfigData {
		return cfgData;
	}

	/**
	 * Returns the current session token.
	 * The Session token is a unique string sent by the server to the client after the initial handshake.
	 *
	 * @return the current session token
	 */
	public function getSessionToken():String {
		return sessionToken;
	}

	/**
	 * Returns the object representing the last Room joined by the client, if any.
	 * This property is <code>null</code> if no Room has been joined, yet.
	 * <p/>
	 *
	 * You can use the <em>JoinRoomRequest</em> request to join a Room.</p>
	 *
	 * @see		#getJoinedRooms()
	 * @see		com.smartfoxserver.v3.requests.JoinRoomRequest
	 * @return  the last joined Room
	 */
	public function getLastJoinedRoom():Room {
		return lastJoinedRoom;
	}

	/** @internal */
	public function setLastJoinedRoom(lastJoinedRoom:Room):Void {
		this.lastJoinedRoom = lastJoinedRoom;
	}

	/**
	 * Returns a list of <em>Room</em> objects representing the Rooms currently joined by the client.
	 * <p/>
	 * <p><b>NOTE</b>: the same list is returned by the <em>IRoomManager.getJoinedRooms()</em> method, accessible through the <em>roomManager</em> getter
	 *
	 * @see		#getLastJoinedRoom()
	 * @see		#getRoomManager()
	 * @see		com.smartfoxserver.v3.entities.Room
	 * @see		com.smartfoxserver.v3.requests.JoinRoomRequest
	 *
	 * @return the list of joined Rooms
	 */
	public function getJoinedRooms():Array<Room> {
		return roomManager.getJoinedRooms();
	}

	/**
	 * Returns a reference to the User Manager.
	 * This manager is used internally by the SmartFoxServer API; the reference returned by this method
	 * gives access to the user list.
	 *
	 * @return the User Manager
	 */
	public function getUserManager():IUserManager {
		return userManager;
	}

	/**
	 * Returns a reference to the Room Manager.
	 * This manager is used internally by the SmartFoxServer API; the reference returned by this method
	 * gives access to the Rooms list and Groups.
	 *
	 * @return the Room Manager
	 */
	public function getRoomManager():IRoomManager {
		return roomManager;
	}

	/**
	 * Returns a reference to the Buddy Manager.
	 *
	 * This manager is used internally by the SmartFoxServer API; the reference returned by this method
	 * gives access to the buddy list and relative buddy variables.
	 *
	 * @see Buddy
	 * @see BuddyVariable
	 *
	 * @return the Buddy Manager
	 */
	public function getBuddyManager():IBuddyManager {
		return buddyManager;
	}

	/**
	 * Returns the current connection mode after a connection has been successfully established. Possible values are defined as constants in the <em>ConnectionMode</em> class.
	 * <p/>
	 * <p/><b>Example</b><br/> The following example traces the current connection mode:
	 * <pre>
	 * System.out.println("Connection mode: " + sfs.getConnectionMode());
	 * </pre>
	 *
	 * @see 	com.smartfoxserver.v3.bitswarm.ConnectionMode
	 */
	public function getConnectionMode():String {
		return bitSwarm.getConnectionMode().name();
	}

	/**
	 * Returns the HTTP/HTTPS URI that can be used to upload files to SmartFoxServer, using an HTTP POST request.
	 * For more info on client side uploads see the relative tutorial in the online documentation under <b>Advanced Topics</b> &gt; <b>File Uploads</b>
	 *
	 * @return the HTTP/HTTPS URI to upload files via a POST request.
	 */
	public function getHttpUploadURI():String {
		if (!isConnected() || mySelf == null)
			return null;

		var protocol = encryptionComplete ? "https://" : "http://";
		var port = encryptionComplete ? cfgData.httpsPort : cfgData.httpPort;
		var path = '/${WebServices.BASE_SERVLET}/${WebServices.UPLOAD_MANAGER}?sessHashId=${sessionToken}';

		return '${protocol}${cfgData.host}:${port}${path}';
	}

	/** @internal */
	public function setReconnectionSeconds(seconds:Int):Void {
		bitSwarm.getConnSettings().reconnectionSeconds = seconds;
	}

	/**
	 *  <p>
	 *  Allows to specify custom client details that will be used to gather statistics about the client platform
	 *  via the SmartFox Analytics Module. By default the generic "Java/Android" label is used as platform, without specifying the version.
	 *  <p>
	 *  This method must be called before the connection is started. <br/>
	 *  The length of the two strings combined must be &lt; 512 characters.
	 *
	 *  @param platformId	the id of the platform (e.g. Java, Android etc...)
	 *  @param version		the version of the platform
	 */
	public function setClientDetails(platformId:String, version:String):Void {
		if (isConnected()) {
			log.warn("setClientDetails() must be called before the connection is started");
			return;
		}

		clientDetails = platformId != null ? platformId.replace(CLIENT_TYPE_SEPARATOR, ' ') : "";
		clientDetails += CLIENT_TYPE_SEPARATOR;
		clientDetails += version != null ? version.replace(CLIENT_TYPE_SEPARATOR, ' ') : "";
	}

	public function getNetDebugLevel():NetDebugLevel {
		if (cfgData != null)
			return cfgData.netDebugLevel;
		else
			return NetDebugLevel.OFF;
	}

	/**
	 * Adds an event listener to handle a specific event
	 * <p><b>Example:</b>
	 * <pre>
	 * {@code
	 * var sfs = new SmartFox();
	 * sfs.addEventListener(SFSEvent.CONNECTION, this.onConnection);
	 *
	 * // ...
	 *
	 * var cfgData = new ConfigData();
	 * sfs.connect(cfgData);
	 *
	 * private void onConnection(ApiEvent evt)
	 * {
	 * 	var success = (Boolean) evt.getParam(EventParam.Success);
	 * 	if (success)
	 * 	{
	 * 		log.info("Connection success: " + sfs.getConfig().host + ", mode: " + sfs.getConnectionMode());
	 * 		sfs.send(new LoginRequest("");
	 * 	}
	 * 	else
	 * 	{
	 * 		var errMsg 	= evt.getParam(EventParam.ErrorMessage);
	 * 		log.warn("Connection Failed: " + errMsg);
	 * 	}
	 * }
	 * }</pre>
	 *
	 * @param eventType	the event name
	 * @param listener	the listener responding to the event
	 *
	 * @see SFSEvent
	 * @see EventParam
	 */
	public function addEventListener<T:ApiEvent>(eventType:String, listener:IEventListener<T>):Void {
		dispatcher.addEventListener(eventType, listener);
	}

	/**
	 * Used to remove a single event listeners that was previously added
	 *
	 * @param eventType	the event name
	 * @param listener	the previous listener that was added
	 *
	 * @see SFSEvent
	 */
	public function removeEventListener<T:ApiEvent>(eventType:String, listener:IEventListener<T>):Void {
		dispatcher.removeEventListener(eventType, listener);
	}

	/**
	 * Used to clear all listeners previously added.
	 * Useful after a disconnection to remove all listeners at once.
	 */
	public function removeAllEventListeners():Void {
		dispatcher.removeAll();
	}

	/** @internal */
	public function getDispatcher():EventDispatcher {
		throw new UnsupportedOperationException();
	}

	/** @internal */
	public function getExecutor():Executor {
		return eventThreadPool;
	}

	/** @internal */
	public function setExecutor(service:Executor):Void {
		if (isConnected())
			throw new IllegalStateException("Can't modify threadpool with an active connection.");

		this.eventThreadPool = service;
	}

	/**
	 * This can be used to schedule simple delayed Tasks.
	 * 
	 * @return the main scheduler used to schedule tasks
	 */
	public function getScheduler():Executor {
		return scheduler;
	}

	/** @internal */
	public function dispatchEvent(evt:ApiEvent):Void {
		dispatcher.dispatchEvent(evt);
	}

	/**
	 * @return true if we have an active TCP connection to the server, false otherwise
	 */
	public function isConnected():Bool {
		if (bitSwarm.isConnected() && handshakeComplete)
			return cfgData.useSSL ? encryptionComplete : true;

		return false;
	}

	/**
	 * @return true if we have an active UDP connection to the server, false otherwise
	 */
	public function isUdpConnected():Bool {
		return bitSwarm.isUdpConnected();
	}

	/**
	 * Attempts to connect to the server. Triggers an {@link SFSEvent#CONNECTION} event
	 *
	 * @param cfgData, the connection configuration
	 * @see ConfigData
	 */
	public function connect(cfgData:ConfigData):Void {
		validateConfigData(cfgData);
		bitSwarm.connect(this.cfgData);
	}

	/**
	 * Manually disconnect from the server. Triggers an {@link SFSEvent#CONNECTION_LOST} event
	 */
	public function disconnect():Void {
		bitSwarm.disconnect();
	}

	/**
	 * Used to simulate an unexpected connection, to test the reconnection system.
	 * For more information see the online SmartFoxServer3 documentation under Development Basics &gt; Reconnection system
	 */
	public function killConnection():Void {
		if (!isConnected())
			throw new IllegalStateException("The client is not connected");

		bitSwarm.killConnection();
	}

	/** @internal */
	public function getNodeId():String {
		return this.isConnected() ? nodeId : null;
	}

	/** @internal */
	public function setNodeId(value:String):Void {
		this.nodeId = value;
	}

	private function validateConfigData(cfgData:ConfigData) {
		if (cfgData.host == null || cfgData.host.length == 0)
			throw new IllegalArgumentException("Invalid Host/IpAddress");

		if (cfgData.zone == null || cfgData.zone.length == 0)
			throw new IllegalArgumentException("Invalid Zone name");

		if (cfgData.port < MIN_PORT_VALUE || cfgData.port > MAX_PORT_VALUE)
			throw new IllegalArgumentException("Invalid TCP port. " + PORT_VALID_RANGE);

		if (cfgData.udpPort < MIN_PORT_VALUE || cfgData.udpPort > MAX_PORT_VALUE)
			throw new IllegalArgumentException("Invalid UDP port. " + PORT_VALID_RANGE);

		if (cfgData.httpPort < MIN_PORT_VALUE || cfgData.httpPort > MAX_PORT_VALUE)
			throw new IllegalArgumentException("Invalid HTTP port. " + PORT_VALID_RANGE);

		if (cfgData.httpsPort < MIN_PORT_VALUE || cfgData.httpsPort > MAX_PORT_VALUE)
			throw new IllegalArgumentException("Invalid HTTPS port. " + PORT_VALID_RANGE);

		// Not Supported
		/*if (cfgData.useSSL && cfgData.allowUnsafeSSL) {
			try {
				var addr = InetAddress.getByName(cfgData.host);

				if (!addr.isLoopbackAddress() && !addr.isSiteLocalAddress())
					throw new IllegalArgumentException("Unsafe SSL can only be used for local testing.");
			} catch (ex:UnknownHostException) {
				throw new IllegalArgumentException("Unexpected issue verifying the current host: " + ex);
			}
		}*/

		cfgData.netDebugLevel = NetDebugLevel.PROTOCOL;

		// Store globally
		this.cfgData = cfgData;
	}

	/**
	 * Initializes the UDP protocol by performing an handshake with the server. Triggers a {@link SFSEvent#UDP_CONNECTION} event.
	 * <p/>
	 * <p>This method can be called at any time, provided that a TCP connection to the server has already been established.
	 * After a successful initialization, UDP requests can be sent to a server-side Extension at any time.</p>
	 * <p/>
	 * For more information and examples see the SFS3 Documentation under Advanced Topics &gt; Using the UDP Protocol
	 */
	public function connectUdp():Void {
		if (isConnected() && mySelf != null) {
			var udpHost:String;
			var udpPort:Int;

			/*
			 * This is Java-only
			 * Allows to specify a local UDP proxy for testing (i.e. UProxy)
			 * This means that no matter the CfgData.Host property we connect UDP to the local UProxy
			 */
			udpHost = cfgData.host;
			udpPort = cfgData.udpPort;

			bitSwarm.connectUdp(udpHost, udpPort);
		} else
			throw new IllegalStateException("Cannot initialize UDP protocol until the client is connected and logged in");
	}

	/**
	 * Closes the current UDP Connection. Triggers a {@link SFSEvent#UDP_CONNECTION_LOST} event.
	 */
	public function disconnectUdp():Void {
		bitSwarm.disconnectUdp();
	}

	/**
	 * Sends a request to the server. All the available request objects can be found
	 * in the <em>requests</em> package.
	 *
	 * @param request A request object.
	 */
	public function send(request:IClientRequest):Void {
		if (!isConnected()) {
			log.warn("Client is not connected. Request cannot be sent: " + request);
			return;
		}

		try {
			// Activate joining flag
			if (request is JoinRoomRequest) {
				if (_isJoining.load()) {
					log.warn("Cannot send a 'JoinRoomRequest' while another JoinRoom transaction is ongoing");
					return;
				} else
					_isJoining.store(true);
			}

			// Validate Request parameters
			request.validate(this);

			// Execute Request logic
			request.execute(this);

			bitSwarm.send(request.getRequest());
		} catch (problem:SFSValidationException) {
			var errMsg:String = problem.message;

			for (errorItem in problem.getErrors())
				errMsg += "\t" + errorItem + "\n";

			log.warn(errMsg);
		} catch (ex:Exception) {
			log.warn(ex.message, ex);
		}
	}

	/**
	 * Enables the automatic monitoring of latency between client and the server in a round-robin fashion.
	 * When turned on, the {@link SFSEvent#PING_PONG}</em> event type is dispatched continuously, providing the average of the last 10 measured lag values,
	 * plus the highest and lowest values recorded.
	 *
	 * <p><b>NOTE</b>: the lag monitoring can be enabled after having logged in successfully.</p>
	 *
	 * @param enabled   The lag monitoring status: <code>true</code> to start the monitoring, <code>false</code> to stop it.
	 * @param interval  An optional amount of seconds to pause between each query (recommended 3-4s)
	 * @param queueSize  The amount of values stored temporarily and used to calculate the average lag
	 *
	 * @see		com.smartfoxserver.v3.core.SFSEvent#PING_PONG
	 */
	public function enableLagMonitor(enabled:Bool, interval:Int = 4, queueSize:Int = 10):Void {
		if (mySelf == null) {
			log.warn("Lag Monitoring requires that you are logged in a Zone first");
			return;
		}

		if (enabled) {
			lagMonitor = new LagMonitor(this, interval, queueSize);
			lagMonitor.start();
		} else {
			if (lagMonitor != null)
				lagMonitor.stop();
		}
	}

	/** @internal */
	public function getLagMonitor():LagMonitor {
		return lagMonitor;
	}

	/** @internal */
	public function handleLogout():Void {
		resetState();
	}

	// ::: ::: ::: ::: ::: ::: ::: ::: ::: ::: ::: ::: ::: ::: ::: ::: ::: ::: ::: ::: ::: ::: ::: :::

	/*
	 * Basic clean up
	 * Invoked on logout, disconnect, connection errors
	 */
	private function resetState():Void {
		if (lagMonitor != null && lagMonitor.isRunning)
			lagMonitor.stop();

		userManager = new SFSGlobalUserManager(this);
		roomManager = new SFSRoomManager(this);
		buddyManager = new SFSBuddyManager(this);

		_isJoining.store(false);
		lastJoinedRoom = null;
		sessionToken = null;
		mySelf = null;
	}

	/*
	 * Advanced clean up
	 * Can be invoked on disconnection and connection errors
	 *
	 * @see shutdownApi()
	 */
	public function stopExecutors():Void {
		scheduler.stop();
		eventThreadPool.stop();

		dispatcher.removeAll();
	}

	private function shutdownApi():Void {
		#if sys
		sys.thread.Thread.create(() -> {
			stopExecutors();
			Sys.sleep(0.5);

			handshakeComplete = false;
			encryptionComplete = false;

			resetState();
		});
		#else
		stopExecutors();

		handshakeComplete = false;
		encryptionComplete = false;

		resetState();
		#end
	}

	/** @internal */
	public function handleHandShake(obj:ISFSObject):Void {
		// Detect reconnection handshake
		if (obj.containsKey(HandshakeRequest.KEY_RECONNECTION_TOKEN)) {
			var reconToken = obj.getBool(HandshakeRequest.KEY_RECONNECTION_TOKEN);

			bitSwarm.completeReconnection(reconToken);
			return;
		}

		// Success
		if (!obj.containsKey(BaseRequest.KEY_ERROR_CODE)) {
			handshakeComplete = true;

			sessionToken = obj.getString(HandshakeRequest.KEY_SESSION_TOKEN);
			bitSwarm.setCompressionThreshold(obj.getInt(HandshakeRequest.KEY_COMPRESSION_THRESHOLD));
			bitSwarm.setMaxMessageSize(obj.getInt(HandshakeRequest.KEY_MAX_MESSAGE_SIZE));

			if (log.isDebugEnabled())
				log.debug('Handshake response: tk => ${sessionToken}, ct => ${bitSwarm.getConnSettings().compressionThreshold}');

			if (cfgData.useSSL)
				bitSwarm.initCrypto();
			else {
				// Fire Conn success event
				var data = new PlatformStringMap<Dynamic>();
				data.set(EventParam.Success, true);
				dispatchEvent(new SFSEvent(SFSEvent.CONNECTION, data));
			}
		}
		// Failed
		else {
			var errorCode:Int = obj.getShort(BaseRequest.KEY_ERROR_CODE);
			var errorMsg:String = SFSErrorCodes.getErrorMessage(errorCode, obj.getStringArray(BaseRequest.KEY_ERROR_PARAMS));

			var params = new PlatformStringMap<Dynamic>();
			params.set(EventParam.Success, false);
			params.set(EventParam.ErrorMessage, errorMsg);
			params.set(EventParam.ErrorCode, errorCode);

			dispatchEvent(new SFSEvent(SFSEvent.CONNECTION, params));
		}
	}

	private function onTcpConnect(evt:ApiEvent):Void {
		var success:Bool = cast evt.getParam(EventParam.Success);

		// Send handshake request
		if (success) {
			var isReconnection:Bool = cast evt.getParam(SysParam.IsReconnection);
			var req:HandshakeRequest = new HandshakeRequest(version.canonical(), isReconnection ? sessionToken : null, clientDetails);

			try {
				var request = req.getRequest();
				bitSwarm.send(request);
			} catch (ex:Exception) {
				log.error("Failed to send Handshake request", ex);
			}
		}
		// Stop here and dispatch relative event
		else {
			var connEvent = new SFSEvent(SFSEvent.CONNECTION, evt.getParams());
			dispatcher.dispatchEvent(connEvent);

			shutdownApi();
		}
	}

	private function onTcpDisconnect(evt:ApiEvent):Void {
		dispatcher.dispatchEvent(new SFSEvent(SFSEvent.CONNECTION_LOST, evt.getParams()));
		shutdownApi();
	}

	private function onTcpConnectionRetry(evt:ApiEvent):Void {
		dispatcher.dispatchEvent(new SFSEvent(SFSEvent.CONNECTION_RETRY, evt.getParams()));
	}

	private function onTcpConnectionResume(evt:ApiEvent):Void {
		dispatcher.dispatchEvent(new SFSEvent(SFSEvent.CONNECTION_RESUME, evt.getParams()));
	}

	private function onUdpInit(evt:ApiEvent):Void {
		var initEvt = new SFSEvent(SFSEvent.UDP_CONNECTION, evt.getParams());
		dispatcher.dispatchEvent(initEvt);
	}

	private function onUdpDisconnect(evt:ApiEvent):Void {
		var initEvt = new SFSEvent(SFSEvent.UDP_CONNECTION_LOST, evt.getParams());
		dispatcher.dispatchEvent(initEvt);
	}

	private function onInitCrypto(evt:ApiEvent):Void {
		var success:Bool = evt.getParam(EventParam.Success);

		/*
		 * A new token is re-assigned when CryptoInit is --> success,
		 * since the original token exchanged at connection time
		 * is transmitted in clear
		 */
		if (success) {
			encryptionComplete = true;
			sessionToken = cast evt.getParam(SysParam.SessionToken);
		} else
			shutdownApi();

		dispatcher.dispatchEvent(new SFSEvent(SFSEvent.CONNECTION, evt.getParams()));
	}

	public function dispose():Void {
		shutdownApi();
	}
}
