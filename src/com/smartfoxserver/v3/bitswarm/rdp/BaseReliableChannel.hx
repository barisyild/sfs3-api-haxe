package com.smartfoxserver.v3.bitswarm.rdp;

import com.smartfoxserver.v3.bitswarm.rdp.data.RDPacket;
import haxe.Timer;
import haxe.io.Bytes;

abstract class BaseReliableChannel extends BaseChannel implements ReliableInternals {
    public function new(transport:ITransport) {
        super(transport);
    }

    public abstract function getPacketBufferSize():Int;
    public abstract function getFragBufferSize():Int;
    public abstract function getBufferDump():Array<String>;
    public abstract function getFragBufferDump():Array<String>;
    public abstract function getUnAckedDump():Array<String>;
    public abstract function getUnAckedIds():Array<Int>;
    public abstract function getCurrentRTT():Float;

    private function triggerSendEvent(packet:RDPacket):Void {
        var data:Bytes = null;
        if (packet.getHeader().isAck()) {
            data = packet.getData();
        } else {
            data = this.preparePacketForSending(packet);
            this.transport.addRtx();
        }

        this.transport.getOutgoingDataHandler()(data, packet.getEndPoint(), TxpMode.RELIABLE_ORDERED);
    }

    private function isExpired(packet:RDPacket):Bool {
        var elapsed = (Timer.stamp() * 1000.0) - packet.getCreationTime();
        return elapsed > this.transport.getCfg().packetBufferExpiryTime;
    }
}
