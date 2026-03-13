package com.smartfoxserver.v3.bitswarm;
import com.smartfoxserver.v3.core.ApiEvent;

class CryptoEvent extends ApiEvent
{
    public static final Init:String = "InitCrypto";

    public function new(type:String, params:Map<String, Dynamic> = null)
    {
        super(type, params);
    }
}
