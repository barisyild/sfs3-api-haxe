package com.smartfoxserver.v3.requests.buddylist;

import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.exceptions.SFSValidationException;
import com.smartfoxserver.v3.requests.BaseRequest;

/**
 * Removes a buddy from the current user's buddies list.
 * <p/>
 * <p>In order to remove a buddy, the current user must be online in the Buddy List system. If the buddy is removed successfully, the operation is confirmed by a <em>buddyRemove</em> event;
 * otherwise the <em>buddyError</em> event is fired.</p>
 * <p/>
 * <p><b>NOTE</b>: this request can be sent if the Buddy List system was previously initialized only (see the <em>InitBuddyListRequest</em> request description).</p>
 * <p/>
 * <p/>
 *
 * @see		com.smartfoxserver.v3.core.SFSBuddyEvent#BUDDY_REMOVE
 * @see		com.smartfoxserver.v3.core.SFSBuddyEvent#BUDDY_ERROR
 * @see		AddBuddyRequest
 * @see		InitBuddyListRequest
 */
class RemoveBuddyRequest extends BaseRequest 
{
	/**
	 * @internal
	 */
	public static final KEY_BUDDY_NAME:String = "bn";

	private var name:String;

	/**
	 * Creates a new <em>RemoveBuddyRequest</em> instance.
	 * The instance must be passed to the <em>SmartFox.send()</em> method for the request to be performed.
	 *
	 * @param	buddyName	The name of the buddy to be removed from the user's buddies list.
	 * 
	 * @see		com.smartfoxserver.v3.SmartFox#send
	 */
	public function new(buddyName:String) 
	{
		super(BaseRequest.RemoveBuddy);
		this.name = buddyName;
	}

	/**
	 * @internal
	 */
	public function validate(sfs:ISmartFox):Void
	{
		var errors = new Array<String>();

		if (!sfs.getBuddyManager().isInited()) 
			errors.push("BuddyList is not inited. Please send an InitBuddyRequest first");

		if (!sfs.getBuddyManager().getMyOnlineState()) 
			errors.push("Can't remove buddy while offline");

		if (!sfs.getBuddyManager().containsBuddy(name)) 
			errors.push("Can't remove buddy that is not in your list: " + name);

		if (errors.length > 0) 
			throw new SFSValidationException("RemoveBuddy request error", errors);
	}

	/**
	 * @internal
	 */
	public function execute(sfs:ISmartFox):Void
	{
		sfso.putString(KEY_BUDDY_NAME, name);
	}
}
