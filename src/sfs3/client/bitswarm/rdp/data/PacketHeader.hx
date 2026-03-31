package sfs3.client.bitswarm.rdp.data;

import haxe.io.BytesInput;
import haxe.io.BytesOutput;

class PacketHeader {
    private var reliable:Bool;
    private var ordered:Bool;
    private var ack:Bool;
    private var frag:Bool;
    private var ping:Bool;

    public function new(reliable:Bool = false, ordered:Bool = false, ack:Bool = false, frag:Bool = false, ping:Bool = false) {
        this.reliable = reliable;
        this.ordered = ordered;
        this.ack = ack;
        this.frag = frag;
        this.ping = ping;
    }

    public static function decode(bi:BytesInput):PacketHeader {
        var hdrByte:Int = bi.readByte();
        var header = new PacketHeader();
        header.reliable = (hdrByte & 128) > 0;
        header.ordered = (hdrByte & 64) > 0;
        header.ack = (hdrByte & 32) > 0;
        header.frag = (hdrByte & 16) > 0;
        header.ping = (hdrByte & 8) > 0;
        return header;
    }

    public function isAck():Bool {
        return this.ack;
    }

    public function isFrag():Bool {
        return this.frag;
    }

    public function isOrdered():Bool {
        return this.ordered;
    }

    public function isRealiable():Bool {
        return this.reliable;
    }

    public function isRaw():Bool {
        return !this.reliable && !this.ordered;
    }

    public function isPing():Bool {
        return this.ping;
    }

    private function toByte():Int {
        var header:Int = 0;
        if (this.reliable) {
            header = header | 128;
        }

        if (this.ordered) {
            header = header | 64;
        }

        if (this.ack) {
            header = header | 32;
        }

        if (this.frag) {
            header = header | 16;
        }

        if (this.ping) {
            header = header | 8;
        }

        return header;
    }

    public function encode(bo:BytesOutput):Void {
        bo.writeByte(this.toByte());
    }

    public function toString():String {
        return '{ Rel: ${reliable}, Ord: ${ordered}, Ack: ${ack}, Frg: ${frag}, Png: ${ping} }';
    }
}
