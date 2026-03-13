package com.smartfoxserver.v3.bitswarm.io.protocol;
import haxe.io.Bytes;

class RequestPacket {
    private final _header:PacketHeader;
    private final _body:Bytes;
    private final _txType:TransportType;

    public function new(header:PacketHeader, body:Bytes, txType:TransportType) {
        this._header = header;
        this._body = body;
        this._txType = txType;
    }

    public function header():PacketHeader {
        return _header;
    }

    public function body():Bytes {
        return _body;
    }

    public function txType():TransportType {
        return _txType;
    }
}