package sfs3.client.requests;

import sfs3.client.entities.data.ISFSObject;
import haxe.Exception;

import sfs3.client.ISmartFox;
import sfs3.client.exceptions.SFSValidationException;
import sfs3.client.entities.Room;
import sfs3.client.entities.User;
import sfs3.client.entities.data.Set;
import sfs3.client.core.LoggerFactory;
import sfs3.client.core.Logger;

@:expose("SFS3.GenericMessageRequest")
class GenericMessageRequest extends BaseRequest
{
	/**
	 * <b>*Private*</b>
	 */
	public static final KEY_ROOM_ID:String = "r";         // The room id

	/**
	 * <b>*Private*</b>
	 */
	public static final KEY_USER_ID:String = "u";          // The sender

	/**
	 * <b>*Private*</b>
	 */
	public static final KEY_MESSAGE:String = "m";         // The actual message

	/**
	 * <b>*Private*</b>
	 */
	public static final KEY_MESSAGE_TYPE:String = "t";    // The message type

	/**
	 * <b>*Private*</b>
	 */
	public static final KEY_RECIPIENT:String = "rc";      // The recipient (for sendObject and sendPrivateMessage)

	/**
	 * <b>*Private*</b>
	 */
	public static final KEY_RECIPIENT_MODE:String = "rm"; // For admin/mod messages, indicate toUser, toRoom, toGroup, toZone

	/**
	 * <b>*Private*</b>
	 */
	public static final KEY_XTRA_PARAMS:String = "p";     // Extra custom parameters (mandatory for sendObject)

	/**
	 * <b>*Private*</b>
	 */
	public static final KEY_SENDER_DATA:String = "sd";    // The sender User data (when cross room message)

	/**
	 * <b>*Private*</b>
	 */
	private var type:Int = -1;

	/**
	 * <b>*Private*</b>
	 */
	private var room:Room;

	/**
	 * <b>*Private*</b>
	 */
	private var user:User;

	/**
	 * <b>*Private*</b>
	 */
	private var message:String;

	/**
	 * <b>*Private*</b>
	 */
	private var params:ISFSObject;

	/**
	 * <b>*Private*</b>
	 */
	private var recipient:Dynamic;

	/**
	 * <b>*Private*</b>
	 */
	private var sendMode:Int = -1;

	/**
	 * <b>*Private*</b>
	 */
	private var log:Logger;

	public function new()
	{
		super(BaseRequest.GenericMessage);
		log = LoggerFactory.getLogger(Type.getClass(this));
	}

	/*
	 * NOTE:
	 * Validation is performed by the specific Message class, e.g. PublicMessageRequest, PrivateMessageRequest, SendObjectRequest
	 */

	/**
	 * <b>*Private*</b>
	 */
	public function validate(sfs:ISmartFox):Void
	{
		// Check for a valid type
		if (type < 0)
			throw new SFSValidationException("PublicMessage request error", ["Unsupported message type: " + type]);

		var errors = new Array<String>();

		switch (type)
		{
			case GenericMessageType.PUBLIC_MSG:
				validatePublicMessage(sfs, errors);

			case GenericMessageType.PRIVATE_MSG:
				validatePrivateMessage(sfs, errors);

			case GenericMessageType.OBJECT_MSG:
				validateObjectMessage(sfs, errors);

			case GenericMessageType.BUDDY_MSG:
				validateBuddyMessage(sfs, errors);

			case GenericMessageType.MODERATOR_MSG | GenericMessageType.ADMIN_MSG:
				validateSuperUserMessage(sfs, errors);

			default:
				throw new Exception("Invalid message type: " + type);
		}

		if (errors.length > 0)
			throw new SFSValidationException("Request error - ", errors);
	}

	/**
	 * <b>*Private*</b>
	 */
	public function execute(sfs:ISmartFox):Void
	{
		// Set the message type
		sfso.putByte(KEY_MESSAGE_TYPE, type);

		switch (type)
		{
			case GenericMessageType.PUBLIC_MSG:
				executePublicMessage(sfs);

			case GenericMessageType.PRIVATE_MSG:
				executePrivateMessage(sfs);

			case GenericMessageType.OBJECT_MSG:
				executeObjectMessage(sfs);

			case GenericMessageType.BUDDY_MSG:
				executeBuddyMessage(sfs);

			case GenericMessageType.MODERATOR_MSG | GenericMessageType.ADMIN_MSG:
				executeSuperUserMessage(sfs);

		}
	}

	//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	// Specialized validators
	//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	private function validatePublicMessage(sfs:ISmartFox, errors:Array<String>):Void
	{
		if (message == null || message.length == 0)
			errors.push("Public message is empty!");

		if (room == null)
		{
			if (sfs.getLastJoinedRoom() != null)
				room = sfs.getLastJoinedRoom();
			else
			{
				errors.push("A valid Room must be provided");
				return;
			}
		}

		if (!sfs.getJoinedRooms().contains(room))
			errors.push("You are not joined in the target Room: " + room.getName());
	}

	private function validatePrivateMessage(sfs:ISmartFox, errors:Array<String>):Void
	{
		if (message == null || message.length == 0)
			errors.push("Private message is empty!");

		if (Std.isOfType(recipient, Int) && cast(recipient, Int) < 0)
			errors.push("Invalid recipient id: " + recipient);
	}

