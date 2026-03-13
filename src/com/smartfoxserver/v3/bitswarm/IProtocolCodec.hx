package com.smartfoxserver.v3.bitswarm;
import haxe.io.Bytes;
import com.smartfoxserver.v3.bitswarm.io.IRequest;

interface IProtocolCodec
{
    public function onPacketRead(byteData:Bytes, txType:TransportType, isRaw:Bool):Void;
    public function onPacketWrite(request:IRequest):Void;
    public function getIOHandler():IOHandler;
}
