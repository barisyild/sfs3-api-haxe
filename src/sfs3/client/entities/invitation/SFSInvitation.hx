package sfs3.client.entities.invitation;

import sfs3.client.entities.User;
import sfs3.client.entities.data.ISFSObject;

/**
 * The <em>SFSInvitation</em> object contains all the informations about an invitation received by the current user.
 *
 * An invitation is sent through the <em>InviteUsersRequest</em> request and it is received as an <em>invitation</em> event.
 * Clients can reply to an invitation using the <em>InvitationReplyRequest</em> request.
 *
 * @see sfs3.client.requests.invitation.InviteUsersRequest
 * @see sfs3.client.requests.invitation.InvitationReplyRequest
 * @see sfs3.client.core.SFSEvent#INVITATION
 */
class SFSInvitation implements Invitation
{
	/** The id is only used when the Invitation is built from a Server Side Invitation */
	public var id:Int;
	private var inviter:User;
	private var invitee:User;
	private var secondsForAnswer:Int;
	private var parameters:ISFSObject;

	/**
	 * Creates a new <em>SFSInvitation</em> instance.
	 *
	 * @param	inviter				A <em>User</em> object corresponding to the user who sent the invitation.
	 * @param	invitee				A <em>User</em> object corresponding to the user who received the invitation.
	 * @param	secondsForAnswer	The number of seconds available to the invitee to reply to the invitation.
	 * @param	parameters			An instance of <em>SFSObject</em> containing a custom set of parameters representing the invitation details.
	 */
	public function new(inviter:User, invitee:User, secondsForAnswer:Int = 15, ?parameters:ISFSObject)
	{
		this.inviter = inviter;
		this.invitee = invitee;
		this.secondsForAnswer = secondsForAnswer;
		this.parameters = parameters;
	}

	public function getId():Int
		return id;

	public function setId(id:Int):Void
		this.id = id;

	public function getInviter():User
		return inviter;

	public function getInvitee():User
		return invitee;

	public function getSecondsForAnswer():Int
		return secondsForAnswer;

	public function getParams():ISFSObject
		return parameters;

	public function toString():String
		return '[id: $id, from: $inviter, TTA: $secondsForAnswer]';
}
