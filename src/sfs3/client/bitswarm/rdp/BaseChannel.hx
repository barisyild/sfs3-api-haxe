package sfs3.client.bitswarm.rdp;

import sfs3.client.bitswarm.rdp.data.PacketHeader;
import sfs3.client.bitswarm.rdp.data.RDPacket;
import hx.concurrent.atomic.AtomicInt;
import hx.concurrent.executor.Executor;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import sfs3.client.core.Logger;
import sfs3.client.core.LoggerFactory;

abstract class BaseChannel implements Channel {
    private var outSeqId:AtomicInt = new AtomicInt(0);
    private var transport:ITransport;
    private var log:Logger;
    private var isRTTProvider:Bool = false;

    public function new(transport:ITransport) {
        this.transport = transport;
        this.log = LoggerFactory.getLogger(Type.getClass(this));
    }

    public abstract function destroy():Void;
    
    public abstract function dataReceived(data:sfs3.client.bitswarm.rdp.data.UDPData):Void;
    public abstract function sendData(packet:RDPacket):Void;

    public abstract function dispatchPacket(packet:RDPacket, ?delay:Int):Void;

    public function getTransport():ITransport {
        return this.transport;
    }

    public function currOutSeqId():Int {
        return this.outSeqId.value;
    }

    public function nextOutSeqId():Int {
        return this.outSeqId.incrementAndGet() - 1; // java getAndIncrement equivalent
    }

    public function getThreadPool():Executor {
        return this.transport.getCfg().threadPool;
    }

    public function providesRTT():Bool {
        return this.isRTTProvider;
    }

    private function preparePacketForSending(packet:RDPacket):Bytes {
        var header = packet.getHeader();
        var isFrag = header.isFrag();
        var isRaw = header.isRaw();

        var bo = new BytesOutput();
        bo.bigEndian = true;
        packet.getHeader().encode(bo);
        if (!isRaw) {
            if (isFrag) {
                packet.getFragHeader().encode(bo);
            }
            bo.writeInt32(packet.getSeqId());
        }
        bo.writeBytes(packet.getData(), 0, packet.getDataSize());
        return bo.getBytes();
    }
}
