package com.smartfoxserver.v3.bitswarm.io.protocol.serialization;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import haxe.Json;
import com.smartfoxserver.v3.core.Logger;
import com.smartfoxserver.v3.core.LoggerFactory;
import com.smartfoxserver.v3.entities.data.ISFSArray;
import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.entities.data.SFSArray;
import com.smartfoxserver.v3.entities.data.SFSDataType;
import com.smartfoxserver.v3.entities.data.SFSDataWrapper;
import com.smartfoxserver.v3.entities.data.SFSObject;
import com.smartfoxserver.v3.entities.data.SFSVector2;
import com.smartfoxserver.v3.entities.data.SFSVector3;
import com.smartfoxserver.v3.exceptions.SFSCodecException;
import haxe.io.BytesData;
import com.smartfoxserver.v3.entities.data.PlatformInt64;
import com.smartfoxserver.v3.util.TypeSafety;

class DefaultSFSDataSerializer implements ISFSDataSerializer {
    private static var _instance:DefaultSFSDataSerializer;
    private var logger:Logger;

    public static function getInstance():DefaultSFSDataSerializer {
        if (_instance == null)
            _instance = new DefaultSFSDataSerializer();
        return _instance;
    }

    private function new() {
        logger = LoggerFactory.getLogger(Type.getClass(this));
    }

    public function getUnsignedByte(b:Int):Int {
        return b & 0xFF;
    }

    // --- Binary to Object ---

    public function binary2object(data:BytesData):ISFSObject {
        #if !strict_language
        TypeSafety.checkByteArray(data);
        #end
        var bytes:Bytes = Bytes.ofData(data);
        if (bytes.length < 3)
            throw new haxe.Exception("Can't decode an SFSObject. Byte data is insufficient. Size: " + bytes.length + " bytes");
        var buffer = new BytesInput(bytes);
        buffer.bigEndian = true;
        return binaryinput2object(buffer);
    }

    private function binaryinput2object(data:BytesInput):ISFSObject {
        if (data.length < 3)
            throw new haxe.Exception("Can't decode an SFSObject. Byte data is insufficient. Size: " + data.length + " bytes");
        return decodeSFSObject(data);
    }

    public function binary2array(data:BytesData):SFSArray {
        #if !strict_language
        TypeSafety.checkByteArray(data);
        #end
        var bytes:Bytes = Bytes.ofData(data);
        if (bytes.length < 3)
            throw new haxe.Exception("Can't decode an SFSArray. Byte data is insufficient. Size: " + bytes.length + " bytes");
        var buffer = new BytesInput(bytes);
        buffer.bigEndian = true;
        return cast decodeSFSArray(buffer);
    }

    private function decodeSFSObject(buffer:BytesInput):ISFSObject {
        var sfsObject = SFSObject.newInstance();
        var headerByte = buffer.readByte();
        if (headerByte != SFSDataType.SFS_OBJECT)
            throw new haxe.Exception("Invalid SFSDataType. Expected: " + SFSDataType.SFS_OBJECT + ", found: " + headerByte);

        var size = buffer.readInt16();
        if (size < 0)
            throw new haxe.Exception("Can't decode SFSObject. Size is negative = " + size);

        for (i in 0...size) {
            var key = decodeSFSObjectKey(buffer);
            var decodedObject = decodeObject(buffer);
            if (decodedObject == null)
                throw new haxe.Exception("Could not decode value for key: " + key);
            sfsObject.put(key, decodedObject);
        }
        return sfsObject;
    }

    private function decodeSFSArray(buffer:BytesInput):ISFSArray {
        var sfsArray = SFSArray.newInstance();
        var headerByte = buffer.readByte();
        if (headerByte != SFSDataType.SFS_ARRAY)
            throw new haxe.Exception("Invalid SFSDataType. Expected: " + SFSDataType.SFS_ARRAY + ", found: " + headerByte);

        var size = buffer.readInt16();
        if (size < 0)
            throw new haxe.Exception("Can't decode SFSArray. Size is negative = " + size);

        for (i in 0...size) {
            var decodedObject = decodeObject(buffer);
            if (decodedObject == null)
                throw new haxe.Exception("Could not decode SFSArray item at index: " + i);
            sfsArray.add(decodedObject);
        }
        return sfsArray;
    }

