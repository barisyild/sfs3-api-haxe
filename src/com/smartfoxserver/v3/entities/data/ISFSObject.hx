package com.smartfoxserver.v3.entities.data;
import haxe.io.Bytes;
import haxe.io.BytesData;

interface ISFSObject {
    function isNull(var1:String):Bool;

    function containsKey(var1:String):Bool;

    function removeElement(var1:String):Bool;

    function getKeys():Array<String>;

    function size():Int;

    function iterator():Iterator<SFSDataWrapper>;

    function toBinary():BytesData;

    function toJson():String;

    function getDump(?var1:Bool):String;

    function getHexDump():String;

    function get(var1:String):Null<SFSDataWrapper>;

    function getBool(var1:String):Null<Bool>;

    function getByte(var1:String):Null<Int>;

    function getShort(var1:String):Null<Int>;

    function getInt(var1:String):Null<Int>;

    function getLong(var1:String):Null<PlatformInt64>;

    function getFloat(var1:String):Null<Float>;

    function getDouble(var1:String):Null<Float>;

    function getString(var1:String):Null<String>;

    function getShortString(var1:String):Null<String>;

    function getText(var1:String):Null<String>;

    function getBoolArray(var1:String):Null<Array<Bool>>;

    function getByteArray(var1:String):Null<BytesData>;

    function getUnsignedByteArray(var1:String):Null<Array<Int>>;

    function getShortArray(var1:String):Null<Array<Int>>;

    function getIntArray(var1:String):Null<Array<Int>>;

    function getLongArray(var1:String):Null<Array<PlatformInt64>>;

    function getFloatArray(var1:String):Null<Array<Float>>;

    function getDoubleArray(var1:String):Null<Array<Float>>;

    function getStringArray(var1:String):Null<Array<String>>;

    function getShortStringArray(var1:String):Null<Array<String>>;

    function getSFSArray(var1:String):Null<ISFSArray>;

    function getSFSObject(var1:String):Null<ISFSObject>;

    function getVector2(var1:String):Null<SFSVector2>;

    function getVector3(var1:String):Null<SFSVector3>;

    function getVector2Array(var1:String):Null<Array<SFSVector2>>;

    function getVector3Array(var1:String):Null<Array<SFSVector3>>;

    function putNull(var1:String):Void;

    function putBool(var1:String, var2:Bool #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function putByte(var1:String, var2:Int #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function putShort(var1:String, var2:Int #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function putInt(var1:String, var2:Int #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function putLong(var1:String, var2:PlatformInt64 #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function putFloat(var1:String, var2:Float #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function putDouble(var1:String, var2:Float #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function putString(var1:String, var2:String):Void;

    function putShortString(var1:String, var2:String):Void;

    function putText(var1:String, var2:String):Void;

    function putVector2(var1:String, var2:SFSVector2 #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function putVector3(var1:String, var2:SFSVector3 #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function putBoolArray(var1:String, var2:Array<Bool> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function putByteArray(var1:String, var2:BytesData #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function putShortArray(var1:String, var2:Array<Int> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function putIntArray(var1:String, var2:Array<Int> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function putLongArray(var1:String, var2:Array<PlatformInt64> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function putFloatArray(var1:String, var2:Array<Float> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function putDoubleArray(var1:String, var2:Array<Float> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function putStringArray(var1:String, var2:Array<String> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function putShortStringArray(var1:String, var2:Array<String> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function putVector2Array(var1:String, var2:Array<SFSVector2> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function putVector3Array(var1:String, var2:Array<SFSVector3> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function putSFSArray(var1:String, var2:ISFSArray #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function putSFSObject(var1:String, var2:ISFSObject #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function put(var1:String, var2:SFSDataWrapper #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;
}