package com.smartfoxserver.v3.bitswarm;
import haxe.io.Bytes;
import com.smartfoxserver.v3.bitswarm.io.IRequest;
import haxe.io.BytesData;

interface IProtocolCodec
{
    public function onPacketRead(byteData:BytesData, txType:TransportType, isRaw:Bool):Void;
    public function onPacketWrite(request:IRequest):Void;
    public function getIOHandler():IOHandler;
}
