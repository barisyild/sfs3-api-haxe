package com.smartfoxserver.v3.entities.data;

import com.smartfoxserver.v3.bitswarm.util.ByteUtils;
import com.smartfoxserver.v3.protocol.serialization.DefaultObjectDumpFormatter;
import com.smartfoxserver.v3.protocol.serialization.DefaultSFSDataSerializer;
import com.smartfoxserver.v3.protocol.serialization.ISFSDataSerializer;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesData;
import haxe.Exception;
import com.smartfoxserver.v3.util.TypeSafety;

@:expose("SFS3.SFSObject")
class SFSObject implements ISFSObject {
    private final serializer:ISFSDataSerializer = DefaultSFSDataSerializer.getInstance();
    private var dataHolder:Map<String, SFSDataWrapper> = new Map<String, SFSDataWrapper>();

    public static function newFromBinaryData(bytes:BytesData):SFSObject {
        return cast DefaultSFSDataSerializer.getInstance().binary2object(bytes);
    }

    private static function newFromBinaryDataInput(bytesInput:BytesInput):SFSObject {
        return cast @:privateAccess DefaultSFSDataSerializer.getInstance().binaryinput2object(bytesInput);
    }

    public static function newFromJsonData(jsonStr:String):ISFSObject {
        return DefaultSFSDataSerializer.getInstance().json2object(jsonStr);
    }

    public static function newInstance():SFSObject {
        return new SFSObject();
    }

    public function new() {}

    public function iterator():Iterator<SFSDataWrapper> {
        return dataHolder.iterator();
    }

    public function containsKey(key:String):Bool {
        return dataHolder.exists(key);
    }

    public function removeElement(key:String):Bool {
        if (dataHolder.exists(key)) {
            dataHolder.remove(key);
            return true;
        }
        return false;
    }

    public function size():Int {
        var count = 0;
        for (_ in dataHolder.keys()) count++;
        return count;
    }

    public function toBinary():BytesData {
        return serializer.object2binary(this);
    }

    public function toJson():String {
        return serializer.object2json(this.flatten());
    }

    public function getDump(?noFormat:Bool):String {
        if (noFormat == null || noFormat == false) {
            return this.size() == 0 ? "[ Empty SFSObject ]" : DefaultObjectDumpFormatter.prettyPrintDump(this.dump());
        }
        return this.dump();
    }

    private function dump():String {
        if (this.size() < 1) {
            return "{}";
        } else {
            var buffer = new StringBuf();
            buffer.addChar(0x11);

            for (key in this.getKeys()) {
                var wrapper = this.get(key);
                buffer.add("(");
                buffer.add(Std.string(wrapper.getTypeId()).toLowerCase());
                buffer.add(") ");
                buffer.add(key);
                buffer.add(": ");
                buffer.add(DefaultObjectDumpFormatter.formattedValue(wrapper));
                buffer.addChar(0x13);
            }

            var s = buffer.toString();
            s = s.substr(0, s.length - 1);
            var finalBuf = new StringBuf();
            finalBuf.add(s);
            finalBuf.addChar(0x12);
            return finalBuf.toString();
        }
    }

    public function getHexDump():String {
        return ByteUtils.hexDump(this.toBinary());
    }

    public function isNull(key:String):Bool {
        var wrapper = dataHolder.get(key);
        if (wrapper == null) {
            return false;
        } else {
            return wrapper.getTypeId() == SFSDataType.NULL;
        }
    }

    public function get(key:String):Null<SFSDataWrapper> {
        return dataHolder.get(key);
    }

    public function getBool(key:String):Null<Bool> {
        var o = dataHolder.get(key);
        return o == null ? null : cast o.getObject();
    }

    public function getBoolArray(key:String):Null<Array<Bool>> {
        var o = dataHolder.get(key);
        return o == null ? null : cast o.getObject();
    }

    public function getByte(key:String):Null<Int> {
        var o = dataHolder.get(key);
        return o == null ? null : cast o.getObject();
    }

