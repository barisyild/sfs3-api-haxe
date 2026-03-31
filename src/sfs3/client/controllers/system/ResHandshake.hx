package sfs3.client.controllers.system;

import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.io.IResponse;

class ResHandshake extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void 
	{
		sfs.handleHandShake(resp.getContent());
	}
}
