package sfs3.client.requests;

import sfs3.client.ISmartFox;
import sfs3.client.exceptions.SFSValidationException;

/**
 * Subscribes the current user to Room-related events occurring in the specified Group.
 * This allows the user to be notified of specific Room events even if he didn't join the Room from which the events originated, provided the Room belongs to the subscribed Group.
 * <p/>
 * <p>If the subscription operation is successful, the current user receives a <em>roomGroupSubscribe</em> event; otherwise the <em>roomGroupSubscribeError</em> event is fired.</p>
 * <p/>
 * <p/>
 *
 * @see		sfs3.client.core.SFSEvent#ROOM_GROUP_SUBSCRIBE
 * @see		sfs3.client.core.SFSEvent#ROOM_GROUP_SUBSCRIBE_ERROR
 * @see		UnsubscribeRoomGroupRequest
 */
@:expose("SFS3.SubscribeRoomGroupRequest")
class SubscribeRoomGroupRequest extends BaseRequest 
{
	/**
	 * @internal
	 */
	public static final KEY_GROUP_ID:String = "g";

	/**
	 * @internal
	 */
	public static final KEY_ROOM_LIST:String = "rl";

	private var groupId:String;

	/**
	 * Creates a new <em>SubscribeRoomGroupRequest</em> instance.
	 * The instance must be passed to the <em>SmartFox.send()</em> method for the request to be performed.
	 *
	 * @param	groupId	The name of the Room Group to subscribe.
	 * 
	 * @see		sfs3.client.SmartFox#send
	 * @see		sfs3.client.entities.Room#getGroupId()
	 */
	public function new(groupId:String) 
	{
		super(BaseRequest.SubscribeRoomGroup);
		this.groupId = groupId;
	}

	/**
	 * @internal
	 */
	public function validate(sfs:ISmartFox):Void
	{
		var errors = new Array<String>();

		// no validation needed
		if (groupId == null || groupId.length == 0)
			errors.push("Null or empty string is not a valid groupId");

		if (errors.length > 0) 
			throw new SFSValidationException("SubscribeGroup request error", errors);
	}

	/**
	 * @internal
	 */
	public function execute(sfs:ISmartFox):Void
	{
		sfso.putString(KEY_GROUP_ID, groupId);
	}
}
