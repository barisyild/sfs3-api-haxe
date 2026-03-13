package com.smartfoxserver.v3.bitswarm.io;

import haxe.io.Bytes;
import haxe.zip.Compress;
import haxe.zip.Uncompress;
import haxe.Exception;

class DefaultPacketCompressor implements IPacketCompressor
{
    public function new() {}

    /**
     * Compress byte array using DEFLATE algorithm (Level 9 / Best Compression)
     */
    public function compress(data:Bytes):Bytes
    {
        return Compress.run(data, 9);
    }

    /**
     * Uncompress byte array of ZIPped data using DEFLATE algorithm
     */
    public function uncompress(zipData:Bytes):Bytes
    {
        try
        {
            return Uncompress.run(zipData);
        }
        catch (e:Dynamic)
        {
            throw new Exception("Bad Packet compression format! Packet dropped. Detail: " + Std.string(e));
        }
    }
}