	private function validateObjectMessage(sfs:ISmartFox, errors:Array<String>):Void
	{
		if (params == null) {
			errors.push("Object message is null!");
			return;
		}

		// No room passed, let's use the last joined one (if it exists)
		if (room == null)
		{
			if (sfs.getLastJoinedRoom() != null)
				room = sfs.getLastJoinedRoom();
			else
			{
				errors.push("A valid Room must be provided");
				return;
			}
		}

		if (!sfs.getJoinedRooms().contains(room))
			errors.push("The provided Room is not currently joined: " + room.getName());
	}

	private function validateBuddyMessage(sfs:ISmartFox, errors:Array<String>):Void
	{
		if (!sfs.getBuddyManager().isInited())
			errors.push("BuddyList is not inited. Please send an InitBuddyRequest first");

		if (sfs.getBuddyManager().getMyOnlineState() == false)
			errors.push("Can't send messages while offline");

		if (message == null || message.length == 0)
			errors.push("Buddy message is empty!");

		if (Std.isOfType(recipient, Int)) {
			var recipientId:Int = cast recipient;
			if (recipientId < 0)
				errors.push("Recipient is not online or not in your buddy list");
		}
	}

	private function validateSuperUserMessage(sfs:ISmartFox, errors:Array<String>):Void
	{
		if (message == null || message.length == 0)
		{
			errors.push("Moderator message is empty!");
			return;
		}

		if (!(sfs.getMySelf().isModerator() || sfs.getMySelf().isAdmin()))
		{
			errors.push("Not enough privileges to send a Mod/Admin message");
			return;
		}

		switch (sendMode)
		{
			case MessageRecipientMode.TO_USER:
				if (!Std.isOfType(recipient, User))
					errors.push("TO_USER expects a User object as recipient");

			case MessageRecipientMode.TO_ROOM:
				if (!Std.isOfType(recipient, Room))
					errors.push("TO_ROOM expects a Room object as recipient");

			case MessageRecipientMode.TO_GROUP:
				if (!Std.isOfType(recipient, String))
					errors.push("TO_GROUP expects a String as recipient (the groupId)");

			default:
				errors.push("MessageRicipientMode not supported: " + sendMode);
		}
	}

	//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	// Specialized executors
	//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	private function executePublicMessage(sfs:ISmartFox):Void
	{
		// No room was passed, let's use the last joined one
		if (room == null)
			room = sfs.getLastJoinedRoom();

		// If it doesn't exist we have a problem
		if (room == null)
			throw new Exception("User should be joined in a Room in order to send a public message");

		sfso.putInt(KEY_ROOM_ID, room.getId());
		sfso.putString(KEY_MESSAGE, message);

		if (params != null)
			sfso.putSFSObject(KEY_XTRA_PARAMS, params);
	}

	private function executePrivateMessage(sfs:ISmartFox):Void
	{
		sfso.putInt(KEY_RECIPIENT, cast recipient);
		sfso.putString(KEY_MESSAGE, message);

		if (params != null)
			sfso.putSFSObject(KEY_XTRA_PARAMS, params);
	}

	private function executeBuddyMessage(sfs:ISmartFox):Void
	{
		// Id of the recipient buddy
		sfso.putInt(KEY_RECIPIENT, cast recipient);

		// Message
		sfso.putString(KEY_MESSAGE, message);

		// Params
		if (params != null)
			sfso.putSFSObject(KEY_XTRA_PARAMS, params);

	}

	private function executeSuperUserMessage(sfs:ISmartFox):Void
	{
		sfso.putString(KEY_MESSAGE, message);

		if (params != null)
			sfso.putSFSObject(KEY_XTRA_PARAMS, params);

		sfso.putInt(KEY_RECIPIENT_MODE, sendMode);

		switch (sendMode)
		{
			// Put the User.id as Int
			case MessageRecipientMode.TO_USER:
				sfso.putInt(KEY_RECIPIENT, (cast recipient:User).getId());

			// Put the Room.id as Int
			case MessageRecipientMode.TO_ROOM:
				sfso.putInt(KEY_RECIPIENT, (cast recipient:Room).getId());

			// Put the Room Group as String
			case MessageRecipientMode.TO_GROUP:
				sfso.putString(KEY_RECIPIENT, cast recipient);

			// the TO_ZONE case does not need to pass any other params
		}
	}

	private function executeObjectMessage(sfs:ISmartFox):Void
	{
		// Recipient list with no duplicates
		var uniqueRecipients = new Set<Int>();

		if (Std.isOfType(recipient, Array))
		{
			var potentialRecipients:Array<Dynamic> = cast recipient;

			// Filter out potential wrong elements
			for (item in potentialRecipients)
			{
				// Skip anything that is not a user
				if (Std.isOfType(item, User))
				{
					var usr:User = cast item;

					// Provided target users must be joined in the target Room
					if (room.containsUser(usr))
					{
						var id = usr.getId();
						uniqueRecipients.push(id);
					}
					else
						log.warn("Target User: " + usr.getName() + " does not belong in Room: " + room.getName());
				}
			}
		}

		sfso.putInt(KEY_ROOM_ID, room.getId());
		sfso.putSFSObject(KEY_XTRA_PARAMS, params);

		// Optional user list
		if (uniqueRecipients.length > 0)
			sfso.putIntArray(KEY_RECIPIENT, uniqueRecipients);
	}
}
