package com.smartfoxserver.v3.controllers.system;

import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.bitswarm.io.IResponse;
import com.smartfoxserver.v3.core.EventParam;
import com.smartfoxserver.v3.core.SFSEvent;
import com.smartfoxserver.v3.entities.Room;
import com.smartfoxserver.v3.requests.BaseRequest;
import com.smartfoxserver.v3.requests.ChangeRoomCapacityRequest;
import com.smartfoxserver.v3.util.SFSErrorCodes;

class ResChangeRoomCapacity extends BaseResponseHandler
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
			// Obtain the target Room
			var roomId:Int = sfso.getInt(ChangeRoomCapacityRequest.KEY_ROOM);
			var targetRoom:Room = sfs.getRoomManager().getRoomById(roomId);

			if (targetRoom != null)
			{
				sfs.getRoomManager().changeRoomCapacity(targetRoom,
						sfso.getInt(ChangeRoomCapacityRequest.KEY_USER_SIZE),
						sfso.getInt(ChangeRoomCapacityRequest.KEY_SPEC_SIZE));

				evtParams.set(EventParam.Room, targetRoom);
				sfs.dispatchEvent(new SFSEvent(SFSEvent.ROOM_CAPACITY_CHANGE, evtParams));
			} 
			
			else
				log.warn("Room not found, ID:" + roomId + ", Room capacity change failed.");
		}

		// ::: FAILURE
		else
		{
			var errorCode:Int = sfso.getShort(BaseRequest.KEY_ERROR_CODE);
			var errorMsg:String = SFSErrorCodes.getErrorMessage(errorCode, sfso.getStringArray(BaseRequest.KEY_ERROR_PARAMS));
			
			evtParams.set(EventParam.ErrorMessage, errorMsg);
			evtParams.set(EventParam.ErrorCode, errorCode);

			sfs.dispatchEvent(new SFSEvent(SFSEvent.ROOM_CAPACITY_CHANGE_ERROR, evtParams));
		}
	}
}
