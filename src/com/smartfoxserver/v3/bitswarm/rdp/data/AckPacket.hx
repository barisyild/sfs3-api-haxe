package com.smartfoxserver.v3.bitswarm.rdp.data;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;

class AckPacket {
    public static var RDP_ACK_SIZE:Int = 5;
    private var header:PacketHeader = new PacketHeader(true, true, true, false, false);
    private var seqId:Int;

    public function new(seqNum:Int) {
        this.seqId = seqNum;
    }

    public function getHeader():PacketHeader {
        return this.header;
    }

    public static function decode(bi:BytesInput):AckPacket {
        var seqNum = bi.readInt32();
        return new AckPacket(seqNum);
    }

    public function getSeqId():Int {
        return this.seqId;
    }

    public function encode():Bytes {
        var bo = new BytesOutput();
        bo.bigEndian = true;
        this.header.encode(bo);
        bo.writeInt32(this.seqId);
        return bo.getBytes();
    }

    public function toString():String {
        return '{ SeqNum: ${seqId} }';
    }
}
