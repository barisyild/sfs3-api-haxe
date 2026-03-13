package com.smartfoxserver.v3.bitswarm;

interface ICryptoStorage
{
    public function getKey():CryptoKey;
    public function setKey(key:CryptoKey):Void;

    public function getHttpHost():String;
    public function getHttpPort():Int;
}

