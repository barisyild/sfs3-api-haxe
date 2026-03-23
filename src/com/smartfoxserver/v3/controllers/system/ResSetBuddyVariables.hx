package com.smartfoxserver.v3.controllers.system;

import com.smartfoxserver.v3.entities.data.ISFSArray;
import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.bitswarm.io.IResponse;
import com.smartfoxserver.v3.core.EventParam;
import com.smartfoxserver.v3.core.SFSBuddyEvent;
import com.smartfoxserver.v3.entities.Buddy;
import com.smartfoxserver.v3.entities.variables.BuddyVariable;
import com.smartfoxserver.v3.entities.variables.SFSBuddyVariable;
import com.smartfoxserver.v3.requests.BaseRequest;
import com.smartfoxserver.v3.requests.buddylist.SetBuddyVariablesRequest;
import com.smartfoxserver.v3.util.SFSErrorCodes;
import com.smartfoxserver.v3.entities.data.PlatformStringMap;

class ResSetBuddyVariables extends BaseResponseHandler
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
			var buddyName:String = sfso.getString(SetBuddyVariablesRequest.KEY_BUDDY_NAME);
			var buddyVarsData:ISFSArray = sfso.getSFSArray(SetBuddyVariablesRequest.KEY_BUDDY_VARS);

			var buddy:Buddy = sfs.getBuddyManager().getBuddyByName(buddyName);

			var isItMe:Bool = buddyName == sfs.getMySelf().getName();

			var changedVarNames = new Array<String>();
			var variables = new Array<BuddyVariable>();

			var fireEvent:Bool = true;

			// Rebuild variables
			for (j in 0...buddyVarsData.size())
			{
				var buddyVar:BuddyVariable = SFSBuddyVariable.fromSFSArray(buddyVarsData.getSFSArray(j));

				variables.push(buddyVar);
				changedVarNames.push(buddyVar.getName());
			}

			// If it's my user, change my local variables
			if (isItMe)
			{
				sfs.getBuddyManager().setMyVariables(variables);
			}

			// or ... change the variables of one of my buddies
			else if (buddy != null)
			{
				buddy.setVariables(variables);

				// See GoOnline handler for more details on this
				fireEvent = sfs.getBuddyManager().getMyOnlineState();
			}

			// Unexpected: it's not me, it's not one of my buddies. Log and quit
			else
			{
				log.warn("Unexpected: target of BuddyVariables update not found:" + buddyName);
				return;
			}

			if (fireEvent)
			{
				evtParams.set(EventParam.IsItMe, isItMe);
				evtParams.set(EventParam.ChangedVars, changedVarNames);
				evtParams.set(EventParam.Buddy, buddy);

				sfs.dispatchEvent(new SFSBuddyEvent(SFSBuddyEvent.BUDDY_VARIABLES_UPDATE, evtParams));
			}
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
