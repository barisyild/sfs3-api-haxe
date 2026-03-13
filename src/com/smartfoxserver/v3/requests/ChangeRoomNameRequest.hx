package com.smartfoxserver.v3.requests;

import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.exceptions.SFSValidationException;
import com.smartfoxserver.v3.entities.Room;

/**
 * Changes the name of a Room.
 * <p/>
 * <p>If the renaming operation is successful, the <em>roomNameChange</em> event is dispatched to all the users
 * who subscribed the Group to which the target Room belongs, including the user who renamed it.
 * If the user is not the creator (owner) of the Room the <em>roomNameChangeError</em> event if fired.
 * An administrator or moderator can override the first constrain (he is not requested to be the Room's owner).</p>
 * <p>
 * If the Room was configured so that renaming is not allowed (see the <em>RoomSettings.permissions</em> parameter), the request is ignored and no error is fired.
 * </p>
 * <p/>
 *
 * @see		com.smartfoxserver.v3.core.SFSEvent#ROOM_NAME_CHANGE
 * @see		com.smartfoxserver.v3.core.SFSEvent#ROOM_NAME_CHANGE_ERROR
 * @see		com.smartfoxserver.v3.requests.RoomSettings#getPermissions()
 */
class ChangeRoomNameRequest extends BaseRequest 
{
	/**
	 * @internal
	 */
	public static final KEY_ROOM:String = "r";

	/**
	 * @internal
	 */
	public static final KEY_NAME:String = "n";

	private var room:Room;
	private var newName:String;

	/**
	 * Creates a new <em>ChangeRoomNameRequest</em> instance.
	 * The instance must be passed to the <em>SmartFox.send()</em> method for the request to be performed.
	 *
	 * @param	room	The <em>Room</em> object corresponding to the Room whose name should be changed.
	 * @param	newName	The new name to be assigned to the Room.
	 * 
	 * @see		com.smartfoxserver.v3.SmartFox#send
	 */
	public function new(room:Room, newName:String) 
	{
		super(BaseRequest.ChangeRoomName);

		this.room = room;
		this.newName = newName;
	}

	/**
	 * @internal
	 */
	public function validate(sfs:ISmartFox):Void
	{
		var errors = new Array<String>();

		// Missing room id
		if (room == null) 
			errors.push("Provided room is null");

		if (newName == null || newName.length == 0) 
			errors.push("Invalid new room name. It must be a non-null and non-empty string.");

		if (errors.length > 0) 
			throw new SFSValidationException("ChangeRoomName request error", errors);
	}

	/**
	 * @internal
	 */
	public function execute(sfs:ISmartFox):Void
	{
		sfso.putInt(KEY_ROOM, room.getId());
		sfso.putString(KEY_NAME, newName);
	}
}
