package sfs3.client.exceptions;
import haxe.Exception;
class UnsupportedOperationException extends Exception {
    public function new(msg:String = "This operation is not supported.") {
        super(msg);
    }
}
