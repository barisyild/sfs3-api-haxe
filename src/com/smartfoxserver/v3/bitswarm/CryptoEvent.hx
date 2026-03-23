package com.smartfoxserver.v3.bitswarm;
import com.smartfoxserver.v3.core.ApiEvent;
import com.smartfoxserver.v3.entities.data.PlatformStringMap;

class CryptoEvent extends ApiEvent
{
    public static final Init:String = "InitCrypto";

    public function new(type:String, params:PlatformStringMap<Dynamic> = null)
    {
        super(type, params);
    }
}
