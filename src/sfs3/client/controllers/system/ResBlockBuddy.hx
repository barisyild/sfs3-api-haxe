package sfs3.client.controllers.system;

import sfs3.client.entities.data.ISFSObject;
import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.io.IResponse;
import sfs3.client.core.EventParam;
import sfs3.client.core.SFSBuddyEvent;
import sfs3.client.entities.Buddy;
import sfs3.client.entities.SFSBuddy;
import sfs3.client.requests.BaseRequest;
import sfs3.client.requests.buddylist.BlockBuddyRequest;
import sfs3.client.util.SFSErrorCodes;
import sfs3.client.entities.data.PlatformStringMap;

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
