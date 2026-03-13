package com.smartfoxserver.v3.controllers.system;

import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.bitswarm.io.IResponse;
import com.smartfoxserver.v3.core.EventParam;
import com.smartfoxserver.v3.core.SFSEvent;
import com.smartfoxserver.v3.util.LagValue;

class ResPingPong extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		var evtParams = new Map<String, Dynamic>();
		evtParams.set(EventParam.LagValue, 
						new LagValue
						(
							sfs.getLagMonitor().onPingPong(), 
							sfs.getLagMonitor().getMinValue(), 
							sfs.getLagMonitor().getMaxValue()
						));
		
		// Redispatch at the user level
		sfs.dispatchEvent(new SFSEvent(SFSEvent.PING_PONG, evtParams));
	}
}
