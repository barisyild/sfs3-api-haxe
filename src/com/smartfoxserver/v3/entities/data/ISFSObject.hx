package com.smartfoxserver.v3.entities.data;
import haxe.io.Bytes;
import haxe.Int64;

interface ISFSObject {
    function isNull(var1:String):Bool;

    function containsKey(var1:String):Bool;

    function removeElement(var1:String):Bool;

    function getKeys():Array<String>;

    function size():Int;

    function iterator():Iterator<SFSDataWrapper>;

    function toBinary():Bytes;

    function toJson():String;

    function getDump(?var1:Bool):String;

    function getHexDump():String;

    function get(var1:String):Null<SFSDataWrapper>;

    function getBool(var1:String):Null<Bool>;

    function getByte(var1:String):Null<Int>;

    function getShort(var1:String):Null<Int>;

    function getInt(var1:String):Null<Int>;

    function getLong(var1:String):Null<Int64>;

    function getFloat(var1:String):Null<Float>;

    function getDouble(var1:String):Null<Float>;

    function getString(var1:String):Null<String>;

    function getShortString(var1:String):Null<String>;

    function getText(var1:String):Null<String>;

    function getBoolArray(var1:String):Null<Array<Bool>>;

    function getByteArray(var1:String):Null<Bytes>;

    function getUnsignedByteArray(var1:String):Null<Array<Int>>;

    function getShortArray(var1:String):Null<Array<Int>>;

    function getIntArray(var1:String):Null<Array<Int>>;

    function getLongArray(var1:String):Null<Array<Int64>>;

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

    function putBool(var1:String, var2:Bool):Void;

    function putByte(var1:String, var2:Int):Void;

    function putShort(var1:String, var2:Int):Void;

    function putInt(var1:String, var2:Int):Void;

    function putLong(var1:String, var2:Int64):Void;

    function putFloat(var1:String, var2:Float):Void;

    function putDouble(var1:String, var2:Float):Void;

    function putString(var1:String, var2:String):Void;

    function putShortString(var1:String, var2:String):Void;

    function putText(var1:String, var2:String):Void;

    function putVector2(var1:String, var2:SFSVector2):Void;

    function putVector3(var1:String, var2:SFSVector3):Void;

    function putBoolArray(var1:String, var2:Array<Bool>):Void;

    function putByteArray(var1:String, var2:Bytes):Void;

    function putShortArray(var1:String, var2:Array<Int>):Void;

    function putIntArray(var1:String, var2:Array<Int>):Void;

    function putLongArray(var1:String, var2:Array<Int64>):Void;

    function putFloatArray(var1:String, var2:Array<Float>):Void;

    function putDoubleArray(var1:String, var2:Array<Float>):Void;

    function putStringArray(var1:String, var2:Array<String>):Void;

    function putShortStringArray(var1:String, var2:Array<String>):Void;

    function putVector2Array(var1:String, var2:Array<SFSVector2>):Void;

    function putVector3Array(var1:String, var2:Array<SFSVector3>):Void;

    function putSFSArray(var1:String, var2:ISFSArray):Void;

    function putSFSObject(var1:String, var2:ISFSObject):Void;

    function put(var1:String, var2:SFSDataWrapper):Void;
}