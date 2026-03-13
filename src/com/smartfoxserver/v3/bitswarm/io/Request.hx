package com.smartfoxserver.v3.bitswarm.io;
class Request implements IRequest
{
    private var cid:Int;
    private var id:Int;

    private var content:Dynamic;
    private var encrypted:Bool = false;
    private var raw:Bool = false;
    private var txType:TransportType = TransportType.TCP;

    /*
	 * By default every Request is assumed to use TCP
	 * Change it were required
	 */
    public function new(cid:Int, id:Int)
    {
        this.cid = cid;
        this.id = id;
    }

    public function getId():Int
    {
        return id;
    }

    public function setId(id:Int):Void
    {
        this.id = id;
    }

    public function getContent():Dynamic
    {
        return content;
    }

    public function setContent(content:Dynamic):Void
    {
        this.content = content;
    }

    public function getControllerId():Int
    {
        return cid;
    }

    public function setControllerId(cid:Int):Void
    {
        this.cid = cid;
    }

    public function isEncrypted():Bool
    {
        return encrypted;
    }

    public function setEncrypted(encrypted:Bool):Void
    {
        this.encrypted = encrypted;
    }

    public function getTransport():TransportType
    {
        return txType;
    }

    public function setTransport(txType:TransportType):Void
    {
        this.txType = txType;
    }

    public function isTcp():Bool
    {
        return txType == TransportType.TCP;
    }

    public function isUdp():Bool
    {
        return !isTcp();
    }

    public function isRaw():Bool
    {
        return raw;
    }

    public function setRaw(value:Bool):Void
    {
        this.raw = value;
    }

    public function toString():String
    {
        return 'Ctrl: $cid, Req: $id, Tx: $txType, Raw: ${isRaw()})';
    }
}