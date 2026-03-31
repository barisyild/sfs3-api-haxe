package sfs3.client.requests;

import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.TransportType;
import sfs3.client.bitswarm.io.IRequest;

interface IClientRequest {
    function validate(sfs:ISmartFox):Void;
    function execute(sfs:ISmartFox):Void;

    function getTargetController():Int;
    public function setTargetController(target:Int):Void;

    public function getTransportType():TransportType;
    public function setTransportType(txType:TransportType):Void;

    public function getRequest():IRequest;
}
