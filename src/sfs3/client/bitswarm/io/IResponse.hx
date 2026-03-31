package sfs3.client.bitswarm.io;

import haxe.io.Bytes;
import sfs3.client.entities.data.ISFSObject;

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
