package com.smartfoxserver.v3.controllers.system;

import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.bitswarm.io.IResponse;
import com.smartfoxserver.v3.core.EventParam;
import com.smartfoxserver.v3.core.SFSEvent;
import com.smartfoxserver.v3.requests.BaseRequest;
import com.smartfoxserver.v3.util.SFSErrorCodes;

class ResQuickJoinGame extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		// NOTE: this is called only in case of error, when no Games to join where found
		var sfso:ISFSObject = resp.getContent();
		var evtParams = new Map<String, Dynamic>();

		// Notify error
		if (sfso.containsKey(BaseRequest.KEY_ERROR_CODE))
		{
			var errorCode:Int = sfso.getShort(BaseRequest.KEY_ERROR_CODE);
			var errorMsg:String = SFSErrorCodes.getErrorMessage(errorCode, sfso.getStringArray(BaseRequest.KEY_ERROR_PARAMS));
			evtParams.set(EventParam.ErrorMessage, errorMsg);
			evtParams.set(EventParam.ErrorCode, errorCode);

			sfs.dispatchEvent(new SFSEvent(SFSEvent.ROOM_JOIN_ERROR, evtParams));
		}
	}
}
