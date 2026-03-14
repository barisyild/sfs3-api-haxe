package com.smartfoxserver.v3.requests.invitation;

import com.smartfoxserver.v3.entities.data.ISFSObject;

import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.exceptions.SFSValidationException;
import com.smartfoxserver.v3.entities.invitation.Invitation;
import com.smartfoxserver.v3.entities.invitation.InvitationReply;
import com.smartfoxserver.v3.requests.BaseRequest;

/**
 * Replies to an invitation received by the current user.
 * <p/>
 * <p>
 * Users who receive an invitation sent by means of the
 * <em>InviteUsersRequest</em> request can either accept or refuse it using this
 * request. The reply causes an <em>invitationReply</em> event to be dispatched
 * to the inviter; if a reply is not sent, or it is sent after the invitation
 * expiration, the system will react as if the invitation was refused.
 * </p>
 * <p>
 * If an error occurs while the reply is delivered to the inviter user (for
 * example the invitation is already expired), an <em>invitationReplyError</em>
 * event is returned to the current user.
 * </p>
 *
 * @see com.smartfoxserver.v3.core.SFSEvent#INVITATION_REPLY
 * @see com.smartfoxserver.v3.core.SFSEvent#INVITATION_REPLY_ERROR
 * @see InviteUsersRequest
 */

@:expose("SFS3.InvitationReplyRequest")
class InvitationReplyRequest extends BaseRequest
{
	/**
	 * @internal
	 */
	public static final KEY_INVITATION_ID:String = "i";

	/**
	 * @internal
	 */
	public static final KEY_INVITATION_REPLY:String = "r";

	/**
	 * @internal
	 */
	public static final KEY_INVITATION_PARAMS:String = "p";

	private var invitation:Invitation;
	private var reply:Int;
	private var params:ISFSObject;

	/**
	 * Creates a new <em>InvitationReplyRequest</em> instance. The instance must be
	 * passed to the <em>SmartFox.send()</em> method for the request to be
	 * performed.
	 *
	 * @param invitation      An instance of the <em>Invitation</em> class
	 *                        containing the invitation details (inviter, custom
	 *                        parameters, etc).
	 * @param invitationReply The answer to be sent to the inviter, among those
	 *                        available as constants in the <em>InvitationReply</em>
	 *                        class.
	 * @param params          An instance of <em>SFSObject</em> containing custom
	 *                        parameters to be returned to the inviter together with
	 *                        the reply (for example a message describing the reason
	 *                        of refusal).
	 * 
	 * @see com.smartfoxserver.v3.SmartFox#send
	 * @see com.smartfoxserver.v3.entities.invitation.InvitationReply
	 * @see com.smartfoxserver.v3.entities.data.SFSObject
	 */
	public function new(invitation:Invitation, invitationReply:InvitationReply, ?params:ISFSObject = null)
	{
		super(BaseRequest.InvitationReply);
		this.invitation = invitation;
		reply = invitationReply;
		this.params = params;
	}

	/**
	 * @internal
	 */
	public function validate(sfs:ISmartFox):Void
	{
		var errors = new Array<String>();

		if (invitation == null)
			errors.push("Missing invitation object");

		if (errors.length > 0)
			throw new SFSValidationException("InvitationReply request error", errors);
	}

	/**
	 * @internal
	 */
	public function execute(sfs:ISmartFox):Void
	{
		sfso.putInt(KEY_INVITATION_ID, invitation.getId());
		sfso.putByte(KEY_INVITATION_REPLY, reply);

		if (params != null)
		{
			sfso.putSFSObject(KEY_INVITATION_PARAMS, params);
		}
	}
}
