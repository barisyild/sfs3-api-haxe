package com.smartfoxserver.v3.core;


/**
 * <em>SFSEvent</em> is the class representing most of the events dispatched by
 * the SmartFoxServer 3 Java client API.
 *
 * <p>
 * The <em>SFSEvent</em> parent class (<em>ApiEvent</em>) provides a public property called
 * <em>params</em> which contains different parameters depending on the event type.
 * </p>
 *
 * <b>Example of usage:</b>
 * <pre>
 * {@code
 *     import sfs3.client.*;
 *     import sfs3.client.requests.*;
 *     import sfs3.client.util.ConfigData;
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
 *             sfs.addEventListener(SFSEvent.CONNECTION, this::onConnection);
 *             sfs.addEventListener(SFSEvent.CONNECTION_LOST, this::onConnectionLost);
 *             sfs.addEventListener(SFSEvent.LOGIN, this::onLogin);
 *             sfs.addEventListener(SFSEvent.LOGIN_ERROR, this::onLoginError);
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
 *                 // Login as guest
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
 *             System.out.println("Logged in as: " + sfs.getMySelf().getName());
 *         }
 *
 *         private void onLoginError(ApiEvent evt)
 *         {
 * 			var message = (String) evt.getParam(EventParam.ErrorMessage);
 * 			System.out.println("Login failed. Error: " + message);
 *         }
 *     }
 * }
 * </pre>
 */
class SFSEvent extends ApiEvent
{
    /**
	 * @internal
	 */
    public static final HANDSHAKE:String = "handshake";

    /**
	 * <p>
	 * Dispatched when the result of the UDP handshake is notified. This event is
	 * fired in response to a call to the <em>connectUdp()</em> method.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" cellspacing="5">
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>success</td>
	 * <td><em>Boolean</em></td>
	 * <td>The connection result: <code>true</code> if a connection was established,
	 * <code>false</code> otherwise.</td>
	 * </tr>
	 * </table>
	 *
	 */
    public static final UDP_CONNECTION:String = "udpConnection";

    /**
	 * <p>
	 * Dispatched when an active UDP connection is lost.
	 * </p>
	 *  <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>errMessage</td>
	 * <td><em>String</em></td>
	 * <td>Provides extra info on what went wrong. Can be null if no specific error occurred.</td>
	 * </tr>
	 * </table>
	 */
    public static final UDP_CONNECTION_LOST:String = "udpConnectionLost";

    /**
	 * <p>
	 * Dispatched when a connection between the client and a SmartFoxServer 3
	 * instance is attempted. This event is fired in response to a call to the
	 * <em>connect()</em> method.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>success</td>
	 * <td><em>Boolean</em></td>
	 * <td>The connection result: <code>true</code> if a connection was established,
	 * <code>false</code> otherwise.</td>
	 * </tr>
	 * </table>
	 *
	 * @see #CONNECTION_RETRY
	 * @see #CONNECTION_RESUME
	 * @see #CONNECTION_LOST
	 */
    public static final CONNECTION:String = "connection";

    /**
	 * <p>
	 * Dispatched when a new lag value measurement is available. This event is fired
	 * when the automatic lag monitoring is turned on by passing <code>true</code>
	 * to the <em>enableLagMonitor()</em> method.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>lagValue</td>
	 * <td><em>LagValue</em></td>
	 * <td>Object providing the average of the last ten measured lag values (milliseconds)
	 * as well as the min. and max. values ever recorded</td>
	 * </tr>
	 * </table>
	 *
	 * @see LagValue
	 * @see sfs3.client.SmartFox#enableLagMonitor(boolean)
	 */
    public static final PING_PONG:String = "pingPong";

    /**
	 * <p>
	 * Dispatched when the connection between the client and the SmartFoxServer 3
	 * instance is interrupted. This event is also fired in response to a call to the
	 * <em>disconnect()</em> method.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" cellspacing="5">
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>reason</td>
	 * <td><em>String</em></td>
	 * <td>The reason of the disconnection, among those available in the
	 * <em>ClientDisconnectionReason</em> class.</td>
	 * </tr>
	 * </table>
	 *
	 * @see sfs3.client.SmartFox#disconnect()
	 * @see sfs3.client.util.ClientDisconnectionReason
	 * @see #CONNECTION
	 * @see #CONNECTION_RETRY
	 */
    public static final CONNECTION_LOST:String = "connectionLost";

    /**
	 * <p>
	 * Dispatched when the connection between the client and the SmartFoxServer 3
	 * instance is interrupted abruptly while the SmartFoxServer 3 HRC system is
	 * available in the Zone.
	 * </p>
	 * <p>
	 * The HRC system allows a broken connection to be re-established transparently
	 * within a certain amount of time, without loosing any of the current
	 * application state. For example this allows any player to get back into a game
	 * without loosing the match because of an unstable connection.
	 * </p>
	 * <p>
	 * When this event is dispatched the API enters a "frozen" mode where no new
	 * requests can be sent until the reconnection is successfully performed. It is
	 * highly recommended to handle this event and freeze the application interface
	 * accordingly until the <em>connectionResume</em> event is fired, or the
	 * reconnection fails and the user is definitely disconnected and the
	 * <em>connectionLost</em> event is fired.
	 * </p>
	 *
	 * <p>
	 * No parameters are available for this event object.
	 * </p>
	 *
	 * @see #CONNECTION_RESUME
	 * @see #CONNECTION_LOST
	 */
    public static final CONNECTION_RETRY:String = "connectionRetry";

