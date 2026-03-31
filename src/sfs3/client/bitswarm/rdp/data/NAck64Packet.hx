package sfs3.client.bitswarm.rdp.data;

import haxe.Int64;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;

class NAck64Packet {
    public static final RDP_ACK_SIZE:Int = 13;
    private var header:PacketHeader;
    private var seqId:Int;
    private var history:Int64;

    public function new(seqNum:Int = -1, history:Int64 = cast 0, nHist:NAck64History = null) {
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

    public static function decode(bi:BytesInput):NAck64Packet {
        var seqNum = bi.readInt32();
        // Construct Int64 from two Int32s. Haxe BytesInput doesn't have native readInt64
        // Big Endian is default for java ByteBuffer unless changed. BytesInput has readInt32
        var high = bi.readInt32();
        var low = bi.readInt32();
        var hist = Int64.make(high, low);
        return new NAck64Packet(seqNum, hist);
    }

    public function getSeqId():Int {
        return this.seqId;
    }

    public function getHistoy():Int64 {
        return this.history;
    }

    public function encode():Bytes {
        var bo = new BytesOutput();
        bo.bigEndian = true;
        this.header.encode(bo);
        bo.writeInt32(this.seqId);
        bo.writeInt32(this.history.high);
        bo.writeInt32(this.history.low);
        return bo.getBytes();
    }

    public function toString():String {
        return '{ Seq: ${seqId}, Hist: ${NAck64History.toBits(this.history)} }';
    }
}
