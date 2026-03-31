package sfs3.client.bitswarm.io;
import sfs3.client.core.LoggerFactory;
import sfs3.client.core.Logger;

abstract class SpecializedIOHandler
{
    private final hexDumpMaxSize:Int = SFSIOHandler.MAX_PACKET_DEBUG_LEN;
    private final log:Logger;
    private var ioHandler:SFSIOHandler;

    public function new(ioHandler:SFSIOHandler)
    {
        this.log = LoggerFactory.getLogger(Type.getClass(this));
        this.ioHandler = ioHandler;
    }

    public function getCodec():IProtocolCodec
    {
        return ioHandler.getCodec();
    }
}