package com.smartfoxserver.v3.requests;

import com.smartfoxserver.v3.entities.data.ISFSObject;

import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.exceptions.SFSValidationException;
import com.smartfoxserver.v3.entities.Room;
import com.smartfoxserver.v3.entities.match.MatchExpression;

/**
 * <p>
 * Attempts to join the first Room that matches the passed Match Expression or creates a new Room with the settings provided.
 * <p/>
 * <p>If the creation is successful, a <em>ROOM_ADD</em> event is dispatched to all the users who subscribed the relative Room Group, including the owner.
 * Otherwise, a <em>roomCreationError</em> event is returned to the caller.</p>
 * <p/>
 * <p>Also a <em>ROOM_JOIN</em> is received upon either joining the Room found via Match Expression or the new Room just created.</p>
 * 
 *
 * @see		com.smartfoxserver.v3.core.SFSEvent#ROOM_JOIN
 * @see 	com.smartfoxserver.v3.core.SFSEvent#ROOM_JOIN_ERROR
 * @see		com.smartfoxserver.v3.core.SFSEvent#ROOM_ADD
 * @see		com.smartfoxserver.v3.core.SFSEvent#ROOM_CREATION_ERROR
 * 
 */
class QuickJoinOrCreateRoomRequest extends BaseRequest 
{
	/**
	 * @internal
	 */
	public static final KEY_MATCH_EXPRESSION:String = "me";
	
	/**
	 * @internal
	 */
	public static final KEY_GROUP_LIST:String = "gl";

	/**
	 * @internal
	 */
	public static final KEY_ROOM_SETTINGS:String = "rs";
	
	/**
	 * @internal
	 */
	public static final KEY_ROOM_TO_LEAVE:String = "tl";

	// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	
	private var exp:MatchExpression;
	private var groupList:Array<String>;
	private var settings:RoomSettings;
	private var roomToLeave:Room;
	private var createRoomRequest:CreateRoomRequest;
	
	public function new(exp:MatchExpression, groupList:Array<String>, settings:RoomSettings, ?roomToLeave:Room = null)
	{
		super(BaseRequest.QuickJoinOrCreateRoom);
		
		this.exp = exp;
		this.groupList = groupList;
		this.settings = settings;
		this.roomToLeave = roomToLeave;
		
		createRoomRequest = new CreateRoomRequest(settings, false, null);
	}
	
	public function validate(sfs:ISmartFox):Void
	{
		var errors = new Array<String>();
		 
		if (exp == null)
			errors.push("Missing MatchExpression parameter");
		 
		if (groupList == null)
			errors.push("List of groups to search is null");
		 
		if (groupList != null && groupList.length == 0)
			errors.push("Empty list of groups to search");
		 
		if (settings == null)
			errors.push("No Room settings provided");
		 
		// Validate the Room Settings
		try 
		{
			createRoomRequest.validate(sfs);
		}
		catch (err:SFSValidationException) 
		{
            for (e in err.getErrors()) {
			    errors.push(e);
            }
		}
		
		if (errors.length > 0) 
			throw new SFSValidationException("QuickJoinOrCreateRoom request error", errors);
	}
	 
	public function execute(sfs:ISmartFox):Void
	{
		// Execute the CreateRoom logic 
		createRoomRequest.execute(sfs);
		
		//createRoomRequest.getMessage().getContent();
		var roomSettings:ISFSObject = cast createRoomRequest.getRequest().getContent(); 
		
		// Populate the data needed by the server
		sfso.putSFSArray(KEY_MATCH_EXPRESSION, exp.toSFSArray());
		sfso.putStringArray(KEY_GROUP_LIST, groupList);
		sfso.putSFSObject(KEY_ROOM_SETTINGS, roomSettings);
		
		if (roomToLeave != null)
			sfso.putInt(KEY_ROOM_TO_LEAVE, roomToLeave.getId());
	}
}
