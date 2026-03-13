package com.smartfoxserver.v3.core;
class LoggerFactory {
    public static function getLogger(cls:Class<Dynamic>):Logger {
        return new Logger(cls);
    }
}