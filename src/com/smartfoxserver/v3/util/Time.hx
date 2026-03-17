package com.smartfoxserver.v3.util;
import haxe.Int64;
class Time {
    public static function ms():Float {
        #if (flash || js)
        return Date.now().getTime(); // Flash'ta epoch bazlı ms döner
        #elseif sys
        return Sys.time() * 1000.0;
        #end
    }

    public static function ms64():Int64 {
        return Int64.fromFloat(ms());
    }
}
