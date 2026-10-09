package sfs3.client.bitswarm.io;
import haxe.io.Bytes;
import haxe.io.BytesData;

interface IPacketCompressor
{
    public function compress(data:BytesData):BytesData;
    public function uncompress(data:BytesData):BytesData;
    #if js
    public function compressAsync(data:BytesData):js.lib.Promise<BytesData>;
    #end
}
