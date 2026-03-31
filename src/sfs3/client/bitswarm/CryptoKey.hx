package sfs3.client.bitswarm;
import haxe.io.Bytes;
import sfs3.client.bitswarm.util.ByteUtils;
import haxe.io.BytesData;

class CryptoKey {
    private static final SIZE:Int = 16;

    private var secretKey:Bytes;
    private var initVector:Bytes;

    public function new(combinedBytesData:BytesData) {
        this.secretKey = Bytes.alloc(SIZE);
        this.initVector = Bytes.alloc(SIZE);

        var combinedBytes:Bytes = Bytes.ofData(combinedBytesData);
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
        return "CryptoKey: " + ByteUtils.hexDump(secretKey.getData()) + "\nIV: " + ByteUtils.hexDump(initVector.getData());
    }
}