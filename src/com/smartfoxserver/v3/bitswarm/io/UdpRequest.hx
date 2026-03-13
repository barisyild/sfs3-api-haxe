package com.smartfoxserver.v3.bitswarm.io;

class UdpRequest extends Request
{
    public function new(id:Int, cid:Int)
    {
        super(id, cid);
        setTransport(TransportType.UDP);
    }
}