    /**
s	 * <p>
	 * Dispatched when the connection between the client and the SmartFoxServer 3
	 * instance is re-established after a temporary disconnection, while the
	 * SmartFoxServer 3 HRC system is available in the Zone.
	 * </p>
	 * <p>
	 * The HRC system allows a broken connection to be re-established transparently
	 * within a certain amount of time, without loosing any of the current
	 * application state. For example this allows a player to get back into a game
	 * without loosing the match because of an unstable connection.
	 * </p>
	 * <p>
	 * When this event is dispatched the application interface should be reverted to
	 * the state it had before the disconnection. In case the reconnection attempt
	 * fails, the <em>CONNECTION_LOST</em> event is fired.
	 * </p>
	 *
	 * <p>
	 * No parameters are available for this event object.
	 * </p>
	 *
	 * @see #CONNECTION_RETRY
	 * @see #CONNECTION_LOST
	 */
    public static final CONNECTION_RESUME:String = "connectionResume";

    /**
	 * <p>
	 * Dispatched in response to a <em>LoginRequest</em> and signaling a successful login in the selected
	 * Zone.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>user</td>
	 * <td><em>User</em></td>
	 * <td>An object representing the user who performed the login.</td>
	 * </tr>
	 * <tr>
	 * <td>data</td>
	 * <td><em>ISFSObject</em></td>
	 * <td>An object containing custom parameters returned by a custom login system,
	 * if any.</td>
	 * </tr>
	 * </table>
	 *
	 * @see sfs3.client.requests.LoginRequest
	 * @see sfs3.client.entities.User
	 * @see #LOGIN_ERROR
	 * @see #LOGOUT
	 */
    public static final LOGIN:String = "login";

    /**
	 *
	 * <p>
	 * Dispatched if an error occurs while the user login is being performed. This
	 * event is fired in response to the <em>LoginRequest</em> request in case the
	 * operation failed.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>errorMessage</td>
	 * <td><em>String</em></td>
	 * <td>A message containing the description of the error.</td>
	 * </tr>
	 * <tr>
	 * <td>errorCode</td>
	 * <td><em>short</em></td>
	 * <td>The error code.</td>
	 * </tr>
	 * </table>
	 *
	 * @see sfs3.client.requests.LoginRequest
	 * @see #LOGIN
	 */
    public static final LOGIN_ERROR:String = "loginError";

    /**
	 * <p>
	 * Dispatched when the current user logs out of the server Zone. This
	 * event is fired in response to the <em>LogoutRequest</em> request.
	 * </p>
	 *
	 * <p>
	 * No parameters are available for this event object.
	 * </p>
	 *
	 * @see sfs3.client.requests.LogoutRequest
	 * @see #LOGIN
	 */
    public static final LOGOUT:String = "logout";

    /**
	 * <p>
	 * Dispatched when a new Room is created inside the Zone under any of the Room
	 * Groups that the client is subscribed to. This event is fired in response to the
	 * <em>CreateRoomRequest</em> / <em>CreateSFSGameRequest</em> requests in case
	 * the operation is executed successfully.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>room</td>
	 * <td><em>Room</em></td>
	 * <td>An object representing the Room that was created.</td>
	 * </tr>
	 * </table>
	 *
	 * @see sfs3.client.requests.CreateRoomRequest
	 * @see sfs3.client.requests.game.CreateSFSGameRequest
	 * @see sfs3.client.entities.Room
	 * @see #ROOM_REMOVE
	 * @see #ROOM_CREATION_ERROR
	 */
    public static final ROOM_ADD:String = "roomAdd";

    /**
	 * <p>
	 * Dispatched when a Room belonging to one of the Groups subscribed by the
	 * client is removed from the Zone.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>room</td>
	 * <td><em>Room</em></td>
	 * <td>An object representing the Room that was removed.</td>
	 * </tr>
	 * </table>
	 *
	 * @see sfs3.client.entities.Room
	 * @see #ROOM_ADD
	 */
    public static final ROOM_REMOVE:String = "roomRemove";

    /**
	 * <p>
	 * Dispatched if an error occurs while creating a new Room. This event is fired
	 * in response to the <em>CreateRoomRequest</em> and
	 * <em>CreateSFSGameRequest</em> requests in case the operation failed.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>errorMessage</td>
	 * <td><em>String</em></td>
	 * <td>A message containing the description of the error.</td>
	 * </tr>
	 * <tr>
	 * <td>errorCode</td>
	 * <td><em>short</em></td>
	 * <td>The error code.</td>
	 * </tr>
	 * </table>
	 *
	 * @see sfs3.client.requests.CreateRoomRequest
	 * @see sfs3.client.requests.game.CreateSFSGameRequest
	 * @see #ROOM_ADD
	 */
    public static final ROOM_CREATION_ERROR:String = "roomCreationError";

