package sfs3.client.bitswarm.rdp;

import sfs3.client.bitswarm.rdp.data.EndPoint;
import sfs3.client.bitswarm.rdp.data.PacketHeader;
import sfs3.client.bitswarm.rdp.data.PingPacket;
import sfs3.client.bitswarm.rdp.data.RDPacket;
import sfs3.client.bitswarm.rdp.data.UDPData;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.Timer;
import hx.concurrent.executor.Executor;
import hx.concurrent.atomic.AtomicInt;
import hx.concurrent.lock.RLock;
import sfs3.client.core.Logger;
import haxe.Int64;
import sfs3.client.entities.data.AtomicInt64;
import sfs3.client.core.LoggerFactory;
import haxe.exceptions.NotImplementedException;
import sfs3.client.exceptions.IllegalStateException;
import sfs3.client.exceptions.UnsupportedOperationException;

class RDPTransport implements ITransport {
    public static final MAX_RTT_AVG_VALUES:Int = 10;
    private static var stats:Stats = new Stats();

    private var log:Logger;
    private var cfg:TransportConfig;
    private var reliableChannel:BaseChannel;
    private var unreliableChannel:BaseChannel;
    private var rawChannel:BaseChannel;
    private var lastRTTValues:Array<Float> = [];
    private var rttLock:RLock = new RLock();
    private var lastPingSendTime:Float = 0;
    public static final VERSION:String = "1.0.40";

    private var incomingDataAvailable:TxpCallback;
    private var outgoingDataAvailable:TxpCallback;
    private var incomingPingCallback:PingCallback;
    private var disconnectionCallback:Void->Void;

    public function new(cfg:TransportConfig) {
        this.cfg = cfg;
        this.log = LoggerFactory.getLogger(Type.getClass(this));
        
        this.incomingDataAvailable = function(data:Bytes, sender:EndPoint, mode:TxpMode) {
            throw new IllegalStateException("Must be implemented");
        };
        this.outgoingDataAvailable = function(data:Bytes, recipient:EndPoint, mode:TxpMode) {
            throw new IllegalStateException("Must be implemented");
        };
        this.incomingPingCallback = function(endpoint:EndPoint) {};
        this.disconnectionCallback = function() {};
    }

    public function init():Void {
        if (this.cfg.threadPool == null) {
            throw new IllegalStateException("A thread pool must be provided");
        } else {
            this.reliableChannel = this.initReliableChannel(this.cfg.reliableImpl);
            this.unreliableChannel = new UnreliableChannel(this);
            this.rawChannel = new RawChannel(this);
        }
    }

    public function destroy():Void {
        this.reliableChannel.destroy();
        this.unreliableChannel.destroy();
        this.rawChannel.destroy();
    }

    public function dataReceived(bytes:Bytes, sender:EndPoint):Void {
        var bi = new BytesInput(bytes);
        bi.bigEndian = true;
        var header = PacketHeader.decode(bi);
        var udpData = new UDPData(header, bytes, sender);
        
        if (header.isPing()) {
            var packet = PingPacket.decode(bi);
            this.handlePingPacket(packet, sender);
        } else {
            var channel:BaseChannel = null;
            if (header.isRaw()) {
                channel = this.rawChannel;
            } else {
                channel = header.isRealiable() ? this.reliableChannel : this.unreliableChannel;
            }
            if (channel != null) {
                channel.dataReceived(udpData);
            }
        }
    }

    public function sendData(data:Bytes, mode:TxpMode, dest:EndPoint):Void {
        var isReliable = mode == TxpMode.RELIABLE_ORDERED;
        var isOrdered = mode == TxpMode.RELIABLE_ORDERED || mode == TxpMode.UNRELIABLE_ORDERED;
        var header = new PacketHeader(isReliable, isOrdered, false, false, false);
        var packet = new RDPacket(header, data);
        packet.setEndPoint(dest);
        this.getChannel(mode).sendData(packet);
    }

    public function getIncomingDataHandler():TxpCallback {
        return this.incomingDataAvailable;
    }

    public function getOutgoingDataHandler():TxpCallback {
        return this.outgoingDataAvailable;
    }

    public function getCfg():TransportConfig {
        return this.cfg;
    }

    public function setIncomingDataHandler(handler:TxpCallback):Void {
        this.incomingDataAvailable = handler;
    }

    public function setOutgoingDataHandler(handler:TxpCallback):Void {
        this.outgoingDataAvailable = handler;
    }

    public function getIncomingPingCallback():PingCallback {
        return this.incomingPingCallback;
    }

    public function setIncomingPingCallback(handler:PingCallback):Void {
        this.incomingPingCallback = handler;
    }

    public function getReliableErrorCallback():Void->Void {
        return this.disconnectionCallback;
    }

