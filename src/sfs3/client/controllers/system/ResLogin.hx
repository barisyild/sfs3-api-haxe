package sfs3.client.controllers.system;

import sfs3.client.entities.data.ISFSObject;
import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.io.IResponse;
import sfs3.client.core.EventParam;
import sfs3.client.core.SFSEvent;
import sfs3.client.entities.SFSUser;
import sfs3.client.requests.BaseRequest;
import sfs3.client.requests.LoginRequest;
import sfs3.client.util.SFSErrorCodes;
import sfs3.client.entities.data.PlatformStringMap;

class ResLogin extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		var sfso:ISFSObject = resp.getContent();
		var evtParams = new PlatformStringMap<Dynamic>();

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
