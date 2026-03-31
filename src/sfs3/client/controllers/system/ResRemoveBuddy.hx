package sfs3.client.controllers.system;

import sfs3.client.entities.data.ISFSObject;
import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.io.IResponse;
import sfs3.client.core.EventParam;
import sfs3.client.core.SFSBuddyEvent;
import sfs3.client.entities.Buddy;
import sfs3.client.requests.BaseRequest;
import sfs3.client.requests.buddylist.RemoveBuddyRequest;
import sfs3.client.util.SFSErrorCodes;
import sfs3.client.entities.data.PlatformStringMap;

class ResRemoveBuddy extends BaseResponseHandler
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
			var buddyName:String = sfso.getString(RemoveBuddyRequest.KEY_BUDDY_NAME);
			var buddy:Buddy = sfs.getBuddyManager().removeBuddyByName(buddyName);

			if (buddy != null)
			{
				// Fire event
				evtParams.set(EventParam.Buddy, buddy);
				sfs.dispatchEvent(new SFSBuddyEvent(SFSBuddyEvent.BUDDY_REMOVE, evtParams));
			}
			else
			{
				log.warn("RemoveBuddy failed, buddy not found: " + buddyName);
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
