package com.smartfoxserver.v3.controllers.system;

import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.bitswarm.io.IResponse;
import com.smartfoxserver.v3.core.EventParam;
import com.smartfoxserver.v3.core.SFSBuddyEvent;
import com.smartfoxserver.v3.entities.Buddy;
import com.smartfoxserver.v3.entities.BuddyOnlineState;
import com.smartfoxserver.v3.entities.variables.BuddyVariable;
import com.smartfoxserver.v3.entities.variables.ReservedBuddyVariables;
import com.smartfoxserver.v3.entities.variables.SFSBuddyVariable;
import com.smartfoxserver.v3.requests.BaseRequest;
import com.smartfoxserver.v3.requests.buddylist.GoOnlineRequest;
import com.smartfoxserver.v3.util.SFSErrorCodes;
import com.smartfoxserver.v3.entities.data.PlatformStringMap;

class ResGoOnline extends BaseResponseHandler
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
			var buddyName:String = sfso.getString(GoOnlineRequest.KEY_BUDDY_NAME);
			var buddy:Buddy = sfs.getBuddyManager().getBuddyByName(buddyName);
			var isItMe:Bool = buddyName == sfs.getMySelf().getName();
			var onlineValue:Int = sfso.getByte(GoOnlineRequest.KEY_ONLINE);
			var onlineState:Bool = (onlineValue == BuddyOnlineState.ONLINE);

			var fireEvent:Bool = true;

			if (isItMe)
			{
				if (sfs.getBuddyManager().getMyOnlineState() != onlineState)
				{
					log.warn("Unexpected: MyOnlineState is not in synch with the server. Updating to: " + onlineState);
					sfs.getBuddyManager().setMyOnlineState(onlineState);
				}
			}
			else if (buddy != null)
			{
				// Reassign ID
				buddy.setId(sfso.getInt(GoOnlineRequest.KEY_BUDDY_ID));
				var bvar:BuddyVariable = new SFSBuddyVariable(ReservedBuddyVariables.BV_ONLINE, onlineState);
				buddy.setVariable(bvar);

				if (onlineValue == BuddyOnlineState.LEFT_THE_SERVER)
					buddy.clearVolatileVariables();

				fireEvent = sfs.getBuddyManager().getMyOnlineState();
			}
			else
			{
				// Log and Exit
				log.warn("GoOnline error, buddy not found: " + buddyName + ", in local BuddyList");
				return;
			}

			if (fireEvent)
			{
				evtParams.set(EventParam.Buddy, buddy);
				evtParams.set(EventParam.IsItMe, isItMe);
				sfs.dispatchEvent(new SFSBuddyEvent(SFSBuddyEvent.BUDDY_ONLINE_STATE_CHANGE, evtParams));
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
