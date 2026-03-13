package com.smartfoxserver.v3.requests;

import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.exceptions.SFSValidationException;
import com.smartfoxserver.v3.entities.User;

/**
 * @internal
 */
class UdpInitRequest extends BaseRequest
{
	public static final KEY_HANDSHAKE:String = "h";
	public static final KEY_RDP_CFG:String = "rc";
	public static final KEY_USER:String = "u";
	public static final KEY_MAX_IDLE_SECS:String = "ms";
	public static final KEY_UDP_KEEPALIVE:String = "uk";

	public function new(myself:User)
	{
		super(BaseRequest.UdpInit);
		
		sfso.putByte(KEY_HANDSHAKE, 0x01);
		sfso.putInt(KEY_USER, myself.getId());
	}
	
	public function validate(sfs:ISmartFox):Void {}
	
	public function execute(sfs:ISmartFox):Void {}
}
