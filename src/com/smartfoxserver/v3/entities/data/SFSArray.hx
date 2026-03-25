package com.smartfoxserver.v3.entities.data;

import com.smartfoxserver.v3.bitswarm.util.ByteUtils;
import com.smartfoxserver.v3.protocol.serialization.DefaultObjectDumpFormatter;
import com.smartfoxserver.v3.protocol.serialization.DefaultSFSDataSerializer;
import com.smartfoxserver.v3.protocol.serialization.ISFSDataSerializer;
import haxe.io.Bytes;
import com.smartfoxserver.v3.exceptions.UnsupportedOperationException;
import haxe.io.BytesData;
import com.smartfoxserver.v3.util.TypeSafety;

@:expose("SFS3.SFSArray")
class SFSArray implements ISFSArray {
    private final serializer:ISFSDataSerializer = DefaultSFSDataSerializer.getInstance();
    private final dataHolder:Array<SFSDataWrapper> = new Array();

    public function new() {

    }

    public static function newFromBinaryData(bytes:BytesData):SFSArray {
        return DefaultSFSDataSerializer.getInstance().binary2array(bytes);
    }

    public static function newFromJsonData(jsonStr:String):SFSArray {
        return DefaultSFSDataSerializer.getInstance().json2array(jsonStr);
    }

    public static function newInstance():SFSArray {
        return new SFSArray();
    }

    public function getDump(noFormat:Bool = true):String {
        return !noFormat ? this.dump() : (this.size() == 0 ? "[ Empty SFSArray ]" : DefaultObjectDumpFormatter.prettyPrintDump(this.dump()));
    }

    private function dump():String {
        if (this.size() < 1) {
            return "[]";
        } else {
            var sb:StringBuf = new StringBuf();
            sb.add('\u0011');

            for(i in 0...this.dataHolder.length) {
                var wrapper:SFSDataWrapper = this.dataHolder[i];
                var typeId:SFSDataType = wrapper.getTypeId();
                sb.add(" (");
                sb.add(typeId.name().toLowerCase());
                sb.add(") ");
                sb.add(i);
                sb.add(": ");
                sb.add(DefaultObjectDumpFormatter.formattedValue(wrapper));
                if (i < this.dataHolder.length - 1) {
                    sb.add('\u0013');
                }
            }

            sb.add('\u0012');
            return sb.toString();
        }
    }

    public function getHexDump():String {
        return ByteUtils.hexDump(this.toBinary());
    }

    public function toBinary():BytesData {
        return this.serializer.array2binary(this);
    }

    public function toArray():Array<Dynamic>
    {
        return DefaultSFSDataSerializer.getInstance().sfsArrayToGenericArray(this);
    }

    public function toJson():String {
        return DefaultSFSDataSerializer.getInstance().array2json(this.flatten());
    }

    public function isNull(index:Int):Bool {
        var wrapper:SFSDataWrapper = this.dataHolder[index];
        if (wrapper == null) {
            return false;
        } else {
            return wrapper.getTypeId() == SFSDataType.NULL.getTypeID();
        }
    }

    public function get(index:Int):SFSDataWrapper {
        return this.dataHolder[index];
    }

    public function getBool(index:Int):Null<Bool> {
        var wrapper:SFSDataWrapper = this.dataHolder[index];
        return wrapper != null ? cast wrapper.getObject() : null;
    }

    public function getByte(index:Int):Null<Int> {
        var wrapper:SFSDataWrapper = this.dataHolder[index];
        return wrapper != null ? cast wrapper.getObject() : null;
    }

    public function getUnsignedByte(index:Int):Null<Int> {
        var wrapper:SFSDataWrapper = this.dataHolder[index];
        return wrapper != null ? DefaultSFSDataSerializer.getInstance().getUnsignedByte(cast wrapper.getObject()) : null;
    }

    public function getShort(index:Int):Null<Int> {
        var wrapper:SFSDataWrapper = this.dataHolder[index];
        return wrapper != null ? cast wrapper.getObject() : null;
    }

