package com.smartfoxserver.v3.controllers.system;

import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.bitswarm.io.IResponse;
import com.smartfoxserver.v3.core.EventParam;
import com.smartfoxserver.v3.core.SFSEvent;
import com.smartfoxserver.v3.entities.Room;

class ResUserCountChange extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		var sfso:ISFSObject = resp.getContent();
		var evtParams = new Map<String, Dynamic>();

		var room:Room = sfs.getRoomManager().getRoomById(sfso.getInt("r"));

		if (room != null)
		{
			var uCount:Int = sfso.getShort("uc");
			var sCount:Int = 0;

			// Check for optional spectator count
			if (sfso.containsKey("sc"))
			{
				sCount = sfso.getShort("sc");
			}

			room.setUserCount(uCount);
			room.setSpectatorCount(sCount);

			evtParams.set(EventParam.Room, room);
			evtParams.set(EventParam.UserCount, uCount);
			evtParams.set(EventParam.SpecCount, sCount);

			sfs.dispatchEvent(new SFSEvent(SFSEvent.USER_COUNT_CHANGE, evtParams));
		}
	}

}
