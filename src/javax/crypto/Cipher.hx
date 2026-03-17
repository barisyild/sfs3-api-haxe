package javax.crypto;

import java.NativeArray;
import java.StdTypes;

@:native("javax.crypto.Cipher")
extern class Cipher {
    static final ENCRYPT_MODE:Int;
    static final DECRYPT_MODE:Int;

    static function getInstance(transformation:String):Cipher;
    @:overload function init(opmode:Int, key:java.security.Key, params:java.security.spec.AlgorithmParameterSpec):Void;
    @:overload function init(opmode:Int, key:java.security.Key):Void;
    function doFinal(input:NativeArray<Int8>):NativeArray<Int8>;
}
