package com.smartfoxserver.v3.core;
class Logger {
    private var clazz:Class<Dynamic>;

    public function new(clazz:Class<Dynamic>) {
        this.clazz = clazz;
    }

    public function isDebugEnabled():Bool {
        return false;
    }

    public function error(...data:Dynamic):Void {
        debugTrace(...data);
    }

    public function debug(...data:Dynamic):Void {
        debugTrace(...data);
    }

    public function warn(...data:Dynamic):Void {
        debugTrace(...data);
    }

    public function log(...data:Dynamic):Void {
        debugTrace(...data);
    }

    public function info(...data:Dynamic):Void {
        debugTrace(...data);
    }

    private function debugTrace(...data:Dynamic):Void {
        var message = data;//;.join(' ');
        trace('[${Type.getClassName(clazz)}] ${message}');
    }
}
