package sfs3.client.controllers.system;

import sfs3.client.entities.data.ISFSObject;
import sfs3.client.ConfigData;
import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.io.IResponse;
import sfs3.client.core.ClusterEvent;
import sfs3.client.core.EventParam;
import sfs3.client.entities.data.PlatformStringMap;

class ResGameServerConnectionRequired extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		var sfso:ISFSObject = resp.getContent();
		var evtParams = new PlatformStringMap<Dynamic>();
		
		var host:String = sfso.getString("h");
		var port:Int = sfso.getInt("p");
		var accessToken:String = sfso.getString("at");
		var zoneName:String = sfso.getString("z");
		
		var cfg = new ConfigData();
		cfg.host = host;
		cfg.port = port;
		cfg.udpPort = port;
		cfg.zone = zoneName;
		
		// TODO this is no longer needed, as ConfigData is required to connect
		if (sfs.getConfig() != null)
		{
			cfg.port = sfs.getConfig().port;
			cfg.udpPort = sfs.getConfig().udpPort;
		}
		
		// Fire event
		evtParams.set(EventParam.ClusterConfigData, cfg);
		evtParams.set(EventParam.ClusterUserName, sfs.getMySelf().getName());
		evtParams.set(EventParam.ClusterPassword, accessToken);
		
		sfs.dispatchEvent(new ClusterEvent(ClusterEvent.CONNECTION_REQUIRED, evtParams));
	}
}