    public function setReliableErrorCallback(handler:Void->Void):Void {
        this.disconnectionCallback = handler;
    }

    public function sendPing(dest:EndPoint):Void {
        var bytes = PingPacket.getEncodedPing();
        this.addOutBytes(bytes.length);
        this.addOutPacket();
        this.outgoingDataAvailable(bytes, dest, TxpMode.RAW_UDP);
        this.lastPingSendTime = Timer.stamp() * 1000.0;
    }

    public function getLastPingSendTime():Float {
        return this.lastPingSendTime;
    }

    public function getChannel(mode:TxpMode):Channel {
        switch (mode) {
            case RAW_UDP: return this.rawChannel;
            case UNRELIABLE_ORDERED: return this.unreliableChannel;
            case RELIABLE_ORDERED: return this.reliableChannel;
            default: throw new UnsupportedOperationException("Unknown channel type, mode: " + mode);
        }
    }

    public function getAverageRTT():Float {
        if (this.reliableChannel.providesRTT()) {
            var rRTT = this.getAverageReliableRTT();
            var uRTT = this.getAverageUnreliableRTT();
            if (rRTT > -1 && uRTT > -1) {
                return (rRTT + uRTT) / 2;
            } else {
                return rRTT > -1 ? rRTT : uRTT;
            }
        } else {
            return this.getAverageUnreliableRTT();
        }
    }

    public function getAverageReliableRTT():Float {
        if (this.reliableChannel.providesRTT()) {
            return cast(this.reliableChannel, BaseReliableChannel).getCurrentRTT();
        } else {
            return this.getAverageUnreliableRTT();
        }
    }

    public function getAverageUnreliableRTT():Float {
        return rttLock.execute(function() {
            if (this.lastRTTValues.length != 0) {
                var totRTT:Float = 0;
                for (value in this.lastRTTValues) {
                    totRTT += value;
                }
                return totRTT / this.lastRTTValues.length;
            }
            return -1.0;
        });
    }

    public static function getInPacketCount():Int64 {
        return stats.totPacketsIn.load();
    }

    public static function getOutPacketCount():Int64 {
        return stats.totPacketsOut.load();
    }

    public static function getInBytes():Int64 {
        return stats.totBytesIn.load();
    }

    public static function getOutBytes():Int64 {
        return stats.totBytesOut.load();
    }

    public static function getRtxCount():Int64 {
        return stats.rtxCount.load();
    }

    public static function getRtxPercent():Int64 {
        var totOut:Int64 = stats.totPacketsOut.load();
        return totOut == 0 ? 0 : (stats.rtxCount.load() * 100) / totOut;
    }

    public function addInBytes(value:Float):Void {
        stats.totBytesIn.fetchAdd(Std.int(value));
    }

    public function addOutBytes(value:Float):Void {
        stats.totBytesOut.fetchAdd(Std.int(value));
    }

    public function addInPacket():Void {
        stats.totPacketsIn.fetchAdd(1);
    }

    public function addOutPacket():Void {
        stats.totPacketsOut.fetchAdd(1);
    }

    public function addRtx():Void {
        stats.rtxCount.fetchAdd(1);
    }

    public function version():String {
        return VERSION;
    }

    private function handlePingPacket(packet:PingPacket, sender:EndPoint):Void {
        var now = Timer.stamp() * 1000.0;
        if (!packet.isPing()) {
            if (this.lastPingSendTime > 0) {
                var rTripMs = now - this.lastPingSendTime;
                rttLock.execute(function() {
                    this.lastRTTValues.unshift(rTripMs); // addFirst
                    if (this.lastRTTValues.length >= MAX_RTT_AVG_VALUES) {
                        this.lastRTTValues.pop(); // removeLast
                    }
                });
            } else {
                this.lastPingSendTime = now;
            }
        } else {
            this.sendPong(sender);
            this.incomingPingCallback(sender);
        }
    }

    private function sendPong(dest:EndPoint):Void {
        var bytes = PingPacket.getEncodedPong();
        this.addOutBytes(bytes.length);
        this.addOutPacket();
        this.outgoingDataAvailable(bytes, dest, TxpMode.RAW_UDP);
    }

    private function initReliableChannel(value:Int):BaseChannel {
        switch (value) {
            case 2: return new ReliableChannelV2(this);
            case 3: return new ReliableChannelV3(this);
            default: return new ReliableChannel(this);
        }
    }
}

private class Stats {
    public var totBytesIn:AtomicInt64 = new AtomicInt64(0);
    public var totBytesOut:AtomicInt64 = new AtomicInt64(0);
    public var totPacketsIn:AtomicInt64 = new AtomicInt64(0);
    public var totPacketsOut:AtomicInt64 = new AtomicInt64(0);
    public var rtxCount:AtomicInt64 = new AtomicInt64(0);
    public function new() {}
}
