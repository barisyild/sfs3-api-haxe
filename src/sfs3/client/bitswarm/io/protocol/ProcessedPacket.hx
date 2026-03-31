package sfs3.client.bitswarm.io.protocol;
import haxe.io.Bytes;

class ProcessedPacket
{
    private var data:Bytes;
    private var state:PacketReadState;

    public function new(state:PacketReadState, data:Bytes)
    {
        this.state = state;
        this.data = data;
    }

    public function getData():Bytes
    {
        return data;
    }

    public function getState():PacketReadState
    {
        return state;
    }
}