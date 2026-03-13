package com.smartfoxserver.v3.controllers.system;

import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.bitswarm.io.IResponse;
import com.smartfoxserver.v3.core.EventParam;
import com.smartfoxserver.v3.core.SFSEvent;
import com.smartfoxserver.v3.entities.Room;
import com.smartfoxserver.v3.entities.User;

class ResUserLost extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		var sfso:ISFSObject = resp.getContent();

		var uId:Int = sfso.getInt("u");
		var user:User = sfs.getUserManager().getUserById(uId);

		if (user != null)
		{
			// keep a copy of the rooms joined by this user
			var joinedRooms:Array<Room> = sfs.getRoomManager().getUserRooms(user);

			// remove from all rooms
			sfs.getRoomManager().removeUser(user);

			// remove from global user manager
			sfs.getUserManager().removeUser(user);

			// Fire one event in each room
			for (room in joinedRooms)
			{
				var evtParams = new Map<String, Dynamic>();
				evtParams.set(EventParam.User, user);
				evtParams.set(EventParam.Room, room);
				
				sfs.dispatchEvent(new SFSEvent(SFSEvent.USER_EXIT_ROOM, evtParams));
			}
		}
	}
}
