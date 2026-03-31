package sfs3.client.controllers.system;

import sfs3.client.entities.data.ISFSObject;
import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.io.IResponse;
import sfs3.client.core.EventParam;
import sfs3.client.core.SFSEvent;
import sfs3.client.requests.LogoutRequest;
import sfs3.client.entities.data.PlatformStringMap;

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
