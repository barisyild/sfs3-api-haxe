package sfs3.client.controllers.system;
import sfs3.client.core.LoggerFactory;
import sfs3.client.core.Logger;

abstract class BaseResponseHandler implements IResponseHandler
{
    private var log:Logger;

    public function new() {
    log = LoggerFactory.getLogger(Type.getClass(this));
    }
}