    /**
	 * <p>
	 * Dispatched when a Room is joined by the current user. This event is fired in
	 * response to the <em>JoinRoomRequest</em> and <em>QuickJoinGameRequest</em>
	 * requests in case the operation is executed successfully.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>room</td>
	 * <td><em>Room</em></td>
	 * <td>An object representing the Room that was joined.</td>
	 * </tr>
	 * </table>
	 *
	 * @see JoinRoomRequest
	 * @see QuickJoinGameRequest
	 * @see sfs3.client.entities.Room
	 * @see #ROOM_JOIN_ERROR
	 */
    public static final ROOM_JOIN:String = "roomJoin";

    /**
	 * <p>
	 * Dispatched when an error occurs while the current user is trying to join a
	 * Room. This event is fired in response to the <em>JoinRoomRequest</em> and
	 * <em>QuickJoinGameRequest</em> requests in case the operation failed.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>errorMessage</td>
	 * <td><em>String</em></td>
	 * <td>A message containing the description of the error.</td>
	 * </tr>
	 * <tr>
	 * <td>errorCode</td>
	 * <td><em>short</em></td>
	 * <td>The error code.</td>
	 * </tr>
	 * </table>
	 *
	 * @see JoinRoomRequest
	 * @see QuickJoinGameRequest
	 * @see #ROOM_JOIN
	 */
    public static final ROOM_JOIN_ERROR:String = "roomJoinError";

    /**
	 * <p>
	 * Dispatched when one of the Rooms joined by the current user is entered by
	 * another user. This event is triggered by a <em>JoinRoomRequest</em> and
	 * <em>QuickJoinGameRequest</em> requests; it might be fired or not depending on
	 * the Room configuration defined upon its creation (see the
	 * <em>RoomSettings.events</em> setting).
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>user</td>
	 * <td><em>User</em></td>
	 * <td>An object representing the user who joined the Room.</td>
	 * </tr>
	 * <tr>
	 * <td>room</td>
	 * <td><em>Room</em></td>
	 * <td>An object representing the Room that was joined by a user.</td>
	 * </tr>
	 * </table>
	 *
	 * @see JoinRoomRequest
	 * @see QuickJoinGameRequest
	 * @see sfs3.client.requests.RoomSettings#setEvents(sfs3.client.requests.RoomEvents)
	 * @see sfs3.client.entities.User
	 * @see sfs3.client.entities.Room
	 * @see #USER_EXIT_ROOM
	 * @see #USER_COUNT_CHANGE
	 */
    public static final USER_ENTER_ROOM:String = "userEnterRoom";

    /**
	 * <p>
	 * Dispatched when one of the Rooms joined by the current user is left by
	 * another user, or by the current user himself. This event is triggered by a
	 * <em>LeaveRoomRequest</em> request; it might be fired or not depending on the
	 * Room configuration defined upon its creation (see the
	 * <em>RoomSettings.events</em> setting).
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>user</td>
	 * <td><em>User</em></td>
	 * <td>An object representing the user who left the Room.</td>
	 * </tr>
	 * <tr>
	 * <td>room</td>
	 * <td><em>Room</em></td>
	 * <td>An object representing the Room that was left by a user.</td>
	 * </tr>
	 * </table>
	 *
	 * @see sfs3.client.requests.LeaveRoomRequest
	 * @see sfs3.client.requests.RoomSettings#setEvents(sfs3.client.requests.RoomEvents)
	 * @see sfs3.client.entities.User
	 * @see sfs3.client.entities.Room
	 * @see #USER_ENTER_ROOM
	 * @see #USER_COUNT_CHANGE
	 */
    public static final USER_EXIT_ROOM:String = "userExitRoom";

    /**
	 * <p>
	 * Dispatched when the number of users/players or spectators inside a Room
	 * changes. This event can be triggered by either a <em>JoinRoomRequest</em>,
	 * <em>QuickJoinGameRequest</em> or a <em>LeaveRoomRequest</em> requests. The
	 * Room must belong to one of the Groups subscribed by the current client; also
	 * this event might be fired or not depending on the Room configuration defined
	 * upon its creation (see the <em>RoomSettings.events</em> setting).
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>room</td>
	 * <td><em>Room</em></td>
	 * <td>An object representing the Room in which the users count changed.</td>
	 * </tr>
	 * <tr>
	 * <td>uCount</td>
	 * <td><em>int</em></td>
	 * <td>The new users count (players in case of Game Room).</td>
	 * </tr>
	 * <tr>
	 * <td>sCount</td>
	 * <td><em>int</em></td>
	 * <td>The new spectators count (Game Room only).</td>
	 * </tr>
	 * </table>
	 *
	 * @see sfs3.client.requests.JoinRoomRequest
	 * @see QuickJoinGameRequest
	 * @see sfs3.client.requests.LeaveRoomRequest
	 * @see sfs3.client.requests.RoomSettings#setEvents(sfs3.client.requests.RoomEvents)
	 * @see sfs3.client.entities.Room
	 * @see #USER_ENTER_ROOM
	 * @see #USER_EXIT_ROOM
	 */
    public static final USER_COUNT_CHANGE:String = "userCountChange";

