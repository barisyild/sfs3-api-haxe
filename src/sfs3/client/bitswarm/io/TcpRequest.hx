package sfs3.client.bitswarm.io;
class TcpRequest extends Request
{
    public function new(id:Int, cid:Int)
    {
        super(id, cid);
        setTransport(TransportType.TCP);
    }
}
