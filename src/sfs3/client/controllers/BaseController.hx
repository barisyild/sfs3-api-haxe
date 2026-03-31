package sfs3.client.controllers;
import sfs3.client.core.LoggerFactory;
import sfs3.client.bitswarm.io.IResponse;
import sfs3.client.core.Logger;
import sfs3.client.bitswarm.IController;
import sfs3.client.bitswarm.BitSwarmClient;
class BaseController implements IController
{
    private final id:Int;
    private final bitSwarm:BitSwarmClient;
    private final log:Logger;

    public function new(id:Int, bitSwarm:BitSwarmClient)
    {
        log = LoggerFactory.getLogger(Type.getClass(this));
        this.id = id;
        this.bitSwarm = bitSwarm;
    }

    public function getId():Int
    {
        return id;
    }

    public function handleMessage(resp:IResponse):Void
    {
        log.info("System controller got request: " + resp);
    }
}
