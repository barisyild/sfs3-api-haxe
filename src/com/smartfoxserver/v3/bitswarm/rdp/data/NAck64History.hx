package com.smartfoxserver.v3.bitswarm.rdp.data;

import haxe.Int64;

class NAck64History {
    public static final BIT_SIZE:Int = 64;
    public static final BIT_MIN_POS:Int = 0;
    public static final BIT_MAX_POS:Int = 63;
    
    private var lastReceived:Int = -1;
    private var history:Int64 = Int64.make(0, 0);

    public function new() {}

    public function getLastReceived():Int {
        return this.lastReceived;
    }

    public function get():Int64 {
        return this.history;
    }

    public function update(newPacketId:Int):Void {
        if (this.lastReceived == -1) {
            this.lastReceived = newPacketId;
        } else {
            if (newPacketId < this.lastReceived) {
                var bitPos = this.lastReceived - newPacketId;
                if (bitPos <= 64) {
                    this.setBit(64 - bitPos, true);
                }
            } else if (newPacketId > this.lastReceived) {
                this.history = this.history >>> 1;
                this.setBit(63, true);
                var shiftPos = newPacketId - this.lastReceived - 1;
                if (shiftPos > 0 && shiftPos <= 63) {
                    this.history = this.history >>> shiftPos;
                } else if (shiftPos > 63) {
                    this.history = Int64.make(0, 0);
                }

                this.lastReceived = newPacketId;
            }
        }
    }

    private function setBit(index:Int, state:Bool):Int64 {
        if (index <= 63 && index >= 0) {
            var one:Int64 = Int64.make(0, 1);
            if (state) {
                this.history |= (one << index);
            } else {
                this.history &= ~(one << index);
            }
            return this.history;
        } else {
            throw new haxe.Exception("Invalid bitpos: " + index);
        }
    }

    private function flipBit(index:Int):Int64 {
        var one:Int64 = Int64.make(0, 1);
        this.history ^= (one << index);
        return this.history;
    }

    private function limit():Int {
        var lim = this.lastReceived >= 64 ? 64 : this.lastReceived;
        return lim - 1;
    }

    public function toString():String {
        return '${toBits(this.history)} (last: ${lastReceived}), base10: ${Int64.toStr(this.history)}';
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

    public static function toBits(val:Int64):String {
        var repr = "";
        var one:Int64 = Int64.make(0, 1);
        for (i in 0...64) {
            var bit = ((val >> i) & one);
            repr = (bit == one ? "1" : "0") + repr;
        }
        return repr;
    }
}
