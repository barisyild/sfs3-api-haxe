package com.smartfoxserver.v3.bitswarm.io;

abstract class BaseIOHandler implements IOHandler
{
    private final _packetEncrypter:IPacketEncrypter;
    private final _packetCompressor:IPacketCompressor;
    private final _bitSwarm:BitSwarmClient;

    public function new(bitSwarm:BitSwarmClient)
    {
        this._packetEncrypter = new DefaultPacketEncrypter(bitSwarm);
        this._packetCompressor = new DefaultPacketCompressor();
        this._bitSwarm = bitSwarm;
    }

    public function packetCompressor():IPacketCompressor
    {
        return _packetCompressor;
    }

    public function packetEncrypter():IPacketEncrypter
    {
        return _packetEncrypter;
    }

    public function getBitSwarm():BitSwarmClient
    {
        return _bitSwarm;
    }
}
