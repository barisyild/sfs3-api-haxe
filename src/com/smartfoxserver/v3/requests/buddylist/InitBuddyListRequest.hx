package com.smartfoxserver.v3.requests.buddylist;

import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.exceptions.SFSValidationException;
import com.smartfoxserver.v3.requests.BaseRequest;

/**
 * Initializes the Buddy List system on the current client.
 * <p/>
 * <p>Buddy List system initialization involves loading any previously stored buddy-specific data from the server, such as the current user's buddies list, his previous state and the persistent Buddy Variables.
 * The initialization request is <b>the first operation to be executed</b> in order to be able to use the Buddy List system features.
 * Once the initialization is completed, the <em>buddyListInit</em> event is fired and the user has access to all his previously set data and can start to interact with his buddies;
 * if the initialization failed, a <em>buddyError</em> event is fired.</p>
 * <p/>
 * <p/>
 *
 * @see		com.smartfoxserver.v3.core.SFSBuddyEvent#BUDDY_LIST_INIT
 * @see		com.smartfoxserver.v3.core.SFSBuddyEvent#BUDDY_ERROR
 */
@:expose("SFS3.InitBuddyListRequest")
class InitBuddyListRequest extends BaseRequest 
{
	/**
	 * @internal
	 */
	public static final KEY_BLIST:String = "bl";
	
	/**
	 * @internal
	 */
	public static final KEY_BUDDY_STATES:String = "bs";
	
	/**
	 * @internal
	 */
	public static final KEY_MY_VARS:String = "mv";

	/**
	 * Creates a new <em>InitBuddyListRequest</em> instance.
	 * The instance must be passed to the <em>SmartFox.send()</em> method for the request to be performed.
	 *
	 * @see		com.smartfoxserver.v3.SmartFox#send
	 */
	public function new() 
	{
		super(BaseRequest.InitBuddyList);
	}

	/**
	 * @internal
	 */
	public function validate(sfs:ISmartFox):Void
	{
		var errors = new Array<String>();

		if (sfs.getBuddyManager().isInited())
			errors.push("Buddy List is already initialized");

		if (errors.length > 0) 
			throw new SFSValidationException("InitBuddyList error", errors);
	}

	/**
	 * @internal
	 */
	public function execute(sfs:ISmartFox):Void
	{
		// no params to add
	}
}
