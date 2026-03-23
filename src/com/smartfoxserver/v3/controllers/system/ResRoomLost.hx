package com.smartfoxserver.v3.controllers.system;

import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.bitswarm.io.IResponse;
import com.smartfoxserver.v3.core.EventParam;
import com.smartfoxserver.v3.core.SFSEvent;
import com.smartfoxserver.v3.entities.Room;
import com.smartfoxserver.v3.entities.User;
import com.smartfoxserver.v3.entities.managers.IUserManager;
import com.smartfoxserver.v3.entities.data.PlatformStringMap;

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
