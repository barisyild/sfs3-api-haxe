package com.smartfoxserver.v3.requests.invitation;

import com.smartfoxserver.v3.entities.data.ISFSObject;

import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.exceptions.SFSValidationException;
import com.smartfoxserver.v3.entities.Room;
import com.smartfoxserver.v3.requests.BaseRequest;
import com.smartfoxserver.v3.requests.RoomSettings;

@:expose("SFS3.JoinRoomInvitationRequest")
class JoinRoomInvitationRequest extends BaseRequest
{
	private static final KEY_ROOM_ID:String = "r";
	private static final KEY_EXPIRY_SECONDS:String = "es";
	private static final KEY_INVITED_NAMES:String = "in";
	private static final KEY_AS_SPECT:String = "as";
	private static final KEY_OPTIONAL_PARAMS:String = "op";
	
	// ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
	
	private var targetRoom:Room;
	private var invitedUserNames:Array<String>;
	private var expirySeconds:Int;
	private var asSpectator:Bool;
	private var params:ISFSObject;
	
	/**
	 * Sends an invitation to other users/players to join a specific Room.
	 * 
	 * <p>Invited users receive the invitation as an <em>invitation</em> event dispatched to their clients: they can accept or refuse it
	 * by means of the <em>InvitationReplyRequest</em> request, which must be sent within the specified amount of time.</p>
	 * 
	 * <p>Depending on the Room's settings the invitation can be sent by the Room's owner only or by any other user.
	 * This behavior can be set via the RoomSettings.allowOwnerOnlyInvitation parameter.</p>
	 * 
	 * <p><b>NOTE:</b> spectators in a Game Room are not allowed to invite other users; only players are.</p>
	 * 
	 * <p>An invitation can also specify the amount of time given to each invitee to reply. Default is 30 seconds. A positive answer will attempt to join the user in the designated Room.
	 * For Game Rooms the <em>asSpectator</em> flag can be toggled to join the invitee as player or spectator (default = player).</p>
	 * 
	 * <p>There aren't any specific notifications sent back to the inviter after the invitee's response. Users that have accepted the invitation will join the Room while those 
	 * who didn't reply or turned down the invitation won't generate any event. In order to send specific messages (e.g. chat), just send a private message back to the inviter.</p>
	 * 
	 * <p>The following example invites two more users in the current game:</p>
	 * 
	 * @see		RoomSettings
	 * @since 	1.7.0
	 */
	public function new(targetRoom:Room, invitedUserNames:Array<String>, ?params:ISFSObject = null, ?expirySeconds:Int = 30, ?asSpectator:Bool = false)
	{
		super(BaseRequest.JoinRoomInvite);
		
		this.targetRoom = targetRoom;
		this.invitedUserNames = invitedUserNames;
		this.params = params;
		this.expirySeconds = expirySeconds;
		this.asSpectator = asSpectator;
	}
	
	public function validate(sfs:ISmartFox):Void
	{
		var errors = new Array<String>();

		if (targetRoom == null) 
			errors.push("Missing target room");
		
		else if (invitedUserNames == null || invitedUserNames.length == 0)
			errors.push("No invitees list provided");

		if (errors.length > 0) 
			throw new SFSValidationException("JoinRoomInvitation request error", errors);
	}

	public function execute(sfs:ISmartFox):Void
	{
		sfso.putInt(KEY_ROOM_ID, targetRoom.getId());
		sfso.putStringArray(KEY_INVITED_NAMES, invitedUserNames);
		if (params != null) {
		    sfso.putSFSObject(KEY_OPTIONAL_PARAMS, params);
        }
		sfso.putInt(KEY_EXPIRY_SECONDS, expirySeconds);
		sfso.putBool(KEY_AS_SPECT, asSpectator);
	}
}
