package sfs3.client.bitswarm;
import haxe.io.Bytes;
import sfs3.client.bitswarm.io.IRequest;
interface IOHandler {
    public function onDataRead(byteData:Bytes, txType:TransportType):Void;
    public function onDataWrite(request:IRequest):Void;

    public function getCodec():IProtocolCodec;
}