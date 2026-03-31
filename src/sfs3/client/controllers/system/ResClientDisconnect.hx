package sfs3.client.controllers.system;

import sfs3.client.entities.data.ISFSObject;
import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.io.IResponse;
import sfs3.client.util.ClientDisconnectionReason;

/*
 * Receives disconnection reason from server
 * Force disconnection at BitSwarm level which in turn fires a disconnection event
 * back up to the SmartFox class
 */
class ResClientDisconnect extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, message:IResponse):Void
	{
		var sfso:ISFSObject = message.getContent();
		var reasonId:Int = sfso.getByte("dr");
		
		sfs.getBitSwarm().disconnect(ClientDisconnectionReason.getReason(reasonId));
	}
}
