package sfs3.client.bitswarm.io.protocol;

enum PacketReadState {
    WaitNewPacket;
    WaitDataSize;
    WaitDataSizeFragment;
    WaitData;
}