package com.smartfoxserver.v3.bitswarm.bbox;
import com.smartfoxserver.v3.core.ApiEvent;

//** <b>*Private*</b> */
class BlueBoxEvent extends ApiEvent
{
    public static final Connected:String = "bbConnected";
    public static final Disconnected:String = "bbDisconnected";
    public static final DataReceived:String = "bbDataReceived";
    public static final Error:String = "bbError";


    public function new(type:String, params:Map<String, Dynamic> = null)
    {
        super(type, params);
    }
}