package sfs3.client.requests;

import sfs3.client.ISmartFox;
import sfs3.client.exceptions.SFSValidationException;
import sfs3.client.entities.Room;

/**
 * Turns the current user from spectator to player in a Game Room.
 * <p/>
 * <p>If the operation is successful, all the users in the target Room are notified with the <em>spectatorToPlayer</em> event.
 * The operation could fail if no player slots are available in the Game Room at the time of the request; in this case
 * the <em>spectatorToPlayerError</em> event is dispatched to the requester's client.</p>
 * <p/>
 * <p/>
 *
 * @see		sfs3.client.core.SFSEvent#SPECTATOR_TO_PLAYER
 * @see		sfs3.client.core.SFSEvent#SPECTATOR_TO_PLAYER_ERROR
 * @see		PlayerToSpectatorRequest
 */
@:expose("SFS3.SpectatorToPlayerRequest")
class SpectatorToPlayerRequest extends BaseRequest 
{
	/**
	 * @internal
	 */
	public static final KEY_ROOM_ID:String = "r";

	/**
	 * @internal
	 */
	public static final KEY_USER_ID:String = "u";

	/**
	 * @internal
	 */
	public static final KEY_PLAYER_ID:String = "p";

	private var room:Room;

	/**
	 * Creates a new <em>SpectatorToPlayerRequest</em> instance.
	 * The instance must be passed to the <em>SmartFox.send()</em> method for the request to be performed.
	 *
	 * @param	targetRoom	The <em>Room</em> object corresponding to the Room in which the spectator should be turned to player. If <code>null</code>, the last Room joined by the user is used.
	 * 
	 * @see		sfs3.client.SmartFox#send
	 * @see		sfs3.client.entities.Room
	 */
	public function new(?targetRoom:Room = null) 
	{
		super(BaseRequest.SpectatorToPlayer);
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
			throw new SFSValidationException("SpectatorToPlayer request error", errors);
	}

	/**
	 * @internal
	 */
	public function execute(sfs:ISmartFox):Void
	{
		sfso.putInt(KEY_ROOM_ID, room.getId());
	}
}
