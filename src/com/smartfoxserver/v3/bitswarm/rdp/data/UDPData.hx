package com.smartfoxserver.v3.bitswarm.rdp.data;

import com.smartfoxserver.v3.bitswarm.rdp.data.EndPoint;
import haxe.io.Bytes;

class UDPData {
    public var header:PacketHeader;
    public var buff:Bytes;
    public var endPoint:EndPoint;

    public function new(header:PacketHeader, buff:Bytes, endPoint:EndPoint) {
        this.header = header;
        this.buff = buff;
        this.endPoint = endPoint;
    }
}
