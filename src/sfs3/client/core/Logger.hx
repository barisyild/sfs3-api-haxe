package sfs3.client.core;

enum abstract LogLevel(Int) to Int from Int {
    var ERROR = 0;
    var WARN = 1;
    var INFO = 2;
    var DEBUG = 3;

    @:to public function toString():String {
        return switch(cast this : LogLevel) {
            case ERROR: "ERROR";
            case WARN: "WARN";
            case INFO: "INFO";
            case DEBUG: "DEBUG";
        };
    }
}

class Logger {
    private static var globalLevel:LogLevel = WARN;
    private static var showPosition:Bool = false;

    private var className:String;

    public function new(clazz:Class<Dynamic>) {
        this.className = Type.getClassName(clazz);
        if(this.className == null) this.className = "?";
    }

    public static function setLevel(level:LogLevel):Void {
        globalLevel = level;
    }

    public static function getLevel():LogLevel {
        return globalLevel;
    }

    public static function setShowPosition(show:Bool):Void {
        showPosition = show;
    }

    public static function getShowPosition():Bool {
        return showPosition;
    }

    public static function isDebugEnabled():Bool {
        return (globalLevel : Int) >= (DEBUG : Int);
    }

    public function error(?a0:Dynamic, ?a1:Dynamic, ?a2:Dynamic, ?a3:Dynamic, ?a4:Dynamic, ?a5:Dynamic, ?a6:Dynamic, ?a7:Dynamic, ?a8:Dynamic, ?a9:Dynamic, ?pos:haxe.PosInfos):Void {
        if((globalLevel : Int) >= (ERROR : Int))
            output(ERROR, collect(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9), pos);
    }

    public function warn(?a0:Dynamic, ?a1:Dynamic, ?a2:Dynamic, ?a3:Dynamic, ?a4:Dynamic, ?a5:Dynamic, ?a6:Dynamic, ?a7:Dynamic, ?a8:Dynamic, ?a9:Dynamic, ?pos:haxe.PosInfos):Void {
        if((globalLevel : Int) >= (WARN : Int))
            output(WARN, collect(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9), pos);
    }

    public function info(?a0:Dynamic, ?a1:Dynamic, ?a2:Dynamic, ?a3:Dynamic, ?a4:Dynamic, ?a5:Dynamic, ?a6:Dynamic, ?a7:Dynamic, ?a8:Dynamic, ?a9:Dynamic, ?pos:haxe.PosInfos):Void {
        if((globalLevel : Int) >= (INFO : Int))
            output(INFO, collect(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9), pos);
    }

    public function debug(?a0:Dynamic, ?a1:Dynamic, ?a2:Dynamic, ?a3:Dynamic, ?a4:Dynamic, ?a5:Dynamic, ?a6:Dynamic, ?a7:Dynamic, ?a8:Dynamic, ?a9:Dynamic, ?pos:haxe.PosInfos):Void {
        if((globalLevel : Int) >= (DEBUG : Int))
            output(DEBUG, collect(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9), pos);
    }

    public function log(?a0:Dynamic, ?a1:Dynamic, ?a2:Dynamic, ?a3:Dynamic, ?a4:Dynamic, ?a5:Dynamic, ?a6:Dynamic, ?a7:Dynamic, ?a8:Dynamic, ?a9:Dynamic, ?pos:haxe.PosInfos):Void {
        if((globalLevel : Int) >= (INFO : Int))
            output(INFO, collect(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9), pos);
    }

    private static function collect(?a0:Dynamic, ?a1:Dynamic, ?a2:Dynamic, ?a3:Dynamic, ?a4:Dynamic, ?a5:Dynamic, ?a6:Dynamic, ?a7:Dynamic, ?a8:Dynamic, ?a9:Dynamic):Array<Dynamic> {
        var arr:Array<Dynamic> = [];
        if(a0 != null) arr.push(a0);
        if(a1 != null) arr.push(a1);
        if(a2 != null) arr.push(a2);
        if(a3 != null) arr.push(a3);
        if(a4 != null) arr.push(a4);
        if(a5 != null) arr.push(a5);
        if(a6 != null) arr.push(a6);
        if(a7 != null) arr.push(a7);
        if(a8 != null) arr.push(a8);
        if(a9 != null) arr.push(a9);
        return arr;
    }

    private function output(level:LogLevel, data:Array<Dynamic>, ?pos:haxe.PosInfos):Void {
        var parts:Array<String> = [];
        var stackTrace:String = null;

        for(i in 0...data.length) {
            var d = data[i];
            if(Std.isOfType(d, haxe.Exception)) {
                var ex:haxe.Exception = cast d;
                parts.push(ex.message);
                if(ex.stack != null)
                    stackTrace = ex.stack.toString();
            } else {
                parts.push(Std.string(d));
            }
        }

        var msg = parts.join(" ");
        if(stackTrace != null)
            msg += '\n${stackTrace}';

        haxe.Log.trace('[${level.toString()}] ${msg}', showPosition ? pos : null);
    }
}
