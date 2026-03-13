package com.smartfoxserver.v3.bitswarm.rdp;

import com.smartfoxserver.v3.bitswarm.rdp.data.RDPacket;
import com.smartfoxserver.v3.bitswarm.rdp.data.UDPData;
import com.smartfoxserver.v3.exceptions.UnsupportedOperationException;

class RawChannel extends BaseChannel {
    public function new(transport:ITransport) {
        super(transport);
    }

    public function dataReceived(data:UDPData):Void {
        var packetData = data.buff; // No need to slice buffer position like Java ByteBuffer, buff is already scaled
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
