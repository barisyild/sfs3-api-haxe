package sfs3.client.requests;

import sfs3.client.entities.data.ISFSObject;


/**
 * Sends a private chat message.
 * <p/>
 * <p>The private message is dispatched to a specific User, in any server Room, or even in no Room at all. The message is delivered by means of the <em>privateMessage</em> event.
 * It is also returned to the sender: this allows showing the messages in the correct order in the application interface.
 * It is also possible to send an optional object together with the message: it can contain custom parameters useful to transmit, for example, additional
 * data, like text font or color etc.</p>
 * <p/>
 * <p/>
 *
 * @see		sfs3.client.core.SFSEvent#PRIVATE_MESSAGE
 */
@:expose("SFS3.PrivateMessageRequest")
class PrivateMessageRequest extends GenericMessageRequest 
{

	/**
	 * Creates a new <em>PrivateMessageRequest</em> instance.
	 * The instance must be passed to the <em>SmartFox.send()</em> method for the request to be performed.
	 *
	 * @param	message		The message to be sent to to the recipient user.
	 * @param	recipientId	The id of the user to which the message is to be sent.
	 * @param	params		An instance of <em>SFSObject</em> containing additional custom parameters to be sent to the message recipient (for example the color of the text, etc).
	 * 
	 * @see		sfs3.client.SmartFox#send
	 * @see		sfs3.client.entities.data.SFSObject
	 */
	public function new(message:String, recipientId:Int, ?params:ISFSObject = null) 
	{
		super();
		type = GenericMessageType.PRIVATE_MSG;
		this.message = message;
		recipient = recipientId;
		this.params = params;
	}
}
