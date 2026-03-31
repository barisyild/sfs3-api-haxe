package sfs3.client.controllers.system;

import sfs3.client.entities.data.ISFSObject;
import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.io.IResponse;
import sfs3.client.core.EventParam;
import sfs3.client.core.SFSEvent;
import sfs3.client.entities.SFSUser;
import sfs3.client.entities.User;
import sfs3.client.entities.invitation.Invitation;
import sfs3.client.entities.invitation.SFSInvitation;
import sfs3.client.requests.invitation.InviteUsersRequest;
import sfs3.client.entities.data.PlatformStringMap;

class ResInviteUsers extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		var sfso:ISFSObject = resp.getContent();
		var evtParams = new PlatformStringMap<Dynamic>();
		var inviter:User = null;

		if (sfso.containsKey(InviteUsersRequest.KEY_USER_ID))
			inviter = sfs.getUserManager().getUserById(sfso.getInt(InviteUsersRequest.KEY_USER_ID));
		else
			inviter = SFSUser.fromSFSArray(sfso.getSFSArray(InviteUsersRequest.KEY_USER));

		var expiryTime:Int = sfso.getShort(InviteUsersRequest.KEY_TIME);
		var invitationId:Int = sfso.getInt(InviteUsersRequest.KEY_INVITATION_ID);
		var invParams:ISFSObject = sfso.getSFSObject(InviteUsersRequest.KEY_PARAMS);
		var invitation:Invitation = new SFSInvitation(inviter, sfs.getMySelf(), expiryTime, invParams);
		invitation.setId(invitationId);

		evtParams.set(EventParam.Invitation, invitation);
		sfs.dispatchEvent(new SFSEvent(SFSEvent.INVITATION, evtParams));
	}
}
