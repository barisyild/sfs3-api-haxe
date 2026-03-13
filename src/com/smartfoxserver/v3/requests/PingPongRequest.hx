package com.smartfoxserver.v3.requests;

import com.smartfoxserver.v3.ISmartFox;

/**
 * <b>*Private*</b> Sends a ping-pong request in order to measure the current lag.
 * This is used by the system. Never send this directly.
 */
class PingPongRequest extends BaseRequest 
{
	/**
	 * <b>*Private*</b>
	 */
	public function new() 
	{
		super(BaseRequest.PingPong);
	}

	/**
	 * <b>*Private*</b>
	 */
	public function validate(sfs:ISmartFox):Void { }

	/**
	 * <b>*Private*</b>
	 */
	public function execute(sfs:ISmartFox):Void { }
}
