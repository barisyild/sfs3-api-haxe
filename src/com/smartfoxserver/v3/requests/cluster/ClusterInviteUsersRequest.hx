package com.smartfoxserver.v3.requests.cluster;

import com.smartfoxserver.v3.entities.data.ISFSObject;

import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.exceptions.SFSValidationException;
import com.smartfoxserver.v3.entities.Buddy;
import com.smartfoxserver.v3.entities.User;
import com.smartfoxserver.v3.requests.BaseRequest;

@:expose("SFS3.ClusterInviteUsersRequest")
class ClusterInviteUsersRequest extends BaseRequest
{
	/**
	 * @internal
	 */
	public static final KEY_USER:String = "u";

	/**
	 * @internal
	 */
	public static final KEY_USER_ID:String = "ui";

	/**
	 * @internal
	 */
	public static final KEY_INVITATION_ID:String = "ii";

	/**
	 * @internal
	 */
	public static final KEY_TIME:String = "t";

	/**
	 * @internal
	 */
	public static final KEY_PARAMS:String = "p";

	/**
	 * @internal
	 */
	public static final KEY_INVITEE_ID:String = "ee";

	/**
	 * @internal
	 */
	public static final KEY_INVITED_USERS:String = "iu";
	
	/**
	 * @internal
	 */
	public static final KEY_SERVER_ID:String = "ss";
	
	/**
	 * @internal
	 */
	public static final KEY_ROOM_ID:String = "rr";

	/**
	 * @internal
	 */
	public static final KEY_REPLY_ID:String = "ri";
	
	/**
	 * @internal
	 */
	public static final MAX_INVITATIONS_FROM_CLIENT_SIDE:Int = 8;

	/**
	 * @internal
	 */
	public static final MIN_EXPIRY_TIME:Int = 10;

	/**
	 * @internal
	 */
	public static final MAX_EXPIRY_TIME:Int = 300;
	
	private var invitedUsers:Array<Dynamic>;
	private var secondsForAnswer:Int;
	private var params:ISFSObject;
	private var target:ClusterTarget;
	
	/**
	 * 
	 * @param invitedUsers
	 * @param secondsForAnswer
	 * @param params
	 * @param target
	 */
	public function new(target:ClusterTarget, invitedUsers:Array<Dynamic>, secondsForAnswer:Int, params:ISFSObject)
	{
		super(BaseRequest.ClusterInviteUsers);
		
		this.invitedUsers = invitedUsers;
		this.secondsForAnswer = secondsForAnswer;
		this.params = params;
		this.target = target;
	}
	
	/**
	 * @internal
	 */
	public function validate(sfs:ISmartFox):Void
	{
		var errors = new Array<String>();

		if (invitedUsers == null || invitedUsers.length == 0) 
			errors.push("No invitation(s) to send");

		if (invitedUsers != null && invitedUsers.length > MAX_INVITATIONS_FROM_CLIENT_SIDE)
			errors.push("Too many invitations. Max allowed from client side is: " + MAX_INVITATIONS_FROM_CLIENT_SIDE);

		if (secondsForAnswer < MIN_EXPIRY_TIME || secondsForAnswer > MAX_EXPIRY_TIME) 
			errors.push("SecondsForAnswer value is out of range (" + MIN_EXPIRY_TIME + "-" + MAX_EXPIRY_TIME + ")");

		if (target == null)
			errors.push("Missing Cluster Target (server id and room id)");
		
		if (errors.length > 0) 
			throw new SFSValidationException("ClusterInvitation request error", errors);
	}
	
	/**
	 * @internal
	 */
	public function execute(sfs:ISmartFox):Void
	{
		var invitedUserIds = new Array<Int>();

		// Check items validity, accept any User or Buddy object(s)
		for (item in invitedUsers) 
		{
			if (Std.isOfType(item, User) || Std.isOfType(item, Buddy)) 
			{
				var id:Int;
				if (Std.isOfType(item, User)) 
					id = cast(item, User).getId();
				else 
					id = cast(item, Buddy).getId();
				
				// Can't invite myself!
				if (id == sfs.getMySelf().getId()) 
					continue;
				
				invitedUserIds.push(id);
			}
		}
		
		sfso.putString(KEY_SERVER_ID, target.getServerId());
		sfso.putInt(KEY_ROOM_ID, target.getRoomId());

		// List of invited people
		sfso.putIntArray(KEY_INVITED_USERS, invitedUserIds);

		// Time to answer
		sfso.putShort(KEY_TIME, secondsForAnswer);

		// Custom params
		if (params != null) 
			sfso.putSFSObject(KEY_PARAMS, params);
		
	}
}
