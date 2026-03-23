package com.smartfoxserver.v3.bitswarm.io;
import haxe.io.Bytes;
import haxe.io.BytesData;

interface IPacketCompressor
{
    public function compress(data:BytesData):BytesData;
    public function uncompress(data:BytesData):BytesData;
}
