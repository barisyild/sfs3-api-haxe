package sfs3.client.bitswarm.rdp.data;

class AckHistory {
    public static final BIT_SIZE:Int = 32;
    private var ackedIds:Array<Int>;
    private var lastAckId:Int;
    private var ackHist:Int;

    public function new(lastAckId:Int, ackHist:Int) {
        this.ackedIds = [];
        this.lastAckId = lastAckId;
        this.ackHist = ackHist;
        this.processHistory();
    }

    public static function bitFieldFromList(bools:Array<Bool>):Int {
        var bfValue:Int = 0;
        var size:Int = bools.length <= 32 ? bools.length : 32;

        for (i in 0...size) {
            if (bools[i]) {
                bfValue += (1 << i);
            }
        }

        return bfValue;
    }

    public static function newHistory(lastPacketId:Int, bools:Array<Bool>):AckHistory {
        return new AckHistory(lastPacketId, bitFieldFromList(bools));
    }

    private function processHistory():Void {
        this.ackedIds.push(this.lastAckId);

        for (pos in 0...32) {
            var ackId = this.lastAckId - pos - 1;
            if (ackId < 0) {
                return;
            }

            if (((this.ackHist >> pos) & 1) == 1) {
                this.ackedIds.push(ackId);
            }
        }
    }

    public function acked():Array<Int> {
        return this.ackedIds;
    }

    public function toString():String {
        return '{ LastId: ${lastAckId}, Hist: ${StringTools.hex(ackHist)} (${formatBinString(ackHist)}) }';
    }

    private function formatBinString(value:Int):String {
        var binStr = NAck32History.toBits(value);
        return binStr;
    }
}
