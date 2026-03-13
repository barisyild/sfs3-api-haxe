package com.smartfoxserver.v3.bitswarm.rdp.data;

class NAck32History {
    public static final BIT_SIZE:Int = 32;
    public static final BIT_MIN_POS:Int = 0;
    public static final BIT_MAX_POS:Int = 31;
    
    private var lastReceived:Int = -1;
    private var history:Int = 0;

    public function new() {}

    public function getLastReceived():Int {
        return this.lastReceived;
    }

    public function get():Int {
        return this.history;
    }

    public function update(newPacketId:Int):Void {
        if (this.lastReceived == -1) {
            this.lastReceived = newPacketId;
        } else {
            if (newPacketId < this.lastReceived) {
                var bitPos = this.lastReceived - newPacketId;
                if (bitPos <= 32) {
                    this.setBit(32 - bitPos, true);
                }
            } else if (newPacketId > this.lastReceived) {
                this.history >>>= 1;
                this.setBit(31, true);
                var shiftPos = newPacketId - this.lastReceived - 1;
                if (shiftPos > 0 && shiftPos <= 31) {
                    this.history >>>= shiftPos;
                } else if (shiftPos > 31) {
                    this.history = 0;
                }

                this.lastReceived = newPacketId;
            }
        }
    }

    private function setBit(index:Int, state:Bool):Int {
        if (index <= 31 && index >= 0) {
            if (state) {
                this.history |= 1 << index;
            } else {
                this.history &= ~(1 << index);
            }
            return this.history;
        } else {
            throw new haxe.Exception("Invalid bitpos: " + index);
        }
    }

    private function flipBit(index:Int):Int {
        this.history ^= 1 << index;
        return this.history;
    }

    private function limit():Int {
        var lim = this.lastReceived >= 32 ? 32 : this.lastReceived;
        return lim - 1;
    }

    public function toString():String {
        return '${toBits(this.history)} (last: ${lastReceived}), base10: ${this.history}';
    }

    public function dump():String {
        var baseRepr = this.toString();
        var pos = this.limit();
        var pointer = "";
        if (pos > 0) {
            var space = StringTools.lpad("", " ", pos);
            pointer = space + "^" + pos;
        }
        return 'LastId: ${this.lastReceived}\n${baseRepr}\n${pointer}';
    }

    public static function toBits(val:Int):String {
        var repr = "";
        // Haxe doesn't have Integer.toBinaryString built-in for negative int parsing simply
        // But we can extract bits manually:
        for (i in 0...32) {
            repr = ((val >> i) & 1 == 1 ? "1" : "0") + repr;
        }
        return repr;
    }
}
