package com.smartfoxserver.v3.requests;

import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.exceptions.SFSValidationException;
import com.smartfoxserver.v3.entities.Room;

/**
 * Turns the current user from player to spectator in a Game Room.
 * <p/>
 * <p>If the operation is successful, all the users in the target Room are notified with the <em>playerToSpectator</em> event.
 * The operation could fail if no spectator slots are available in the Game Room at the time of the request; in this case
 * the <em>playerToSpectatorError</em> event is dispatched to the requester's client.</p>
 * <p/>
 * <p/>
 *
 * @see 	com.smartfoxserver.v3.core.SFSEvent#PLAYER_TO_SPECTATOR
 * @see 	com.smartfoxserver.v3.core.SFSEvent#PLAYER_TO_SPECTATOR_ERROR
 * @see		SpectatorToPlayerRequest
 */
@:expose("SFS3.PlayerToSpectatorRequest")
class PlayerToSpectatorRequest extends BaseRequest 
{
	/**
	 * @internal
	 */
	public static final KEY_ROOM_ID:String = "r";

	/**
	 * @internal
	 */
	public static final KEY_USER_ID:String = "u";

	private var room:Room;


	/**
	 * Creates a new <em>PlayerToSpectatorRequest</em> instance.
	 * The instance must be passed to the <em>SmartFox.send()</em> method for the request to be performed.
	 *
	 * @param	targetRoom	The <em>Room</em> object corresponding to the Room in which the player should be turned to spectator. If <code>null</code>, the last Room joined by the user is used.
	 * 
	 * @see		com.smartfoxserver.v3.SmartFox#send
	 * @see		com.smartfoxserver.v3.entities.Room
	 */
	public function new(?targetRoom:Room = null) 
	{
		super(BaseRequest.PlayerToSpectator);
		room = targetRoom;
	}

	/**
	 * @internal
	 */
	public function validate(sfs:ISmartFox):Void
	{
		var errors = new Array<String>();
		
		if (room == null)
		{
			if (sfs.getLastJoinedRoom() != null)
				room = sfs.getLastJoinedRoom();
			else
			{
				errors.push("A valid Room must be provided");
				return;
			}
		}

		if (!sfs.getJoinedRooms().contains(room))
			errors.push("You are not joined in the target Room: " + room.getName());
		
		if (errors.length > 0)
			throw new SFSValidationException("PlayerToSpecator request error", errors);
	}

	/**
	 * @internal
	 */
	public function execute(sfs:ISmartFox):Void
	{
		sfso.putInt(KEY_ROOM_ID, room.getId());
	}
}
