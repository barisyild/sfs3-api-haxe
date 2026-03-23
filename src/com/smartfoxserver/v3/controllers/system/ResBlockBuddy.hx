package com.smartfoxserver.v3.controllers.system;

import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.bitswarm.io.IResponse;
import com.smartfoxserver.v3.core.EventParam;
import com.smartfoxserver.v3.core.SFSBuddyEvent;
import com.smartfoxserver.v3.entities.Buddy;
import com.smartfoxserver.v3.entities.SFSBuddy;
import com.smartfoxserver.v3.requests.BaseRequest;
import com.smartfoxserver.v3.requests.buddylist.BlockBuddyRequest;
import com.smartfoxserver.v3.util.SFSErrorCodes;
import com.smartfoxserver.v3.entities.data.PlatformStringMap;

class ResBlockBuddy extends BaseResponseHandler 
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
			var buddyName:String = sfso.getString(BlockBuddyRequest.KEY_BUDDY_NAME);
			var buddy:Buddy = sfs.getBuddyManager().getBuddyByName(buddyName);
			
			/*
			* If buddy was un-blocked we receive the whole buddy object with his latest data
			* @since 1.7.0
			*/
			if (sfso.containsKey(BlockBuddyRequest.KEY_BUDDY))
			{
				buddy = SFSBuddy.fromSFSArray( sfso.getSFSArray(BlockBuddyRequest.KEY_BUDDY) );
				sfs.getBuddyManager().addBuddy(buddy);
			}
			
			/*
			* Executes only if buddy was blocked
			*/
			else if (buddy != null)
				buddy.setBlocked(sfso.getBool(BlockBuddyRequest.KEY_BUDDY_BLOCK_STATE));
			
			else
			{
				log.warn("BlockBuddy failed, buddy not found: " + buddyName + ", in local BuddyList");
				return;
			}
			
			evtParams.set(EventParam.Buddy, buddy);
			sfs.dispatchEvent(new SFSBuddyEvent(SFSBuddyEvent.BUDDY_BLOCK, evtParams));
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
