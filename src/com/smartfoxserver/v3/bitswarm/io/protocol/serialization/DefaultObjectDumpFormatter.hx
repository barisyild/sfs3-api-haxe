package com.smartfoxserver.v3.bitswarm.io.protocol.serialization;

import haxe.io.Bytes;
import com.smartfoxserver.v3.entities.data.SFSArray;
import com.smartfoxserver.v3.entities.data.SFSDataType;
import com.smartfoxserver.v3.entities.data.SFSDataWrapper;
import com.smartfoxserver.v3.entities.data.SFSObject;

class DefaultObjectDumpFormatter {
    private static final MAX_ARRAY_DUMP_SIZE:Int = 10;
    private static final MAX_STRING_DUMP_SIZE:Int = 50;
    public static final TOKEN_INDENT_OPEN:Int = 0x11;
    public static final TOKEN_INDENT_CLOSE:Int = 0x12;
    public static final TOKEN_DIVIDER:Int = 0x13;
    public static var NEW_LINE:String = #if sys (Sys.systemName() == "Windows" ? "\r\n" : "\n"); #else "\n"; #end

    public static function prettyPrintByteArray(bytes:Bytes):String {
        return bytes == null ? "Null" : 'Byte[${bytes.length}]';
    }

    public static function prettyPrintCollection(coll:Array<Dynamic>, typeId:SFSDataType):String {
        if (coll == null) {
            return "null";
        } else {
            return coll.length <= 10 ? Std.string(coll) : '$typeId[${coll.length}]';
        }
    }

    public static function prettyPrintString(str:String):String {
        if (str == null) {
            return "null";
        } else {
            var len = str.length;
            return len <= 50 ? str : '${str.substr(0, 50)} [..+${len - 50}]';
        }
    }

    public static function formattedValue(wrapper:SFSDataWrapper):String {
        var typeId:SFSDataType = wrapper.getTypeId();
        var value:Dynamic = wrapper.getObject();

        if (typeId == SFSDataType.NULL) {
            return "null";
        } else if (typeId == SFSDataType.STRING || typeId == SFSDataType.SHORT_STRING || typeId == SFSDataType.TEXT) {
            return prettyPrintString(cast value);
        } else if (typeId == SFSDataType.BOOL_ARRAY || typeId == SFSDataType.SHORT_ARRAY || typeId == SFSDataType.INT_ARRAY
            || typeId == SFSDataType.LONG_ARRAY || typeId == SFSDataType.FLOAT_ARRAY || typeId == SFSDataType.DOUBLE_ARRAY
            || typeId == SFSDataType.STRING_ARRAY || typeId == SFSDataType.SHORT_STRING_ARRAY
            || typeId == SFSDataType.VECTOR2_ARRAY || typeId == SFSDataType.VECTOR3_ARRAY) {
            return prettyPrintCollection(cast value, typeId);
        } else if (typeId == SFSDataType.BYTE_ARRAY) {
            return prettyPrintByteArray(cast value);
        } else if (typeId == SFSDataType.SFS_ARRAY) {
            return (cast(value, SFSArray)).getDump(false);
        } else if (typeId == SFSDataType.SFS_OBJECT) {
            return (cast(value, SFSObject)).getDump(false);
        } else {
            return Std.string(value);
        }
    }

    public static function prettyPrintDump(rawDump:String):String {
        var buf = new StringBuf();
        var indentPos = 0;
        var lastCh:Int = 0;

        for (i in 0...rawDump.length) {
            var ch = rawDump.charCodeAt(i);

            if (ch == 0x11) {
                ++indentPos;
                buf.add(NEW_LINE);
                buf.add(getFormatTabs(indentPos));
            } else if (ch == 0x12) {
                --indentPos;
                if (indentPos < 0) {
                    throw new haxe.Exception("Unbalanced dump tokens: indentPos is negative");
                }
                if (lastCh != ch) {
                    buf.add(NEW_LINE);
                }
            } else if (ch == 0x13) {
                buf.add(NEW_LINE);
                buf.add(getFormatTabs(indentPos));
            } else {
                buf.addChar(ch);
            }

            lastCh = ch;
        }

        if (indentPos != 0) {
            throw new haxe.Exception("Unbalanced dump tokens: indentPos should be zero");
        }

        return buf.toString();
    }

    private static function getFormatTabs(howMany:Int):String {
        return strFill(0x09, howMany);
    }

    private static function strFill(c:Int, howMany:Int):String {
        var buf = new StringBuf();
        for (_ in 0...howMany) {
            buf.addChar(c);
        }
        return buf.toString();
    }
}
