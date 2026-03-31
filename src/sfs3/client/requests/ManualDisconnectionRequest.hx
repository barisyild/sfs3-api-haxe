package sfs3.client.requests;

import sfs3.client.ISmartFox;

/**
 * <b>*Private*</b>
 * This is used by the system. Never send this directly.
 */
@:expose("SFS3.ManualDisconnectionRequest")
class ManualDisconnectionRequest extends BaseRequest 
{
	public function new() 
	{
		super(BaseRequest.ManualDisconnection);
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
