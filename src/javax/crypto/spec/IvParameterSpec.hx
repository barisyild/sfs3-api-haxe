package javax.crypto.spec;

import java.NativeArray;
import java.StdTypes;

@:native("javax.crypto.spec.IvParameterSpec")
extern class IvParameterSpec implements java.security.spec.AlgorithmParameterSpec {
    function new(iv:NativeArray<Int8>):Void;
}
