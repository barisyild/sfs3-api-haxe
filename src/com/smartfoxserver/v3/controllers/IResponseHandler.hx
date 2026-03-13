package com.smartfoxserver.v3.controllers;
import com.smartfoxserver.v3.bitswarm.io.IResponse;

interface IResponseHandler {
    public function handleResponse(sfs:ISmartFox, resp:IResponse):Void;
}
