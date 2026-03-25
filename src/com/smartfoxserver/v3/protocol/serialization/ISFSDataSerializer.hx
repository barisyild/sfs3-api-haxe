package com.smartfoxserver.v3.protocol.serialization;

import haxe.io.Bytes;
import com.smartfoxserver.v3.entities.data.ISFSArray;
import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.entities.data.SFSArray;
import com.smartfoxserver.v3.entities.data.SFSObject;
import haxe.io.BytesData;

interface ISFSDataSerializer {
    function object2binary(object:ISFSObject):BytesData;
    function array2binary(array:ISFSArray):BytesData;
    function binary2object(data:BytesData):ISFSObject;
    function binary2array(data:BytesData):ISFSArray;
    function object2json(map:Map<String, Dynamic>):String;
    function array2json(list:Array<Dynamic>):String;
    function json2object(jsonStr:String):ISFSObject;
    function json2array(jsonStr:String):ISFSArray;
    function getUnsignedByte(b:Int):Int;
    function flattenObject(map:Map<String, Dynamic>, sfsObj:SFSObject):Void;
    function flattenArray(array:Array<Dynamic>, sfsArray:SFSArray):Void;
}
