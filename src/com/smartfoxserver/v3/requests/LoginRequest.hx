package com.smartfoxserver.v3.requests;

import com.smartfoxserver.v3.entities.data.ISFSObject;

import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.exceptions.SFSValidationException;
import com.smartfoxserver.v3.util.PasswordUtil;

/**
 * Logs the current user in one of the server Zones.
 * <p/>
 * <p>Each Zone represent an independent multiuser application governed by SmartFoxServer. In order to join a Zone, a user name and password are usually required.
 * In order to validate the user credentials, a custom login process should be implemented in the Zone's server-side Extension.</p>
 * <p/>
 * <p>Read the SmartFoxServer 3 documentation about the login process for more informations.</p>
 * <p/>
 * <p>If the login operation is successful, the current user receives a <em>login</em> event; otherwise the <em>loginError</em> event is fired.</p>
 * <p/>
 * <p/>
 *
 * @see com.smartfoxserver.v3.core.SFSEvent#LOGIN
 * @see com.smartfoxserver.v3.core.SFSEvent#LOGIN_ERROR
 */
class LoginRequest extends BaseRequest 
{
	/** @internal */
	public static final KEY_ZONE_NAME:String = "zn";

	/** @internal */
	public static final KEY_USER_NAME:String = "un";

	/** @internal */
	public static final KEY_PASSWORD:String = "pw";
	
	/** @internal */
	public static final KEY_PARAMS:String = "p";

	/** @internal */
	public static final KEY_PRIVILEGE_ID:String = "pi";

	/** @internal */
	public static final KEY_ID:String = "id";

	/** @internal */
	public static final KEY_ROOMLIST:String = "rl";

	/** @internal */
	public static final KEY_RECONNECTION_SECONDS:String = "rs";
	
	/** @internal */
	public static final KEY_CLUSTER_SID:String = "_sid";

	private var zoneName:String;
	private var userName:String;
	private var password:String;
	private var params:ISFSObject;

	/**
	 * Creates a new <em>LoginRequest</em> instance.
	 * The instance must be passed to the <em>SmartFox.send()</em> method for the request to be performed.
	 *
	 * @param	userName	The name to be assigned to the user. If not passed and if the Zone allows guest users, the name is generated automatically by the server.
	 * @param	password	The user password to access the system. SmartFoxServer doesn't offer a default authentication system,
	 * 						so the password must be validated implementing a custom login system in the Zone's server-side Extension.
	 * @param	zoneName	The name (case-sensitive) of the server Zone to login to; if a Zone name is not specified, the client will use the setting loaded via <em>SmartFox.loadConfig()</em> method.
	 * @param	params		An instance of <em>SFSObject</em> containing custom parameters to be passed to the Zone Extension (requires a custom login system to be in place).
	 * 
	 * @see		com.smartfoxserver.v3.SmartFox#send
	 * @see		com.smartfoxserver.v3.entities.data.SFSObject SFSObject
	 */
	public function new(?userName:String = "", ?password:String = "", ?zoneName:String = null, ?params:ISFSObject = null) 
	{
		super(BaseRequest.Login);

		this.zoneName = zoneName;
		this.userName = userName;
		this.password = (password == null) ? "" : password;
		this.params = params;
	}

	/**
	 * @internal
	 */
	public function validate(sfs:ISmartFox):Void
	{
		if (sfs.getMySelf() != null) 
			throw new SFSValidationException("LoginRequest Error", ["You are already logged in. Logout first"]);

		// Attempt to use config data, if provided
		if ((zoneName == null || zoneName.length == 0) && sfs.getConfig() != null)
			zoneName = sfs.getConfig().zone;

		if (zoneName == null || zoneName.length == 0) 
			throw new SFSValidationException("LoginRequest Error", ["Missing Zone name"]);
		
		if (userName == null)
			userName = "";
	}

	/**
	 * @internal
	 */
	public function execute(sfs:ISmartFox):Void
	{
		sfso.putString(KEY_ZONE_NAME, zoneName);
		sfso.putString(KEY_USER_NAME, userName);
			
		var useSSL:Bool = sfs.getConfig().useSSL;
		
		/*
		 * If SSL is not active: 
		 * 		Minimal password encryption using CHAP auth 
		 * 		https://en.wikipedia.org/wiki/Challenge-Handshake_Authentication_Protocol
		 * 
		 * Otherwise we send the plain text over the encrypted connection
		 */
		
		if (!useSSL && password.length > 0)
			password = PasswordUtil.SHA256Password(sfs.getSessionToken() + password);
		
		sfso.putString(KEY_PASSWORD, password);

		// optional params
		if (params != null)
			sfso.putSFSObject(KEY_PARAMS, params);
	}
}
