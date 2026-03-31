package sfs3.client.controllers.system;

import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.io.IResponse;
import sfs3.client.core.EventParam;
import sfs3.client.core.SFSEvent;
import sfs3.client.util.LagValue;
import sfs3.client.entities.data.PlatformStringMap;

class ResPingPong extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		var evtParams = new PlatformStringMap<Dynamic>();
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
