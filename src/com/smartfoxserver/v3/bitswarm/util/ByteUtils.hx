package com.smartfoxserver.v3.bitswarm.util;

import haxe.io.Bytes;
import haxe.io.BytesData;

class ByteUtils {

    private static final HEX_ARRAY:Bytes = Bytes.ofString("0123456789ABCDEF");
    private static final HEX_BYTES_PER_LINE:Int = 16;
    private static final TAB:String = "\t";

    private static final NEW_LINE:String = #if sys Sys.systemName() == "Windows" ? "\r\n" : "\n"; #else "\n"; #end

    private static final DOT:String = ".";

    public static function resizeByteArray(source:Bytes, pos:Int, size:Int):Bytes {
        var tmpArray = Bytes.alloc(size);
        tmpArray.blit(0, source, pos, size);
        return tmpArray;
    }

    public static function hexDump(bytesData:BytesData, ?size:Null<Int>):String {
        var buffer:Bytes = Bytes.ofData(bytesData);
        if (size == null) {
            size = buffer.length;
        }

        if (size > buffer.length) {
            size = buffer.length;
        }

        if (size < 1) {
            throw 'Invalid byte size for HexDump: $size -- Must be > 0';
        }

        var sb = new StringBuf();
        sb.add("Binary size: ");
        sb.add(size);

        if (size < buffer.length) {
            sb.add("/");
            sb.add(buffer.length);
        }
        sb.add("\n");

        var hexLine = new StringBuf();
        var chrLine = new StringBuf();
        var index:Int = 0;
        var currLineCount:Int = 0;

        do {
            var currByte:Int = buffer.get(index);
            var hexByte:String = StringTools.hex(currByte, 2);

            hexLine.add(hexByte);
            hexLine.add(" ");

            var currChar:String = (currByte >= 33 && currByte <= 126) ? String.fromCharCode(currByte) : DOT;
            chrLine.add(currChar);

            currLineCount++;

            if (currLineCount == HEX_BYTES_PER_LINE) {
                currLineCount = 0;
                sb.add(hexLine.toString());
                sb.add(TAB);
                sb.add(chrLine.toString());
                sb.add(NEW_LINE);

                hexLine = new StringBuf();
                chrLine = new StringBuf();
            }

            index++;
        } while (index < size);

        if (currLineCount != 0) {
            var j:Int = HEX_BYTES_PER_LINE - currLineCount;
            while (j > 0) {
                hexLine.add("   ");
                chrLine.add(" ");
                j--;
            }

            sb.add(hexLine.toString());
            sb.add(TAB);
            sb.add(chrLine.toString());
            sb.add(NEW_LINE);
        }

        return sb.toString();
    }

    public static function bytesToHexString(bytes:Bytes):String {
        var hexChars = Bytes.alloc(bytes.length * 2);

        for (j in 0...bytes.length) {
            var v = bytes.get(j);
            hexChars.set(j * 2, HEX_ARRAY.get(v >>> 4));
            hexChars.set(j * 2 + 1, HEX_ARRAY.get(v & 15));
        }

        return hexChars.toString();
    }
}