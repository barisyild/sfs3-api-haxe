package com.smartfoxserver.v3.requests;

import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.exceptions.SFSValidationException;
import com.smartfoxserver.v3.entities.Room;

/**
 * Joins the current user in a Room.
 * <p/>
 * <p>If the operation is successful, the current user receives a <em>roomJoin</em> event; otherwise the <em>roomJoinError</em> event is fired. This
 * usually happens when the Room is full, or the password is wrong in case of password protected Rooms.</p>
 * <p/>
 * <p>Depending on the Room configuration defined upon its creation (see the <em>RoomSettings.events</em> setting), when the current user joins it,
 * the following events might be fired: <em>userEnterRoom</em>, dispatched to the other users inside the Room to warn them that a new user has arrived;
 * <em>userCountChange</em>, dispatched to all clients which subscribed the Group to which the Room belongs, to update the count of users inside the Room.</p>
 * <p/>
 * <p/>
 *
 * @see 	com.smartfoxserver.v3.core.SFSEvent#ROOM_JOIN
 * @see 	com.smartfoxserver.v3.core.SFSEvent#ROOM_JOIN_ERROR
 * @see 	com.smartfoxserver.v3.core.SFSEvent#USER_ENTER_ROOM
 * @see 	com.smartfoxserver.v3.core.SFSEvent#USER_COUNT_CHANGE
 * @see		com.smartfoxserver.v3.requests.RoomSettings#getEvents()
 */
class JoinRoomRequest extends BaseRequest 
{
	/**
	 * @internal
	 */
	public static final KEY_ROOM:String = "r";

	/**
	 * @internal
	 */
	public static final KEY_USER_LIST:String = "ul";

	/**
	 * @internal
	 */
	public static final KEY_ROOM_NAME:String = "n";

	/**
	 * @internal
	 */
	public static final KEY_ROOM_ID:String = "i";

	/**
	 * @internal
	 */
	public static final KEY_PASS:String = "p";

	/**
	 * @internal
	 */
	public static final KEY_ROOM_TO_LEAVE:String = "rl";

	/**
	 * @internal
	 */
	public static final KEY_AS_SPECTATOR:String = "sp";

	private var name:String;
	private var pass:String;
	private var roomIdToLeave:Null<Int>;
	private var asSpectator:Bool;

	/**
	 * Creates a new <em>JoinRoomRequest</em> instance.
	 * The instance must be passed to the <em>SmartFox.send()</em> method for the request to be performed.
	 *
	 * @param	id				The id or the name of the Room to be joined.
	 * @param	pass			The password of the Room, in case it is password protected.
	 * @param	roomIdToLeave	The id of a previously joined Room that the user should leave when joining the new Room.
	 * 							By default, the last joined Room is left; if a negative number is passed, no previous Room is left.
	 * @param	asSpectator		<code>true</code> to join the Room as a spectator (in Game Rooms only).
	 * 
	 * @see		com.smartfoxserver.v3.SmartFox#send
	 */
	public function new(id:Dynamic, ?pass:String = null, ?roomIdToLeave:Null<Int> = null, ?asSpectator:Bool = false) 
	{
		super(BaseRequest.JoinRoom);

		if (Std.isOfType(id, String)) 
			this.name = cast id;
		
		else if (Std.isOfType(id, Int)) 
			this.id = cast id;
		
		else if (Std.isOfType(id, Room)) 
			this.id = (cast id:Room).getId();

		this.pass = pass;
		this.roomIdToLeave = roomIdToLeave;
		this.asSpectator = asSpectator;
	}

	/**
	 * @internal
	 */
	public function validate(sfs:ISmartFox):Void
	{
		// Missing room id
		if (id < 0 && name == null) 
			throw new SFSValidationException("JoinRoomRequest Error", ["Missing Room id or name, you should provide at least one"]);
	}

	/**
	 * @internal
	 */
	public function execute(sfs:ISmartFox):Void
	{
		if (id > -1) 
			sfso.putInt(KEY_ROOM_ID, id);
		
		else if (name != null) 
			sfso.putString(KEY_ROOM_NAME, name);

		if (pass != null) 
			sfso.putString(KEY_PASS, pass);

		/*
		 * roomIdToLeave:
		 * 
		 * null 	--->> Leave Last Joined Room
		 * > 0 		--->> Leave the Room with that ID
		 * < 0		--->> Do not leave any Room
		 */

		if (roomIdToLeave != null) 
			sfso.putInt(KEY_ROOM_TO_LEAVE, roomIdToLeave);
		
		if (asSpectator) 
			sfso.putBool(KEY_AS_SPECTATOR, asSpectator);
		
	}
}
