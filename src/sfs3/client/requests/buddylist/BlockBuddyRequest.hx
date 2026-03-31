package sfs3.client.requests.buddylist;

import sfs3.client.ISmartFox;
import sfs3.client.exceptions.SFSValidationException;
import sfs3.client.entities.Buddy;
import sfs3.client.requests.BaseRequest;

/**
 * Blocks or unblocks a buddy in the current user's buddies list. Blocked
 * buddies won't be able to see if the user who blocked them is online in their
 * buddies list; they also won't be able to send messages or requests to that
 * user.
 * <p/>
 * <p>
 * In order to block a buddy, the current user must be online in the Buddy List
 * system. If the operation is successful, a <em>buddyBlock</em> confirmation
 * event is dispatched; otherwise the <em>buddyError</em> event is fired.
 * </p>
 * <p/>
 * <p>
 * <b>NOTE</b>: this request can be sent if the Buddy List system was previously
 * initialized only (see the <em>InitBuddyListRequest</em> request description).
 * </p>
 * <p/>
 * <p/>
 *
 * @see sfs3.client.core.SFSBuddyEvent#BUDDY_BLOCK
 * @see sfs3.client.core.SFSBuddyEvent#BUDDY_ERROR
 * @see InitBuddyListRequest
 */

@:expose("SFS3.BlockBuddyRequest")
class BlockBuddyRequest extends BaseRequest
{
	/**
	 * @internal
	 */
	public static final KEY_BUDDY_NAME:String = "bn";

	/**
	 * @internal
	 */
	public static final KEY_BUDDY:String = "bd";

	/**
	 * @internal
	 */
	public static final KEY_BUDDY_BLOCK_STATE:String = "bs";

	private var buddyName:String;
	private var blocked:Bool;

	/**
	 * Creates a new <em>BlockBuddyRequest</em> instance. The instance must be
	 * passed to the <em>SmartFox.send()</em> method for the request to be
	 * performed.
	 *
	 * @param buddyName The name of the buddy to be blocked or unblocked.
	 * @param blocked   <code>true</code> if the buddy must be blocked;
	 *                  <code>false</code> if he must be unblocked.
	 * 
	 * @see sfs3.client.SmartFox#send
	 */
	public function new(buddyName:String, blocked:Bool)
	{

		super(BaseRequest.BlockBuddy);

		this.buddyName = buddyName;
		this.blocked = blocked;
	}

	/**
	 * @internal
	 */
	public function validate(sfs:ISmartFox):Void
	{
		var errors = new Array<String>();

		if (!sfs.getBuddyManager().isInited())
			errors.push("BuddyList is not inited. Please send an InitBuddyRequest first");

		if (buddyName == null || buddyName.length == 0)
			errors.push("Invalid buddy name: " + buddyName);

		if (!sfs.getBuddyManager().getMyOnlineState())
			errors.push("Can't block buddy while offline");

		var buddy:Buddy = sfs.getBuddyManager().getBuddyByName(buddyName);

		if (buddy == null)
			errors.push("Can't block buddy that is not in your list: " + buddyName);

		else if (buddy.isBlocked() == blocked)
			errors.push("BuddyBlock flag is already in the requested state: " + blocked + ", for buddy: " + buddy);

		if (errors.length > 0)
			throw new SFSValidationException("BlockBuddy request error", errors);
	}

	/**
	 * @internal
	 */
	public function execute(sfs:ISmartFox):Void
	{
		sfso.putString(BlockBuddyRequest.KEY_BUDDY_NAME, buddyName);
		sfso.putBool(BlockBuddyRequest.KEY_BUDDY_BLOCK_STATE, blocked);
	}

}
