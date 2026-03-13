package com.smartfoxserver.v3.requests.buddylist;

import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.exceptions.SFSValidationException;
import com.smartfoxserver.v3.requests.BaseRequest;

/**
 * Toggles the current user's online/offline state as buddy in other users' buddies lists.
 * <p/>
 * <p>All clients who have the current user as buddy in their buddies list will receive the <em>buddyOnlineStateChange</em> event and see the <em>Buddy.isOnline</em> property change accordingly.
 * The same event is also dispatched to the current user, who sent the request, so that the application interface can be updated accordingly.
 * Going online/offline as buddy doesn't affect the user connection, the currently joined Zone and Rooms, etc.</p>
 * <p/>
 * <p>The online state of a user in a buddy list is handled by means of a reserved and persistent Buddy Variable.</p>
 * <p/>
 * <p><b>NOTE</b>: this request can be sent if the Buddy List system was previously initialized only (see the <em>InitBuddyListRequest</em> request description).</p>
 * <p/>
 * <p/>
 *
 * @see		com.smartfoxserver.v3.entities.managers.IBuddyManager#getMyOnlineState()
 * @see		com.smartfoxserver.v3.entities.Buddy#isOnline()
 * @see		com.smartfoxserver.v3.core.SFSBuddyEvent#BUDDY_ONLINE_STATE_CHANGE
 * @see		InitBuddyListRequest
 */
class GoOnlineRequest extends BaseRequest 
{
	/**
	 * @internal
	 */
	public static final KEY_ONLINE:String = "o";
	
	/**
	 * @internal
	 */
	public static final KEY_BUDDY_NAME:String = "bn";
	
	/**
	 * @internal
	 */
	public static final KEY_BUDDY_ID:String = "bi";

	private var online:Bool;

	/**
	 * Creates a new <em>GoOnlineRequest</em> instance.
	 * The instance must be passed to the <em>SmartFox.send()</em> method for the request to be performed.
	 *
	 * @param	online	<code>true</code> to make the current user available (online) in the Buddy List system; <code>false</code> to make him not available (offline).
	 * 
	 * @see		com.smartfoxserver.v3.SmartFox#send
	 */
	public function new(online:Bool) 
	{
		super(BaseRequest.GoOnline);
		this.online = online;
	}

	/**
	 * @internal
	 */
	public function validate(sfs:ISmartFox):Void
	{
		var errors = new Array<String>();

		if (!sfs.getBuddyManager().isInited()) 
			errors.push("BuddyList is not inited. Please send an InitBuddyRequest first");

		if (errors.length > 0) 
			throw new SFSValidationException("GoOnline request error", errors);
	}

	/**
	 * @internal
	 */
	public function execute(sfs:ISmartFox):Void
	{
		/*
		 * Locally we already set the flag without the need of a server response
		 * There's no need to fire an asynchronous event for this request.
		 * As soon as the command is sent the local flag is set
		 */
		sfs.getBuddyManager().setMyOnlineState(online);
		sfso.putBool(KEY_ONLINE, online);
	}
}
