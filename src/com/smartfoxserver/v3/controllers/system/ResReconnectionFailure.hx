package com.smartfoxserver.v3.controllers.system;

import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.SmartFox;
import com.smartfoxserver.v3.bitswarm.io.IResponse;

class ResReconnectionFailure extends BaseResponseHandler 
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, message:IResponse):Void
	{
		/*
		 * Works with the default implementation of SFS2X/SFS3 Client API
		 * The custom SFS2X/SFS3 API in BitSmasher will ignore it.
		 */
		if (Std.isOfType(sfs, SmartFox)) {
            var smartFox:SmartFox = cast sfs;
            smartFox.getBitSwarm().completeReconnection(false);
        }
	}
}
