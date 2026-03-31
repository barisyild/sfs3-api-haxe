package sfs3.client.bitswarm;
import sfs3.client.core.ApiEvent;
import sfs3.client.entities.data.PlatformStringMap;

class CryptoEvent extends ApiEvent
{
    public static final Init:String = "InitCrypto";

    public function new(type:String, params:PlatformStringMap<Dynamic> = null)
    {
        super(type, params);
    }
}
