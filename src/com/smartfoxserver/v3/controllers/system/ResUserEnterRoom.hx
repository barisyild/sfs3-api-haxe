package com.smartfoxserver.v3.controllers.system;

import com.smartfoxserver.v3.entities.data.ISFSArray;
import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.bitswarm.io.IResponse;
import com.smartfoxserver.v3.core.EventParam;
import com.smartfoxserver.v3.core.SFSEvent;
import com.smartfoxserver.v3.entities.Room;
import com.smartfoxserver.v3.entities.User;
import com.smartfoxserver.v3.entities.managers.SFSGlobalUserManager;
import com.smartfoxserver.v3.entities.data.PlatformStringMap;

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
