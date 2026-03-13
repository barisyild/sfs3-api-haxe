package com.smartfoxserver.v3.bitswarm;
import haxe.io.Bytes;
import com.smartfoxserver.v3.bitswarm.io.IRequest;
interface IOHandler {
    public function onDataRead(byteData:Bytes, txType:TransportType):Void;
    public function onDataWrite(request:IRequest):Void;

    public function getCodec():IProtocolCodec;
}