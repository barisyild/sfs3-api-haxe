package sfs3.client.requests.mmo;

import sfs3.client.ISmartFox;
import sfs3.client.exceptions.SFSValidationException;
import sfs3.client.entities.MMORoom;
import sfs3.client.entities.Room;
import sfs3.client.entities.data.Vec3D;
import sfs3.client.requests.BaseRequest;

/**
 * Updates the User position inside an MMORoom.
 * 
 * <p>MMORooms represent virtual environments and can host any number of users. Based on their position, the system allows users within a certain range
 * from each other (Area of Interest, or AoI) to interact.
 * This request allows the current user to update his position inside the MMORoom, which in turn will trigger a <em>SFSEvent.PROXIMITY_LIST_UPDATE</em> event
 * for all users that fall within his AoI.</p>
 * 
 * </pre>
 * 
 * @see sfs3.client.core.SFSEvent#PROXIMITY_LIST_UPDATE
 * @see sfs3.client.entities.MMORoom
 * @see sfs3.client.entities.data.Vec3D
 * 
 */
@:expose("SFS3.SetUserPositionRequest")
class SetUserPositionRequest extends BaseRequest
{
	/** <b>API internal usage only</b> */
	public static final KEY_ROOM:String = "r";
	
	/** <b>API internal usage only</b> */
	public static final KEY_VEC3D:String = "v";

	/** <b>API internal usage only</b> */
	public static final KEY_PLUS_USER_LIST:String = "p";
	
	/** <b>API internal usage only</b> */
	public static final KEY_MINUS_USER_LIST:String = "m";
	
	/** <b>API internal usage only</b> */
	public static final KEY_PLUS_ITEM_LIST:String = "q";
	
	/** <b>API internal usage only</b> */
	public static final KEY_MINUS_ITEM_LIST:String = "n";
	
	private var pos:Vec3D<Any>;
	private var room:Room;
	 
	/**
	 * Creates a new <em>SetUserPositionRequest</em> instance.
	 * The instance must be passed to the <em>SmartFox.send()</em> method for the request to be performed.
	 * 
	 * @param	position	The user position.
	 * @param	room		The <em>MMORoom</em> object corresponding to the Room where the position should be set; if <b>null</b>, the last Room joined by the user is used.
	 * 
	 * @see		sfs3.client.SmartFox#send
	 * @see 	sfs3.client.entities.MMORoom
	 * @see     sfs3.client.entities.data.Vec3D
	 */
	public function new(position:Vec3D<Any>, ?room:Room = null)
    {
		super(BaseRequest.SetUserPosition);
		this.pos = position;
		this.room = room;
    }
	
	public function validate(sfs:ISmartFox):Void
	{
		var errors = new Array<String>();
		
		if (pos == null)
			errors.push("Position must be a valid Vec3D ");

		if (room == null)
		{
			var lastJoined = sfs.getLastJoinedRoom();
			if (lastJoined != null && Std.isOfType(lastJoined, MMORoom))
				room = lastJoined;
			else
			{
				errors.push("A valid MMORoom must be provided");
				throw new SFSValidationException("SetUserPosition request error", errors);
			}
		}
		
		if (!Std.isOfType(room, MMORoom))
			errors.push("Passed Room is not an MMORoom");
		
		if (!sfs.getJoinedRooms().contains(room))
			errors.push("You are not joined in the target Room: " + room);
		
		if (errors.length > 0)
			throw new SFSValidationException("SetUserPosition request error", errors);
	}
	
	public function execute(sfs:ISmartFox):Void
	{
		sfso.putInt(KEY_ROOM, room.getId());
		
		if (pos.isFloat())
			sfso.putFloatArray(KEY_VEC3D, pos.toFloatArray());
		
		else 
			sfso.putIntArray(KEY_VEC3D, pos.toIntArray());	    
	}
}
