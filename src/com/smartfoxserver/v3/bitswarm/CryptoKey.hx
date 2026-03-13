package com.smartfoxserver.v3.bitswarm;
import haxe.io.Bytes;
import com.smartfoxserver.v3.bitswarm.util.ByteUtils;

class CryptoKey {
    private static final SIZE:Int = 16;

    private var secretKey:Bytes;
    private var initVector:Bytes;

    public function new(combinedBytes:Bytes) {
        this.secretKey = Bytes.alloc(SIZE);
        this.initVector = Bytes.alloc(SIZE);

        this.secretKey.blit(0, combinedBytes, 0, SIZE);
        this.initVector.blit(0, combinedBytes, SIZE, SIZE);
    }

    public function getSecretKey():Bytes {
        return secretKey;
    }

    public function getInitVector():Bytes {
        return initVector;
    }

    public function toString():String {
        // ByteUtils.hexDump metodunun daha önce import.hx içinde tanımlandığını varsayıyorum
        return "CryptoKey: " + ByteUtils.hexDump(secretKey) + "\nIV: " + ByteUtils.hexDump(initVector);
    }
}