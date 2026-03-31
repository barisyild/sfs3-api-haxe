package sfs3.client.bitswarm.io;
import sfs3.client.core.ApiEvent;
import sfs3.client.entities.data.PlatformStringMap;

class SocketEvent extends ApiEvent
{
    public static final DataReceived:String = "DataReceived";
    public static final Error:String = "Error";
    public static final Connected:String = "Connected";
    public static final Disconnected:String = "Disconnected";
    public static final UdpHandshake:String = "UdpHandshake";


    public function new(type:String, params:PlatformStringMap<Dynamic> = null)
    {
        super(type, params);
    }
}