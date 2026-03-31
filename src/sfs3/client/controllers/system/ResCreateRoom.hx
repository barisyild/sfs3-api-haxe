package sfs3.client.controllers.system;

import sfs3.client.entities.data.ISFSObject;
import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.io.IResponse;
import sfs3.client.core.EventParam;
import sfs3.client.core.SFSEvent;
import sfs3.client.entities.Room;
import sfs3.client.entities.SFSRoom;
import sfs3.client.entities.managers.IRoomManager;
import sfs3.client.requests.BaseRequest;
import sfs3.client.requests.CreateRoomRequest;
import sfs3.client.util.SFSErrorCodes;
import sfs3.client.entities.data.PlatformStringMap;

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
