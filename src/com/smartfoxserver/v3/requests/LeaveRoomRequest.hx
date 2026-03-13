package com.smartfoxserver.v3.requests;

import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.exceptions.SFSValidationException;
import com.smartfoxserver.v3.entities.Room;

/**
 * Leaves one of the Rooms joined by the current user.
 * <p/>
 * <p>Depending on the Room configuration defined upon its creation (see the <em>RoomSettings.events</em> setting), when the current user leaves it,
 * the following events might be fired: <em>userExitRoom</em>, dispatched to all the users inside the Room (including the current user then) to warn them that a user has gone away;
 * <em>userCountChange</em>, dispatched to all clients which subscribed the Group to which the Room belongs, to update the count of users inside the Room.</p>
 * <p/>
 * <p/>
 *
 * @see 	com.smartfoxserver.v3.core.SFSEvent#USER_EXIT_ROOM
 * @see 	com.smartfoxserver.v3.core.SFSEvent#USER_COUNT_CHANGE
 * @see		RoomSettings#getEvents()
 */

class LeaveRoomRequest extends BaseRequest 
{
	/**
	 * @internal
	 */
	public static final KEY_ROOM_ID:String = "r";

	private var room:Room;

	/**
	 * Creates a new <em>LeaveRoomRequest</em> instance.
	 * The instance must be passed to the <em>SmartFox.send()</em> method for the request to be performed.
	 *
	 * @param	theRoom	The <em>Room</em> object corresponding to the Room that the current user must leave. If <code>null</code>, the last Room joined by the user is left.
	 * 
	 * @see		com.smartfoxserver.v3.SmartFox#send
	 * @see		com.smartfoxserver.v3.entities.Room
	 */
	public function new(?theRoom:Room = null) 
	{
		super(BaseRequest.LeaveRoom);
		room = theRoom;
	}

	/**
	 * @internal
	 */
	public function validate(sfs:ISmartFox):Void
	{
		var errors = new Array<String>();

		// no validation needed
		if (sfs.getJoinedRooms().length < 1)
			errors.push("You are not joined in any rooms");

		if (errors.length > 0) 
			throw new SFSValidationException("LeaveRoom request error", errors);
		
	}

	/**
	 * @internal
	 */
	public function execute(sfs:ISmartFox):Void
	{
		if (room != null) 
			sfso.putInt(KEY_ROOM_ID, room.getId());
	}
}
