package sfs3.client.bitswarm.rdp;

import sfs3.client.bitswarm.rdp.data.RDPacket;
import sfs3.client.bitswarm.rdp.data.UDPData;
import sfs3.client.exceptions.UnsupportedOperationException;

class RawChannel extends BaseChannel {
    public function new(transport:ITransport) {
        super(transport);
    }

    public function dataReceived(data:UDPData):Void {
        var packetData = data.buff.sub(1, data.buff.length - 1);
        var packet = new RDPacket(data.header, packetData, -1, null);
        packet.setEndPoint(data.endPoint);
        this.transport.addInBytes(packetData.length);
        this.transport.addInPacket();
        this.transport.getIncomingDataHandler()(packet.getData(), packet.getEndPoint(), TxpMode.RAW_UDP);
    }

    public function sendData(packet:RDPacket):Void {
        var buffer = this.preparePacketForSending(packet);
        this.transport.addOutBytes(buffer.length);
        this.transport.addOutPacket();
        this.transport.getOutgoingDataHandler()(buffer, packet.getEndPoint(), TxpMode.RAW_UDP);
    }

    public function destroy():Void {
    }

    public function dispatchPacket(packet:RDPacket, ?fragCount:Int):Void {
        throw new UnsupportedOperationException();
    }
}
