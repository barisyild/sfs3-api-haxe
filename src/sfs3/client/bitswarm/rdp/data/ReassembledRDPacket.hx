package sfs3.client.bitswarm.rdp.data;

import haxe.io.Bytes;

class ReassembledRDPacket extends RDPacket {
    private var fragCount:Int;

    public function new(ph:PacketHeader, seqId:Int, data:Bytes) {
        super(ph, data, seqId, null);
    }

    public function getFragCount():Int {
        return this.fragCount;
    }

    public function setFragCount(fragCount:Int):Void {
        this.fragCount = fragCount;
    }
}
