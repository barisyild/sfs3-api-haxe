package com.smartfoxserver.v3.entities.data;
import haxe.io.Bytes;
import haxe.io.BytesData;

interface ISFSArray {
    function contains(var1:Dynamic):Bool;

    function iterator():Iterator<SFSDataWrapper>;

    function getElementAt(var1:Int):Null<Dynamic>;

    function get(var1:Int):SFSDataWrapper;

    function removeElementAt(var1:Int):Void;

    function size():Int;

    function toBinary():BytesData;

    function toJson():String;

    function getHexDump():String;

    function getDump(noFormat:Bool = true):String;

    function addNull():Void;

    function addBool(var1:Bool #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function addByte(var1:Int #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function addShort(var1:Int #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function addInt(var1:Int #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function addLong(var1:PlatformInt64 #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function addFloat(var1:Float #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function addDouble(var1:Float #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function addString(var1:String):Void;

    function addShortString(var1:String):Void;

    function addText(var1:String):Void;

    function addVector2(var1:SFSVector2 #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function addVector3(var1:SFSVector3 #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function addBoolArray(var1:Array<Bool> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function addByteArray(var1:BytesData #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function addShortArray(var1:Array<Int> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function addIntArray(var1:Array<Int> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function addLongArray(var1:Array<PlatformInt64> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function addFloatArray(var1:Array<Float> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function addDoubleArray(var1:Array<Float> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function addStringArray(var1:Array<String> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function addShortStringArray(var1:Array<String> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function addVector2Array(var1:Array<SFSVector2> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function addVector3Array(var1:Array<SFSVector3> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function addSFSArray(var1:ISFSArray #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function addSFSObject(var1:ISFSObject #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function add(var1:SFSDataWrapper #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void;

    function isNull(var1:Int):Bool;

    function getBool(var1:Int):Null<Bool>;

    function getByte(var1:Int):Null<Int>;

    function getUnsignedByte(var1:Int):Null<Int>;

    function getShort(var1:Int):Null<Int>;

    function getInt(var1:Int):Null<Int>;

    function getLong(var1:Int):Null<PlatformInt64>;

    function getFloat(var1:Int):Null<Float>;

    function getDouble(var1:Int):Null<Float>;

    function getString(var1:Int):Null<String>;

    function getShortString(var1:Int):Null<String>;

    function getText(var1:Int):Null<String>;

    function getVector2(var1:Int):Null<SFSVector2>;

    function getVector3(var1:Int):Null<SFSVector3>;

    function getBoolArray(var1:Int):Null<Array<Bool>>;

    function getByteArray(var1:Int):Null<BytesData>;

    function getUnsignedByteArray(var1:Int):Null<BytesData>;

    function getShortArray(var1:Int):Null<Array<Int>>;

    function getIntArray(var1:Int):Null<Array<Int>>;

    function getLongArray(var1:Int):Null<Array<PlatformInt64>>;

    function getFloatArray(var1:Int):Null<Array<Float>>;

    function getDoubleArray(var1:Int):Null<Array<Float>>;

    function getStringArray(var1:Int):Null<Array<String>>;

    function getShortStringArray(var1:Int):Null<Array<String>>;

    function getVector2Array(var1:Int):Null<Array<SFSVector2>>;

    function getVector3Array(var1:Int):Null<Array<SFSVector3>>;

    function getSFSArray(var1:Int):Null<ISFSArray>;

    function getSFSObject(var1:Int):Null<ISFSObject>;
}