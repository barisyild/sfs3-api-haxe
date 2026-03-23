package com.smartfoxserver.v3.controllers.system;

import com.smartfoxserver.v3.entities.data.ISFSArray;
import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.bitswarm.io.IResponse;
import com.smartfoxserver.v3.core.EventParam;
import com.smartfoxserver.v3.core.SFSBuddyEvent;
import com.smartfoxserver.v3.entities.Buddy;
import com.smartfoxserver.v3.entities.SFSBuddy;
import com.smartfoxserver.v3.entities.variables.BuddyVariable;
import com.smartfoxserver.v3.entities.variables.SFSBuddyVariable;
import com.smartfoxserver.v3.requests.BaseRequest;
import com.smartfoxserver.v3.requests.buddylist.InitBuddyListRequest;
import com.smartfoxserver.v3.util.SFSErrorCodes;
import com.smartfoxserver.v3.entities.data.PlatformStringMap;

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
