package com.smartfoxserver.v3.exceptions;
import haxe.Exception;
class UnsupportedOperationException extends Exception {
    public function new(msg:String = "This operation is not supported.") {
        super(msg);
    }
}
