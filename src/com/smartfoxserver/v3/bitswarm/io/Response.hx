package com.smartfoxserver.v3.bitswarm.io;
import haxe.io.Bytes;
import com.smartfoxserver.v3.entities.data.ISFSObject;
class Response implements IResponse
{
    private final cid:Int;
    private final id:Int;
    private final content:Dynamic;
    private final txType:TransportType;
    private final raw:Bool;

    public function new(cid:Int, id:Int, content:Dynamic, txType:TransportType, isRaw:Bool)
    {
        this.cid = cid;
        this.id = id;
        this.content = content;
        this.txType = txType;
        this.raw = isRaw;
    }

    public function getControllerId():Int
    {
        return cid;
    }

    public function getId():Int
    {
        return id;
    }

    public function getContent():ISFSObject
    {
        return cast(content, ISFSObject);
    }

    public function getRawContent():Bytes
    {
        return cast(content, Bytes);
    }

    public function getTransportType():TransportType
    {
        return txType;
    }

    public function isRaw():Bool
    {
        return raw;
    }

    public function isTcp():Bool
    {
        return txType == TransportType.TCP;
    }

    public function isUdp():Bool
    {
        return !isTcp();
    }

    public function toString():String
    {
        return '($id, $cid, $txType)';
    }
}