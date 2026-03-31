package sfs3.client.bitswarm.io;
import sfs3.client.core.Logger;
import sfs3.client.core.LoggerFactory;
import haxe.io.Bytes;
import sfs3.client.exceptions.IllegalStateException;
import sfs3.client.bitswarm.io.protocol.ProtocolUtils;
import sfs3.client.bitswarm.io.protocol.PacketHeader;
import sfs3.client.bitswarm.io.protocol.RequestPacket;
import sfs3.client.util.NetDebugLevel;
import haxe.io.BytesOutput;
import sfs3.client.exceptions.SFSCodecException;
import sfs3.client.entities.User;
import sfs3.client.bitswarm.util.ByteUtils;
import haxe.io.BytesData;
class SFSIOHandler extends BaseIOHandler
{
    public static final MAX_PACKET_DEBUG_LEN:Int = 1024;

    private final log:Logger;
    private final tcpHandler:TcpIOHandler;
    private final udpHandler:UdpIOHandler;
    private final codec:IProtocolCodec;

    public function new(bitSwarm:BitSwarmClient)
    {
        super(bitSwarm);
        log = LoggerFactory.getLogger(Type.getClass(this));

        tcpHandler = new TcpIOHandler(this);
        udpHandler = new UdpIOHandler(this);

        this.codec = new SFSProtocolCodec(this);
    }

    public function getCodec():IProtocolCodec
    {
        return codec;
    }

    public function getPacketCompressor():IPacketCompressor
    {
        return packetCompressor();
    }

    public function getPacketEncrypter():IPacketEncrypter
    {
        return packetEncrypter();
    }

    /*
	 * Decode packets
	 */
    public function onDataRead(byteData:Bytes, txType:TransportType):Void
    {
        if (byteData == null || byteData.length < 1)
            throw new IllegalStateException("Empty data! (" + txType + ")");

        switch(txType)
        {
            case TCP:
                tcpHandler.handleRead(byteData);
            case UDP | UDP_RELIABLE | UDP_UNRELIABLE:
                udpHandler.handleRead(byteData, txType);
            default:
                log.warn("Unsupported transport:" + txType);
        }
    }

/*
	 * Transport neutral
	 * Write data to socket (TCP/UDP)
	 */
    public function onDataWrite(request:IRequest):Void
    {
        var binData:BytesData = cast request.getContent();

        /*
		 * Prepend UserId if we're sending Raw packet via UDP
		 */
        if (request.isRaw() && request.isUdp())
        {
            var user:User = getBitSwarm().getSmartFox().getMySelf();
            if (user == null)
                throw new IllegalStateException("Cannot send request before having logged in");

            binData = ProtocolUtils.encodeUserId(binData, user.getId());
        }

        // Prepend controller data (ctrlId [byte], actionId [short])
        binData = ProtocolUtils.encodeControllerData(binData, request.getControllerId(), request.getId());
        var binDataBytes:Bytes = Bytes.ofData(binData);

        //--- Compress data if necessary ---------------------------------------------
        var isCompressed:Bool = false;
        var originalSize:Int = binDataBytes.length;

        if (binDataBytes.length > getBitSwarm().getConnSettings().compressionThreshold)
        {
            var beforeCompression:BytesData = binData;
            binData = packetCompressor().compress(binData);
            binDataBytes = Bytes.ofData(binData);

            /*
			 * Data might not have been compressed, if the compressor has an internal MAX limit
			 * With this check we verify that compression has really taken place
			 * If the new byte data is still pointing to the old byte[], compression was not added
			 */
            if (binData != beforeCompression)
                isCompressed = true;
        }

        var maxMsgSize = getBitSwarm().getMaxMessageSize();
        if (binDataBytes.length > maxMsgSize)
        {
            /*
			 * The outgoing message is bigger than what the server allows us to send.
			 * We should stop here and provide an error to the developer
			 */

            throw new SFSCodecException('Packet is too big: ${binDataBytes.length} bytes, server limit is: ${maxMsgSize} bytes');
        }

        // Default size descriptor is short (UInt16)
        var sizeBytes:Int = ProtocolUtils.INT16_BYTE_SIZE;

        /*
		 * UDP packet size > 64K? Not possible over the internet.
		 * And likely not even in a local or loopback network
		 */
        if (binDataBytes.length > ProtocolUtils.UINT16_MAX_VALUE)
            sizeBytes = ProtocolUtils.INT32_BYTE_SIZE;

        var txType = request.getTransport();

        var packetHeader:PacketHeader = new PacketHeader
        (
        isCompressed,
        false,	// <<--- Encryption flag is always false at this stage, the PacketFinalizer will deal with it
        sizeBytes == ProtocolUtils.INT32_BYTE_SIZE,
        request.isRaw()
        );

        var packet = new RequestPacket(packetHeader, binData, txType);

        // finalize
        var byteData:Bytes;
        if (txType == TransportType.TCP)
            byteData = finalizeTCPPacket(packet);
        else
            byteData = finalizeUDPPacket(packet);

        // --- DEBUG -------------------------------------------------------------------------------------------------
        var dbgLvl = getBitSwarm().getNetDebugLevel();
        if (dbgLvl == NetDebugLevel.PACKET || dbgLvl == NetDebugLevel.PROTOCOL)
        {
            if (isCompressed)
                log.debug(' (cmp: ${originalSize} / ${byteData.length})');

            if (binDataBytes.length < MAX_PACKET_DEBUG_LEN && log.isDebugEnabled())
                log.debug("Outgoing, {}, {}", request.getTransport(), ByteUtils.hexDump(byteData.getData()));
            else
                log.debug("Outgoing, {}, Size: {}, Dump omitted", request.getTransport(), byteData.length);
        }
        // --- DEBUG -------------------------------------------------------------------------------------------------

        // ---> network
        getBitSwarm().writeToSocket(byteData, txType);
    }