    /**
	 * <p>
	 * Dispatched when a public message is received by the current user. This event
	 * is caused by a <em>PublicMessageRequest</em> request sent by any user in the
	 * target Room, including the current user himself.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>room</td>
	 * <td><em>Room</em></td>
	 * <td>An object representing the Room at which the message is targeted.</td>
	 * </tr>
	 * <tr>
	 * <td>sender</td>
	 * <td><em>User</em></td>
	 * <td>An object representing the user who sent the message.</td>
	 * </tr>
	 * <tr>
	 * <td>message</td>
	 * <td><em>String</em></td>
	 * <td>The message sent by the user.</td>
	 * </tr>
	 * <tr>
	 * <td>data</td>
	 * <td><em>ISFSObject</em></td>
	 * <td>An object containing custom parameters which might accompany the
	 * message.</td>
	 * </tr>
	 * </table>
	 *
	 * @see sfs3.client.entities.User
	 * @see sfs3.client.entities.Room
	 * @see #PRIVATE_MESSAGE
	 */
    public static final PUBLIC_MESSAGE:String = "publicMessage";

    /**
	 * <p>
	 * Dispatched when a private message is received by the current user. This event
	 * is caused by a <em>PrivateMessageRequest</em> request sent by any user in the
	 * Zone.
	 * </p>
	 * <p>
	 * <b>NOTE:</b> the same event is also fired by the sender's client, so that the
	 * user is aware that the message was delivered successfully to the recipient,
	 * and it can be displayed in the private chat UI keeping the correct message
	 * ordering. In this case there is no default way to know who the message was
	 * originally sent to. As this information can be useful in scenarios where the
	 * sender is chatting privately with more than one user at the same time in
	 * separate windows or tabs (and we need to write his own message in the proper
	 * one), the data parameter can be used to store, for example, the id of the
	 * recipient user.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>sender</td>
	 * <td><em>User</em></td>
	 * <td>An object representing the user who sent the message.</td>
	 * </tr>
	 * <tr>
	 * <td>message</td>
	 * <td><em>String</em></td>
	 * <td>The message sent by the user.</td>
	 * </tr>
	 * <tr>
	 * <td>data</td>
	 * <td><em>ISFSObject</em></td>
	 * <td>An object containing custom parameters which might accompany the
	 * message.</td>
	 * </tr>
	 * </table>
	 *
	 * @see sfs3.client.requests.PrivateMessageRequest
	 * @see sfs3.client.entities.User
	 * @see #PUBLIC_MESSAGE
	 */
    public static final PRIVATE_MESSAGE:String = "privateMessage";

    /**
	 * <p>
	 * Dispatched when an object containing custom data is received by the current
	 * user. This event is triggered by an <em>ObjectMessageRequest</em> request sent
	 * by any user in the target Room.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>sender</td>
	 * <td><em>User</em></td>
	 * <td>An object representing the user who sent the message.</td>
	 * </tr>
	 * <tr>
	 * <td>message</td>
	 * <td><em>SFSObject</em></td>
	 * <td>The content of the message: an object containing the custom parameters
	 * sent by the sender.</td>
	 * </tr>
	 * </table>
	 *
	 * @see sfs3.client.requests.ObjectMessageRequest
	 * @see sfs3.client.entities.User
	 */
    public static final OBJECT_MESSAGE:String = "objectMessage";

    /**
	 * <p>
	 * Dispatched when the current user receives a message from a moderator user.
	 * This event can be triggered by either a <em>ModeratorMessageRequest</em>,
	 * <em>KickUserRequest</em> or a <em>BanUserRequest</em> request.
	 * Also, this event can be triggered by a kick/ban action performed through the
	 * SmartFoxServer 3 Administration Tool.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>sender</td>
	 * <td><em>User</em></td>
	 * <td>An object representing the moderator user who sent the message.</td>
	 * </tr>
	 * <tr>
	 * <td>message</td>
	 * <td><em>String</em></td>
	 * <td>The message sent by the moderator.</td>
	 * </tr>
	 * <tr>
	 * <td>data</td>
	 * <td><em>ISFSObject</em></td>
	 * <td>An object containing custom parameters which might accompany the
	 * message.</td>
	 * </tr>
	 * </table>
	 *
	 * @see sfs3.client.requests.ModeratorMessageRequest
	 * @see sfs3.client.requests.KickUserRequest
	 * @see sfs3.client.requests.BanUserRequest
	 * @see sfs3.client.entities.User
	 * @see #ADMIN_MESSAGE
	 */
    public static final MODERATOR_MESSAGE:String = "moderatorMessage";

    /**
	 * <p>
	 * Dispatched when the current user receives a message from an administrator
	 * user. This event is triggered by the <em>AdminMessageRequest</em> request sent
	 * by a user with administration privileges.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>sender</td>
	 * <td><em>User</em></td>
	 * <td>An object representing the administrator user who sent the message.</td>
	 * </tr>
	 * <tr>
	 * <td>message</td>
	 * <td><em>String</em></td>
	 * <td>The message sent by the administrator.</td>
	 * </tr>
	 * <tr>
	 * <td>data</td>
	 * <td><em>ISFSObject</em></td>
	 * <td>An object containing custom parameters which might accompany the
	 * message.</td>
	 * </tr>
	 * </table>
	 *
	 * @see sfs3.client.requests.AdminMessageRequest
	 * @see sfs3.client.entities.User
	 * @see #MODERATOR_MESSAGE
	 */
    public static final ADMIN_MESSAGE:String = "adminMessage";

