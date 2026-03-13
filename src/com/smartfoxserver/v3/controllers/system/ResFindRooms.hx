package com.smartfoxserver.v3.controllers.system;

import com.smartfoxserver.v3.entities.data.ISFSArray;
import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.bitswarm.io.IResponse;
import com.smartfoxserver.v3.core.EventParam;
import com.smartfoxserver.v3.core.SFSEvent;
import com.smartfoxserver.v3.entities.Room;
import com.smartfoxserver.v3.entities.SFSRoom;
import com.smartfoxserver.v3.requests.FindRoomsRequest;

class ResFindRooms extends BaseResponseHandler 
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void 
	{
		var sfso:ISFSObject = resp.getContent();
		var evtParams = new Map<String, Dynamic>();

		var roomListData:ISFSArray = sfso.getSFSArray(FindRoomsRequest.KEY_FILTERED_ROOMS);
		var roomList = new Array<Room>();

		for (i in 0...roomListData.size()) 
		{
			var theRoom:Room = SFSRoom.fromSFSArray(roomListData.getSFSArray(i));
			var localRoom:Room = sfs.getRoomManager().getRoomById(theRoom.getId());
			
			if (localRoom != null)
				theRoom.setJoined(localRoom.isJoined());
			
			roomList.push(theRoom);
		}

		evtParams.set(EventParam.RoomList, roomList);
		sfs.dispatchEvent(new SFSEvent(SFSEvent.ROOM_FIND_RESULT, evtParams));
	}
}
