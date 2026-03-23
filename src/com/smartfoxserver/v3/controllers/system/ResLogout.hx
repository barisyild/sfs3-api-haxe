package com.smartfoxserver.v3.controllers.system;

import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.bitswarm.io.IResponse;
import com.smartfoxserver.v3.core.EventParam;
import com.smartfoxserver.v3.core.SFSEvent;
import com.smartfoxserver.v3.requests.LogoutRequest;
import com.smartfoxserver.v3.entities.data.PlatformStringMap;

class ResLogout extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		var sfso:ISFSObject = resp.getContent();
		var evtParams = new PlatformStringMap<Dynamic>();

		sfs.handleLogout();

		evtParams.set(EventParam.ZoneName, sfso.getString(LogoutRequest.KEY_ZONE_NAME));
		sfs.dispatchEvent(new SFSEvent(SFSEvent.LOGOUT, evtParams));
	}
}
