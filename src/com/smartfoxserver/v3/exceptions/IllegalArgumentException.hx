package com.smartfoxserver.v3.exceptions;
import haxe.Exception;
class IllegalArgumentException extends Exception {
    public function new(message:String) {
        super(message);
    }
}