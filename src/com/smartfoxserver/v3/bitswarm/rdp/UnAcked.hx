package com.smartfoxserver.v3.bitswarm.rdp;

import com.smartfoxserver.v3.bitswarm.rdp.data.RDPacket;
import haxe.Timer;
import hx.concurrent.atomic.AtomicInt;

class UnAcked {
    private static var totPacketRtxCount:AtomicInt = new AtomicInt(0);
    private var creationTime:Float;
    private var tStamp:Float;
    private var packet:RDPacket;
    private var rtxCount:Int;
    private var rtxTimeout:Int;
    private var backoffMultiplier:Float;
    private var maxBackoffMillis:Int;

    public function new(packet:RDPacket, rtxTimeout:Int, backoffMultipler:Float, maxBackoffMillis:Int, ?tStampValue:Float) {
        this.maxBackoffMillis = maxBackoffMillis;
        this.creationTime = tStampValue != null ? tStampValue : Timer.stamp() * 1000.0;
        this.rtxTimeout = rtxTimeout;
        this.backoffMultiplier = backoffMultipler;
        this.tStamp = this.creationTime;
        this.packet = packet;
        this.rtxCount = 0;
    }

    public function getPacket():RDPacket {
        return this.packet;
    }

    public function getTimeStamp():Float {
        return this.tStamp;
    }

    public function isExpired():Bool {
        return (Timer.stamp() * 1000.0) - this.tStamp >= this.rtxTimeout;
    }

    public function getRtxCount():Int {
        return this.rtxCount;
    }

    public function getRtxTimeout():Int {
        return this.rtxTimeout;
    }

    public function setTimeStamp(value:Float):Void {
        this.tStamp = value;
    }

    public function getCreationTime():Float {
        return this.creationTime;
    }

    public function retryOneMoreTime():Void {
        this.rtxCount++;
        this.tStamp = Timer.stamp() * 1000.0;
        this.rtxTimeout = this.applyExpBackoff(this.rtxTimeout);
        totPacketRtxCount.incrementAndGet();
    }

    private function applyExpBackoff(currValue:Int):Int {
        if (this.backoffMultiplier != 0.0 && currValue != this.maxBackoffMillis) {
            var newValue = currValue + Std.int(currValue * this.backoffMultiplier);
            return newValue <= this.maxBackoffMillis ? newValue : this.maxBackoffMillis;
        } else {
            return currValue;
        }
    }

    public static function getTotPacketRtxCount():Int {
        return totPacketRtxCount.value;
    }

    public function toString():String {
        return '(id: ${this.getPacket().getSeqId()}, next rtx: ${this.rtxTimeout}ms, exp: ${this.isExpired()}, size: ${this.getPacket().getDataSize()})';
    }
}
