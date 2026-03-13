package com.smartfoxserver.v3.controllers.system;

import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.bitswarm.io.IResponse;
import com.smartfoxserver.v3.util.ClientDisconnectionReason;

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
