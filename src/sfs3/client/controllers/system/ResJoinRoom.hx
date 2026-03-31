package sfs3.client.controllers.system;

import sfs3.client.entities.data.ISFSArray;
import sfs3.client.entities.data.ISFSObject;
import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.io.IResponse;
import sfs3.client.core.EventParam;
import sfs3.client.core.SFSEvent;
import sfs3.client.entities.Room;
import sfs3.client.entities.SFSRoom;
import sfs3.client.entities.User;
import sfs3.client.entities.managers.IRoomManager;
import sfs3.client.entities.managers.SFSGlobalUserManager;
import sfs3.client.requests.BaseRequest;
import sfs3.client.requests.JoinRoomRequest;
import sfs3.client.util.SFSErrorCodes;
import sfs3.client.entities.data.PlatformStringMap;

class ResJoinRoom extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		var roomManager:IRoomManager = sfs.getRoomManager();
		var userManager:SFSGlobalUserManager = cast sfs.getUserManager();
		
		var sfso:ISFSObject = resp.getContent();
		var evtParams = new PlatformStringMap<Dynamic>();

		// set flag off
		sfs.setJoining(false);

		// Success
		if (!sfso.containsKey(BaseRequest.KEY_ERROR_CODE))
		{
			var roomObj:ISFSArray = sfso.getSFSArray(JoinRoomRequest.KEY_ROOM);
			var userList:ISFSArray = sfso.getSFSArray(JoinRoomRequest.KEY_USER_LIST);

			// Get the joined Room data
			var room:Room = SFSRoom.fromSFSArray(roomObj);
			room.setRoomManager(sfs.getRoomManager());

			roomManager.addRoom(room, roomManager.containsGroup(room.getGroupId()));
			
			// Populate room's user list
			for (j in 0...userList.size())
			{
				var userObj:ISFSArray = userList.getSFSArray(j);
				var userInRoom:User = userManager.getOrCreateUser(userObj, room);
				room.addUser(userInRoom);
			}

			// Set as joined
			room.setJoined(true);

			// Set as the last joined Room
			sfs.setLastJoinedRoom(room);

			evtParams.set(EventParam.Room, room);
			sfs.dispatchEvent(new SFSEvent(SFSEvent.ROOM_JOIN, evtParams));
		}
		
		// Failure
		else
		{
			var errorCode:Int = sfso.getShort(BaseRequest.KEY_ERROR_CODE);
			var errorMsg:String = SFSErrorCodes.getErrorMessage(errorCode, sfso.getStringArray(BaseRequest.KEY_ERROR_PARAMS));
			evtParams.set(EventParam.ErrorMessage, errorMsg);
			evtParams.set(EventParam.ErrorCode, errorCode);

			sfs.dispatchEvent(new SFSEvent(SFSEvent.ROOM_JOIN_ERROR, evtParams));
		}
	}
}
