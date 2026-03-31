package sfs3.client.bitswarm.rdp;

import sfs3.client.bitswarm.rdp.data.RDPacket;
import sfs3.client.bitswarm.rdp.data.UDPData;
import haxe.io.BytesInput;
import sfs3.client.exceptions.UnsupportedOperationException;

class UnreliableChannel extends BaseChannel {
    private var lastDispatchedSeqId:Int = -1;

    public function new(transport:ITransport) {
        super(transport);
    }

    public function destroy():Void {
    }

    public function dataReceived(data:UDPData):Void {
        var buff = data.buff;
        var bi = new BytesInput(buff);
        bi.bigEndian = true;
        var seqId = bi.readInt32();
        var delta = seqId - this.lastDispatchedSeqId;

        if (delta > 0) {
            var packetData = bi.read(buff.length - 4); // Remaining bytes
            var packet = new RDPacket(data.header, packetData, seqId, null);
            packet.setEndPoint(data.endPoint);
            this.lastDispatchedSeqId = seqId;
            this.transport.addInBytes(packetData.length);
            this.transport.addInPacket();
            this.transport.getIncomingDataHandler()(packet.getData(), packet.getEndPoint(), TxpMode.UNRELIABLE_ORDERED);
        } else if (this.log.isDebugEnabled()) {
            this.log.debug("Unreliable packet discarded: " + seqId);
        }
    }

    public function sendData(packet:RDPacket):Void {
        packet.setSeqId(this.nextOutSeqId());
        var buffer = this.preparePacketForSending(packet);
        this.transport.addOutBytes(buffer.length);
        this.transport.addOutPacket();
        this.transport.getOutgoingDataHandler()(buffer, packet.getEndPoint(), TxpMode.UNRELIABLE_ORDERED);
    }

    public function dispatchPacket(packet:RDPacket, ?fragCount:Int):Void {
        throw new UnsupportedOperationException();
    }
}