    /**
	 * <p>
	 * Dispatched when data coming from a server-side Extension is received by the
	 * current user. Data is usually sent by the server to one or more clients in
	 * response to an <em>ExtensionRequest</em> request.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>cmd</td>
	 * <td><em>String</em></td>
	 * <td>The name of a custom command to be processed. If this event is fired in response to a request sent
	 * by the client, it is a common practice to use the same command name passed sent in the request</td>
	 * </tr>
	 * <tr>
	 * <td>extParams</td>
	 * <td><em>ISFSObject</em></td>
	 * <td>An object containing the data sent by the Extension.</td>
	 * </tr>
	 * <tr>
	 * <td>room</td>
	 * <td><em>Room</em></td>
	 * <td>An object representing the Room which the Extension is attached to (null if it's not a Room Extension)</td>
	 * </tr>
	 * <tr>
	 * <td>roomId</td>
	 * <td><em>int</em></td>
	 * <td>The id of the Room Extension (null if it's not a Room Extension)</td>
	 * </tr>
	 * <tr>
	 * <td>txTtpe</td>
	 * <td><em>TransportType</em></td>
	 * <td>The transport type used by the Extensions (TCP, UDP_RELIABLE, UDP_UNRELIABLE etc...)</td>
	 * </tr>
	 * </table>
	 *
	 * @see sfs3.client.requests.ExtensionRequest
	 */
    public static final EXTENSION_RESPONSE:String = "extensionResponse";

    /**
	 * <p>
	 * Dispatched when a Room Variable is updated. This event is triggered by the
	 * <em>SetRoomVariablesRequest</em> request, which could have been sent by
	 * a user in the same Room or, in case of a global Room
	 * Variable, in a Room belonging to one of the subscribed Groups.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>room</td>
	 * <td><em>Room</em></td>
	 * <td>An object representing the Room where the Room Variable update
	 * occurred.</td>
	 * </tr>
	 * <tr>
	 * <td>changedVars</td>
	 * <td><em>List&lt;String&gt;</em></td>
	 * <td>The list of names of the Room Variables that were updated (or created for
	 * the first time).</td>
	 * </tr>
	 * </table>
	 *
	 * @see sfs3.client.requests.SetRoomVariablesRequest
	 * @see sfs3.client.entities.Room
	 */
    public static final ROOM_VARIABLES_UPDATE:String = "roomVariablesUpdate";

    /**
	 * <p>
	 * Dispatched when a User Variable is updated. This event is triggered by the
	 * <em>SetUserVariablesRequest</em> request sent by a user in one of the currently joined Rooms.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>user</td>
	 * <td><em>User</em></td>
	 * <td>An object representing the User who updated his own User Variables.</td>
	 * </tr>
	 * <tr>
	 * <td>changedVars</td>
	 * <td><em>List&lt;String&gt;</em></td>
	 * <td>The list of names of the User Variables that were updated (or created for
	 * the first time).</td>
	 * </tr>
	 * </table>
	 *
	 * @see SmartFox#getJoinedRooms()
	 * @see sfs3.client.requests.SetUserVariablesRequest
	 * @see sfs3.client.entities.User
	 */
    public static final USER_VARIABLES_UPDATE:String = "userVariablesUpdate";

    /**
	 * <p>
	 * Dispatched when a Room Group is subscribed by the current user. This event is
	 * fired in response to the <em>SubscribeRoomGroupRequest</em> request if the
	 * operation is executed successfully.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>groupId</td>
	 * <td><em>String</em></td>
	 * <td>The name of the Group that was subscribed.</td>
	 * </tr>
	 * <tr>
	 * <td>newRooms</td>
	 * <td><em>List&lt;Room&gt;</em></td>
	 * <td>A list of <em>Room</em> objects representing the Rooms belonging to the
	 * subscribed Group.</td>
	 * </tr>
	 * </table>
	 *
	 * @see sfs3.client.requests.SubscribeRoomGroupRequest
	 * @see sfs3.client.entities.Room
	 * @see #ROOM_GROUP_SUBSCRIBE_ERROR
	 * @see #ROOM_GROUP_UNSUBSCRIBE
	 */
    public static final ROOM_GROUP_SUBSCRIBE:String = "roomGroupSubscribe";

    /**
	 * <p>
	 * Dispatched when a Group is unsubscribed by the current user. This event is
	 * fired in response to the <em>UnsubscribeRoomGroupRequest</em> request if the
	 * operation is executed successfully.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>groupId</td>
	 * <td><em>String</em></td>
	 * <td>The name of the Group that was unsubscribed.</td>
	 * </tr>
	 * </table>
	 *
	 * @see sfs3.client.requests.UnsubscribeRoomGroupRequest
	 * @see #ROOM_GROUP_UNSUBSCRIBE_ERROR
	 * @see #ROOM_GROUP_SUBSCRIBE
	 */
    public static final ROOM_GROUP_UNSUBSCRIBE:String = "roomGroupUnsubscribe";

    /**
	 * <p>
	 * This event is fired in response to the <em>SubscribeRoomGroupRequest</em> request
	 * in case the operation failed.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>errorMessage</td>
	 * <td><em>String</em></td>
	 * <td>A message containing the description of the error.</td>
	 * </tr>
	 * <tr>
	 * <td>errorCode</td>
	 * <td><em>short</em></td>
	 * <td>The error code.</td>
	 * </tr>
	 * </table>
	 *
	 * @see sfs3.client.requests.SubscribeRoomGroupRequest
	 * @see #ROOM_GROUP_SUBSCRIBE
	 */
    public static final ROOM_GROUP_SUBSCRIBE_ERROR:String = "roomGroupSubscribeError";