    private function decodeSFSObjectKey(buffer:BytesInput):String {
        var keySize = buffer.readByte() & 0xFF;
        var keyData = buffer.read(keySize);
        return keyData.toString();
    }

    private function decodeObject(buffer:BytesInput):SFSDataWrapper {
        var headerByte = buffer.readByte();

        if (headerByte == SFSDataType.NULL) return binDecode_NULL(buffer);
        if (headerByte == SFSDataType.BOOL) return binDecode_BOOL(buffer);
        if (headerByte == SFSDataType.BOOL_ARRAY) return binDecode_BOOL_ARRAY(buffer);
        if (headerByte == SFSDataType.BYTE) return binDecode_BYTE(buffer);
        if (headerByte == SFSDataType.BYTE_ARRAY) return binDecode_BYTE_ARRAY(buffer);
        if (headerByte == SFSDataType.SHORT) return binDecode_SHORT(buffer);
        if (headerByte == SFSDataType.SHORT_ARRAY) return binDecode_SHORT_ARRAY(buffer);
        if (headerByte == SFSDataType.INT) return binDecode_INT(buffer);
        if (headerByte == SFSDataType.INT_ARRAY) return binDecode_INT_ARRAY(buffer);
        if (headerByte == SFSDataType.LONG) return binDecode_LONG(buffer);
        if (headerByte == SFSDataType.LONG_ARRAY) return binDecode_LONG_ARRAY(buffer);
        if (headerByte == SFSDataType.FLOAT) return binDecode_FLOAT(buffer);
        if (headerByte == SFSDataType.FLOAT_ARRAY) return binDecode_FLOAT_ARRAY(buffer);
        if (headerByte == SFSDataType.DOUBLE) return binDecode_DOUBLE(buffer);
        if (headerByte == SFSDataType.DOUBLE_ARRAY) return binDecode_DOUBLE_ARRAY(buffer);
        if (headerByte == SFSDataType.STRING) return binDecode_STRING(buffer);
        if (headerByte == SFSDataType.SHORT_STRING) return binDecode_SHORT_STRING(buffer);
        if (headerByte == SFSDataType.TEXT) return binDecode_TEXT(buffer);
        if (headerByte == SFSDataType.VECTOR2) return binDecode_VECTOR2(buffer);
        if (headerByte == SFSDataType.VECTOR3) return binDecode_VECTOR3(buffer);
        if (headerByte == SFSDataType.STRING_ARRAY) return binDecode_STRING_ARRAY(buffer);
        if (headerByte == SFSDataType.SHORT_STRING_ARRAY) return binDecode_SHORT_STRING_ARRAY(buffer);
        if (headerByte == SFSDataType.VECTOR2_ARRAY) return binDecode_VECTOR2_ARRAY(buffer);
        if (headerByte == SFSDataType.VECTOR3_ARRAY) return binDecode_VECTOR3_ARRAY(buffer);

        if (headerByte == SFSDataType.SFS_ARRAY) {
            buffer.position = buffer.position - 1;
            return new SFSDataWrapper(SFSDataType.SFS_ARRAY, decodeSFSArray(buffer));
        }

        if (headerByte == SFSDataType.SFS_OBJECT) {
            buffer.position = buffer.position - 1;
            return new SFSDataWrapper(SFSDataType.SFS_OBJECT, decodeSFSObject(buffer));
        }

        throw new SFSCodecException("Unknown SFSDataType ID: " + headerByte);
    }

    // --- Decode helpers ---

    private function binDecode_NULL(buffer:BytesInput):SFSDataWrapper {
        return new SFSDataWrapper(SFSDataType.NULL, null);
    }

    private function binDecode_BOOL(buffer:BytesInput):SFSDataWrapper {
        var boolByte = buffer.readByte();
        if (boolByte == 0) return new SFSDataWrapper(SFSDataType.BOOL, false);
        if (boolByte == 1) return new SFSDataWrapper(SFSDataType.BOOL, true);
        throw new SFSCodecException("Error decoding Bool type. Illegal value: " + boolByte);
    }

