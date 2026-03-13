package com.smartfoxserver.v3.bitswarm.io.protocol;

enum PacketReadState {
    WaitNewPacket;
    WaitDataSize;
    WaitDataSizeFragment;
    WaitData;
}