package sfs3.client.bitswarm.io.protocol;
import haxe.io.Bytes;
import haxe.io.BytesData;

class RequestPacket {
    private final _header:PacketHeader;
    private final _body:BytesData;
    private final _txType:TransportType;

    public function new(header:PacketHeader, body:BytesData, txType:TransportType) {
        this._header = header;
        this._body = body;
        this._txType = txType;
    }

    public function header():PacketHeader {
        return _header;
    }

    public function body():BytesData {
        return _body;
    }

    public function txType():TransportType {
        return _txType;
    }
}