    private function binDecode_BYTE(buffer:BytesInput):SFSDataWrapper {
        return new SFSDataWrapper(SFSDataType.BYTE, buffer.readByte());
    }

    private function binDecode_SHORT(buffer:BytesInput):SFSDataWrapper {
        return new SFSDataWrapper(SFSDataType.SHORT, buffer.readInt16());
    }

    private function binDecode_INT(buffer:BytesInput):SFSDataWrapper {
        return new SFSDataWrapper(SFSDataType.INT, buffer.readInt32());
    }

    private function binDecode_LONG(buffer:BytesInput):SFSDataWrapper {
        var hi = buffer.readInt32();
        var lo = buffer.readInt32();
        trace(PlatformInt64.make(hi, lo));
        return new SFSDataWrapper(SFSDataType.LONG, PlatformInt64.make(hi, lo));
    }

    private function binDecode_FLOAT(buffer:BytesInput):SFSDataWrapper {
        return new SFSDataWrapper(SFSDataType.FLOAT, buffer.readFloat());
    }

    private function binDecode_DOUBLE(buffer:BytesInput):SFSDataWrapper {
        return new SFSDataWrapper(SFSDataType.DOUBLE, buffer.readDouble());
    }

    private function binDecode_STRING(buffer:BytesInput):SFSDataWrapper {
        var strLen = buffer.readInt16();
        if (strLen < 0) throw new SFSCodecException("Error decoding UtfString. Negative size: " + strLen);
        var strData = buffer.read(strLen);
        return new SFSDataWrapper(SFSDataType.STRING, strData.toString());
    }

    private function binDecode_SHORT_STRING(buffer:BytesInput):SFSDataWrapper {
        var strLen = buffer.readByte() & 0xFF;
        var strData = buffer.read(strLen);
        return new SFSDataWrapper(SFSDataType.SHORT_STRING, strData.toString());
    }

    private function binDecode_TEXT(buffer:BytesInput):SFSDataWrapper {
        var strLen = buffer.readInt32();
        if (strLen < 0) throw new SFSCodecException("Error decoding Text. Negative size: " + strLen);
        var strData = buffer.read(strLen);
        return new SFSDataWrapper(SFSDataType.TEXT, strData.toString());
    }

    private function binDecode_VECTOR2(buffer:BytesInput):SFSDataWrapper {
        var vec = new SFSVector2(buffer.readFloat(), buffer.readFloat());
        return new SFSDataWrapper(SFSDataType.VECTOR2, vec);
    }

    private function binDecode_VECTOR3(buffer:BytesInput):SFSDataWrapper {
        var vec = new SFSVector3(buffer.readFloat(), buffer.readFloat(), buffer.readFloat());
        return new SFSDataWrapper(SFSDataType.VECTOR3, vec);
    }

    private function binDecode_BOOL_ARRAY(buffer:BytesInput):SFSDataWrapper {
        var arraySize = getTypeArraySize(buffer);
        var arr = new Array<Bool>();
        for (j in 0...arraySize) {
            var boolData = buffer.readByte();
            if (boolData == 0) arr.push(false);
            else if (boolData == 1) arr.push(true);
            else throw new SFSCodecException("Error decoding BoolArray. Invalid bool value: " + boolData);
        }
        return new SFSDataWrapper(SFSDataType.BOOL_ARRAY, arr);
    }

    private function binDecode_BYTE_ARRAY(buffer:BytesInput):SFSDataWrapper {
        var arraySize = buffer.readInt32();
        if (arraySize < 0) throw new SFSCodecException("Error decoding typed array size. Negative size: " + arraySize);
        var byteData = buffer.read(arraySize);
        var bytesData:BytesData = byteData.getData();
        return new SFSDataWrapper(SFSDataType.BYTE_ARRAY, bytesData);
    }

