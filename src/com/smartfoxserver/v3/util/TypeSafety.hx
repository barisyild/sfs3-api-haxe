package com.smartfoxserver.v3.util;
import com.smartfoxserver.v3.entities.data.PlatformInt64;
import com.smartfoxserver.v3.exceptions.IllegalArgumentException;
import haxe.io.BytesData;
import com.smartfoxserver.v3.entities.data.ISFSArray;
import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.entities.data.SFSVector2;
import com.smartfoxserver.v3.entities.data.SFSVector3;
import com.smartfoxserver.v3.entities.data.SFSDataWrapper;
class TypeSafety {

    public static function checkBool(value:Bool):Void {
        var isBool:Bool = value is Bool;
        if(!isBool)
            throw new IllegalArgumentException("Value is not a boolean.");
    }

    public static function checkBoolArray(value:Array<Bool>):Void {
        var isBoolArray:Bool;
        #if python
        isBoolArray = python.Syntax.code("all(isinstance(x, bool) for x in {0})", value);
        #elseif js
        isBoolArray = js.Syntax.code("{0}.every(x => typeof x === 'boolean')", value);
        #else
        isBoolArray = Lambda.find(value, val -> !(val is Bool)) == null;
        #end
        if(!isBoolArray)
            throw new IllegalArgumentException("Array contains non-boolean values.");
    }

    public static function checkFloat(value:Float):Void {
        var isFloat:Bool = value is Float;
        if(!isFloat)
            throw new IllegalArgumentException("Value is not a float.");
    }
    
    public static function checkFloatArray(value:Array<Float>):Void {
        var isFloatArray:Bool;
        #if python
        isFloatArray = python.Syntax.code("all(isinstance(x, float) for x in {0})", value);
        #elseif js
        isFloatArray = js.Syntax.code("{0}.every(Number.isFloat)", value);
        #else
        isFloatArray = Lambda.find(value, val -> !(val is Float)) == null;
        #end
        if(!isFloatArray)
            throw new IllegalArgumentException("Array contains non-float values.");
    }

    public static function checkDouble(value:Float):Void {
        return checkFloat(value);
    }

    public static function checkDoubleArray(value:Array<Float>):Void {
        return checkFloatArray(value);
    }

    public static function checkShortString(value:String):Void {
        return checkString(value);
    }

    public static function checkString(value:String):Void {
        var isStringType:Bool = value is String;
        if(!isStringType)
            throw new IllegalArgumentException('Value is not a "string" type.');
    }

    public static function checkText(value:String):Void {
        return checkString(value);
    }

    public static function checkStringArray(value:Array<String>):Void {
        #if python
        var isStringArray:Bool = python.Syntax.code("all(isinstance(x, str) for x in {0})", value);
        #elseif js
        var isStringArray:Bool = js.Syntax.code("{0}.every(x => typeof x === 'string')", value);
        #else
        var isStringArray:Bool = Lambda.find(value, val -> !(val is String)) == null;
        #end
        if(!isStringArray)
            throw new IllegalArgumentException("Array contains non-string values.");
    }

    public static function checkShortStringArray(value:Array<String>):Void {
        // Revise up to 255
        #if python
        var isStringArray:Bool = python.Syntax.code("all(isinstance(x, str) for x in {0})", value);
        #elseif js
        var isStringArray:Bool = js.Syntax.code("{0}.every(x => typeof x === 'string')", value);
        #else
        var isStringArray:Bool = Lambda.find(value, val -> !(val is String)) == null;
        #end
        if(!isStringArray)
            throw new IllegalArgumentException("Array contains non-string values.");
    }

    public static function checkByte(value:Int):Void {
        var isByte:Bool = value is Int && value >= 0 && value <= 255;
        if(!isByte)
            throw new IllegalArgumentException("Value is not a byte.");
    }

    public static function checkByteArray(value:BytesData):Void {
        var isByteArray:Bool = value is BytesData;
        #if python
        if(!isByteArray)
            isByteArray = python.Syntax.code("all(isinstance(x, int) and 0 <= x < 256 for x in {0})", value);
        #end
        if(!isByteArray)
            throw new IllegalArgumentException("Value is not a byte array.");
    }

    public static function checkShort(value:Int):Void {
        var isShort:Bool = value is Int && value >= -32768 && value <= 32767;
        if(!isShort)
            throw new IllegalArgumentException("Value is not a short.");
    }

