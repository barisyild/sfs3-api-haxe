package com.smartfoxserver.v3.bitswarm.io.protocol;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import haxe.io.BytesInput;
import haxe.io.BytesData;

class ProtocolUtils
{
    public static final UINT16_MAX_VALUE:Int = 65535;
    public static final INT16_BYTE_SIZE:Int = 2; // Short.SIZE / 8 = 16 / 8
    public static final INT32_BYTE_SIZE:Int = 4; // Integer.SIZE / 8 = 32 / 8

    public static final CTRL_DATA_BYTE_SIZE:Int = 3;

    public static function encodePacketHeader(packetHeader:PacketHeader):Int
    {
        var headerByte:Int = 0;

        if (packetHeader.isCompressed())
            headerByte += 0x80;

        if (packetHeader.isEncrypted())
            headerByte += 0x40;

        if (packetHeader.isBigSized())
            headerByte += 0x20;

        if (packetHeader.isRaw())
            headerByte += 0x10;

        return headerByte;
    }

    public static function decodePacketHeader(headerByte:Int):PacketHeader
    {
        return new PacketHeader
        (
        (headerByte & 0x80) > 0,
        (headerByte & 0x40) > 0,
        (headerByte & 0x20) > 0,
        (headerByte & 0x10) > 0
        );
    }

/*
	 * Prepends the binary packet (SFSObject) with its controller data
	 * 	- controllerId 	(byte)
	 * 	- actionId		(short)
	 */
    public static function encodeControllerData(data:BytesData, ctrlId:Int, actId:Int):BytesData
    {
        var bb:BytesOutput = new BytesOutput(); //  //ByteBuffer.allocate(data.length + 3);
        bb.bigEndian = true;
        bb.writeByte(ctrlId);
        bb.writeInt16(actId); // Önce yüksek bayt
        bb.write(Bytes.ofData(data));
        return bb.getBytes().getData();
    }

/*
	 * Prepends the binary raw packet with its Sender userId (Int32)
	 */
    public static function encodeUserId(data:BytesData, userId:Int):BytesData
    {
        var bb:BytesOutput = new BytesOutput(); //ByteBuffer.allocate(data.length + 4);
        bb.bigEndian = true;
        bb.writeInt32(userId);
        bb.write(Bytes.ofData(data));

        return bb.getBytes().getData();
    }

    public static function decodeControllerData(buff:BytesData):ControllerData
    {
        var bytesInput:BytesInput = new BytesInput(Bytes.ofData(buff));
        bytesInput.bigEndian = true;
        return new ControllerData(bytesInput.readByte(), bytesInput.readInt16());
    }
}
