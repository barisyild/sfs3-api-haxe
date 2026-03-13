package com.smartfoxserver.v3.entities.data;
import haxe.io.Bytes;
import haxe.Int64;

interface ISFSArray {
    function contains(var1:Dynamic):Bool;

    function iterator():Iterator<SFSDataWrapper>;

    function getElementAt(var1:Int):Null<Dynamic>;

    function get(var1:Int):SFSDataWrapper;

    function removeElementAt(var1:Int):Void;

    function size():Int;

    function toBinary():Bytes;

    function toJson():String;

    function getHexDump():String;

    function getDump(noFormat:Bool = true):String;

    function addNull():Void;

    function addBool(var1:Bool):Void;

    function addByte(var1:Int):Void;

    function addShort(var1:Int):Void;

    function addInt(var1:Int):Void;

    function addLong(var1:Int64):Void;

    function addFloat(var1:Float):Void;

    function addDouble(var1:Float):Void;

    function addString(var1:String):Void;

    function addShortString(var1:String):Void;

    function addText(var1:String):Void;

    function addVector2(var1:SFSVector2):Void;

    function addVector3(var1:SFSVector3):Void;

    function addBoolArray(var1:Array<Bool>):Void;

    function addByteArray(var1:Bytes):Void;

    function addShortArray(var1:Array<Int>):Void;

    function addIntArray(var1:Array<Int>):Void;

    function addLongArray(var1:Array<Int64>):Void;

    function addFloatArray(var1:Array<Float>):Void;

    function addDoubleArray(var1:Array<Float>):Void;

    function addStringArray(var1:Array<String>):Void;

    function addShortStringArray(var1:Array<String>):Void;

    function addVector2Array(var1:Array<SFSVector2>):Void;

    function addVector3Array(var1:Array<SFSVector3>):Void;

    function addSFSArray(var1:ISFSArray):Void;

    function addSFSObject(var1:ISFSObject):Void;

    function add(var1:SFSDataWrapper):Void;

    function isNull(var1:Int):Bool;

    function getBool(var1:Int):Null<Bool>;

    function getByte(var1:Int):Null<Int>;

    function getUnsignedByte(var1:Int):Null<Int>;

    function getShort(var1:Int):Null<Int>;

    function getInt(var1:Int):Null<Int>;

    function getLong(var1:Int):Null<Int64>;

    function getFloat(var1:Int):Null<Float>;

    function getDouble(var1:Int):Null<Float>;

    function getString(var1:Int):Null<String>;

    function getShortString(var1:Int):Null<String>;

    function getText(var1:Int):Null<String>;

    function getVector2(var1:Int):Null<SFSVector2>;

    function getVector3(var1:Int):Null<SFSVector3>;

    function getBoolArray(var1:Int):Null<Array<Bool>>;

    function getByteArray(var1:Int):Null<Bytes>;

    function getUnsignedByteArray(var1:Int):Null<Bytes>;

    function getShortArray(var1:Int):Null<Array<Int>>;

    function getIntArray(var1:Int):Null<Array<Int>>;

    function getLongArray(var1:Int):Null<Array<Int64>>;

    function getFloatArray(var1:Int):Null<Array<Float>>;

    function getDoubleArray(var1:Int):Null<Array<Float>>;

    function getStringArray(var1:Int):Null<Array<String>>;

    function getShortStringArray(var1:Int):Null<Array<String>>;

    function getVector2Array(var1:Int):Null<Array<SFSVector2>>;

    function getVector3Array(var1:Int):Null<Array<SFSVector3>>;

    function getSFSArray(var1:Int):Null<ISFSArray>;

    function getSFSObject(var1:Int):Null<ISFSObject>;
}