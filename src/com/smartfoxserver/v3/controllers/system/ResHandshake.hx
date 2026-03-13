package com.smartfoxserver.v3.controllers.system;

import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.bitswarm.io.IResponse;

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
