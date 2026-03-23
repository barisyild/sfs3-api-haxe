package com.smartfoxserver.v3.bitswarm.bbox;
import com.smartfoxserver.v3.core.ApiEvent;
import com.smartfoxserver.v3.entities.data.PlatformStringMap;

//** <b>*Private*</b> */
class BlueBoxEvent extends ApiEvent
{
    public static final Connected:String = "bbConnected";
    public static final Disconnected:String = "bbDisconnected";
    public static final DataReceived:String = "bbDataReceived";
    public static final Error:String = "bbError";


    public function new(type:String, params:PlatformStringMap<Dynamic> = null)
    {
        super(type, params);
    }
}