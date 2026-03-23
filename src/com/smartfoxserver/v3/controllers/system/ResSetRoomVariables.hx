package com.smartfoxserver.v3.controllers.system;

import com.smartfoxserver.v3.entities.data.ISFSArray;
import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.bitswarm.io.IResponse;
import com.smartfoxserver.v3.core.EventParam;
import com.smartfoxserver.v3.core.SFSEvent;
import com.smartfoxserver.v3.entities.Room;
import com.smartfoxserver.v3.entities.variables.RoomVariable;
import com.smartfoxserver.v3.entities.variables.SFSRoomVariable;
import com.smartfoxserver.v3.requests.SetRoomVariablesRequest;
import com.smartfoxserver.v3.entities.data.PlatformStringMap;

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
