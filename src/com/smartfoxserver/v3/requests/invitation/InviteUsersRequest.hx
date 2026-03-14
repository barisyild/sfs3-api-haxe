package com.smartfoxserver.v3.requests.invitation;

import com.smartfoxserver.v3.entities.data.ISFSObject;

import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.exceptions.SFSValidationException;
import com.smartfoxserver.v3.entities.Buddy;
import com.smartfoxserver.v3.entities.User;
import com.smartfoxserver.v3.requests.BaseRequest;

/**
 * Sends a generic invitation to a list of users.
 * <p/>
 * <p>
 * Invitations can be used for different purposes, such as requesting users to
 * join a game or visit a specific Room, asking the permission to add them as
 * buddies, etc. Invited users receive the invitation as an <em>invitation</em>
 * event dispatched to their clients: they can accept or refuse it by means of
 * the <em>InvitationReplyRequest</em> request, which must be sent within the
 * specified amount of time.
 * </p>
 * <p/>
 * <p/>
 *
 * @see com.smartfoxserver.v3.core.SFSEvent#INVITATION
 * @see InvitationReplyRequest
 */

@:expose("SFS3.InviteUsersRequest")
class InviteUsersRequest extends BaseRequest
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
	public static final KEY_REPLY_ID:String = "ri";

	/**
	 * @internal
	 */
	public static final MAX_INVITATIONS_FROM_CLIENT_SIDE:Int = 8;

	/**
	 * @internal
	 */
	public static final MIN_EXPIRY_TIME:Int = 5;

	/**
	 * @internal
	 */
	public static final MAX_EXPIRY_TIME:Int = 300;

	private var invitedUsers:Array<Dynamic>;
	private var secondsForAnswer:Int;
	private var params:ISFSObject;

	/**
	 * Creates a new <em>InviteUsersRequest</em> instance. The instance must be
	 * passed to the <em>SmartFox.send()</em> method for the request to be
	 * performed.
	 *
	 * @param invitedUsers     A list of <em>User</em> or <em>Buddy</em> objects representing user to
	 *                         send the invitation to.
	 * @param secondsForAnswer The number of seconds available to each invited user
	 *                         to reply to the invitation (recommended range: 15 to
	 *                         40 seconds).
	 * @param params           An instance of <em>SFSObject</em> containing custom
	 *                         parameters which specify the invitation details.
	 * 
	 * @see com.smartfoxserver.v3.SmartFox#send
	 * @see com.smartfoxserver.v3.entities.User
	 * @see com.smartfoxserver.v3.entities.data.SFSObject
	 */
	public function new(invitedUsers:Array<Dynamic>, secondsForAnswer:Int, ?params:ISFSObject = null)
	{
		super(BaseRequest.InviteUser);

		this.invitedUsers = invitedUsers;
		this.secondsForAnswer = secondsForAnswer;
		this.params = params;
	}

	/**
	 * @internal
	 */
	public function validate(sfs:ISmartFox):Void
	{
		var errors = new Array<String>();

		if (invitedUsers == null || invitedUsers.length == 0)
			errors.push("No invitation to send");

		if (invitedUsers != null && invitedUsers.length > MAX_INVITATIONS_FROM_CLIENT_SIDE)
			errors.push("Too many invitations. Max allowed from client side is: " + MAX_INVITATIONS_FROM_CLIENT_SIDE);

		if (secondsForAnswer < 5 || secondsForAnswer > 300)
			errors.push("SecondsForAnswer value is out of range (" + InviteUsersRequest.MIN_EXPIRY_TIME + "-" + InviteUsersRequest.MAX_EXPIRY_TIME + ")");

		if (errors.length > 0)
			throw new SFSValidationException("InviteUser request error", errors);
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
				var id:Int = -1;
				
				if (Std.isOfType(item, User))
					id = cast(item, User).getId();
				else
					id = cast(item, Buddy).getId();

				// Can't invite myself!
				if (id == sfs.getMySelf().getId())
					continue;

				if (id > -1)
					invitedUserIds.push(id);
			}
		}

		// List of invited people
		sfso.putIntArray(KEY_INVITED_USERS, invitedUserIds);

		// Time to answer
		sfso.putShort(KEY_TIME, secondsForAnswer);

		// Custom params
		if (params != null)
			sfso.putSFSObject(KEY_PARAMS, params);
	}
}
