package sfs3.client.bitswarm;
import haxe.io.Bytes;
import sfs3.client.bitswarm.io.IRequest;
import haxe.io.BytesData;

interface IProtocolCodec
{
    public function onPacketRead(byteData:BytesData, txType:TransportType, isRaw:Bool):Void;
    public function onPacketWrite(request:IRequest):Void;
    public function getIOHandler():IOHandler;
}