    private function binDecode_SHORT_ARRAY(buffer:BytesInput):SFSDataWrapper {
        var arraySize = getTypeArraySize(buffer);
        var arr = new Array<Int>();
        for (j in 0...arraySize) arr.push(buffer.readInt16());
        return new SFSDataWrapper(SFSDataType.SHORT_ARRAY, arr);
    }

    private function binDecode_INT_ARRAY(buffer:BytesInput):SFSDataWrapper {
        var arraySize = getTypeArraySize(buffer);
        var arr = new Array<Int>();
        for (j in 0...arraySize) arr.push(buffer.readInt32());
        return new SFSDataWrapper(SFSDataType.INT_ARRAY, arr);
    }

    private function binDecode_LONG_ARRAY(buffer:BytesInput):SFSDataWrapper {
        var arraySize = getTypeArraySize(buffer);
        var arr = new Array<PlatformInt64>();
        for (j in 0...arraySize) {
            var hi = buffer.readInt32();
            var lo = buffer.readInt32();
            arr.push(PlatformInt64.make(hi, lo));
        }
        return new SFSDataWrapper(SFSDataType.LONG_ARRAY, arr);
    }

    private function binDecode_FLOAT_ARRAY(buffer:BytesInput):SFSDataWrapper {
        var arraySize = getTypeArraySize(buffer);
        var arr = new Array<Float>();
        for (j in 0...arraySize) arr.push(buffer.readFloat());
        return new SFSDataWrapper(SFSDataType.FLOAT_ARRAY, arr);
    }

    private function binDecode_DOUBLE_ARRAY(buffer:BytesInput):SFSDataWrapper {
        var arraySize = getTypeArraySize(buffer);
        var arr = new Array<Float>();
        for (j in 0...arraySize) arr.push(buffer.readDouble());
        return new SFSDataWrapper(SFSDataType.DOUBLE_ARRAY, arr);
    }

    private function binDecode_STRING_ARRAY(buffer:BytesInput):SFSDataWrapper {
        var arraySize = getTypeArraySize(buffer);
        var arr = new Array<String>();
        for (j in 0...arraySize) {
            var strLen = buffer.readInt16();
            if (strLen < 0) throw new SFSCodecException("Error decoding UtfStringArray element. Element has negative size: " + strLen);
            var strData = buffer.read(strLen);
            arr.push(strData.toString());
        }
        return new SFSDataWrapper(SFSDataType.STRING_ARRAY, arr);
    }

    private function binDecode_SHORT_STRING_ARRAY(buffer:BytesInput):SFSDataWrapper {
        var arraySize = getTypeArraySize(buffer);
        var arr = new Array<String>();
        for (j in 0...arraySize) {
            var strLen = buffer.readByte() & 0xFF;
            var strData = buffer.read(strLen);
            arr.push(strData.toString());
        }
        return new SFSDataWrapper(SFSDataType.SHORT_STRING_ARRAY, arr);
    }

    private function binDecode_VECTOR2_ARRAY(buffer:BytesInput):SFSDataWrapper {
        var arraySize = getTypeArraySize(buffer);
        var arr = new Array<SFSVector2>();
        for (j in 0...arraySize) arr.push(new SFSVector2(buffer.readFloat(), buffer.readFloat()));
        return new SFSDataWrapper(SFSDataType.VECTOR2_ARRAY, arr);
    }

    private function binDecode_VECTOR3_ARRAY(buffer:BytesInput):SFSDataWrapper {
        var arraySize = getTypeArraySize(buffer);
        var arr = new Array<SFSVector3>();
        for (j in 0...arraySize) arr.push(new SFSVector3(buffer.readFloat(), buffer.readFloat(), buffer.readFloat()));
        return new SFSDataWrapper(SFSDataType.VECTOR3_ARRAY, arr);
    }

    private function getTypeArraySize(buffer:BytesInput):Int {
        var arraySize = buffer.readInt16();
        if (arraySize < 0) throw new SFSCodecException("Error decoding typed array size. Negative size: " + arraySize);
        return arraySize;
    }

    // --- Object to Binary ---

