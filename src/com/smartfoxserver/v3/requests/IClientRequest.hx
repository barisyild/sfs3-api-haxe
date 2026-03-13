package com.smartfoxserver.v3.requests;

import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.bitswarm.TransportType;
import com.smartfoxserver.v3.bitswarm.io.IRequest;

interface IClientRequest {
    function validate(sfs:ISmartFox):Void;
    function execute(sfs:ISmartFox):Void;

    function getTargetController():Int;
    public function setTargetController(target:Int):Void;

    public function getTransportType():TransportType;
    public function setTransportType(txType:TransportType):Void;

    public function getRequest():IRequest;
}
