package com.smartfoxserver.v3.controllers.system;

import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.ConfigData;
import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.bitswarm.io.IResponse;
import com.smartfoxserver.v3.core.ClusterEvent;
import com.smartfoxserver.v3.core.EventParam;

class ResGameServerConnectionRequired extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		var sfso:ISFSObject = resp.getContent();
		var evtParams = new Map<String, Dynamic>();
		
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
