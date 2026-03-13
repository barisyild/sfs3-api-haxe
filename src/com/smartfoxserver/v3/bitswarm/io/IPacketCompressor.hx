package com.smartfoxserver.v3.bitswarm.io;
import haxe.io.Bytes;

interface IPacketCompressor
{
    public function compress(data:Bytes):Bytes;
    public function uncompress(data:Bytes):Bytes;
}
