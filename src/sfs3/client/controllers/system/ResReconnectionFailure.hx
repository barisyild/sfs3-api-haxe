package sfs3.client.controllers.system;

import sfs3.client.ISmartFox;
import sfs3.client.SmartFox;
import sfs3.client.bitswarm.io.IResponse;

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
