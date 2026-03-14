package com.smartfoxserver.v3.requests;

import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.exceptions.SFSValidationException;

/**
 * Logs the user out of the current server Zone.
 * <p/>
 * <p>The user is notified of the logout operation by means of the <em>logout</em> event.
 * This doesn't shut down the connection, so the user will be able to login again in the same Zone or in a different one right after the confirmation event.</p>
 * <p/>
 * <p/>
 *
 * @see		com.smartfoxserver.v3.core.SFSEvent#LOGOUT
 */
@:expose("SFS3.LogoutRequest")
class LogoutRequest extends BaseRequest 
{
	/**
	 * @internal
	 */
	public static final KEY_ZONE_NAME:String = "zn";


	/**
	 * Creates a new <em>LogoutRequest</em> instance.
	 * The instance must be passed to the <em>SmartFox.send()</em> method for the request to be performed.
	 *
	 * @see		com.smartfoxserver.v3.SmartFox#send
	 */
	public function new() 
	{
		super(BaseRequest.Logout);
	}

	/**
	 * @internal
	 */
	public function validate(sfs:ISmartFox):Void
	{
		if (sfs.getMySelf() == null) 
			throw new SFSValidationException("LogoutRequest Error", ["You are not logged in a the moment!"]);
	}

	/**
	 * @internal
	 */
	public function execute(sfs:ISmartFox):Void { }
}
