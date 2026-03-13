package com.smartfoxserver.v3.requests;

import com.smartfoxserver.v3.entities.data.ISFSObject;

import com.smartfoxserver.v3.entities.Room;
import com.smartfoxserver.v3.entities.User;

/**
 * Sends an object containing custom data to all users in a Room, or a subset of them.
 * <p/>
 * <p>The data object is delivered to the selected users (or all users excluding the sender) inside the target Room by means of the <em>objectMessage</em> event.
 * It can be useful to send game data, like for example the target coordinates of the user's avatar in a virtual world.</p>
 * <p/>
 * <p/>
 *
 * @see		com.smartfoxserver.v3.core.SFSEvent#OBJECT_MESSAGE
 */
class ObjectMessageRequest extends GenericMessageRequest 
{
	/**
	 * Creates a new <em>ObjectMessageRequest</em> instance.
	 * The instance must be passed to the <em>SmartFox.send()</em> method for the request to be performed.
	 *
	 * @param	obj			An instance of <em>SFSObject</em> containing custom parameters to be sent to the message recipients.
	 * @param	targetRoom	The <em>Room</em> object corresponding to the Room where the message should be dispatched; if <code>null</code>, the last Room joined by the user is used.
	 * @param	recipients	A list of <em>User</em> objects corresponding to the message recipients; if <code>null</code>, the message is sent to all users in the target Room (except the sender itself).
	 * 
	 * @see		com.smartfoxserver.v3.SmartFox#send
	 * @see		com.smartfoxserver.v3.entities.data.SFSObject
	 * @see		com.smartfoxserver.v3.entities.User
	 */
	public function new(obj:ISFSObject, ?targetRoom:Room = null, ?recipients:Array<User> = null) 
	{
		super();
		type = GenericMessageType.OBJECT_MSG;
		params = obj;
		room = targetRoom;
		recipient = recipients;
	}

}