    public function object2binary(object:ISFSObject):BytesData {
        var buffer = new BytesOutput();
        buffer.bigEndian = true;
        buffer.writeByte(SFSDataType.SFS_OBJECT);
        buffer.writeInt16(object.size());
        return obj2bin(object, buffer);
    }

    private function obj2bin(object:ISFSObject, buffer:BytesOutput):BytesData {
        for (key in object.getKeys()) {
            var wrapper = object.get(key);
            encodeSFSObjectKey(buffer, key);
            encodeObject(buffer, wrapper.getTypeId(), wrapper.getObject());
        }
        return buffer.getBytes().getData();
    }

    public function array2binary(array:ISFSArray):BytesData {
        var buffer = new BytesOutput();
        buffer.bigEndian = true;
        buffer.writeByte(SFSDataType.SFS_ARRAY);
        buffer.writeInt16(array.size());
        return arr2bin(array, buffer);
    }

    private function arr2bin(array:ISFSArray, buffer:BytesOutput):BytesData {
        for (wrapper in array) {
            encodeObject(buffer, wrapper.getTypeId(), wrapper.getObject());
        }
        return buffer.getBytes().getData();
    }

    private function encodeSFSObjectKey(buffer:BytesOutput, value:String):Void {
        var keyBytes = Bytes.ofString(value);
        if (keyBytes.length > 255)
            throw new haxe.Exception("Object Key size: " + keyBytes.length + ", expected max 255 bytes.");
        buffer.writeByte(keyBytes.length);
        buffer.write(keyBytes);
    }

    private function encodeObject(buffer:BytesOutput, typeId:SFSDataType, object:Dynamic):Void {
        if (typeId == SFSDataType.NULL) { binEncode_NULL(buffer); }
        else if (typeId == SFSDataType.BOOL) { binEncode_BOOL(buffer, cast object); }
        else if (typeId == SFSDataType.BYTE) { binEncode_BYTE(buffer, cast object); }
        else if (typeId == SFSDataType.SHORT) { binEncode_SHORT(buffer, cast object); }
        else if (typeId == SFSDataType.INT) { binEncode_INT(buffer, cast object); }
        else if (typeId == SFSDataType.LONG) { binEncode_LONG(buffer, cast object); }
        else if (typeId == SFSDataType.FLOAT) { binEncode_FLOAT(buffer, cast object); }
        else if (typeId == SFSDataType.DOUBLE) { binEncode_DOUBLE(buffer, cast object); }
        else if (typeId == SFSDataType.STRING) { binEncode_STRING(buffer, cast object); }
        else if (typeId == SFSDataType.SHORT_STRING) { binEncode_SHORT_STRING(buffer, cast object); }
        else if (typeId == SFSDataType.TEXT) { binEncode_TEXT(buffer, cast object); }
        else if (typeId == SFSDataType.VECTOR2) { binEncode_VECTOR2(buffer, cast object); }
        else if (typeId == SFSDataType.VECTOR3) { binEncode_VECTOR3(buffer, cast object); }
        else if (typeId == SFSDataType.BOOL_ARRAY) { binEncode_BOOL_ARRAY(buffer, cast object); }
        else if (typeId == SFSDataType.BYTE_ARRAY) { binEncode_BYTE_ARRAY(buffer, cast object); }
        else if (typeId == SFSDataType.SHORT_ARRAY) { binEncode_SHORT_ARRAY(buffer, cast object); }
        else if (typeId == SFSDataType.INT_ARRAY) { binEncode_INT_ARRAY(buffer, cast object); }
        else if (typeId == SFSDataType.LONG_ARRAY) { binEncode_LONG_ARRAY(buffer, cast object); }
        else if (typeId == SFSDataType.FLOAT_ARRAY) { binEncode_FLOAT_ARRAY(buffer, cast object); }
        else if (typeId == SFSDataType.DOUBLE_ARRAY) { binEncode_DOUBLE_ARRAY(buffer, cast object); }
        else if (typeId == SFSDataType.STRING_ARRAY) { binEncode_STRING_ARRAY(buffer, cast object); }
        else if (typeId == SFSDataType.SHORT_STRING_ARRAY) { binEncode_SHORT_STRING_ARRAY(buffer, cast object); }
        else if (typeId == SFSDataType.VECTOR2_ARRAY) { binEncode_VECTOR2_ARRAY(buffer, cast object); }
        else if (typeId == SFSDataType.VECTOR3_ARRAY) { binEncode_VECTOR3_ARRAY(buffer, cast object); }
        else if (typeId == SFSDataType.SFS_ARRAY) { buffer.write(Bytes.ofData(array2binary(cast object))); }
        else if (typeId == SFSDataType.SFS_OBJECT) { buffer.write(Bytes.ofData(object2binary(cast object))); }
        else { throw new haxe.Exception("Unrecognized type in SFSObject serialization: " + typeId); }
    }

