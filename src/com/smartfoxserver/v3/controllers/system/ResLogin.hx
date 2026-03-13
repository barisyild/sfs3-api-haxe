package com.smartfoxserver.v3.controllers.system;

import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.bitswarm.io.IResponse;
import com.smartfoxserver.v3.core.EventParam;
import com.smartfoxserver.v3.core.SFSEvent;
import com.smartfoxserver.v3.entities.SFSUser;
import com.smartfoxserver.v3.requests.BaseRequest;
import com.smartfoxserver.v3.requests.LoginRequest;
import com.smartfoxserver.v3.util.SFSErrorCodes;

class ResLogin extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		var sfso:ISFSObject = resp.getContent();
		var evtParams = new Map<String, Dynamic>();

		// Success
		if (!sfso.containsKey(BaseRequest.KEY_ERROR_CODE))
		{
			// Populate room list
			sfs.getRoomManager().updateRoomList(sfso.getSFSArray(LoginRequest.KEY_ROOMLIST));

			// create local user
			sfs.setMySelf(new SFSUser(sfso.getInt(LoginRequest.KEY_ID), sfso.getString(LoginRequest.KEY_USER_NAME), true));

			sfs.getMySelf().setUserManager(sfs.getUserManager());
			sfs.getMySelf().setPrivilegeId(sfso.getShort(LoginRequest.KEY_PRIVILEGE_ID));
			sfs.getUserManager().addUser(sfs.getMySelf());

			// set the reconnection seconds
			sfs.setReconnectionSeconds(sfso.getShort(LoginRequest.KEY_RECONNECTION_SECONDS));
			
			// Check custom params
			var customParams:ISFSObject = sfso.getSFSObject(LoginRequest.KEY_PARAMS);

			if (customParams != null)
			{
				var sid:String = customParams.getString(LoginRequest.KEY_CLUSTER_SID);
				if (sid != null) 
					sfs.setNodeId(sid);
			}
			
			// Fire success event
			evtParams.set(EventParam.ZoneName, sfso.getString(LoginRequest.KEY_ZONE_NAME));
			evtParams.set(EventParam.User, sfs.getMySelf());
			evtParams.set(EventParam.Data, sfso.getSFSObject(LoginRequest.KEY_PARAMS));

			var evt = new SFSEvent(SFSEvent.LOGIN, evtParams);
			
			sfs.dispatchEvent(evt);
		}

		// Failure
		else
		{
			var errorCode:Int = sfso.getShort(BaseRequest.KEY_ERROR_CODE);
			var errorMsg:String = SFSErrorCodes.getErrorMessage(errorCode, sfso.getStringArray(BaseRequest.KEY_ERROR_PARAMS));
			
			evtParams.set(EventParam.ErrorMessage, errorMsg);
			evtParams.set(EventParam.ErrorCode, errorCode);

			sfs.dispatchEvent(new SFSEvent(SFSEvent.LOGIN_ERROR, evtParams));
		}
	}
}
