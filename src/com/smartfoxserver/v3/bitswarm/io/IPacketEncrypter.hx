package com.smartfoxserver.v3.bitswarm.io;
import haxe.io.Bytes;
import haxe.io.BytesData;

interface IPacketEncrypter
{
    public function encrypt(data:BytesData):BytesData;
    public function decrypt(data:BytesData):BytesData;
}