    /**
	 * <p>
	 * This event is fired in response to the <em>UnsubscribeRoomGroupRequest</em>
	 * request in case the operation failed.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>errorMessage</td>
	 * <td><em>String</em></td>
	 * <td>A message containing the description of the error.</td>
	 * </tr>
	 * <tr>
	 * <td>errorCode</td>
	 * <td><em>short</em></td>
	 * <td>The error code.</td>
	 * </tr>
	 * </table>
	 *
	 * @see sfs3.client.requests.UnsubscribeRoomGroupRequest
	 * @see #ROOM_GROUP_UNSUBSCRIBE
	 */
    public static final ROOM_GROUP_UNSUBSCRIBE_ERROR:String = "roomGroupUnsubscribeError";

    /**
	 * <p>
	 * This event is fired in response to the <em>SpectatorToPlayerRequest</em> request
	 * if the operation is executed successfully.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>room</td>
	 * <td><em>Room</em></td>
	 * <td>An object representing the Room in which the spectator is turned to
	 * player.</td>
	 * </tr>
	 * <tr>
	 * <td>user</td>
	 * <td><em>User</em></td>
	 * <td>An object representing the spectator who was turned to player.</td>
	 * </tr>
	 * <tr>
	 * <td>playerId</td>
	 * <td><em>int</em></td>
	 * <td>The player id of the user.</td>
	 * </tr>
	 * </table>
	 *
	 * @see sfs3.client.requests.SpectatorToPlayerRequest
	 * @see sfs3.client.entities.User
	 * @see sfs3.client.entities.Room
	 * @see #SPECTATOR_TO_PLAYER_ERROR
	 * @see #PLAYER_TO_SPECTATOR
	 */
    public static final SPECTATOR_TO_PLAYER:String = "spectatorToPlayer";

    /**
	 * <p>
	 * Dispatched when a player is turned to a spectator inside a Game Room. This
	 * event is fired in response to the <em>PlayerToSpectatorRequest</em> request
	 * if the operation is executed successfully.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>room</td>
	 * <td><em>Room</em></td>
	 * <td>An object representing the Room in which the player is turned to
	 * spectator.</td>
	 * </tr>
	 * <tr>
	 * <td>user</td>
	 * <td><em>User</em></td>
	 * <td>An object representing the player who was turned to spectator.</td>
	 * </tr>
	 * </table>
	 *
	 * @see sfs3.client.requests.PlayerToSpectatorRequest
	 * @see sfs3.client.entities.User
	 * @see sfs3.client.entities.Room
	 * @see #PLAYER_TO_SPECTATOR_ERROR
	 * @see #SPECTATOR_TO_PLAYER
	 */
    public static final PLAYER_TO_SPECTATOR:String = "playerToSpectator";

    /**
	 * <p>
	 * Dispatched when an error occurs while the current user is being turned from
	 * spectator to player in a Game Room. This event is fired in response to the
	 * <em>SpectatorToPlayerRequest</em> request in case the operation failed.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>errorMessage</td>
	 * <td><em>String</em></td>
	 * <td>A message containing the description of the error.</td>
	 * </tr>
	 * <tr>
	 * <td>errorCode</td>
	 * <td><em>short</em></td>
	 * <td>The error code.</td>
	 * </tr>
	 * </table>
	 *
	 * @see sfs3.client.requests.SpectatorToPlayerRequest
	 * @see #SPECTATOR_TO_PLAYER
	 */
    public static final SPECTATOR_TO_PLAYER_ERROR:String = "spectatorToPlayerError";

    /**
	 * <p>
	 * Dispatched when an error occurs while the current user is being turned from
	 * player to spectator in a Game Room. This event is fired in response to the
	 * <em>PlayerToSpectatorRequest</em> request in case the operation failed.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>errorMessage</td>
	 * <td><em>String</em></td>
	 * <td>A message containing the description of the error.</td>
	 * </tr>
	 * <tr>
	 * <td>errorCode</td>
	 * <td><em>short</em></td>
	 * <td>The error code.</td>
	 * </tr>
	 * </table>
	 *
	 * @see sfs3.client.requests.PlayerToSpectatorRequest
	 * @see #PLAYER_TO_SPECTATOR
	 */
    public static final PLAYER_TO_SPECTATOR_ERROR:String = "playerToSpectatorError";

    /**
	 * <p>
	 * Dispatched when the name of a Room is changed. This event is fired in
	 * response to the <em>ChangeRoomNameRequest</em> request if the operation is
	 * executed successfully.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>room</td>
	 * <td><em>Room</em></td>
	 * <td>An object representing the Room which was renamed.</td>
	 * </tr>
	 * <tr>
	 * <td>oldName</td>
	 * <td><em>String</em></td>
	 * <td>The previous name of the Room.</td>
	 * </tr>
	 * </table>
	 *
	 * @see sfs3.client.requests.ChangeRoomNameRequest
	 * @see sfs3.client.entities.Room
	 * @see #ROOM_NAME_CHANGE_ERROR
	 */
    public static final ROOM_NAME_CHANGE:String = "roomNameChange";

