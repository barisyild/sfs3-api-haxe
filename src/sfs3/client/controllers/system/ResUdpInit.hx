package sfs3.client.controllers.system;

import sfs3.client.bitswarm.rdp.TransportConfig;
import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.io.IResponse;
import sfs3.client.bitswarm.io.SocketEvent;
import sfs3.client.bitswarm.io.SysParam;
import sfs3.client.requests.UdpInitRequest;
import sfs3.client.entities.data.PlatformStringMap;

class ResUdpInit extends BaseResponseHandler
{
    public function new() {
        super();
    }

	public function handleResponse(sfs:ISmartFox, resp:IResponse):Void
	{
		var sfso = resp.getContent();
		var rdpTxCfg:TransportConfig = TransportConfig.deserialize(sfso.getByteArray(UdpInitRequest.KEY_RDP_CFG));
		
		if (log.isDebugEnabled())
			log.debug("RDP Transport cfg:\n" + rdpTxCfg.toString());
		
		/*
		 *  This event is expected by the UdpClient class used in BitSwarm which initiated 
		 *  the UDP handshake 
		 */

        var params = new PlatformStringMap<Dynamic>();
        params.set(SysParam.RdpCfg, rdpTxCfg);
        params.set(SysParam.MaxUdpIdleSecs, sfso.getByte(UdpInitRequest.KEY_MAX_IDLE_SECS));
        params.set(SysParam.UdpKeepAlive, sfso.getBool(UdpInitRequest.KEY_UDP_KEEPALIVE));

		var evt = new SocketEvent
		(
			SocketEvent.UdpHandshake, 
			params
		); 
		
		sfs.getBitSwarm().getDispatcher().dispatchEvent(evt);
	}
}
