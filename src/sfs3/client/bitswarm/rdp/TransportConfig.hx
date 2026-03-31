package sfs3.client.bitswarm.rdp;

import hx.concurrent.executor.Executor;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import haxe.io.BytesInput;
import haxe.io.BytesData;

class ReliableImpl {
    public static final ACK_ACTIVE:Int = 1;
    public static final ACK_PASSIVE:Int = 2;
    public static final NACK_PASSIVE:Int = 3;
}

class TransportConfig {
    public var maxRtxAttempts:Int = 2;
    public var backOffMultiplier:Float = 0.5;
    public final maxBackoffTime:Int = 3000;
    public var unACKBufferSize:Int = 500;
    public var packetBufferSize:Int = 500;
    public var rtxBaseTimeout:Int = 50;
    public var packetBufferExpiryTime:Int = 0;
    public var mtu:Int = 1360;
    public var maxFragments:Int = 256;
    public var fragBufferLimit:Int = 1000;
    public var triggerReliableErrors:Bool = false;
    public var threadPool:Executor;
    public var reliableImpl:Int = 1;

    public function new() {
    }

    public function serialize():Bytes {
        var bo = new BytesOutput();
        bo.bigEndian = true;
        bo.writeByte(this.reliableImpl);
        bo.writeInt32(this.maxRtxAttempts);
        bo.writeInt32(this.rtxBaseTimeout);
        bo.writeFloat(this.backOffMultiplier);
        bo.writeInt16(this.mtu);
        bo.writeInt32(this.packetBufferExpiryTime);
        bo.writeInt16(this.unACKBufferSize);
        bo.writeInt16(this.packetBufferSize);
        bo.writeByte(this.triggerReliableErrors ? 1 : 0);
        return bo.getBytes();
    }

    public static function deserialize(bytesData:BytesData):TransportConfig {
        var bytes:Bytes = Bytes.ofData(bytesData);
        var txCfg = new TransportConfig();
        var bi = new BytesInput(bytes);
        bi.bigEndian = true;

        txCfg.reliableImpl = bi.readByte();
        txCfg.maxRtxAttempts = bi.readInt32();
        txCfg.rtxBaseTimeout = bi.readInt32();
        txCfg.backOffMultiplier = bi.readFloat();
        txCfg.mtu = bi.readInt16();
        txCfg.packetBufferExpiryTime = bi.readInt32();
        txCfg.unACKBufferSize = bi.readInt16();
        txCfg.packetBufferSize = bi.readInt16();
        txCfg.triggerReliableErrors = bi.readByte() == 1;
        return txCfg;
    }

    public static function computeRtxBufferTimeout(cfg:TransportConfig):Void {
        if (cfg.maxRtxAttempts > 0) {
            var minTimeout:Int = cfg.rtxBaseTimeout;
            var totalTimeout:Int = minTimeout;

            if (cfg.backOffMultiplier > 0.0) {
                for (i in 0...(cfg.maxRtxAttempts - 1)) {
                    minTimeout = Std.int(minTimeout + (minTimeout * cfg.backOffMultiplier));
                    if (minTimeout > 3000) {
                        minTimeout = 3000;
                    }
                    totalTimeout += minTimeout;
                }
            } else {
                totalTimeout = cfg.rtxBaseTimeout * cfg.maxRtxAttempts;
            }

            if (cfg.packetBufferExpiryTime < totalTimeout) {
                cfg.packetBufferExpiryTime = totalTimeout;
            }
        }
    }

    public function toString():String {
        var debug = "";
        debug += "+ - - - - - - - - - - - - - - - - - - - +\n";
        debug += "+ RDP Protocol Settings                 +\n";
        debug += "+ - - - - - - - - - - - - - - - - - - - +\n";
        debug += "  Mtu: " + this.mtu + "\n";
        debug += "  ReliableImpl: " + this.reliableImpl + "\n";
        debug += "  MaxRtxAttempts: " + this.maxRtxAttempts + "\n";
        debug += "  BackOffMultiplier: " + this.backOffMultiplier + "\n";
        debug += "  UnACKBufferSize: " + this.unACKBufferSize + "\n";
        debug += "  PacketBufferSize: " + this.packetBufferSize + "\n";
        debug += "  RtxBaseTimeout: " + this.rtxBaseTimeout + "\n";
        debug += "  PacketBufferExpiryTime: " + this.packetBufferExpiryTime + "\n";
        debug += "  TriggerReliableErrors: " + this.triggerReliableErrors + "\n";
        debug += "  MaxFragments: " + this.maxFragments + "\n";
        debug += "  FragBufferLimit: " + this.fragBufferLimit + "\n";
        debug += "+ - - - - - - - - - - - - - - - - - - - +\n";
        return debug;
    }
}
