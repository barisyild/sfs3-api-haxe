package com.smartfoxserver.v3.entities.invitation;

/**
 * The <em>InvitationReply</em> class contains the constants describing the possible replies to an invitation.
 *
 * @see com.smartfoxserver.v3.requests.invitation.InvitationReplyRequest
 */
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
