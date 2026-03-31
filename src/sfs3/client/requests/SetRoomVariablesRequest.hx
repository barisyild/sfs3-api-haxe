package sfs3.client.requests;

import sfs3.client.entities.data.ISFSArray;
import sfs3.client.entities.data.SFSArray;

import sfs3.client.ISmartFox;
import sfs3.client.exceptions.SFSValidationException;
import sfs3.client.entities.Room;
import sfs3.client.entities.variables.RoomVariable;

/**
 * Sets one or more custom Room Variables in a Room.
 * <p/>
 * <p>When a Room Variable is set, the <em>roomVariablesUpdate</em> event is dispatched to all the users in the target Room, including the user who updated it.
 * Also, if the Room Variable is global (see the <em>SFSRoomVariable</em> class description), the event is dispatched to all users who subscribed the Group to which the target Room is associated.</p>
 * <p/>
 * <p/>
 *
 * @see		sfs3.client.core.SFSEvent#ROOM_VARIABLES_UPDATE
 * @see		sfs3.client.entities.variables.SFSRoomVariable
 */
@:expose("SFS3.SetRoomVariablesRequest")
class SetRoomVariablesRequest extends BaseRequest 
{
	/**
	 * @internal
	 */
	public static final KEY_VAR_ROOM:String = "r";

	/**
	 * @internal
	 */
	public static final KEY_VAR_LIST:String = "vl";

	private var roomVariables:Array<RoomVariable>;
	private var room:Room;

	/**
	 * Creates a new <em>SetRoomVariablesRequest</em> instance.
	 * The instance must be passed to the <em>SmartFox.send()</em> method for the request to be performed.
	 *
	 * @param	roomVariables	A list of <em>RoomVariable</em> objects representing the Room Variables to be set.
	 * @param	room			A <em>Room</em> object representing the Room where to set the Room Variables; if <code>null</code>, the last Room joined by the current user is used.
	 * 
	 * @see		sfs3.client.SmartFox#send
	 * @see		sfs3.client.entities.variables.RoomVariable
	 * @see		sfs3.client.entities.Room
	 */
	public function new(roomVariables:Array<RoomVariable>, ?room:Room = null) 
	{
		super(BaseRequest.SetRoomVariables);

		this.roomVariables = roomVariables;
		this.room = room;
	}

	/**
	 * @internal
	 */
	public function validate(sfs:ISmartFox):Void
	{
		var errors = new Array<String>();

		// Make sure that the user is joined in the room where variables are going to be set
		if (room != null && !room.getJoined())
			errors.push("You are not joined in the target room: " + room.getName());
		
		else if (sfs.getLastJoinedRoom() == null) 
			errors.push("You are not joined in any rooms");

		if (roomVariables == null || roomVariables.length == 0) 
			errors.push("No variables were specified");

		if (errors.length > 0) 
			throw new SFSValidationException("SetRoomVariables request error", errors);
	}

	/**
	 * @internal
	 */
	public function execute(sfs:ISmartFox):Void
	{
		var varList:ISFSArray = new SFSArray();

		for (rv in roomVariables) {
			varList.addSFSArray(rv.toSFSArray());
		}

		if (room == null) 
			room = sfs.getLastJoinedRoom();

		sfso.putSFSArray(KEY_VAR_LIST, varList);
		sfso.putInt(KEY_VAR_ROOM, room.getId());
	}
}
