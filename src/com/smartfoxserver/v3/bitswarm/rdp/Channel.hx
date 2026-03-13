package com.smartfoxserver.v3.bitswarm.rdp;

import com.smartfoxserver.v3.bitswarm.rdp.data.RDPacket;
import com.smartfoxserver.v3.bitswarm.rdp.data.UDPData;

interface Channel {
    function dataReceived(data:UDPData):Void;
    function sendData(packet:RDPacket):Void;
}
