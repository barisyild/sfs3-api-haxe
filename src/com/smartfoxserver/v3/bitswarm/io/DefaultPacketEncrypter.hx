package com.smartfoxserver.v3.bitswarm.io;

import haxe.io.BytesData;
import haxe.io.Bytes;
#if crypto
import haxe.crypto.Aes;
import haxe.crypto.mode.Mode;
import haxe.crypto.padding.Padding;
#end
import haxe.Exception;
import com.smartfoxserver.v3.bitswarm.BitSwarmClient;
import com.smartfoxserver.v3.bitswarm.CryptoKey;

class DefaultPacketEncrypter implements IPacketEncrypter {
    private var bitSwarm:BitSwarmClient;

    public function new(bitSwarmClient:BitSwarmClient) {
        this.bitSwarm = bitSwarmClient;
    }

    public function encrypt(data:Bytes):Bytes {
        return execute(true, data);
    }

    public function decrypt(data:Bytes):Bytes {
        return execute(false, data);
    }

    // ---------------------------------------------------------------------------------------------------

    #if crypto
    private function execute(isEncrypt:Bool, data:Bytes):Bytes {
        var ck:CryptoKey = bitSwarm.getCryptoKey();
        if (ck != null) {
            var iv:Bytes = ck.getInitVector();
            var skeySpec:Bytes = ck.getSecretKey();
            var aes = new Aes(skeySpec, iv);
            if (isEncrypt) {
                return aes.encrypt(Mode.CBC, data, Padding.PKCS7);
            } else {
                return aes.decrypt(Mode.CBC, data, Padding.PKCS7);
            }
        }
        throw new Exception("The current connection does not support encryption!");
    }
    #elseif jvm
    private function execute(isEncrypt:Bool, data:Bytes):Bytes {
        var ck:CryptoKey = bitSwarm.getCryptoKey();
        if (ck == null)
            throw new Exception("The current connection does not support encryption!");
        var iv:Bytes = ck.getInitVector();
        var skeySpec:Bytes = ck.getSecretKey();
        var cipher = javax.crypto.Cipher.getInstance("AES/CBC/PKCS5Padding");
        var keySpec = new javax.crypto.spec.SecretKeySpec(cast skeySpec.getData(), "AES");
        var ivSpec = new javax.crypto.spec.IvParameterSpec(cast iv.getData());
        cipher.init(isEncrypt ? javax.crypto.Cipher.ENCRYPT_MODE : javax.crypto.Cipher.DECRYPT_MODE, keySpec, ivSpec);
        var result = cipher.doFinal(cast data.getData());
        return Bytes.ofData(cast result);
    }
    #elseif python
    private function execute(isEncrypt:Bool, data:Bytes):Bytes {
        var ck:CryptoKey = bitSwarm.getCryptoKey();
        if (ck == null)
            throw new Exception("The current connection does not support encryption!");
        var iv:Bytes = ck.getInitVector();
        var skeySpec:Bytes = ck.getSecretKey();
        var keyArr = skeySpec.getData();
        var ivArr = iv.getData();
        var dataArr = data.getData();
        var result:BytesData = null;
        python.Syntax.code("
        from Crypto.Cipher import AES
        from Crypto.Util.Padding import pad, unpad
        key = bytes({0})
        iv = bytes({1})
        data = bytes({2})
        cipher = AES.new(key, AES.MODE_CBC, iv)
        if {3}:
            {4} = cipher.encrypt(pad(data, AES.block_size))
        else:
            {4} = unpad(cipher.decrypt(data), AES.block_size)
        ", keyArr, ivArr, dataArr, isEncrypt, result);
        return Bytes.ofData(result);
    }
    #else
    private function execute(isEncrypt:Bool, data:Bytes):Bytes {
        throw new Exception("Encryption is not supported on this target. Add -lib crypto or use JVM/Python target.");
    }
    #end
}
