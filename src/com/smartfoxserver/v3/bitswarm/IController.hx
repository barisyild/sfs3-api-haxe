package com.smartfoxserver.v3.bitswarm;
import com.smartfoxserver.v3.bitswarm.io.IResponse;

interface IController
{
    public function getId():Int;
    public function handleMessage(resp:IResponse):Void;
}