    public function getByteArray(key:String):Null<BytesData> {
        var o = dataHolder.get(key);
        return o == null ? null : cast o.getObject();
    }

    public function getDouble(key:String):Null<Float> {
        var o = dataHolder.get(key);
        return o == null ? null : cast o.getObject();
    }

    public function getDoubleArray(key:String):Null<Array<Float>> {
        var o = dataHolder.get(key);
        return o == null ? null : cast o.getObject();
    }

    public function getFloat(key:String):Null<Float> {
        var o = dataHolder.get(key);
        return o == null ? null : cast o.getObject();
    }

    public function getFloatArray(key:String):Null<Array<Float>> {
        var o = dataHolder.get(key);
        return o == null ? null : cast o.getObject();
    }

    public function getInt(key:String):Null<Int> {
        var o = dataHolder.get(key);
        return o == null ? null : cast o.getObject();
    }

    public function getIntArray(key:String):Null<Array<Int>> {
        var o = dataHolder.get(key);
        return o == null ? null : cast o.getObject();
    }

    public function getKeys():Array<String> {
        return [for (k in dataHolder.keys()) k];
    }

    public function getLong(key:String):Null<PlatformInt64> {
        var o = dataHolder.get(key);
        return o == null ? null : cast o.getObject();
    }

    public function getLongArray(key:String):Null<Array<PlatformInt64>> {
        var o = dataHolder.get(key);
        return o == null ? null : cast o.getObject();
    }

    public function getSFSArray(key:String):Null<ISFSArray> {
        var o = dataHolder.get(key);
        return o == null ? null : cast o.getObject();
    }

    public function getSFSObject(key:String):Null<ISFSObject> {
        var o = dataHolder.get(key);
        return o == null ? null : cast o.getObject();
    }

    public function getShort(key:String):Null<Int> {
        var o = dataHolder.get(key);
        return o == null ? null : cast o.getObject();
    }

    public function getShortArray(key:String):Null<Array<Int>> {
        var o = dataHolder.get(key);
        return o == null ? null : cast o.getObject();
    }

    public function getUnsignedByteArray(key:String):Null<Array<Int>> {
        var o = dataHolder.get(key);
        if (o == null) {
            return null;
        } else {
            var ser = DefaultSFSDataSerializer.getInstance();
            var rawBytes:Bytes = cast o.getObject();
            var intCollection = new Array<Int>();

            for (i in 0...rawBytes.length) {
                intCollection.push(ser.getUnsignedByte(rawBytes.get(i)));
            }

            return intCollection;
        }
    }

    public function getString(key:String):Null<String> {
        var o = dataHolder.get(key);
        return o == null ? null : cast o.getObject();
    }

    public function getShortString(key:String):Null<String> {
        return this.getString(key);
    }

    public function getText(key:String):Null<String> {
        return this.getString(key);
    }

    public function getVector2(key:String):Null<SFSVector2> {
        var o = dataHolder.get(key);
        return o == null ? null : cast o.getObject();
    }

    public function getVector3(key:String):Null<SFSVector3> {
        var o = dataHolder.get(key);
        return o == null ? null : cast o.getObject();
    }

    public function getStringArray(key:String):Null<Array<String>> {
        var o = dataHolder.get(key);
        return o == null ? null : cast o.getObject();
    }

    public function getShortStringArray(key:String):Null<Array<String>> {
        return this.getStringArray(key);
    }

    public function getVector2Array(key:String):Null<Array<SFSVector2>> {
        var o = dataHolder.get(key);
        return o == null ? null : cast o.getObject();
    }

    public function getVector3Array(key:String):Null<Array<SFSVector3>> {
        var o = dataHolder.get(key);
        return o == null ? null : cast o.getObject();
    }

    public function putBool(key:String, value:Bool #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        TypeSafety.checkNotNull(value);
        #if !strict_language
        if(validateType)
            TypeSafety.checkBool(value);
        #end
        this.putObj(key, value, SFSDataType.BOOL);
    }

