package sfs3.client.entities.invitation;

/**
 * The <em>InvitationReply</em> class contains the constants describing the possible replies to an invitation.
 *
 * @see sfs3.client.requests.invitation.InvitationReplyRequest
 */
@:expose("SFS3.InvitationReply")
enum abstract InvitationReply(Int) from Int to Int
{
	/** Accept the invitation */
	var ACCEPT = 0;
	/** Refuse the invitation */
	var REFUSE = 1;
	/** Invitation has expired */
	var EXPIRED = 2;

	public inline function getId():Int
		return this;

	public static function fromId(id:Int):InvitationReply
	{
		return switch (id)
		{
			case 0: ACCEPT;
			case 1: REFUSE;
			default: EXPIRED;
		}
	}
}