    /*
	 * Assemble the complete packet to send:
	 * --------------------------------------------------------------------------
	 *
	 *  Header          +---------------- Data Segment -----------------+
	 *	+---------------+---------------+---------------+---------------+
	 *	|7|6|5|4|3|2|1|0|   Data Size   |           Packet Data         |
	 *	+---------------+---------------+---------------+---------------+
	 *
	 * 	 | | | | | | | (unused)
	 * 	 | | | | | | (unused)
	 * 	 | | | | | (unused)
	 * 	 | | | | (unused)
	 * 	 | | | isRaw
	 * 	 | | isBigSize
	 * 	 | isEnc
	 * 	 isComp
	 *
	 * --------------------------------------------------------------------------
	 *
	 */
    private function finalizeTCPPacket(packet:RequestPacket):Bytes
    {
        var header:PacketHeader = packet.header();
        var outBytesData:BytesData = packet.body();
        var outBytes:Bytes = Bytes.ofData(outBytesData);

        if (getBitSwarm().useEncryption() && !getBitSwarm().isReconnecting())
        {
            outBytesData = packetEncrypter().encrypt(outBytesData);
            header.setEncrypted(true);

            /*
			 * If the Packet Size is small we need to re-check that the size doesn't exceed the 16bit range
			 * AFTER encryption.
			 */
            if (!header.isBigSized())
                header.setBigSize(outBytes.length > ProtocolUtils.UINT16_MAX_VALUE);
        }

        //--- Prepare the full packet to send -----------------------------------------
        var headerByte:Int = ProtocolUtils.encodePacketHeader(header);
        var payloadSize:Int = header.isBigSized() ? ProtocolUtils.INT32_BYTE_SIZE : ProtocolUtils.INT16_BYTE_SIZE;

        // Header byte + Payload Size + Data Size
        var packetBuffer:BytesOutput = new BytesOutput();//ByteBuffer.allocate(1 + payloadSize + outBytes.length);
        packetBuffer.bigEndian = true;
        packetBuffer.writeByte(headerByte);

        if (header.isBigSized())
            packetBuffer.writeInt32(outBytes.length);
        else
            packetBuffer.writeInt16(outBytes.length);

        packetBuffer.write(outBytes);

        return packetBuffer.getBytes();
    }

    /*
	 * Finalizes an outgoing UDP packet.
	 * Under UDP we don't encode the "DataSize" section (see protocol specs) because UDP
	 * packets don't get fragmented, we either receive everything or nothing.
	 *
	 * NOTE: RDP packets **CAN** get fragmented but that aspect is already managed by RDP itself
	 */
    private function finalizeUDPPacket(packet:RequestPacket):Bytes
    {
        var header:PacketHeader = packet.header();
        var outBytes:BytesData = packet.body();

        /*
		 * Encryption does not apply to the UDP Handshake
		 */
        if (getBitSwarm().useEncryption() && getBitSwarm().isUdpConnected())
        {
            outBytes = packetEncrypter().encrypt(outBytes);
            header.setEncrypted(true);
        }

        //--- Prepare the full packet to send -----------------------------------------
        var headerByte:Int = ProtocolUtils.encodePacketHeader(header);

        // Header byte + Payload Size + Data Size
        var packetBuffer:BytesOutput = new BytesOutput(); //ByteBuffer.allocate(1 + outBytes.length);
        packetBuffer.bigEndian = true;
        packetBuffer.writeByte(headerByte);
        packetBuffer.write(Bytes.ofData(outBytes));

        return packetBuffer.getBytes();
    }
}