    // --- Encode helpers ---

    private function binEncode_NULL(buffer:BytesOutput):Void {
        buffer.writeByte(SFSDataType.NULL);
    }

    private function binEncode_BOOL(buffer:BytesOutput, value:Bool):Void {
        buffer.writeByte(SFSDataType.BOOL);
        buffer.writeByte(value ? 1 : 0);
    }

    private function binEncode_BYTE(buffer:BytesOutput, value:Int):Void {
        buffer.writeByte(SFSDataType.BYTE);
        buffer.writeByte(value);
    }

    private function binEncode_SHORT(buffer:BytesOutput, value:Int):Void {
        buffer.writeByte(SFSDataType.SHORT);
        buffer.writeInt16(value);
    }

    private function binEncode_INT(buffer:BytesOutput, value:Int):Void {
        buffer.writeByte(SFSDataType.INT);
        buffer.writeInt32(value);
    }

    private function binEncode_LONG(buffer:BytesOutput, value:PlatformInt64):Void {
        buffer.writeByte(SFSDataType.LONG);
        buffer.writeInt32(value.high);
        buffer.writeInt32(value.low);
    }

    private function binEncode_FLOAT(buffer:BytesOutput, value:Float):Void {
        buffer.writeByte(SFSDataType.FLOAT);
        buffer.writeFloat(value);
    }

    private function binEncode_DOUBLE(buffer:BytesOutput, value:Float):Void {
        buffer.writeByte(SFSDataType.DOUBLE);
        buffer.writeDouble(value);
    }

    private function binEncode_STRING(buffer:BytesOutput, value:String):Void {
        var stringBytes = Bytes.ofString(value);
        if (stringBytes.length > 32767)
            throw new haxe.Exception("String element exceeds max size: " + stringBytes.length + ", Limit is: 32767");
        buffer.writeByte(SFSDataType.STRING);
        buffer.writeInt16(stringBytes.length);
        buffer.write(stringBytes);
    }

    private function binEncode_SHORT_STRING(buffer:BytesOutput, value:String):Void {
        var stringBytes = Bytes.ofString(value);
        if (stringBytes.length > 255)
            throw new haxe.Exception("Short String element exceeds max size: " + stringBytes.length + ", Limit is: 255");
        buffer.writeByte(SFSDataType.SHORT_STRING);
        buffer.writeByte(stringBytes.length);
        buffer.write(stringBytes);
    }

    private function binEncode_TEXT(buffer:BytesOutput, value:String):Void {
        var stringBytes = Bytes.ofString(value);
        buffer.writeByte(SFSDataType.TEXT);
        buffer.writeInt32(stringBytes.length);
        buffer.write(stringBytes);
    }

    private function binEncode_VECTOR2(buffer:BytesOutput, value:SFSVector2):Void {
        buffer.writeByte(SFSDataType.VECTOR2);
        buffer.writeFloat(value.x);
        buffer.writeFloat(value.y);
    }

    private function binEncode_VECTOR3(buffer:BytesOutput, value:SFSVector3):Void {
        buffer.writeByte(SFSDataType.VECTOR3);
        buffer.writeFloat(value.x);
        buffer.writeFloat(value.y);
        buffer.writeFloat(value.z);
    }

    private function binEncode_BOOL_ARRAY(buffer:BytesOutput, value:Array<Bool>):Void {
        buffer.writeByte(SFSDataType.BOOL_ARRAY);
        buffer.writeInt16(value.length);
        for (b in value) buffer.writeByte(b ? 1 : 0);
    }

