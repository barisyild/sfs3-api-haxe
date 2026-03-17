package javax.crypto.spec;

import java.NativeArray;
import java.StdTypes;

@:native("javax.crypto.spec.SecretKeySpec")
extern class SecretKeySpec implements java.security.Key {
    @:overload function new(key:NativeArray<Int8>, algorithm:String):Void;
    @:overload function new(key:NativeArray<Int8>, offset:Int, len:Int, algorithm:String):Void;
}
