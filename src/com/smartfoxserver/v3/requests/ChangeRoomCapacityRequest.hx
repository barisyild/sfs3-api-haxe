package com.smartfoxserver.v3.requests;

import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.exceptions.SFSValidationException;
import com.smartfoxserver.v3.entities.Room;

/**
 * Changes the maximum number of users and/or spectators who can join a Room.
 * <p/>
 * <p>If the operation is successful, the <em>roomCapacityChange</em> event is dispatched to all the users
 * who subscribed the Group to which the target Room belongs, including the requester user himself.
 * If the user is not the creator (owner) of the Room the <em>roomCapacityChangeError</em> event is fired.
 * An administrator or moderator can override this constraint (he is not requested to be the Room's owner).</p>
 * <p/>
 * <p>In case the Room's capacity is reduced to a value less than the current number of users/spectators inside the Room, exceeding users are NOT disconnected.</p>
 * <p>
 * If the Room was configured so that resizing is not allowed (see the <em>RoomSettings.permissions</em> parameter), the request is ignored and no error is fired.
 * </p>
 * <p>Also note that some restrictions are applied to the passed values (i.e. a client can't set the max users to more than 200, or the max spectators to more than 32).</p>
 * <p/>
 *
 * @see		com.smartfoxserver.v3.core.SFSEvent#ROOM_CAPACITY_CHANGE
 * @see		com.smartfoxserver.v3.core.SFSEvent#ROOM_CAPACITY_CHANGE_ERROR
 * @see		com.smartfoxserver.v3.requests.RoomSettings#getPermissions()
 */
class ChangeRoomCapacityRequest extends BaseRequest 
{
	/**
	 * @internal
	 */
	public static final KEY_ROOM:String = "r";

	/**
	 * @internal
	 */
	public static final KEY_USER_SIZE:String = "u";

	/**
	 * @internal
	 */
	public static final KEY_SPEC_SIZE:String = "s";

	private var room:Room;
	private var newMaxUsers:Int;
	private var newMaxSpect:Int;

	/**
	 * Creates a new <em>ChangeRoomCapacityRequest</em> instance.
	 * The instance must be passed to the <em>SmartFox.send()</em> method for the request to be performed.
	 *
	 * @param	room		The <em>Room</em> object corresponding to the Room whose capacity should be changed.
	 * @param	newMaxUsers	The new maximum number of users/players who can join the Room; 
	 * @param	newMaxSpect	The new maximum number of spectators who can join the Room (for Game Rooms only); 
	 * 
	 * @see		com.smartfoxserver.v3.SmartFox#send
	 * @see		com.smartfoxserver.v3.entities.Room#getMaxUsers()
	 */
	public function new(room:Room, newMaxUsers:Int, newMaxSpect:Int) 
	{
		super(BaseRequest.ChangeRoomCapacity);

		this.room = room;
		this.newMaxUsers = newMaxUsers;
		this.newMaxSpect = newMaxSpect;
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
		
		if (newMaxUsers < 1)
			errors.push("newMaxUsers value must be > 0");
		
		if (newMaxSpect < 0)
			errors.push("newMaxSpect value must be >= 0");

		if (errors.length > 0)
			throw new SFSValidationException("ChangeRoomCapacity request error", errors);
	}

	/**
	 * @internal
	 */
	public function execute(sfs:ISmartFox):Void
	{
		sfso.putInt(KEY_ROOM, room.getId());
		sfso.putInt(KEY_USER_SIZE, newMaxUsers);
		sfso.putInt(KEY_SPEC_SIZE, newMaxSpect);
	}
}
