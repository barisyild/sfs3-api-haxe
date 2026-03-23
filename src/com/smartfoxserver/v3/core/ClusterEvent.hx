package com.smartfoxserver.v3.core;
import com.smartfoxserver.v3.entities.data.PlatformStringMap;

@:expose("SFS3.SFSClusterEvent")
class ClusterEvent extends ApiEvent
{
    public static final CONNECTION_REQUIRED:String = "connectionRequired";

    public function new(type:String, args:PlatformStringMap<Dynamic> = null)
    {
        super(type, args);
    }
}