    /**
	 * <p>
	 * Dispatched when an error occurs while attempting to change the name of a
	 * Room. This event is fired in response to the <em>ChangeRoomNameRequest</em>
	 * request in case the operation failed.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>errorMessage</td>
	 * <td><em>String</em></td>
	 * <td>A message containing the description of the error.</td>
	 * </tr>
	 * <tr>
	 * <td>errorCode</td>
	 * <td><em>short</em></td>
	 * <td>The error code.</td>
	 * </tr>
	 * </table>
	 *
	 * @see sfs3.client.requests.ChangeRoomNameRequest
	 * @see #ROOM_NAME_CHANGE
	 */
    public static final ROOM_NAME_CHANGE_ERROR:String = "roomNameChangeError";

    /**
	 * <p>
	 * Dispatched when the password of a Room is set, changed or removed. This event
	 * is fired in response to the <em>ChangeRoomPasswordStateRequest</em> request
	 * if the operation is executed successfully.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>room</td>
	 * <td><em>Room</em></td>
	 * <td>An object representing the Room whose password was changed.</td>
	 * </tr>
	 * </table>
	 *
	 * @see sfs3.client.requests.ChangeRoomPasswordStateRequest
	 * @see sfs3.client.entities.Room
	 * @see #ROOM_PASSWORD_STATE_CHANGE_ERROR
	 */
    public static final ROOM_PASSWORD_STATE_CHANGE:String = "roomPasswordStateChange";

    /**
	 * <p>
	 * Dispatched when an error occurs while attempting to set, change or remove the
	 * password of a Room. This event is fired in response to the
	 * <em>ChangeRoomPasswordStateRequest</em> request in case the operation failed.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>errorMessage</td>
	 * <td><em>String</em></td>
	 * <td>A message containing the description of the error.</td>
	 * </tr>
	 * <tr>
	 * <td>errorCode</td>
	 * <td><em>short</em></td>
	 * <td>The error code.</td>
	 * </tr>
	 * </table>
	 *
	 * @see sfs3.client.requests.ChangeRoomPasswordStateRequest
	 * @see #ROOM_PASSWORD_STATE_CHANGE
	 */
    public static final ROOM_PASSWORD_STATE_CHANGE_ERROR:String = "roomPasswordStateChangeError";

    /**
	 * <p>
	 * Dispatched when the capacity of a Room is changed. This event is fired in
	 * response to the <em>ChangeRoomCapacityRequest</em> request if the operation
	 * is executed successfully.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>room</td>
	 * <td><em>Room</em></td>
	 * <td>An object representing the Room whose capacity was changed.</td>
	 * </tr>
	 * </table>
	 *
	 * @see sfs3.client.requests.ChangeRoomCapacityRequest
	 * @see sfs3.client.entities.Room
	 * @see #ROOM_CAPACITY_CHANGE_ERROR
	 */
    public static final ROOM_CAPACITY_CHANGE:String = "roomCapacityChange";

    /**
	 * <p>
	 * Dispatched when an error occurs while attempting to change the capacity of a
	 * Room. This event is fired in response to the
	 * <em>ChangeRoomCapacityRequest</em> request in case the operation failed.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>errorMessage</td>
	 * <td><em>String</em></td>
	 * <td>A message containing the description of the error.</td>
	 * </tr>
	 * <tr>
	 * <td>errorCode</td>
	 * <td><em>short</em></td>
	 * <td>The error code.</td>
	 * </tr>
	 * </table>
	 *
	 * @see sfs3.client.requests.ChangeRoomCapacityRequest
	 * @see #ROOM_CAPACITY_CHANGE
	 */
    public static final ROOM_CAPACITY_CHANGE_ERROR:String = "roomCapacityChangeError";

    /**
	 * <p>
	 * Dispatched when a Rooms search is completed. This event is fired in response
	 * to the <em>FindRoomsRequest</em> request to return the search result.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>rooms</td>
	 * <td><em>List&lt;Room&gt;</em></td>
	 * <td>A list of <em>Room</em> objects representing the Rooms matching the
	 * search criteria. If no Room is found, the list is empty</td>
	 * </tr>
	 * </table>
	 *
	 * @see sfs3.client.requests.FindRoomsRequest
	 */
    public static final ROOM_FIND_RESULT:String = "roomFindResult";

    /**
	 * <p>
	 * Dispatched when a Users search is completed. This event is fired in response
	 * to the <em>FindUsersRequest</em> request to return the search result.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>users</td>
	 * <td><em>List&lt;User&gt;</em></td>
	 * <td>A list of <em>User</em> objects representing the Users matching the
	 * search criteria. If no User is found, the list is empty</td>
	 * </tr>
	 * </table>
	 *
	 * @see sfs3.client.requests.FindUsersRequest
	 */
    public static final USER_FIND_RESULT:String = "userFindResult";

    /**
	 * <p>
	 * Dispatched when the current user receives an invitation from another user.
	 * This event is triggered by the <em>InviteUsersRequest</em> request; the user is
	 * supposed to reply using the <em>InvitationReplyRequest</em> request.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>invitation</td>
	 * <td><em>Invitation</em></td>
	 * <td>An object representing the invitation received by the current user.</td>
	 * </tr>
	 * </table>
	 *
	 * @see sfs3.client.requests.invitation.InviteUsersRequest
	 * @see sfs3.client.requests.invitation.InvitationReplyRequest
	 * @see sfs3.client.entities.invitation.Invitation
	 * @see #INVITATION_REPLY
	 */
    public static final INVITATION:String = "invitation";

