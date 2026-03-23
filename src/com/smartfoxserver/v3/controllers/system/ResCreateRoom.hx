package com.smartfoxserver.v3.controllers.system;

import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.bitswarm.io.IResponse;
import com.smartfoxserver.v3.core.EventParam;
import com.smartfoxserver.v3.core.SFSEvent;
import com.smartfoxserver.v3.entities.Room;
import com.smartfoxserver.v3.entities.SFSRoom;
import com.smartfoxserver.v3.entities.managers.IRoomManager;
import com.smartfoxserver.v3.requests.BaseRequest;
import com.smartfoxserver.v3.requests.CreateRoomRequest;
import com.smartfoxserver.v3.util.SFSErrorCodes;
import com.smartfoxserver.v3.entities.data.PlatformStringMap;

class ResCreateRoom extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		var sfso:ISFSObject = resp.getContent();
		var evtParams = new PlatformStringMap<Dynamic>();

		// Success
		if (!sfso.containsKey(BaseRequest.KEY_ERROR_CODE))
		{
			var roomManager:IRoomManager = sfs.getRoomManager();
			var newRoom:Room = SFSRoom.fromSFSArray(sfso.getSFSArray(CreateRoomRequest.KEY_ROOM));
			newRoom.setRoomManager(sfs.getRoomManager());

			// Add room to room manager
			roomManager.addRoom(newRoom);

			evtParams.set(EventParam.Room, newRoom);
			sfs.dispatchEvent(new SFSEvent(SFSEvent.ROOM_ADD, evtParams));
		}

		// Failure
		else
		{
			var errorCode:Int = sfso.getShort(BaseRequest.KEY_ERROR_CODE);
			var errorMsg:String = SFSErrorCodes.getErrorMessage(errorCode, sfso.getStringArray(BaseRequest.KEY_ERROR_PARAMS));
			
			evtParams.set(EventParam.ErrorMessage, errorMsg);
			evtParams.set(EventParam.ErrorCode, errorCode);
			
			sfs.dispatchEvent(new SFSEvent(SFSEvent.ROOM_CREATION_ERROR, evtParams));
		}
	}
}
