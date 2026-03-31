package sfs3.client.controllers.system;

import sfs3.client.entities.data.ISFSObject;
import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.io.IResponse;
import sfs3.client.core.EventParam;
import sfs3.client.core.SFSBuddyEvent;
import sfs3.client.entities.Buddy;
import sfs3.client.entities.BuddyOnlineState;
import sfs3.client.entities.variables.BuddyVariable;
import sfs3.client.entities.variables.ReservedBuddyVariables;
import sfs3.client.entities.variables.SFSBuddyVariable;
import sfs3.client.requests.BaseRequest;
import sfs3.client.requests.buddylist.GoOnlineRequest;
import sfs3.client.util.SFSErrorCodes;
import sfs3.client.entities.data.PlatformStringMap;

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
