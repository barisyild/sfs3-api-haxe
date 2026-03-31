package sfs3.client.requests;

import sfs3.client.entities.data.ISFSObject;

import sfs3.client.entities.Room;

/**
 * Sends a public chat message.
 * <p/>
 * <p>A public message is dispatched to all the users in the specified Room, including the message sender (this allows showing
 * messages in the correct order in the application interface); the corresponding event is the <em>publicMessage</em> event.
 * It is also possible to send an optional object together with the message: it can contain custom parameters useful to transmit, for example, additional
 * informations related to the message, like the text font or color, or other formatting details.</p>
 * <p/>
 * <p>In case the target Room is not specified, the message is sent in the last Room joined by the sender.</p>
 * <p/>
 * <p><b>NOTE</b>: the <em>publicMessage</em> event is dispatched if the Room is configured to allow public messaging only (see the <em>RoomSettings.permissions</em> parameter).</p>
 * <p/>
 * <p/>
 *
 * @see		sfs3.client.core.SFSEvent#PUBLIC_MESSAGE
 * @see		sfs3.client.requests.RoomSettings#getPermissions()
 */
@:expose("SFS3.PublicMessageRequest")
class PublicMessageRequest extends GenericMessageRequest 
{

	/**
	 * Creates a new <em>PublicMessageRequest</em> instance.
	 * The instance must be passed to the <em>SmartFox.send()</em> method for the request to be performed.
	 *
	 * @param	message		The message to be sent to all the users in the target Room.
	 * @param	params		An instance of <em>ISFSObject</em> containing additional custom parameters to be sent to the message recipients (for example the color of the text, etc).
	 * @param	targetRoom	The <em>Room</em> object corresponding to the Room where the message should be dispatched; if <code>null</code>, the last Room joined by the user is used.
	 * 
	 * @see		sfs3.client.SmartFox#send
	 * @see		sfs3.client.entities.data.SFSObject
	 */
	public function new(message:String, ?params:ISFSObject = null, ?targetRoom:Room = null) 
	{
		super();
		type = GenericMessageType.PUBLIC_MSG;
		this.message = message;
		room = targetRoom;
		this.params = params;
	}
}
