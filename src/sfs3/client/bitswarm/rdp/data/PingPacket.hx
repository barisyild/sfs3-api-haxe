package sfs3.client.bitswarm.rdp.data;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;

class PingPacket {
    public static final RDP_PING_SIZE:Int = 2;
    private static var header:PacketHeader = new PacketHeader(false, false, false, false, true);

    private static var encodedPing:Bytes = createEncoded(true);
    private static var encodedPong:Bytes = createEncoded(false);

    private var ping:Bool;

    private function new(isPing:Bool) {
        this.ping = isPing;
    }

    private static function createEncoded(isPing:Bool):Bytes {
        var pp = new PingPacket(isPing);
        return pp.encode();
    }

    public static function getEncodedPing():Bytes {
        return encodedPing;
    }

    public static function getEncodedPong():Bytes {
        return encodedPong;
    }

    public static function decode(bi:BytesInput):PingPacket {
        var type = bi.readByte();
        return new PingPacket(type == 0);
    }

    public function isPing():Bool {
        return this.ping;
    }

    private function encode():Bytes {
        var bo = new BytesOutput();
        bo.bigEndian = true;
        header.encode(bo);
        bo.writeByte(this.ping ? 0 : 1);
        return bo.getBytes();
    }

    public function toString():String {
        return this.isPing() ? "{ Ping }" : "{ Pong }";
    }
}
