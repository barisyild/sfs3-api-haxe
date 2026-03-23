package com.smartfoxserver.v3.controllers.system;

import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.bitswarm.io.IResponse;
import com.smartfoxserver.v3.core.EventParam;
import com.smartfoxserver.v3.core.SFSEvent;
import com.smartfoxserver.v3.entities.SFSUser;
import com.smartfoxserver.v3.entities.User;
import com.smartfoxserver.v3.entities.invitation.Invitation;
import com.smartfoxserver.v3.entities.invitation.SFSInvitation;
import com.smartfoxserver.v3.requests.invitation.InviteUsersRequest;
import com.smartfoxserver.v3.entities.data.PlatformStringMap;

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
