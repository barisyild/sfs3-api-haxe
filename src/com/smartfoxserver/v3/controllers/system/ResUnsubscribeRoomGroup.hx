package com.smartfoxserver.v3.controllers.system;

import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.bitswarm.io.IResponse;
import com.smartfoxserver.v3.core.EventParam;
import com.smartfoxserver.v3.core.SFSEvent;
import com.smartfoxserver.v3.requests.BaseRequest;
import com.smartfoxserver.v3.requests.UnsubscribeRoomGroupRequest;
import com.smartfoxserver.v3.util.SFSErrorCodes;

class ResUnsubscribeRoomGroup extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		var sfso:ISFSObject = resp.getContent();
		var evtParams = new Map<String, Dynamic>();

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
