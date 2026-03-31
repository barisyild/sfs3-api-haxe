package sfs3.client.core;
class LoggerFactory {
    public static function getLogger(cls:Class<Dynamic>):Logger {
        return new Logger(cls);
    }
}