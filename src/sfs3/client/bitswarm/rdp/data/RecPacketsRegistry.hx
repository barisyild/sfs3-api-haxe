package sfs3.client.bitswarm.rdp.data;

import hx.concurrent.lock.RLock;

class RecPacketsRegistry {
    private var maxSize:Int = 33;
    private var data:Array<Int> = [];
    private var highestPacketId:Int = 0;
    private var lock:RLock = new RLock();

    public function new() {}

    public function getHistory():AckHistory {
        return lock.execute(function():AckHistory {
            var bools:Array<Bool> = [];
            var startValue = this.highestPacketId - 1;
            var lowerValue = startValue - 32;

            var id = startValue;
            while (id > lowerValue) {
                bools.push(this.data.indexOf(id) != -1);
                id--;
            }

            return AckHistory.newHistory(this.highestPacketId, bools);
        });
    }

    public function ackHistoryAsBitField():Int {
        return lock.execute(function():Int {
            var startValue = this.highestPacketId - 1;
            var lowerValue = startValue - 32;
            var bfValue = 0;
            var i = 0;

            var id = startValue;
            while (id > lowerValue) {
                if (this.data.indexOf(id) != -1) {
                    bfValue += 1 << i;
                }
                i++;
                id--;
            }

            return bfValue;
        });
    }

    public function addItem(item:Int):Void {
        lock.execute(function():Void {
            this.data.unshift(item); // addFirst
            if (this.data.length > this.maxSize) {
                this.data.pop(); // removeLast
            }

            if (item > this.highestPacketId) {
                this.highestPacketId = item;
            }
        });
    }

    public function getHighestPacketId():Int {
        return this.highestPacketId;
    }

    public function contains(item:Int):Bool {
        return lock.execute(function():Bool {
            return this.data.indexOf(item) != -1;
        });
    }

    public function getFirst():Int {
        return lock.execute(function():Int {
            return this.data.length > 0 ? this.data[0] : -1;
        });
    }

    public function clear():Void {
        lock.execute(function():Void {
            this.data = [];
        });
    }

    public function getMaxSize():Int {
        return this.maxSize;
    }

    public function size():Int {
        return lock.execute(function():Int {
            return this.data.length;
        });
    }

    public function dumpData():String {
        return lock.execute(function():String {
            var cloned = this.data.copy();
            cloned.sort(function(a, b) return b - a); // reverse sorted
            return Std.string(cloned);
        });
    }
}
