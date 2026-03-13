package com.smartfoxserver.v3.bitswarm.io;

interface IRequest
{
    public function getControllerId():Int;
    public function setControllerId(targetController:Int):Void;

    public function getId():Int;
    public function setId(id:Int):Void;

    public function getContent():Dynamic;
    public function setContent(obj:Dynamic):Void;

    public function getTransport():TransportType;
    public function setTransport(type:TransportType):Void;

    public function isEncrypted():Bool;
    public function setEncrypted(encrypted:Bool):Void;

    public function isRaw():Bool;
    public function setRaw(value:Bool):Void;

    public function isTcp():Bool;
    public function isUdp():Bool;
}