    public function getInt(index:Int):Null<Int> {
        var wrapper:SFSDataWrapper = this.dataHolder[index];
        return wrapper != null ? cast wrapper.getObject() : null;
    }

    public function getLong(index:Int):Null<PlatformInt64> {
        var wrapper:SFSDataWrapper = this.dataHolder[index];
        return wrapper != null ? cast wrapper.getObject() : null;
    }

    public function getFloat(index:Int):Null<Float> {
        var wrapper:SFSDataWrapper = this.dataHolder[index];
        return wrapper != null ? cast wrapper.getObject() : null;
    }

    public function getDouble(index:Int):Null<Float> {
        var wrapper:SFSDataWrapper = this.dataHolder[index];
        return wrapper != null ? cast wrapper.getObject() : null;
    }

    public function getString(index:Int):Null<String> {
        var wrapper:SFSDataWrapper = this.dataHolder[index];
        return wrapper != null ? cast wrapper.getObject() : null;
    }

    public function getShortString(index:Int):Null<String> {
        return this.getString(index);
    }

    public function getText(index:Int):Null<String> {
        return this.getString(index);
    }

    public function getVector2(index:Int):Null<SFSVector2> {
        var wrapper:SFSDataWrapper = this.dataHolder[index];
        return wrapper != null ? wrapper.getObject() : null;
    }

    public function getVector3(index:Int):Null<SFSVector3> {
        var wrapper:SFSDataWrapper = this.dataHolder[index];
        return wrapper != null ? wrapper.getObject() : null;
    }

    public function getBoolArray(index:Int):Null<Array<Bool>> {
        var wrapper:SFSDataWrapper = this.dataHolder[index];
        return wrapper != null ? cast wrapper.getObject() : null;
    }

    public function getByteArray(index:Int):Null<BytesData> {
        var wrapper:SFSDataWrapper = this.dataHolder[index];
        return wrapper != null ? cast wrapper.getObject() : null;
    }

    public function getUnsignedByteArray(index:Int):Null<BytesData> {
        var wrapper:SFSDataWrapper = this.dataHolder[index];
        if (wrapper == null) {
            return null;
        } else {
            var serializer:ISFSDataSerializer = DefaultSFSDataSerializer.getInstance();
            var wrapperBytes:Bytes = cast wrapper.getObject();
            var unsignedBytes:Bytes = Bytes.alloc(wrapperBytes.length);

            for(i in 0...wrapperBytes.length) {
                var b:Int = wrapperBytes.get(i);
                unsignedBytes.set(i, serializer.getUnsignedByte(b));
            }

            return unsignedBytes.getData();
        }
    }

    public function getShortArray(index:Int):Null<Array<Int>> {
        var wrapper:SFSDataWrapper = this.dataHolder[index];
        return wrapper != null ? cast wrapper.getObject() : null;
    }

    public function getIntArray(index:Int):Null<Array<Int>> {
        var wrapper:SFSDataWrapper = this.dataHolder[index];
        return wrapper != null ? cast wrapper.getObject() : null;
    }

    public function getLongArray(index:Int):Null<Array<PlatformInt64>> {
        var wrapper:SFSDataWrapper = this.dataHolder[index];
        return wrapper != null ? cast wrapper.getObject() : null;
    }

    public function getFloatArray(index:Int):Null<Array<Float>> {
        var wrapper:SFSDataWrapper = this.dataHolder[index];
        return wrapper != null ? cast wrapper.getObject() : null;
    }

    public function getDoubleArray(index:Int):Null<Array<Float>> {
        var wrapper:SFSDataWrapper = this.dataHolder[index];
        return wrapper != null ? cast wrapper.getObject() : null;
    }

    public function getStringArray(index:Int):Null<Array<String>> {
        var wrapper:SFSDataWrapper = this.dataHolder[index];
        return wrapper != null ? cast wrapper.getObject() : null;
    }

    public function getShortStringArray(index:Int):Null<Array<String>> {
        return this.getStringArray(index);
    }

