package sfs3.client.controllers.system;

import sfs3.client.entities.data.ISFSObject;
import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.io.IResponse;
import sfs3.client.core.EventParam;
import sfs3.client.core.SFSEvent;
import sfs3.client.entities.Room;
import sfs3.client.entities.User;
import sfs3.client.entities.managers.IUserManager;
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
		var globalUserManager:IUserManager = sfs.getUserManager();

		if (room != null)
		{
			// remove from all rooms
			sfs.getRoomManager().removeRoom(room);

			// remove users in this room from user manager
			for (user in room.getUserList())
			{
				globalUserManager.removeUser(user);
			}

			// Fire event
			evtParams.set(EventParam.Room, room);
			sfs.dispatchEvent(new SFSEvent(SFSEvent.ROOM_REMOVE, evtParams));
		}
	}
}