    private function binEncode_BYTE_ARRAY(buffer:BytesOutput, value:BytesData):Void {
        var bytes:Bytes = Bytes.ofData(value);

        buffer.writeByte(SFSDataType.BYTE_ARRAY);
        buffer.writeInt32(bytes.length);
        buffer.write(bytes);
    }

    private function binEncode_SHORT_ARRAY(buffer:BytesOutput, value:Array<Int>):Void {
        buffer.writeByte(SFSDataType.SHORT_ARRAY);
        buffer.writeInt16(value.length);
        for (item in value) buffer.writeInt16(item);
    }

    private function binEncode_INT_ARRAY(buffer:BytesOutput, value:Array<Int>):Void {
        buffer.writeByte(SFSDataType.INT_ARRAY);
        buffer.writeInt16(value.length);
        for (item in value) buffer.writeInt32(item);
    }

    private function binEncode_LONG_ARRAY(buffer:BytesOutput, value:Array<PlatformInt64>):Void {
        buffer.writeByte(SFSDataType.LONG_ARRAY);
        buffer.writeInt16(value.length);
        for (item in value) {
            buffer.writeInt32(item.high);
            buffer.writeInt32(item.low);
        }
    }

    private function binEncode_FLOAT_ARRAY(buffer:BytesOutput, value:Array<Float>):Void {
        buffer.writeByte(SFSDataType.FLOAT_ARRAY);
        buffer.writeInt16(value.length);
        for (item in value) buffer.writeFloat(item);
    }

    private function binEncode_DOUBLE_ARRAY(buffer:BytesOutput, value:Array<Float>):Void {
        buffer.writeByte(SFSDataType.DOUBLE_ARRAY);
        buffer.writeInt16(value.length);
        for (item in value) buffer.writeDouble(item);
    }

    private function binEncode_STRING_ARRAY(buffer:BytesOutput, value:Array<String>):Void {
        buffer.writeByte(SFSDataType.STRING_ARRAY);
        buffer.writeInt16(value.length);
        for (item in value) {
            var binStr = Bytes.ofString(item);
            if (binStr.length > 32767)
                throw new haxe.Exception("String element in array exceeds max size: " + binStr.length + ", Limit is: 32767");
            buffer.writeInt16(binStr.length);
            buffer.write(binStr);
        }
    }

    private function binEncode_SHORT_STRING_ARRAY(buffer:BytesOutput, value:Array<String>):Void {
        buffer.writeByte(SFSDataType.SHORT_STRING_ARRAY);
        buffer.writeInt16(value.length);
        for (item in value) {
            var binStr = Bytes.ofString(item);
            if (binStr.length > 255)
                throw new haxe.Exception("Short String element in array exceeds max size: " + binStr.length + ", Limit is: 255");
            buffer.writeByte(binStr.length);
            buffer.write(binStr);
        }
    }

    private function binEncode_VECTOR2_ARRAY(buffer:BytesOutput, value:Array<SFSVector2>):Void {
        buffer.writeByte(SFSDataType.VECTOR2_ARRAY);
        buffer.writeInt16(value.length);
        for (vec in value) {
            buffer.writeFloat(vec.x);
            buffer.writeFloat(vec.y);
        }
    }

    private function binEncode_VECTOR3_ARRAY(buffer:BytesOutput, value:Array<SFSVector3>):Void {
        buffer.writeByte(SFSDataType.VECTOR3_ARRAY);
        buffer.writeInt16(value.length);
        for (vec in value) {
            buffer.writeFloat(vec.x);
            buffer.writeFloat(vec.y);
            buffer.writeFloat(vec.z);
        }
    }

    // --- JSON ---

    public function object2json(map:Map<String, Dynamic>):String {
        var obj:Dynamic = {};
        for (key => value in map) {
            Reflect.setField(obj, key, value);
        }
        return Json.stringify(obj);
    }

    public function array2json(list:Array<Dynamic>):String {
        return Json.stringify(list);
    }

