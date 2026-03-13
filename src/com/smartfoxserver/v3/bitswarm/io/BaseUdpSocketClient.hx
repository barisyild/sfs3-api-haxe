package com.smartfoxserver.v3.bitswarm.io;

abstract class BaseUdpSocketClient extends BaseSocketClient
{
    public abstract function isUdpInited():Bool;

    public function new(bitSwarm:BitSwarmClient)
    {
        super(bitSwarm);
    }
}