package sfs3.client.controllers.system;

import sfs3.client.entities.data.ISFSObject;
import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.io.IResponse;
import sfs3.client.core.EventParam;
import sfs3.client.core.SFSEvent;
import sfs3.client.entities.Room;
import sfs3.client.requests.BaseRequest;
import sfs3.client.requests.ChangeRoomPasswordStateRequest;
import sfs3.client.util.SFSErrorCodes;
import sfs3.client.entities.data.PlatformStringMap;

class ResChangeRoomPassword extends BaseResponseHandler
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
			// Obtain the target Room
			var roomId:Int = sfso.getInt(ChangeRoomPasswordStateRequest.KEY_ROOM);
			var targetRoom:Room = sfs.getRoomManager().getRoomById(roomId);

			if (targetRoom != null)
			{
				sfs.getRoomManager().changeRoomPasswordState(targetRoom, sfso.getBool(ChangeRoomPasswordStateRequest.KEY_PASS));
				evtParams.set(EventParam.Room, targetRoom);
				sfs.dispatchEvent(new SFSEvent(SFSEvent.ROOM_PASSWORD_STATE_CHANGE, evtParams));
			} 
			
			else
				log.warn("Room not found, ID:" + roomId + ", Room password change failed.");
		}

		// ::: FAILURE
		else
		{
			var errorCode:Int = sfso.getShort(BaseRequest.KEY_ERROR_CODE);
			var errorMsg:String = SFSErrorCodes.getErrorMessage(errorCode, sfso.getStringArray(BaseRequest.KEY_ERROR_PARAMS));

			evtParams.set(EventParam.ErrorMessage, errorMsg);
			evtParams.set(EventParam.ErrorCode, errorCode);

			sfs.dispatchEvent(new SFSEvent(SFSEvent.ROOM_PASSWORD_STATE_CHANGE_ERROR, evtParams));
		}
	}
}
