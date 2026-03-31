package sfs3.client.controllers.system;

import sfs3.client.entities.data.ISFSArray;
import sfs3.client.entities.data.ISFSObject;
import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.io.IResponse;
import sfs3.client.core.EventParam;
import sfs3.client.core.SFSEvent;
import sfs3.client.requests.BaseRequest;
import sfs3.client.requests.SubscribeRoomGroupRequest;
import sfs3.client.util.SFSErrorCodes;
import sfs3.client.entities.data.PlatformStringMap;

class ResSubscribeRoomGroup extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		var sfso:ISFSObject = resp.getContent();
		var evtParams = new PlatformStringMap<Dynamic>();

		// ::: Success ::::::::::::::::::::::::::::::::::::::::::::::::
		if (!sfso.containsKey(BaseRequest.KEY_ERROR_CODE))
		{
			var groupId:String = sfso.getString(SubscribeRoomGroupRequest.KEY_GROUP_ID);

			// Integrity Check
			if (sfs.getRoomManager().containsGroup(groupId))
				log.warn("SubscribeGroup Error. Group:" + groupId + "already subscribed!");

			// Add subscribed group
			sfs.getRoomManager().addGroup(groupId);

			// Update global room list
			var roomListData:ISFSArray = sfso.getSFSArray(SubscribeRoomGroupRequest.KEY_ROOM_LIST);
			sfs.getRoomManager().updateRoomList(roomListData);

			// Pass the groupId
			evtParams.set(EventParam.GroupId, groupId);

			// Pass the new rooms that are present in the subscribed group
			evtParams.set(EventParam.NewRooms, sfs.getRoomManager().getRoomListFromGroup(groupId));

			sfs.dispatchEvent(new SFSEvent(SFSEvent.ROOM_GROUP_SUBSCRIBE, evtParams));
		}

		// ::: Failure :::::::::::::::::::::::::::::::::::::::::::::::::::::
		else
		{
			var errorCode:Int = sfso.getShort(BaseRequest.KEY_ERROR_CODE);
			var errorMsg:String = SFSErrorCodes.getErrorMessage(errorCode, sfso.getStringArray(BaseRequest.KEY_ERROR_PARAMS));
			evtParams.set(EventParam.ErrorMessage, errorMsg);
			evtParams.set(EventParam.ErrorCode, errorCode);

			sfs.dispatchEvent(new SFSEvent(SFSEvent.ROOM_GROUP_SUBSCRIBE_ERROR, evtParams));
		}
	}
}
