package sfs3.client.bitswarm.bbox;
import sfs3.client.core.ApiEvent;
import sfs3.client.entities.data.PlatformStringMap;

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