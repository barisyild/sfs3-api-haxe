package sfs3.client.controllers.system;

import sfs3.client.entities.data.ISFSObject;
import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.io.IResponse;
import sfs3.client.core.EventParam;
import sfs3.client.core.SFSEvent;
import sfs3.client.entities.Room;
import sfs3.client.entities.data.PlatformStringMap;

class ResUserCountChange extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		var sfso:ISFSObject = resp.getContent();
		var evtParams = new PlatformStringMap<Dynamic>();

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
