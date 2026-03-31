package sfs3.client.controllers.system;

import sfs3.client.entities.data.ISFSArray;
import sfs3.client.entities.data.ISFSObject;
import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.io.IResponse;
import sfs3.client.core.EventParam;
import sfs3.client.core.SFSEvent;
import sfs3.client.entities.Room;
import sfs3.client.entities.SFSRoom;
import sfs3.client.requests.FindRoomsRequest;
import sfs3.client.entities.data.PlatformStringMap;

class ResFindRooms extends BaseResponseHandler 
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void 
	{
		var sfso:ISFSObject = resp.getContent();
		var evtParams = new PlatformStringMap<Dynamic>();

		var roomListData:ISFSArray = sfso.getSFSArray(FindRoomsRequest.KEY_FILTERED_ROOMS);
		var roomList = new Array<Room>();

		for (i in 0...roomListData.size()) 
		{
			var theRoom:Room = SFSRoom.fromSFSArray(roomListData.getSFSArray(i));
			var localRoom:Room = sfs.getRoomManager().getRoomById(theRoom.getId());
			
			if (localRoom != null)
				theRoom.setJoined(localRoom.getJoined());
			
			roomList.push(theRoom);
		}

		evtParams.set(EventParam.RoomList, roomList);
		sfs.dispatchEvent(new SFSEvent(SFSEvent.ROOM_FIND_RESULT, evtParams));
	}
}
