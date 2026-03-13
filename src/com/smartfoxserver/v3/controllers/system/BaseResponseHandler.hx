package com.smartfoxserver.v3.controllers.system;
import com.smartfoxserver.v3.core.LoggerFactory;
import com.smartfoxserver.v3.core.Logger;

abstract class BaseResponseHandler implements IResponseHandler
{
    private var log:Logger;

    public function new() {
    log = LoggerFactory.getLogger(Type.getClass(this));
    }
}
