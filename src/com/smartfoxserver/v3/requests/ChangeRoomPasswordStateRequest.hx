package com.smartfoxserver.v3.requests;

import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.exceptions.SFSValidationException;
import com.smartfoxserver.v3.entities.Room;

/**
 * Changes the password of a Room.
 * This request not only changes the password of a Room, but also its "password state", which indicates if the Room is password protected or not.
 * <p/>
 * <p>If the operation is successful, the <em>roomPasswordStateChange</em> event is dispatched to all the users
 * who subscribed the Group to which the target Room belongs, including the requester user himself.
 * If the user is not the creator (owner) of the Room the <em>roomPasswordStateChangeError</em> event if fired.
 * An administrator or moderator can override the constraint (he is not requested to be the Room's owner).</p>
 * <p>If the Room was configured so that password change is not allowed (see the <em>RoomSettings.permissions</em> parameter), the request is ignored and no error is fired.</p>
 * <p/>
 *
 * @see		com.smartfoxserver.v3.core.SFSEvent#ROOM_PASSWORD_STATE_CHANGE
 * @see		com.smartfoxserver.v3.core.SFSEvent#ROOM_PASSWORD_STATE_CHANGE_ERROR
 * @see		com.smartfoxserver.v3.requests.RoomSettings#getPermissions()
 */
class ChangeRoomPasswordStateRequest extends BaseRequest 
{
	/**
	 * @internal
	 */
	public static final KEY_ROOM:String = "r";

	/**
	 * @internal
	 */
	public static final KEY_PASS:String = "p";

	private var room:Room;
	private var newPass:String;

	/**
	 * Creates a new <em>ChangeRoomPasswordStateRequest</em> instance.
	 * The instance must be passed to the <em>SmartFox.send()</em> method for the request to be performed.
	 *
	 * @param	room	The <em>Room</em> object corresponding to the Room whose password should be changed.
	 * @param	newPass	The new password to be assigned to the Room; an empty string or the <code>null</code> value can be passed to remove the Room's password.
	 * 
	 * @see		com.smartfoxserver.v3.SmartFox#send
	 */
	public function new(room:Room, newPass:String) 
	{
		super(BaseRequest.ChangeRoomPassword);

		this.room = room;
		this.newPass = newPass;
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

		if (newPass == null)
			errors.push("Invalid new room password. It must be a non-null string.");

		if (errors.length > 0)
			throw new SFSValidationException("ChangePassState request error", errors);
	}

	/**
	 * @internal
	 */
	public function execute(sfs:ISmartFox):Void
	{
		sfso.putInt(KEY_ROOM, room.getId());
		sfso.putString(KEY_PASS, newPass);
	}
}
