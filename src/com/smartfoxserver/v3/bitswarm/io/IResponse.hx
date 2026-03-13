package com.smartfoxserver.v3.bitswarm.io;

import haxe.io.Bytes;
import com.smartfoxserver.v3.entities.data.ISFSObject;

interface IResponse {
    public function getControllerId():Int;
    public function getId():Int;

    public function getContent():ISFSObject;
    public function getRawContent():Bytes;

    public function getTransportType():TransportType;

    public function isRaw():Bool;
    public function isTcp():Bool;
    public function isUdp():Bool;
}