    public function putBoolArray(key:String, value:Array<Bool> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        TypeSafety.checkNotNull(value);
        #if !strict_language
        if(validateType)
            TypeSafety.checkBoolArray(value);
        #end
        this.putObj(key, value, SFSDataType.BOOL_ARRAY);
    }

    public function putByte(key:String, value:Int #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        TypeSafety.checkNotNull(value);
        #if !strict_language
        if(validateType)
            TypeSafety.checkByte(value);
        #end
        this.putObj(key, value, SFSDataType.BYTE);
    }

    public function putByteArray(key:String, value:BytesData #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        TypeSafety.checkNotNull(value);
        #if !strict_language
        if(validateType)
            TypeSafety.checkByteArray(value);
        #end
        this.putObj(key, value, SFSDataType.BYTE_ARRAY);
    }

    public function putDouble(key:String, value:Float #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        TypeSafety.checkNotNull(value);
        #if !strict_language
        if(validateType)
            TypeSafety.checkDouble(value);
        #end
        this.putObj(key, value, SFSDataType.DOUBLE);
    }

    public function putDoubleArray(key:String, value:Array<Float> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        TypeSafety.checkNotNull(value);
        #if !strict_language
        if(validateType)
            TypeSafety.checkDoubleArray(value);
        #end
        this.putObj(key, value, SFSDataType.DOUBLE_ARRAY);
    }

    public function putFloat(key:String, value:Float #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        TypeSafety.checkNotNull(value);
        #if !strict_language
        if(validateType)
            TypeSafety.checkFloat(value);
        #end
        this.putObj(key, value, SFSDataType.FLOAT);
    }

    public function putFloatArray(key:String, value:Array<Float> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        TypeSafety.checkNotNull(value);
        #if !strict_language
        if(validateType)
            TypeSafety.checkFloatArray(value);
        #end
        this.putObj(key, value, SFSDataType.FLOAT_ARRAY);
    }

    public function putInt(key:String, value:Int #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        TypeSafety.checkNotNull(value);
        #if !strict_language
        if(validateType)
            TypeSafety.checkInt(value);
        #end
        this.putObj(key, value, SFSDataType.INT);
    }

    public function putIntArray(key:String, value:Array<Int> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        TypeSafety.checkNotNull(value);
        #if !strict_language
        if(validateType)
            TypeSafety.checkIntArray(value);
        #end
        this.putObj(key, value, SFSDataType.INT_ARRAY);
    }

    public function putLong(key:String, value:PlatformInt64 #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        TypeSafety.checkNotNull(value);
        #if !strict_language
        if(validateType)
            TypeSafety.checkLong(value);
        #end
        this.putObj(key, value, SFSDataType.LONG);
    }

    public function putLongArray(key:String, value:Array<PlatformInt64> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        TypeSafety.checkNotNull(value);
        #if !strict_language
        if(validateType)
            TypeSafety.checkLongArray(value);
        #end
        this.putObj(key, value, SFSDataType.LONG_ARRAY);
    }

    public function putNull(key:String):Void {
        dataHolder.set(key, new SFSDataWrapper(SFSDataType.NULL, null));
    }

    public function putSFSArray(key:String, value:ISFSArray #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        TypeSafety.checkNotNull(value);
        #if !strict_language
        if(validateType)
            TypeSafety.checkSFSArray(value);
        #end
        this.putObj(key, value, SFSDataType.SFS_ARRAY);
    }

    public function putSFSObject(key:String, value:ISFSObject #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        TypeSafety.checkNotNull(value);
        #if !strict_language
        if(validateType)
            TypeSafety.checkSFSObject(value);
        #end
        this.putObj(key, value, SFSDataType.SFS_OBJECT);
    }

    public function putShort(key:String, value:Int #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        TypeSafety.checkNotNull(value);
        #if !strict_language
        if(validateType)
            TypeSafety.checkShort(value);
        #end
        this.putObj(key, value, SFSDataType.SHORT);
    }

