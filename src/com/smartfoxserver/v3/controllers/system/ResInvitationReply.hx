package com.smartfoxserver.v3.controllers.system;

import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.bitswarm.io.IResponse;
import com.smartfoxserver.v3.core.EventParam;
import com.smartfoxserver.v3.core.SFSEvent;
import com.smartfoxserver.v3.entities.SFSUser;
import com.smartfoxserver.v3.entities.User;
import com.smartfoxserver.v3.entities.invitation.InvitationReply;
import com.smartfoxserver.v3.requests.BaseRequest;
import com.smartfoxserver.v3.requests.invitation.InviteUsersRequest;
import com.smartfoxserver.v3.util.SFSErrorCodes;

class ResInvitationReply extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		var sfso:ISFSObject = resp.getContent();
		var evtParams = new Map<String, Dynamic>();

		// ::: SUCCESS :::
		if (!sfso.containsKey(BaseRequest.KEY_ERROR_CODE))
		{
			var invitee:User = null;

			if (sfso.containsKey(InviteUsersRequest.KEY_USER_ID))
				invitee = sfs.getUserManager().getUserById(sfso.getInt(InviteUsersRequest.KEY_USER_ID));
			else
				invitee = SFSUser.fromSFSArray(sfso.getSFSArray(InviteUsersRequest.KEY_USER));

			var reply:Int = sfso.getByte(InviteUsersRequest.KEY_REPLY_ID);
			var data:ISFSObject = sfso.getSFSObject(InviteUsersRequest.KEY_PARAMS);

			evtParams.set(EventParam.Invitee, invitee);
			evtParams.set(EventParam.Reply, InvitationReply.fromId(reply));
			evtParams.set(EventParam.Data, data);

			sfs.dispatchEvent(new SFSEvent(SFSEvent.INVITATION_REPLY, evtParams));
		}

		// ::: FAILURE :::
		else
		{
			var errorCode:Int = sfso.getShort(BaseRequest.KEY_ERROR_CODE);
			var errorMsg:String = SFSErrorCodes.getErrorMessage(errorCode, sfso.getStringArray(BaseRequest.KEY_ERROR_PARAMS));
			evtParams.set(EventParam.ErrorMessage, errorMsg);
			evtParams.set(EventParam.ErrorCode, errorCode);

			sfs.dispatchEvent(new SFSEvent(SFSEvent.INVITATION_REPLY_ERROR, evtParams));
		}
	}
}
