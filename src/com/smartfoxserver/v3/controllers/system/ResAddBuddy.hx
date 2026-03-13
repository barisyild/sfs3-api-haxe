package com.smartfoxserver.v3.controllers.system;

import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.bitswarm.io.IResponse;
import com.smartfoxserver.v3.core.EventParam;
import com.smartfoxserver.v3.core.SFSBuddyEvent;
import com.smartfoxserver.v3.entities.Buddy;
import com.smartfoxserver.v3.entities.SFSBuddy;
import com.smartfoxserver.v3.requests.BaseRequest;
import com.smartfoxserver.v3.requests.buddylist.AddBuddyRequest;
import com.smartfoxserver.v3.util.SFSErrorCodes;

class ResAddBuddy extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		var sfso:ISFSObject = resp.getContent();
		var evtParams = new Map<String, Dynamic>();

		// ::: SUCCESS :::
		if (!sfso.containsKey(BaseRequest.KEY_ERROR_CODE))
		{
			var buddy:Buddy = SFSBuddy.fromSFSArray(sfso.getSFSArray(AddBuddyRequest.KEY_BUDDY_NAME));
			sfs.getBuddyManager().addBuddy(buddy);

			// Fire event
			evtParams.set(EventParam.Buddy, buddy);
			sfs.dispatchEvent(new SFSBuddyEvent(SFSBuddyEvent.BUDDY_ADD, evtParams));
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