    /**
	 * <p>
	 * Dispatched when the current user receives a reply to an invitation sent
	 * previously. This event is triggered by the <em>InvitationReplyRequest</em>
	 * request sent by the invitee.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>invitee</td>
	 * <td><em>User</em></td>
	 * <td>An object representing the user who replied to the invitation.</td>
	 * </tr>
	 * <tr>
	 * <td>reply</td>
	 * <td><em>InvitationReply</em></td>
	 * <td>The response from the invitee (ACCEPT, REFUSE or EXPIRED)
	 * <em>InvitationReply</em> class.</td>
	 * </tr>
	 * <tr>
	 * <td>data</td>
	 * <td><em>ISFSObject</em></td>
	 * <td>An optional object containing custom parameters, for example a message describing
	 * the reason of the refusal.</td>
	 * </tr>
	 * </table>
	 *
	 * @see sfs3.client.requests.invitation.InvitationReplyRequest
	 * @see sfs3.client.entities.invitation.InvitationReply
	 * @see #INVITATION
	 * @see #INVITATION_REPLY_ERROR
	 */
    public static final INVITATION_REPLY:String = "invitationReply";

    /**
	 * <p>
	 * Dispatched when an error occurs while the current user is sending a reply to
	 * an invitation. This event is fired in response to the
	 * <em>InvitationReplyRequest</em> request in case the operation failed.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable" >
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>errorMessage</td>
	 * <td><em>String</em></td>
	 * <td>A message containing the description of the error.</td>
	 * </tr>
	 * <tr>
	 * <td>errorCode</td>
	 * <td><em>short</em></td>
	 * <td>The error code.</td>
	 * </tr>
	 * </table>
	 *
	 * @see sfs3.client.requests.invitation.InvitationReplyRequest
	 * @see #INVITATION_REPLY
	 * @see #INVITATION
	 */
    public static final INVITATION_REPLY_ERROR:String = "invitationReplyError";

    /**
	 * <p>
	 * Dispatched to notify about Users and MMOItem changes in the players' AoI of a joined MMORoom, typically
	 * in response to a SetUserPositionRequest request.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event object
	 * have the following values:
	 * </p>
	 * <table class="innertable">
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>room</td>
	 * <td><em>Room</em></td>
	 * <td>The Room where the event occurred.</td>
	 * </tr>
	 * <tr>
	 * <td>addedUsers</td>
	 * <td><em>List&lt;Users&gt;</em></td>
	 * <td>A list of <em>User</em> objects representing the users who entered the
	 * current user's Area of Interest.</td>
	 * </tr>
	 * <tr>
	 * <td>removedUsers</td>
	 * <td><em>List&lt;Users&gt;</em></td>
	 * <td>A list of <em>User</em> objects representing the users who left the
	 * current user's Area of Interest.</td>
	 * </tr>
	 * <tr>
	 * <td>addedItems</td>
	 * <td><em>List&lt;IMMOItem&gt;</em></td>
	 * <td>A list of <em>MMOItem</em> objects which entered the current user's Area
	 * of Interest.</td>
	 * </tr>
	 * <tr>
	 * <td>removedItems</td>
	 * <td><em>List&lt;IMMOItem&gt;</em></td>
	 * <td>A list of <em>MMOItem</em> objects which left the current user's Area of
	 * Interest.</td>
	 * </tr>
	 * </table>
	 *
	 * @see SetUserPositionRequest
	 * @see MMORoom
	 */
    public static final PROXIMITY_LIST_UPDATE:String = "proximityListUpdate";

    /**
	 * <p>
	 * Dispatched to notify about MMOItemVariables updates in the current MMORoom.
	 * </p>
	 *
	 * <p>
	 * The properties of the <em>params</em> object contained in the event have the
	 * following values:
	 * </p>
	 * <table class="innertable">
	 * <tr>
	 * <th>Property</th>
	 * <th>Type</th>
	 * <th>Description</th>
	 * </tr>
	 * <tr>
	 * <td>room</td>
	 * <td><em>MMORoom</em></td>
	 * <td>The MMORoom where the MMOItem whose Variables have been updated is
	 * located.</td>
	 * </tr>
	 * <tr>
	 * <td>mmoItem</td>
	 * <td><em>MMOItem</em></td>
	 * <td>The MMOItem whose variables have been updated.</td>
	 * </tr>
	 * <tr>
	 * <td>changedVars</td>
	 * <td><em>List&lt;String&gt;</em></td>
	 * <td>The list of names of the MMOItem Variables that were changed (or created
	 * for the first time).</td>
	 * </tr>
	 * </table>
	 *
	 * @see MMORoom
	 * @see MMOItem
	 * @see MMOItemVariable
	 */
    public static final MMOITEM_VARIABLES_UPDATE:String = "mmoItemVariablesUpdate";

    // ========================================================

    /**
	 * Creates a new <em>SFSEvent</em> instance.
	 *
	 * @param type The type of event.
	 * @param args An object containing the parameters of the event.
	 */
    public function new(type:String, args:Map<String, Dynamic> = null)
    {
        super(type, args);
    }
}