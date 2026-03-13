package com.smartfoxserver.v3.bitswarm.io.protocol;
class PacketHeader
{
    private var expectedLen:Int = -1;

    private final compressed:Bool;
    private var encrypted:Bool;

    /*
	 * false --> size is Uint16, up to 64KB (default)
	 * true  --> size is Int32, up to 2GB
	 */
    private var bigSized:Bool;

    // Packet is raw (doesn't use default serialization)
    private var raw:Bool;

    public function new(compressed:Bool, encrypted:Bool, bigSized:Bool, raw:Bool)
    {
        this.compressed = compressed;
        this.encrypted 	= encrypted;
        this.bigSized 	= bigSized;
        this.raw 		= raw;
    }

    public function getExpectedLen():Int
    {
        return expectedLen;
    }

    public function setExpectedLen(len:Int):Void
    {
        this.expectedLen = len;
    }

    public function isRaw():Bool
    {
        return raw;
    }

    public function isCompressed():Bool
    {
        return compressed;
    }

    public function isEncrypted():Bool
    {
        return encrypted;
    }

    public function isBigSized():Bool
    {
        return bigSized;
    }

    public function setEncrypted(value:Bool):Void
    {
        this.encrypted = value;
    }

    public function setBigSize(value:Bool):Void
    {
        this.bigSized = value;
    }

    public function setRaw(value:Bool):Void
    {
        this.raw = value;
    }

    public function toString():String
    {
        var buf:StringBuf = new StringBuf();

        buf.add("\n---------------------------------------------\n");
        buf.add("Compressed:\t" + isCompressed() + "\n");
        buf.add("Encrypted :\t" + isEncrypted() + "\n");
        buf.add("BigSized  :\t" + isBigSized() + "\n");
        buf.add("Raw       :\t" + isRaw() + "\n");
        buf.add("---------------------------------------------\n");

        return buf.toString();
    }
}

