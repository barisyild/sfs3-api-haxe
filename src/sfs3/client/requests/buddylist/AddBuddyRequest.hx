package sfs3.client.requests.buddylist;

import sfs3.client.ISmartFox;
import sfs3.client.exceptions.SFSValidationException;
import sfs3.client.entities.Buddy;
import sfs3.client.requests.BaseRequest;

/**
 * Adds a new buddy to the current user's buddies list.
 * <p/>
 * <p>
 * In order to add a buddy, the current user must be online in the Buddy List
 * system. If the buddy is added successfully, the operation is confirmed by a
 * <em>buddyAdd</em> event; otherwise the <em>buddyError</em> event is fired.
 * </p>
 * <p/>
 * <p>
 * <b>NOTE</b>: this request can be sent if the Buddy List system was previously
 * initialized only (see the <em>InitBuddyListRequest</em> request description).
 * </p>
 * <p/>
 * <p/>
 *
 * @see sfs3.client.core.SFSBuddyEvent#BUDDY_ADD
 * @see sfs3.client.core.SFSBuddyEvent#BUDDY_ERROR
 * @see RemoveBuddyRequest
 * @see InitBuddyListRequest
 */
@:expose("SFS3.AddBuddyRequest")
class AddBuddyRequest extends BaseRequest
{
	/**
	 * @internal
	 */
	public static final KEY_BUDDY_NAME:String = "bn";

	private var name:String;

	/**
	 * Creates a new <em>AddBuddyRequest</em> instance. The instance must be passed
	 * to the <em>SmartFox.send()</em> method for the request to be performed.
	 *
	 * @param buddyName The name of the user to be added as a buddy.
	 * 
	 * @see sfs3.client.SmartFox#send
	 */
	public function new(buddyName:String)
	{
		super(BaseRequest.AddBuddy);
		name = buddyName;
	}

	/**
	 * @internal
	 */
	public function validate(sfs:ISmartFox):Void
	{
		var errors = new Array<String>();

		if (!sfs.getBuddyManager().isInited())
			errors.push("BuddyList is not inited. Please send an InitBuddyRequest first");

		if (name == null || name.length == 0)
			errors.push("Invalid buddy name: " + name);

		if (!sfs.getBuddyManager().getMyOnlineState())
			errors.push("Can't add buddy while offline");

		// Duplicate buddy only allowed if the existing buddy is temp
		var buddy:Buddy = sfs.getBuddyManager().getBuddyByName(name);
		if (buddy != null && !buddy.isTemp())
			errors.push("Can't add buddy, it is already in your list: " + name);

		if (errors.length > 0)
			throw new SFSValidationException("AddBuddy request error", errors);
	}

	/**
	 * @internal
	 */
	public function execute(sfs:ISmartFox):Void
	{
		sfso.putString(KEY_BUDDY_NAME, name);
	}
}
