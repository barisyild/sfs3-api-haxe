package com.smartfoxserver.v3.util;
class ApiVersion
{
    private var maj(default, null):Int;
    private var min(default, null):Int;
    private var sub(default, null):Int;
    private var status(default, null):String; // e.g. alpha, beta, release candidate, final

    public function new(maj:Int, min:Int, sub:Int, status:String = null)
    {
        this.maj = maj;
        this.min = min;
        this.sub = sub;
        this.status = status;
    }

    public function canonical():String
    {
        return '$maj.$min.$sub';
    }

    public function toString():String
    {
        return (status == null ? canonical() : canonical() + "_" + status);
    }
}