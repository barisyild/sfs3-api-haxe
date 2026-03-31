package sfs3.client.controllers.system;

import sfs3.client.entities.data.ISFSObject;
import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.io.IResponse;
import sfs3.client.core.EventParam;
import sfs3.client.core.SFSEvent;
import sfs3.client.entities.Room;
import sfs3.client.entities.User;
import sfs3.client.entities.data.PlatformStringMap;

class ResUserExitRoom extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		var sfso:ISFSObject = resp.getContent();
		var evtParams = new PlatformStringMap<Dynamic>();

		var rId:Int = sfso.getInt("r");
		var uId:Int = sfso.getInt("u");
		var room:Room = sfs.getRoomManager().getRoomById(rId);
		var user:User = sfs.getUserManager().getUserById(uId);

		if (room != null && user != null)
		{
			room.removeUser(user);
			sfs.getUserManager().removeUser(user);

			// If I have left a room I need to mark the room as NOT JOINED
			if (user.getIsItMe() && room.getJoined())
			{
				// Turn of the Room's joined flag
				room.setJoined(false);

				// Reset the lastJoinedRoom reference if no Room is currently joined
				if (sfs.getJoinedRooms().length == 0)
					sfs.setLastJoinedRoom(null);

				/*
				 * Room is NOT managed, we need to remove it
				 */
				if (!room.getManaged())
					sfs.getRoomManager().removeRoom(room);
			}
			
			evtParams.set(EventParam.User, user);
			evtParams.set(EventParam.Room, room);

			// Fire event
			sfs.dispatchEvent(new SFSEvent(SFSEvent.USER_EXIT_ROOM, evtParams));
		}
		else
			log.warn("Failed to handle UserExit event. Room: " + (room != null? room.getName() : "null") + ", User: " + (user != null ? user.getName() : "null"));
	}
}
