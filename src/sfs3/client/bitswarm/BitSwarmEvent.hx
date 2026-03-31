package sfs3.client.bitswarm;

import sfs3.client.core.ApiEvent;
import sfs3.client.entities.data.PlatformStringMap;

class BitSwarmEvent extends ApiEvent {
    public static final CONNECT:String = "connect";
    public static final DISCONNECT:String = "disconnect";
    public static final CONNECTION_RETRY:String = "connectionRetry";
    public static final CONNECTION_RESUME:String = "connectionResume";
    public static final IO_ERROR:String = "ioError";
    public static final SECURITY_ERROR:String = "securityError";
    public static final DATA_ERROR:String = "dataError";
    public static final INIT_CRYPTO:String = "initCrypto";

    // Used internally to complete the UdpInit cycle stated by UdpClient.connect(...)
    public static final UDP_CONNECT:String = "udpConnect";
    public static final UDP_DISCONNECT:String = "udpDisconnect";


    public function new(type:String, params:PlatformStringMap<Dynamic> = null)
    {
        if(params == null)
            params = new PlatformStringMap<Dynamic>();
        super(type, params);
    }
}
