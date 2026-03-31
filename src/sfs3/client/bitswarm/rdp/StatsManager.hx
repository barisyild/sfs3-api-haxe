package sfs3.client.bitswarm.rdp;

import hx.concurrent.executor.Executor;
import hx.concurrent.executor.Schedule;
import hx.concurrent.Future;
import hx.concurrent.atomic.AtomicInt;
import haxe.Int64;

class StatsManager {
    private var lastBytesIn:Int64 = 0;
    private var lastBytesOut:Int64 = 0;
    private var lastPacketsIn:Int64 = 0;
    private var lastPacketsOut:Int64 = 0;
    
    private var currBytesOut:Int64 = 0;
    private var currBytesIn:Int64 = 0;
    private var currPacketsIn:Int64 = 0;
    private var currPacketsOut:Int64 = 0;
    
    // We cannot access RDPTransport statically since Haxe requires us to pass it or have a singleton.
    // In Java it accesses RDPTransport static getters. Since static gets are there in Java, we'll keep it static on RDPTransport
    private var task:Future<Dynamic>;

    public function new(sched:Executor) {
        task = sched.submit(function () {
           monitor();
        }, FIXED_RATE(1000));
    }

    private function monitor():Void {
        this.currBytesIn = RDPTransport.getInBytes() - this.lastBytesIn;
        this.lastBytesIn = RDPTransport.getInBytes();

        this.currBytesOut = RDPTransport.getOutBytes() - this.lastBytesOut;
        this.lastBytesOut = RDPTransport.getOutBytes();

        this.currPacketsIn = RDPTransport.getInPacketCount() - this.lastPacketsIn;
        this.lastPacketsIn = RDPTransport.getInPacketCount();

        this.currPacketsOut = RDPTransport.getOutPacketCount() - this.lastPacketsOut;
        this.lastPacketsOut = RDPTransport.getOutPacketCount();
    }

    public function getBytesOut():Int64 {
        return this.currBytesOut;
    }

    public function getBytesIn():Int64 {
        return this.currBytesIn;
    }

    public function getPacketsIn():Int64 {
        return this.currPacketsIn;
    }

    public function getPacketsOut():Int64 {
        return this.currPacketsOut;
    }
}
