package sfs3.client.controllers;
import sfs3.client.bitswarm.io.IResponse;

interface IResponseHandler {
    public function handleResponse(sfs:ISmartFox, resp:IResponse):Void;
}
