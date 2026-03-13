package com.smartfoxserver.v3.controllers.system;

import com.smartfoxserver.v3.entities.data.ISFSArray;
import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.bitswarm.io.IResponse;
import com.smartfoxserver.v3.core.EventParam;
import com.smartfoxserver.v3.core.SFSEvent;
import com.smartfoxserver.v3.entities.IMMOItem;
import com.smartfoxserver.v3.entities.MMORoom;
import com.smartfoxserver.v3.entities.variables.IMMOItemVariable;
import com.smartfoxserver.v3.entities.variables.MMOItemVariable;
import com.smartfoxserver.v3.requests.mmo.SetMMOItemVariables;

class ResSetMMOItemVariable extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		var sfso:ISFSObject = resp.getContent();
		var evtParams = new Map<String, Dynamic>();
		
		var roomId:Int = sfso.getInt(SetMMOItemVariables.KEY_ROOM_ID);
		var mmoItemId:Int = sfso.getInt(SetMMOItemVariables.KEY_ITEM_ID);
		var varList:ISFSArray = sfso.getSFSArray(SetMMOItemVariables.KEY_VAR_LIST);
		
		var mmoRoom:MMORoom = cast sfs.getRoomManager().getRoomById(roomId);
		
		var changedVarNames = new Array<String>();
		
		if (mmoRoom != null)
		{
			var mmoItem:IMMOItem = mmoRoom.getMMOItem(mmoItemId);
		
			if (mmoItem != null)
			{
				for (i in 0...varList.size())
				{
					var itemVar:IMMOItemVariable = MMOItemVariable.fromSFSArray(varList.getSFSArray(i));
					mmoItem.setVariable(itemVar);
					
					changedVarNames.push(itemVar.getName());
				}
				
				evtParams.set(EventParam.ChangedVars, changedVarNames);
				evtParams.set(EventParam.MMOItem, mmoItem);
				evtParams.set(EventParam.Room, mmoRoom);
				
				sfs.dispatchEvent(new SFSEvent(SFSEvent.MMOITEM_VARIABLES_UPDATE, evtParams));
			}
		}
	}
}
