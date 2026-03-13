package com.smartfoxserver.v3.bitswarm.io;
import haxe.io.Bytes;

interface IPacketEncrypter
{
    public function encrypt(data:Bytes):Bytes;
    public function decrypt(data:Bytes):Bytes;
}
