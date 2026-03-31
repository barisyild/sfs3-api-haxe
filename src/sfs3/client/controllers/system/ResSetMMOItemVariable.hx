package sfs3.client.controllers.system;

import sfs3.client.entities.data.ISFSArray;
import sfs3.client.entities.data.ISFSObject;
import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.io.IResponse;
import sfs3.client.core.EventParam;
import sfs3.client.core.SFSEvent;
import sfs3.client.entities.IMMOItem;
import sfs3.client.entities.MMORoom;
import sfs3.client.entities.variables.IMMOItemVariable;
import sfs3.client.entities.variables.MMOItemVariable;
import sfs3.client.requests.mmo.SetMMOItemVariables;
import sfs3.client.entities.data.PlatformStringMap;

class ResSetMMOItemVariable extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		var sfso:ISFSObject = resp.getContent();
		var evtParams = new PlatformStringMap<Dynamic>();
		
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
