package sfs3.client.requests.buddylist;

import sfs3.client.entities.data.ISFSObject;

import sfs3.client.entities.Buddy;
import sfs3.client.requests.GenericMessageRequest;
import sfs3.client.requests.GenericMessageType;

/**
 * Sends a message to a buddy in the current user's buddies list.
 * <p>
 * <p>Messages sent to buddies using the <em>BuddyMessageRequest</em> request are similar to the standard private messages (see the <em>PrivateMessageRequest</em> request)
 * but are specifically designed for the Buddy List system: they don't require any Room parameter, nor they require that users joined a Room.
 * Additionally, buddy messages are subject to specific validation, such as making sure that the recipient is in the sender's buddies list and the sender is not blocked by the recipient.</p>
 * 
 * <p>If the operation is successful, a <em>buddyMessage</em> event is dispatched in both the sender and recipient clients.</p>
 * <p><b>NOTE</b>: this request can be sent if the Buddy List system was previously initialized only (see the <em>InitBuddyListRequest</em> request description).</p>
 * 
 *
 * @see		sfs3.client.core.SFSBuddyEvent#BUDDY_MESSAGE
 * @see		InitBuddyListRequest
 */
@:expose("SFS3.BuddyMessageRequest")
class BuddyMessageRequest extends GenericMessageRequest 
{
	/**
	 * Creates a new <em>BuddyMessageRequest</em> instance.
	 * The instance must be passed to the <em>SmartFox.send()</em> method for the request to be performed.
	 *
	 * @param	message		The message to be sent to a buddy.
	 * @param	targetBuddy	The <em>Buddy</em> object corresponding to the message recipient.
	 * @param	params		An instance of <em>SFSObject</em> containing additional custom parameters (e.g. the message color, an emoticon id, etc).
	 * 
	 * @see		sfs3.client.SmartFox#send
	 * @see		sfs3.client.entities.data.SFSObject
	 */
	public function new(message:String, targetBuddy:Buddy, ?params:ISFSObject = null) 
	{
		super();
		type = GenericMessageType.BUDDY_MSG;
		this.message = message;
		recipient = targetBuddy != null ? targetBuddy.getId() : -1;
		this.params = params;
	}
}