    public static function checkShortArray(value:Array<Int>):Void {
        #if python
        var isShortArray:Bool = python.Syntax.code("all(isinstance(x, int) and -32768 <= x <= 32767 for x in {0})", value);
        #elseif js
        var isShortArray:Bool = js.Syntax.code("{0}.every(x => Number.isInteger(x) && x >= -32768 && x <= 32767)", value);
        #else
        var isShortArray:Bool = Lambda.find(value, val -> !(val is Int) || val < -32768 || val > 32767) == null;
        #end
        if(!isShortArray)
            throw new IllegalArgumentException("Array contains non-short values.");
    }

    public static function checkInt(value:Int):Void {
        var isInt:Bool = value is Int;
        if(!isInt)
            throw new IllegalArgumentException("Value is not an integer.");
    }

    public static function checkIntArray(value:Array<Int>):Void {
        var isIntArray:Bool;
        #if python
        isIntArray = python.Syntax.code("all(isinstance(x, int) for x in {0})", value);
        #elseif js
        isIntArray = js.Syntax.code("{0}.every(Number.isInteger)", value);
        #else
        isIntArray = Lambda.find(value, val -> !(val is Int)) == null;
        #end
        if(!isIntArray)
            throw new IllegalArgumentException("Array contains non-integer values.");
    }

    public static function checkLong(value:PlatformInt64):Void {
        #if python
        var isLong:Bool = python.Syntax.code("isinstance({0}, int)", value);
        #else
        var isLong:Bool = haxe.Int64.isInt64(value);
        #end
        if(!isLong)
            throw new IllegalArgumentException("Value is not a long.");
    }

    public static function checkLongArray(value:Array<PlatformInt64>):Void {
        #if python
        var isLongArray:Bool = python.Syntax.code("all(isinstance(x, int) for x in {0})", value);
        #else
        var isLongArray:Bool = Lambda.find(value, val -> !haxe.Int64.isInt64(val)) == null;
        #end
        if(!isLongArray)
            throw new IllegalArgumentException("Array contains non-long values.");
    }

    public static function checkSFSArray(value:ISFSArray):Void {
        var isSFSArray:Bool = value is ISFSArray;
        if(!isSFSArray)
            throw new IllegalArgumentException("Value is not a SFS array.");
    }

    public static function checkSFSObject(value:ISFSObject):Void {
        var isSFSObject:Bool = value is ISFSObject;
        if(!isSFSObject)
            throw new IllegalArgumentException("Value is not a SFS object.");
    }

    public static function checkVector2(value:SFSVector2):Void {
        var isSFSVector2:Bool = value is SFSVector2;
        if(!isSFSVector2)
            throw new IllegalArgumentException("Value is not a SFS vector2.");
    }

    public static function checkVector3(value:SFSVector3):Void {
        var isSFSVector3:Bool = value is SFSVector3;
        if(!isSFSVector3)
            throw new IllegalArgumentException("Value is not a SFS vector3.");
    }

    public static function checkVector2Array(value:Array<SFSVector2>):Void {
        #if python
        var isVector2Array:Bool = python.Syntax.code("all(isinstance(x, {1}) for x in {0})", value, SFSVector2);
        #else
        var isVector2Array:Bool = Lambda.find(value, val -> !(val is SFSVector2)) == null;
        #end
        if(!isVector2Array)
            throw new IllegalArgumentException("Array contains non-Vector2 values.");
    }

    public static function checkVector3Array(value:Array<SFSVector3>):Void {
        #if python
        var isVector3Array:Bool = python.Syntax.code("all(isinstance(x, {1}) for x in {0})", value, SFSVector3);
        #else
        var isVector3Array:Bool = Lambda.find(value, val -> !(val is SFSVector3)) == null;
        #end
        if(!isVector3Array)
            throw new IllegalArgumentException("Array contains non-Vector3 values.");
    }

    public static function checkDataWrapper(value:SFSDataWrapper):Void {
        var isSFSDataWrapper:Bool = value is SFSDataWrapper;
        if(!isSFSDataWrapper)
            throw new IllegalArgumentException("Value is not a SFS data wrapper.");
    }

    public static inline function checkNotNull(value:Any):Void {
        if(value == null)
            throw new IllegalArgumentException("Value is cannot be null.");
    }
}
