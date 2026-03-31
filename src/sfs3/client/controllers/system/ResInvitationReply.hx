package sfs3.client.controllers.system;

import sfs3.client.entities.data.ISFSObject;
import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.io.IResponse;
import sfs3.client.core.EventParam;
import sfs3.client.core.SFSEvent;
import sfs3.client.entities.SFSUser;
import sfs3.client.entities.User;
import sfs3.client.entities.invitation.InvitationReply;
import sfs3.client.requests.BaseRequest;
import sfs3.client.requests.invitation.InviteUsersRequest;
import sfs3.client.util.SFSErrorCodes;
import sfs3.client.entities.data.PlatformStringMap;

class ResInvitationReply extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		var sfso:ISFSObject = resp.getContent();
		var evtParams = new PlatformStringMap<Dynamic>();

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
