package com.smartfoxserver.v3.core;

class ClusterEvent extends ApiEvent
{
    public static final CONNECTION_REQUIRED:String = "connectionRequired";

    public function new(type:String, args:Map<String, Dynamic> = null)
    {
        super(type, args);
    }
}
