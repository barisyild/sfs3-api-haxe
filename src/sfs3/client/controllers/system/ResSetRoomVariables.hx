package sfs3.client.controllers.system;

import sfs3.client.entities.data.ISFSArray;
import sfs3.client.entities.data.ISFSObject;
import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.io.IResponse;
import sfs3.client.core.EventParam;
import sfs3.client.core.SFSEvent;
import sfs3.client.entities.Room;
import sfs3.client.entities.variables.RoomVariable;
import sfs3.client.entities.variables.SFSRoomVariable;
import sfs3.client.requests.SetRoomVariablesRequest;
import sfs3.client.entities.data.PlatformStringMap;

class ResSetRoomVariables extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		var sfso:ISFSObject = resp.getContent();
		var evtParams = new PlatformStringMap<Dynamic>();

		var rId:Int = sfso.getInt(SetRoomVariablesRequest.KEY_VAR_ROOM);
		var varListData:ISFSArray = sfso.getSFSArray(SetRoomVariablesRequest.KEY_VAR_LIST);

		var targetRoom:Room = sfs.getRoomManager().getRoomById(rId);
		var changedVarNames = new Array<String>();

		if (targetRoom != null)
		{
			for (j in 0...varListData.size())
			{
				var roomVar:RoomVariable = SFSRoomVariable.fromSFSArray(varListData.getSFSArray(j));
				targetRoom.setVariable(roomVar);

				changedVarNames.push(roomVar.getName());
			}

			evtParams.set(EventParam.ChangedVars, changedVarNames);
			evtParams.set(EventParam.Room, targetRoom);

			sfs.dispatchEvent(new SFSEvent(SFSEvent.ROOM_VARIABLES_UPDATE, evtParams));
		}
		else
			log.warn("RoomVariablesUpdate, unknown Room id = " + rId);
	}
}
