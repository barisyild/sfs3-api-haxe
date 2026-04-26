package sfs3.client.bitswarm.io;

import sfs3.client.core.LoggerFactory;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import sfs3.client.util.NetDebugLevel;
import sfs3.client.exceptions.IllegalArgumentException;
import sfs3.client.core.Logger;
import sfs3.client.entities.data.ISFSObject;
import sfs3.client.exceptions.SFSException;
import sfs3.client.bitswarm.util.ByteUtils;
import sfs3.client.entities.data.SFSObject;
import haxe.io.BytesData;

class SFSProtocolCodec implements IProtocolCodec
{
    private final log:Logger;
    private final ioHandler:IOHandler;
    private final bitSwarm:BitSwarmClient;

    public function new(handler:BaseIOHandler)
    {
        this.log = LoggerFactory.getLogger(Type.getClass(this));
        this.ioHandler = handler;
        this.bitSwarm = handler.getBitSwarm();
    }

    public function onPacketRead(buff:BytesData, txType:TransportType, isRaw:Bool):Void
    {
        if (isRaw)
            onRawPacketRead(buff, txType);
        else
            onStdPacketRead(buff, txType);
    }

    private function onRawPacketRead(bytesData:BytesData, txType:TransportType):Void
    {
        var bytes = Bytes.ofData(bytesData);
        var input = new BytesInput(bytes);
        input.bigEndian = true;
        var ctrlId:Int = input.readByte();
        var reqId:Int = input.readInt16();

        var remainingLen = input.length - input.position;
        var respData:Bytes = input.read(remainingLen);

        var resp:Response = new Response(ctrlId, reqId, respData, txType, true);
        dispatchResponse(resp);
    }

    private function onStdPacketRead(bytesData:BytesData, txType:TransportType):Void
    {
        var bytes = Bytes.ofData(bytesData);
        var buff = new BytesInput(bytes);
        buff.bigEndian = true;
        var ctrlId:Int =  buff.readByte();
        var reqId = buff.readInt16();
        var remaining = bytes.sub(3, bytes.length - 3); // TODO: Optimize
        var sfso:SFSObject = SFSObject.newFromBinaryData(remaining.getData());

        // Debug
        var dbgLvl:NetDebugLevel = bitSwarm.getNetDebugLevel();
        if (Logger.isDebugEnabled() && dbgLvl == NetDebugLevel.PROTOCOL)
            log.debug("Incoming, {}, {}", txType, sfso.getDump());

        var resp:Response = new Response(ctrlId, reqId, sfso, txType, false);
        dispatchResponse(resp);
    }

    public function onPacketWrite(request:IRequest):Void
    {
        if (request.isRaw())
            onRawPacketWrite(request);
        else
            onStdPacketWrite(request);
    }

    private function onRawPacketWrite(request:IRequest):Void
    {
        var data:Dynamic = request.getContent();
        if (!(data is Bytes))
            throw new IllegalArgumentException("Invalid type: " + data.getClass() + ", expected byte[]");

        // Debug
        if (bitSwarm.getNetDebugLevel() == NetDebugLevel.PROTOCOL)
            log.info("Outgoing, {}, {}", request.getTransport(), ByteUtils.hexDump(data));

        ioHandler.onDataWrite(request);
    }

    private function onStdPacketWrite(request:IRequest):Void
    {
        var sfso = cast(request.getContent(), ISFSObject);
        request.setContent(sfso.toBinary());

        // Debug
        if (bitSwarm.getNetDebugLevel() == NetDebugLevel.PROTOCOL && Logger.isDebugEnabled())
            log.debug("Outgoing, {}, {}", request.getTransport(), sfso.getDump());

        ioHandler.onDataWrite(request);
    }

    public function getIOHandler():IOHandler
    {
        return ioHandler;
    }

    private function dispatchResponse(resp:IResponse):Void
    {
        var controller:IController = bitSwarm.getController(resp.getControllerId());

        if (controller == null) {
            throw new SFSException("Cannot handle server response. Unknown controller, id: " + resp.getControllerId());
        }

        // Dispatch to controller
        controller.handleMessage(resp);
    }
}