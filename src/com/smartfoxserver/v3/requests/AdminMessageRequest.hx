package com.smartfoxserver.v3.requests;

import com.smartfoxserver.v3.entities.data.ISFSObject;

/**
 * Sends an administrator message to a specific user or a group of users.
 * <p/>
 * <p>
 * The current user must have administration privileges to be able to send the
 * message (see the <em>User.privilegeId</em> property).
 * </p>
 * <p/>
 * <p>
 * The <em>recipientMode</em> parameter in the class constructor is used to
 * determine the message recipients: a single user or all the users in a Room, a
 * Group or the entire Zone. Upon message delivery, the clients of the recipient
 * users dispatch the <em>adminMessage</em> event.
 * </p>
 * <p/>
 * <p/>
 *
 * @see com.smartfoxserver.v3.core.SFSEvent#ADMIN_MESSAGE
 * @see com.smartfoxserver.v3.entities.User#getPrivilegeId()
 * @see ModeratorMessageRequest
 */
@:expose("SFS3.AdminMessageRequest")
class AdminMessageRequest extends GenericMessageRequest
{

	/**
	 * Creates a new <em>AdminMessageRequest</em> instance. The instance must be
	 * passed to the <em>SmartFox.send()</em> method for the request to be
	 * performed.
	 *
	 * @param message       The message of the administrator to be sent to the
	 *                      target user/s defined by the <em>recipientMode</em>
	 *                      parameter.
	 * @param recipientMode An instance of <em>MessageRecipientMode</em> containing
	 *                      the target to which the message should be delivered.
	 * @param params        An instance of <em>ISFSObject</em> containing custom
	 *                      parameters to be sent to the recipient user/s.
	 * 
	 * @see com.smartfoxserver.v3.SmartFox#send
	 * @see com.smartfoxserver.v3.entities.data.SFSObject
	 */
	public function new(message:String, recipientMode:MessageRecipientMode, ?params:ISFSObject = null)
	{
		super();
		
		if (recipientMode == null)
			throw new haxe.Exception("RecipientMode cannot be null!");

		type = GenericMessageType.ADMIN_MSG;
		this.message = message;
		this.params = params;
		recipient = recipientMode.getTarget();
		sendMode = recipientMode.getMode();
	}
}
