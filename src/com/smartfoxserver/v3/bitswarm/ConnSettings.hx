package com.smartfoxserver.v3.bitswarm;
class ConnSettings {
    public var compressionThreshold:Int = 2000000;
    public var maxMessageSize:Int = 10000;
    public var reconnectionDelayMillis:Int = 2000;
    public var reconnectionSeconds:Int = 0;

    public function new(){}
}
