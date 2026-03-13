package com.smartfoxserver.v3.controllers;
import com.smartfoxserver.v3.core.LoggerFactory;
import com.smartfoxserver.v3.bitswarm.io.IResponse;
import com.smartfoxserver.v3.core.Logger;
import com.smartfoxserver.v3.bitswarm.IController;
import com.smartfoxserver.v3.bitswarm.BitSwarmClient;
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

    @Override
    public function getId():Int
    {
        return id;
    }

    public function handleMessage(resp:IResponse):Void
    {
        log.info("System controller got request: " + resp);
    }
}
