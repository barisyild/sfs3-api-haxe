package sfs3.client.controllers.system;

import sfs3.client.entities.data.ISFSObject;
import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.io.IResponse;
import sfs3.client.core.EventParam;
import sfs3.client.core.SFSEvent;
import sfs3.client.entities.Room;
import sfs3.client.entities.User;
import sfs3.client.entities.data.PlatformStringMap;

class ResRoomLost extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		var sfso:ISFSObject = resp.getContent();
		var evtParams = new PlatformStringMap<Dynamic>();

		var rId:Int = sfso.getInt("r");
		var room:Room = sfs.getRoomManager().getRoomById(rId);

		if (room != null)
		{
			// remove from all rooms
			sfs.getRoomManager().removeRoom(room);

			/*
			 * The server never destroys a populated Room: it removes every joined User
			 * first, so the exit response has already cleared these; reaching this branch
			 * means the client is out of sync with the server
			 */
			if (room.getJoined())
			{
				log.warn("Room " + room.getName() + " was still flagged as joined when it was removed");

				// Turn off the Room's joined flag
				room.setJoined(false);

				var lastJoinedRoom:Room = sfs.getLastJoinedRoom();

				if ((lastJoinedRoom != null && room.getId() == lastJoinedRoom.getId()) || sfs.getJoinedRooms().length == 0)
					sfs.setLastJoinedRoom(null);
			}

			// Fire event
			evtParams.set(EventParam.Room, room);
			sfs.dispatchEvent(new SFSEvent(SFSEvent.ROOM_REMOVE, evtParams));
		}
	}
}
