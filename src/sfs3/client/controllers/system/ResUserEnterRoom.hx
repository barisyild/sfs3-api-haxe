package sfs3.client.controllers.system;

import sfs3.client.entities.data.ISFSArray;
import sfs3.client.entities.data.ISFSObject;
import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.io.IResponse;
import sfs3.client.core.EventParam;
import sfs3.client.core.SFSEvent;
import sfs3.client.entities.Room;
import sfs3.client.entities.User;
import sfs3.client.entities.managers.SFSGlobalUserManager;
import sfs3.client.entities.data.PlatformStringMap;

class ResUserEnterRoom extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		var userManager:SFSGlobalUserManager = cast sfs.getUserManager();
		
		var sfso:ISFSObject = resp.getContent();
		var evtParams = new PlatformStringMap<Dynamic>();

		var room:Room = sfs.getRoomManager().getRoomById(sfso.getInt("r"));

		if (room != null)
		{
			var userObj:ISFSArray = sfso.getSFSArray("u");
			
			var user:User = userManager.getOrCreateUser(userObj, room);
			room.addUser(user);
			
			evtParams.set(EventParam.User, user);
			evtParams.set(EventParam.Room, room);
			
			sfs.dispatchEvent(new SFSEvent(SFSEvent.USER_ENTER_ROOM, evtParams));
		}
	}
}
