package com.smartfoxserver.v3.requests;

import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.exceptions.SFSValidationException;

/**
 * Unsubscribes the current user to Room-related events occurring in the specified Group.
 * This allows the user to stop being notified of specific Room events occurring in Rooms belonging to the unsubscribed Group.
 * <p/>
 * <p>If the operation is successful, the current user receives a <em>roomGroupUnsubscribe</em> event; otherwise the <em>roomGroupUnsubscribeError</em> event is fired.</p>
 * <p/>
 * <p/>
 *
 * @see		com.smartfoxserver.v3.core.SFSEvent#ROOM_GROUP_UNSUBSCRIBE
 * @see		com.smartfoxserver.v3.core.SFSEvent#ROOM_GROUP_UNSUBSCRIBE_ERROR
 * @see		SubscribeRoomGroupRequest
 */
@:expose("SFS3.UnsubscribeRoomGroupRequest")
class UnsubscribeRoomGroupRequest extends BaseRequest 
{

	/**
	 * @internal
	 */
	public static final KEY_GROUP_ID:String = "g";

	private var groupId:String;

	/**
	 * Creates a new <em>UnsubscribeRoomGroupRequest</em> instance.
	 * The instance must be passed to the <em>SmartFox.send()</em> method for the request to be performed.
	 *
	 * @param	groupId	The name of the Room Group to unsubscribe.
	 * 
	 * @see		com.smartfoxserver.v3.SmartFox#send
	 * @see		com.smartfoxserver.v3.entities.Room#getGroupId()
	 */
	public function new(groupId:String) 
	{
		super(BaseRequest.UnsubscribeRoomGroup);
		this.groupId = groupId;
	}

	/**
	 * @internal
	 */
	public function validate(sfs:ISmartFox):Void
	{
		var errors = new Array<String>();

		if (groupId == null || groupId.length == 0)
			errors.push("Null or empty string is not a valid groupId");

		if (errors.length > 0) 
			throw new SFSValidationException("UnsubscribeGroup request error", errors);
	}

	/**
	 * @internal
	 */
	public function execute(sfs:ISmartFox):Void
	{
		sfso.putString(KEY_GROUP_ID, groupId);
	}
}
