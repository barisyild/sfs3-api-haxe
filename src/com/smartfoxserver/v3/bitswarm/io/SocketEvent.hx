package com.smartfoxserver.v3.bitswarm.io;
import com.smartfoxserver.v3.core.ApiEvent;
import com.smartfoxserver.v3.entities.data.PlatformStringMap;

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