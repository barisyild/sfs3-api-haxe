package sfs3.client.core;
import sfs3.client.entities.data.PlatformStringMap;

@:expose("SFS3.SFSClusterEvent")
class ClusterEvent extends ApiEvent
{
    public static final CONNECTION_REQUIRED:String = "connectionRequired";

    public function new(type:String, args:PlatformStringMap<Dynamic> = null)
    {
        super(type, args);
    }
}
