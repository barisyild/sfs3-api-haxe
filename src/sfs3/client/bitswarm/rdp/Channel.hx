package sfs3.client.bitswarm.rdp;

import sfs3.client.bitswarm.rdp.data.RDPacket;
import sfs3.client.bitswarm.rdp.data.UDPData;

interface Channel {
    function dataReceived(data:UDPData):Void;
    function sendData(packet:RDPacket):Void;
}