    public function putShortArray(key:String, value:Array<Int> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        TypeSafety.checkNotNull(value);
        #if !strict_language
        if(validateType)
            TypeSafety.checkShortArray(value);
        #end
        this.putObj(key, value, SFSDataType.SHORT_ARRAY);
    }

    public function putString(key:String, value:String):Void {
        TypeSafety.checkNotNull(value);
        TypeSafety.checkString(value);
        this.putObj(key, value, SFSDataType.STRING);
    }

    public function putShortString(key:String, value:String):Void {
        TypeSafety.checkNotNull(value);
        TypeSafety.checkShortString(value);
        this.putObj(key, value, SFSDataType.SHORT_STRING);
    }

    public function putText(key:String, value:String):Void {
        TypeSafety.checkNotNull(value);
        TypeSafety.checkText(value);
        this.putObj(key, value, SFSDataType.TEXT);
    }

    public function putVector2(key:String, value:SFSVector2 #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        TypeSafety.checkNotNull(value);
        #if !strict_language
        if(validateType)
            TypeSafety.checkVector2(value);
        #end
        this.putObj(key, value, SFSDataType.VECTOR2);
    }

    public function putVector3(key:String, value:SFSVector3 #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        TypeSafety.checkNotNull(value);
        #if !strict_language
        if(validateType)
            TypeSafety.checkVector3(value);
        #end
        this.putObj(key, value, SFSDataType.VECTOR3);
    }

    public function putStringArray(key:String, value:Array<String> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        TypeSafety.checkNotNull(value);
        #if !strict_language
        if(validateType)
            TypeSafety.checkStringArray(value);
        #end
        this.putObj(key, value, SFSDataType.STRING_ARRAY);
    }

    public function putShortStringArray(key:String, value:Array<String> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        TypeSafety.checkNotNull(value);
        #if !strict_language
        if(validateType)
            TypeSafety.checkShortStringArray(value);
        #end
        this.putObj(key, value, SFSDataType.SHORT_STRING_ARRAY);
    }

    public function putVector2Array(key:String, value:Array<SFSVector2> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        TypeSafety.checkNotNull(value);
        #if !strict_language
        if(validateType)
            TypeSafety.checkVector2Array(value);
        #end
        this.putObj(key, value, SFSDataType.VECTOR2_ARRAY);
    }

    public function putVector3Array(key:String, value:Array<SFSVector3> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        TypeSafety.checkNotNull(value);
        #if !strict_language
        if(validateType)
            TypeSafety.checkVector3Array(value);
        #end
        this.putObj(key, value, SFSDataType.VECTOR3_ARRAY);
    }

    public function put(key:String, wrappedObject:SFSDataWrapper #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        TypeSafety.checkNotNull(wrappedObject);
        #if !strict_language
        if(validateType)
            TypeSafety.checkDataWrapper(wrappedObject);
        #end
        this.putObj(key, wrappedObject, null);
    }

    public function toString():String {
        return "[SFSObject, size: " + this.size() + "]";
    }

    private function putObj(key:String, value:Dynamic, typeId:Null<SFSDataType>):Void {
        if (key == null) {
            throw new Exception("SFSObject requires a non-null key for a 'put' operation");
        } else if (key.length > 255) {
            throw new Exception("SFSObject keys must not exceed 255 characters");
        } else if (value == null && typeId != SFSDataType.NULL) {
            throw new Exception("SFSObject requires a non-null value! Key: " + key + " -- If you need to add a null use the putNull() method.");
        } else {
            if (Std.isOfType(value, SFSDataWrapper)) {
                dataHolder.set(key, cast value);
            } else {
                dataHolder.set(key, new SFSDataWrapper(typeId, value));
            }
        }
    }

    private function flatten():Map<String, Dynamic> {
        var map = new Map<String, Dynamic>();
        DefaultSFSDataSerializer.getInstance().flattenObject(map, this);
        return map;
    }
}
