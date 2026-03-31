package sfs3.client.controllers.system;

import sfs3.client.entities.data.ISFSArray;
import sfs3.client.entities.data.ISFSObject;
import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.io.IResponse;
import sfs3.client.core.EventParam;
import sfs3.client.core.SFSBuddyEvent;
import sfs3.client.entities.Buddy;
import sfs3.client.entities.variables.BuddyVariable;
import sfs3.client.entities.variables.SFSBuddyVariable;
import sfs3.client.requests.BaseRequest;
import sfs3.client.requests.buddylist.SetBuddyVariablesRequest;
import sfs3.client.util.SFSErrorCodes;
import sfs3.client.entities.data.PlatformStringMap;

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
