package sfs3.client.controllers.system;

import sfs3.client.entities.data.ISFSObject;
import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.io.IResponse;
import sfs3.client.core.EventParam;
import sfs3.client.core.SFSEvent;
import sfs3.client.entities.Room;
import sfs3.client.entities.User;
import sfs3.client.entities.data.PlatformStringMap;

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
				var evtParams = new PlatformStringMap<Dynamic>();
				evtParams.set(EventParam.User, user);
				evtParams.set(EventParam.Room, room);
				
				sfs.dispatchEvent(new SFSEvent(SFSEvent.USER_EXIT_ROOM, evtParams));
			}
		}
	}
}
