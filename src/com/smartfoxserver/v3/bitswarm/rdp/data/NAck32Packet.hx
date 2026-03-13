package com.smartfoxserver.v3.bitswarm.rdp.data;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;

class NAck32Packet {
    public static final RDP_ACK_SIZE:Int = 9;
    private var header:PacketHeader;
    private var seqId:Int;
    private var history:Int;

    public function new(seqNum:Int = -1, history:Int = 0, nHist:NAck32History = null) {
        if (nHist != null) {
            this.seqId = nHist.getLastReceived();
            this.history = nHist.get();
        } else {
            this.seqId = seqNum;
            this.history = history;
        }
        this.header = new PacketHeader(true, true, true, false, false);
    }

    public function getHeader():PacketHeader {
        return this.header;
    }

    public static function decode(bi:BytesInput):NAck32Packet {
        var seqNum = bi.readInt32();
        var hist = bi.readInt32();
        return new NAck32Packet(seqNum, hist);
    }

    public function getSeqId():Int {
        return this.seqId;
    }

    public function getHistoy():Int {
        return this.history;
    }

    public function encode():Bytes {
        var bo = new BytesOutput();
        bo.bigEndian = true;
        this.header.encode(bo);
        bo.writeInt32(this.seqId);
        bo.writeInt32(this.history);
        return bo.getBytes();
    }

    public function toString():String {
        return '{ Seq: ${seqId}, Hist: ${NAck32History.toBits(this.history)} }';
    }
}
