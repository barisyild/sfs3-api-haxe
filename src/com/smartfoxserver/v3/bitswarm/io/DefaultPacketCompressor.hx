package com.smartfoxserver.v3.bitswarm.io;

import haxe.io.Bytes;
#if !python
import haxe.zip.Compress;
import haxe.zip.Uncompress;
#end
import haxe.Exception;
import haxe.io.BytesData;

class DefaultPacketCompressor implements IPacketCompressor {
    public function new() {}

    /**
     * Compress byte array using DEFLATE algorithm (Level 9 / Best Compression)
     */
    public function compress(data:BytesData):BytesData {
        #if python
        return compressPython(Bytes.ofData(data)).getData();
        #else
        return Compress.run(Bytes.ofData(data), 9).getData();
        #end
    }

    /**
     * Uncompress byte array of ZIPped data using DEFLATE algorithm
     */
    public function uncompress(zipData:BytesData):BytesData {
        #if python
        return uncompressPython(Bytes.ofData(zipData)).getData();
        #else
        try {
            return Uncompress.run(Bytes.ofData(zipData)).getData();
        } catch (e:Dynamic) {
            throw new Exception("Bad Packet compression format! Packet dropped. Detail: " + Std.string(e));
        }
        #end
    }

    #if python
    private function compressPython(data:Bytes):Bytes {
        var dataArr = data.getData();
        var result:BytesData = null;
        python.Syntax.code("
        import zlib
        data = bytes({0})
        {1} = zlib.compress(data, 9)
        ", dataArr, result);
        return Bytes.ofData(result);
    }

    private function uncompressPython(zipData:Bytes):Bytes {
        var zipDataArr = zipData.getData();
        var result:BytesData = null;
        try {
            python.Syntax.code("
            import zlib
            data = bytes({0})
            {1} = zlib.decompress(data)
            ", zipDataArr, result);
            return Bytes.ofData(result);
        } catch (e:Dynamic) {
            throw new Exception("Bad Packet compression format! Packet dropped. Detail: " + Std.string(e));
        }
    }
    #end
}