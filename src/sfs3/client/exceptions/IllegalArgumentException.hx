package sfs3.client.exceptions;
import haxe.Exception;
class IllegalArgumentException extends Exception {
    public function new(message:String) {
        super(message);
    }
}