    public function getVector2Array(index:Int):Null<Array<SFSVector2>> {
        var wrapper:SFSDataWrapper = this.dataHolder[index];
        return wrapper != null ? cast wrapper.getObject() : null;
    }

    public function getVector3Array(index:Int):Null<Array<SFSVector3>> {
        var wrapper:SFSDataWrapper = this.dataHolder[index];
        return wrapper != null ? cast wrapper.getObject() : null;
    }

    public function getSFSArray(index:Int):Null<ISFSArray> {
        var wrapper:SFSDataWrapper = this.dataHolder[index];
        return wrapper != null ? cast wrapper.getObject() : null;
    }

    public function getSFSObject(index:Int):Null<ISFSObject> {
        var wrapper:SFSDataWrapper = this.dataHolder[index];
        return wrapper != null ? cast wrapper.getObject() : null;
    }

    public function addBool(value:Bool #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        TypeSafety.checkNotNull(value);
        #if !strict_language
        if(validateType)
            TypeSafety.checkBool(value);
        #end
        this.addObject(value, SFSDataType.BOOL);
    }

    public function addBoolArray(value:Array<Bool> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        TypeSafety.checkNotNull(value);
        #if !strict_language
        if(validateType)
            TypeSafety.checkBoolArray(value);
        #end
        this.addObject(value, SFSDataType.BOOL_ARRAY);
    }

    public function addByte(value:Int #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        TypeSafety.checkNotNull(value);
        #if !strict_language
        if(validateType)
            TypeSafety.checkByte(value);
        #end
        this.addObject(value, SFSDataType.BYTE);
    }

    public function addByteArray(value:BytesData #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        #if !strict_language
        if(validateType)
            TypeSafety.checkByteArray(value);
        #end
        this.addObject(value, SFSDataType.BYTE_ARRAY);
    }

    public function addDouble(value:Float #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        #if !strict_language
        if(validateType)
            TypeSafety.checkDouble(value);
        #end
        this.addObject(value, SFSDataType.DOUBLE);
    }

    public function addDoubleArray(value:Array<Float> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        #if !strict_language
        if(validateType)
            TypeSafety.checkDoubleArray(value);
        #end
        this.addObject(value, SFSDataType.DOUBLE_ARRAY);
    }

    public function addFloat(value:Float #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        #if !strict_language
        if(validateType)
            TypeSafety.checkFloat(value);
        #end
        this.addObject(value, SFSDataType.FLOAT);
    }

    public function addFloatArray(value:Array<Float> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        #if !strict_language
        if(validateType)
            TypeSafety.checkFloatArray(value);
        #end
        this.addObject(value, SFSDataType.FLOAT_ARRAY);
    }

    public function addInt(value:Int #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        #if !strict_language
        if(validateType)
            TypeSafety.checkInt(value);
        #end
        this.addObject(value, SFSDataType.INT);
    }

    public function addIntArray(value:Array<Int> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        #if !strict_language
        if(validateType)
            TypeSafety.checkIntArray(value);
        #end
        this.addObject(value, SFSDataType.INT_ARRAY);
    }

    public function addLong(value:PlatformInt64 #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        #if !strict_language
        if(validateType)
            TypeSafety.checkLong(value);
        #end
        this.addObject(value, SFSDataType.LONG);
    }

    public function addLongArray(value:Array<PlatformInt64> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        #if !strict_language
        if(validateType)
            TypeSafety.checkLongArray(value);
        #end
        this.addObject(value, SFSDataType.LONG_ARRAY);
    }

    public function addNull():Void {
        this.addObject(null, SFSDataType.NULL);
    }

    public function addSFSArray(value:ISFSArray #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        #if !strict_language
        if(validateType)
            TypeSafety.checkSFSArray(value);
        #end
        this.addObject(value, SFSDataType.SFS_ARRAY);
    }

    public function addSFSObject(value:ISFSObject #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        #if !strict_language
        if(validateType)
            TypeSafety.checkSFSObject(value);
        #end
        this.addObject(value, SFSDataType.SFS_OBJECT);
    }

