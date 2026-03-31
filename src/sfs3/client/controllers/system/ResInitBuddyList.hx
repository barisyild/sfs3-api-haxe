package sfs3.client.controllers.system;

import sfs3.client.entities.data.ISFSArray;
import sfs3.client.entities.data.ISFSObject;
import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.io.IResponse;
import sfs3.client.core.EventParam;
import sfs3.client.core.SFSBuddyEvent;
import sfs3.client.entities.Buddy;
import sfs3.client.entities.SFSBuddy;
import sfs3.client.entities.variables.BuddyVariable;
import sfs3.client.entities.variables.SFSBuddyVariable;
import sfs3.client.requests.BaseRequest;
import sfs3.client.requests.buddylist.InitBuddyListRequest;
import sfs3.client.util.SFSErrorCodes;
import sfs3.client.entities.data.PlatformStringMap;

class ResInitBuddyList extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		var sfso:ISFSObject = resp.getContent();
		var evtParams = new PlatformStringMap<Dynamic>();

		// ::: SUCCESS :::
		if (!sfso.containsKey(BaseRequest.KEY_ERROR_CODE))
		{
			var bListData:ISFSArray = sfso.getSFSArray(InitBuddyListRequest.KEY_BLIST);
			var myVarsData:ISFSArray = sfso.getSFSArray(InitBuddyListRequest.KEY_MY_VARS);
			var buddyStates:Array<String> = sfso.getStringArray(InitBuddyListRequest.KEY_BUDDY_STATES);

			// Clear BuddyManager
			sfs.getBuddyManager().clearAll();

			// Populate the BuddyList
			for (i in 0...bListData.size())
			{
				var b:Buddy = SFSBuddy.fromSFSArray(bListData.getSFSArray(i));
				sfs.getBuddyManager().addBuddy(b);
			}

			// Set the buddy states
			if (buddyStates != null)
				sfs.getBuddyManager().setBuddyStates(buddyStates);

			// Populate MyBuddyVariables
			var myBuddyVariables = new Array<BuddyVariable>();

			for (i in 0...myVarsData.size())
			{
				myBuddyVariables.push(SFSBuddyVariable.fromSFSArray(myVarsData.getSFSArray(i)));
			}

			sfs.getBuddyManager().setMyVariables(myBuddyVariables);
			sfs.getBuddyManager().setInited(true);

			// Fire event
			evtParams.set(EventParam.BuddyList, sfs.getBuddyManager().getBuddyList());
			evtParams.set(EventParam.MyBuddyVars, sfs.getBuddyManager().getMyVariables());

			sfs.dispatchEvent(new SFSBuddyEvent(SFSBuddyEvent.BUDDY_LIST_INIT, evtParams));
		}

		// ::: FAILURE :::
		else
		{
			var errorCode:Int = sfso.getShort(BaseRequest.KEY_ERROR_CODE);
			var errorMsg:String = SFSErrorCodes.getErrorMessage(errorCode, sfso.getStringArray(BaseRequest.KEY_ERROR_PARAMS));

			evtParams.set(EventParam.ErrorMessage, errorMsg);
			evtParams.set(EventParam.ErrorCode, errorCode);

			sfs.dispatchEvent(new SFSBuddyEvent(SFSBuddyEvent.BUDDY_ERROR, evtParams));
		}
	}
}