    public function json2object(jsonStr:String):ISFSObject {
        if (jsonStr.length < 2)
            throw new haxe.Exception("Can't decode SFSObject. JSON String is too short. Len: " + jsonStr.length);
        var parsed:Dynamic = Json.parse(jsonStr);
        return decodeJsonSFSObject(parsed);
    }

    public function json2array(jsonStr:String):SFSArray {
        if (jsonStr.length < 2)
            throw new haxe.Exception("Can't decode SFSArray. JSON String is too short. Len: " + jsonStr.length);
        var parsed:Array<Dynamic> = Json.parse(jsonStr);
        return decodeJsonSFSArray(parsed);
    }

    private function decodeJsonSFSObject(jso:Dynamic):ISFSObject {
        var sfsObject = SFSObject.newInstance();
        var fields = Reflect.fields(jso);
        for (key in fields) {
            var value:Dynamic = Reflect.field(jso, key);
            var decodedObject = decodeJsonObject(value);
            if (decodedObject == null)
                throw new haxe.Exception("(json2sfsobj) Could not decode value for key: " + key);
            sfsObject.put(key, decodedObject);
        }
        return sfsObject;
    }

    private function decodeJsonSFSArray(jsa:Array<Dynamic>):SFSArray {
        var sfsArray = SFSArray.newInstance();
        for (value in jsa) {
            var decodedObject = decodeJsonObject(value);
            if (decodedObject == null)
                throw new haxe.Exception("(json2sfarray) Could not decode value for object: " + Std.string(value));
            sfsArray.add(decodedObject);
        }
        return sfsArray;
    }

    private function decodeJsonObject(o:Dynamic):SFSDataWrapper {
        if (o == null) return new SFSDataWrapper(SFSDataType.NULL, null);
        if (Std.isOfType(o, Bool)) return new SFSDataWrapper(SFSDataType.BOOL, o);
        if (Std.isOfType(o, Int)) return new SFSDataWrapper(SFSDataType.INT, o);
        if (Std.isOfType(o, Float)) return new SFSDataWrapper(SFSDataType.DOUBLE, o);
        if (Std.isOfType(o, String)) {
            var str:String = cast o;
            var type = str.length > 32767 ? SFSDataType.TEXT : SFSDataType.STRING;
            return new SFSDataWrapper(type, o);
        }
        if (Std.isOfType(o, Array)) return new SFSDataWrapper(SFSDataType.SFS_ARRAY, decodeJsonSFSArray(cast o));
        // Otherwise treat as anonymous object => SFSObject
        return new SFSDataWrapper(SFSDataType.SFS_OBJECT, decodeJsonSFSObject(o));
    }

    // --- Flatten ---

    public function flattenObject(map:Map<String, Dynamic>, sfsObj:SFSObject):Void {
        for (wrapper in sfsObj) {
            // We need the key - iterate over the internal map via getKeys
        }
        // Use getKeys approach
        for (key in sfsObj.getKeys()) {
            var value = sfsObj.get(key);
            if (value.getTypeId() == SFSDataType.SFS_OBJECT) {
                var newMap = new Map<String, Dynamic>();
                map.set(key, newMap);
                flattenObject(newMap, cast value.getObject());
            } else if (value.getTypeId() == SFSDataType.SFS_ARRAY) {
                var newList = new Array<Dynamic>();
                map.set(key, newList);
                flattenArray(newList, cast value.getObject());
            } else {
                map.set(key, value.getObject());
            }
        }
    }

    public function flattenArray(array:Array<Dynamic>, sfsArray:SFSArray):Void {
        for (value in sfsArray) {
            if (value.getTypeId() == SFSDataType.SFS_OBJECT) {
                var newMap = new Map<String, Dynamic>();
                array.push(newMap);
                flattenObject(newMap, cast value.getObject());
            } else if (value.getTypeId() == SFSDataType.SFS_ARRAY) {
                var newList = new Array<Dynamic>();
                array.push(newList);
                flattenArray(newList, cast value.getObject());
            } else {
                array.push(value.getObject());
            }
        }
    }
}
