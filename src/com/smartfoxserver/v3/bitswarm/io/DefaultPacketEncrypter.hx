package com.smartfoxserver.v3.bitswarm.io;

import haxe.Exception;
import haxe.io.Bytes;
import haxe.crypto.Aes;
import haxe.crypto.mode.Mode;
import haxe.crypto.padding.Padding;

class DefaultPacketEncrypter implements IPacketEncrypter
{
    private var bitSwarm:BitSwarmClient;

    public function new(bitSwarmClient:BitSwarmClient)
    {
        this.bitSwarm = bitSwarmClient;
    }

    public function encrypt(data:Bytes):Bytes
    {
        return execute(true, data);
    }

    public function decrypt(data:Bytes):Bytes
    {
        return execute(false, data);
    }

    // ---------------------------------------------------------------------------------------------------

    private function execute(isEncrypt:Bool, data:Bytes):Bytes
    {
        var ck:CryptoKey = bitSwarm.getCryptoKey();

        if (ck != null)
        {
            var iv:Bytes = ck.getInitVector();
            var skeySpec:Bytes = ck.getSecretKey();

            var aes = new Aes(skeySpec, iv);

            if (isEncrypt)
            {
                return aes.encrypt(Mode.CBC, data, Padding.PKCS7);
            }
            else
            {
                return aes.decrypt(Mode.CBC, data, Padding.PKCS7);
            }
        }

        throw new Exception("The current connection does not support encryption!");
    }
}