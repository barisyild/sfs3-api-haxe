package sfs3.client.bitswarm.io.protocol;

class PendingPacket
{
    private var header:PacketHeader;
    private var buffer:Dynamic;

    public function new(header:PacketHeader)
    {
        this.header = header;
    }

    public function getHeader():PacketHeader
    {
        return header;
    }

    public function getBuffer():Dynamic
    {
        return buffer;
    }

    public function setBuffer(buffer:Dynamic):Void
    {
        this.buffer = buffer;
    }

    public function toString():String
    {
        return header.toString() + Std.string(buffer);
    }
}
