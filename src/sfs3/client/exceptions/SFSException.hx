package sfs3.client.exceptions;
import haxe.Exception;
import sfs3.client.entities.data.SFSErrorData;

class SFSException extends Exception {
    private var errorData:SFSErrorData;

    public function new(message:String = null, data:SFSErrorData = null) {
        super(message);
        this.errorData = data;
    }

    public function getErrorData():SFSErrorData {
        return this.errorData;
    }
}
