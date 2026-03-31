package sfs3.client.controllers.system;

import sfs3.client.entities.data.ISFSObject;
import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.io.IResponse;
import sfs3.client.core.EventParam;
import sfs3.client.core.SFSEvent;
import sfs3.client.requests.BaseRequest;
import sfs3.client.requests.UnsubscribeRoomGroupRequest;
import sfs3.client.util.SFSErrorCodes;
import sfs3.client.entities.data.PlatformStringMap;

class ResUnsubscribeRoomGroup extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		var sfso:ISFSObject = resp.getContent();
		var evtParams = new PlatformStringMap<Dynamic>();

		// ::: SUCCESS
		if (!sfso.containsKey(BaseRequest.KEY_ERROR_CODE))
		{
			var groupId:String = sfso.getString(UnsubscribeRoomGroupRequest.KEY_GROUP_ID);
			
			// Integrity Check
			if (!sfs.getRoomManager().containsGroup(groupId))
				log.warn("UnsubscribeGroup error. Group: " + groupId + "is not subscribed");

			sfs.getRoomManager().removeGroup(groupId);

			// Pass the groupId
			evtParams.set(EventParam.GroupId, groupId);
			sfs.dispatchEvent(new SFSEvent(SFSEvent.ROOM_GROUP_UNSUBSCRIBE, evtParams));
		}

		// ::: FAILURE
		else
		{
			var errorCode:Int = sfso.getShort(BaseRequest.KEY_ERROR_CODE);
			var errorMsg:String = SFSErrorCodes.getErrorMessage(errorCode, sfso.getStringArray(BaseRequest.KEY_ERROR_PARAMS));
			evtParams.set(EventParam.ErrorMessage, errorMsg);
			evtParams.set(EventParam.ErrorCode, errorCode);

			sfs.dispatchEvent(new SFSEvent(SFSEvent.ROOM_GROUP_UNSUBSCRIBE_ERROR, evtParams));
		}
	}
}