    public function addShort(value:Int #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        #if !strict_language
        if(validateType)
            TypeSafety.checkShort(value);
        #end
        this.addObject(value, SFSDataType.SHORT);
    }

    public function addShortArray(value:Array<Int> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        #if !strict_language
        if(validateType)
            TypeSafety.checkShortArray(value);
        #end
        this.addObject(value, SFSDataType.SHORT_ARRAY);
    }

    public function addString(value:String):Void {
        TypeSafety.checkString(value);
        this.addObject(value, SFSDataType.STRING);
    }

    public function addShortString(value:String):Void {
        TypeSafety.checkShortString(value);
        this.addObject(value, SFSDataType.SHORT_STRING);
    }

    public function addText(value:String):Void {
        TypeSafety.checkText(value);
        this.addObject(value, SFSDataType.TEXT);
    }

    public function addVector2(value:SFSVector2 #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        #if !strict_language
        if(validateType)
            TypeSafety.checkVector2(value);
        #end
        this.addObject(value, SFSDataType.VECTOR2);
    }

    public function addVector3(value:SFSVector3 #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        #if !strict_language
        if(validateType)
            TypeSafety.checkVector3(value);
        #end
        this.addObject(value, SFSDataType.VECTOR3);
    }

    public function addStringArray(value:Array<String> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        #if !strict_language
        if(validateType)
            TypeSafety.checkStringArray(value);
        #end
        this.addObject(value, SFSDataType.STRING_ARRAY);
    }

    public function addShortStringArray(value:Array<String> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        #if !strict_language
        if(validateType)
            TypeSafety.checkShortStringArray(value);
        #end
        this.addObject(value, SFSDataType.SHORT_STRING_ARRAY);
    }

    public function addVector2Array(value:Array<SFSVector2> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        #if !strict_language
        if(validateType)
            TypeSafety.checkVector2Array(value);
        #end
        this.addObject(value, SFSDataType.VECTOR2_ARRAY);
    }

    public function addVector3Array(value:Array<SFSVector3> #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        #if !strict_language
        if(validateType)
            TypeSafety.checkVector3Array(value);
        #end
        this.addObject(value, SFSDataType.VECTOR3_ARRAY);
    }

    public function add(wrappedObject:SFSDataWrapper #if !strict_language, validateType:Bool = #if default_validation true #else false #end #end):Void {
        #if !strict_language
        if(validateType)
            TypeSafety.checkDataWrapper(wrappedObject);
        #end
        this.dataHolder.push(wrappedObject);
    }

    public function contains(obj:Dynamic):Bool {
        if (!(obj is ISFSArray) && !(obj is ISFSObject)) {
            var found:Bool = false;
            var iter:Iterator<SFSDataWrapper> = this.dataHolder.iterator();

            while(iter.hasNext()) {
                var item:Dynamic = cast iter.next().getObject();
                if (item == obj) {
                    found = true;
                    break;
                }
            }

            return found;
        } else {
            throw new UnsupportedOperationException("ISFSArray and ISFSObject are not supported by this method.");
        }
    }

    public function getElementAt(index:Int):Null<Dynamic> {
        var item:Dynamic = null;
        var wrapper:SFSDataWrapper = this.dataHolder[index];
        return wrapper != null ? cast wrapper.getObject() : null;
    }

    public function iterator():Iterator<SFSDataWrapper> {
        return this.dataHolder.iterator();
    }

    public function removeElementAt(index:Int):Void {
        var wrapper:SFSDataWrapper = this.dataHolder[index];
        if (wrapper != null) {
            this.dataHolder.splice(index, 1);
        }
    }

    public function size():Int {
        return this.dataHolder.length;
    }

    public function toString():String {
        return "[SFSArray, size: " + this.size() + "]";
    }

    private function addObject(value:Dynamic, typeId:SFSDataType):Void {
        this.dataHolder.push(new SFSDataWrapper(typeId, value));
    }

    private function flatten():Array<Dynamic> {
        var list:Array<Dynamic> = new Array();
        DefaultSFSDataSerializer.getInstance().flattenArray(list, this);
        return list;
    }
}
