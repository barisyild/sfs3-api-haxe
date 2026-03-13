package com.smartfoxserver.v3.requests.game;

import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.entities.data.ISFSArray;

import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.exceptions.SFSValidationException;
import com.smartfoxserver.v3.entities.Buddy;
import com.smartfoxserver.v3.entities.User;
import com.smartfoxserver.v3.requests.BaseRequest;
import com.smartfoxserver.v3.requests.CreateRoomRequest;
import com.smartfoxserver.v3.requests.invitation.InviteUsersRequest;


/**
 * Creates a new public or private game, including player matching criteria, invitations settings and more.
 * <p/>
 * <p>A game is created through the instantiation of a <em>SFSGame</em> on the server-side,
 * a specialized Room type that provides advanced features during the creation phase of a game.
 * Specific game-configuration settings are passed by means of the <em>SFSGameSettings</em> class.</p>
 * <p/>
 * <p>If the creation is successful, a <em>roomAdd</em> event is dispatched to all the users who subscribed the Group to which the Room is associated, including the game creator.
 * Otherwise, a <em>roomCreationError</em> event is returned to the creator's client.</p>
 * <p/>
 * <p>Also, if the settings passed in the <em>SFSGameSettings</em> object cause invitations to join the game to be sent, an <em>invitation</em> event is
 * dispatched to all the recipient clients.</p>
 * <p/>
 * <p>Check the SmartFoxServer 3 documentation for a more in-depth overview of the GAME API.</p>
 * <p/>
 * <p/>
 *
 * @see		SFSGameSettings
 * @see		com.smartfoxserver.v3.core.SFSEvent#ROOM_ADD
 * @see		com.smartfoxserver.v3.core.SFSEvent#ROOM_CREATION_ERROR
 * @see		com.smartfoxserver.v3.core.SFSEvent#INVITATION
 */

class CreateSFSGameRequest extends BaseRequest 
{
	/**
	 * @internal
	 */
	public static final KEY_IS_PUBLIC:String = "gip";

	/**
	 * @internal
	 */
	public static final KEY_MIN_PLAYERS:String = "gmp";

	/**
	 * @internal
	 */
	public static final KEY_INVITED_PLAYERS:String = "ginp";

	/**
	 * @internal
	 */
	public static final KEY_SEARCHABLE_ROOMS:String = "gsr";

	/**
	 * @internal
	 */
	public static final KEY_PLAYER_MATCH_EXP:String = "gpme";

	/**
	 * @internal
	 */
	public static final KEY_SPECTATOR_MATCH_EXP:String = "gsme";

	/**
	 * @internal
	 */
	public static final KEY_INVITATION_EXPIRY:String = "gie";

	/**
	 * @internal
	 */
	public static final KEY_LEAVE_ROOM:String = "glr";

	/**
	 * @internal
	 */
	public static final KEY_NOTIFY_GAME_STARTED:String = "gns";

	/**
	 * @internal
	 */
	public static final KEY_INVITATION_PARAMS:String = "ip";

	private var createRoomRequest:CreateRoomRequest;
	private var settings:SFSGameSettings;

	/**
	 * Creates a new <em>CreateSFSGameRequest</em> instance.
	 * The instance must be passed to the <em>SmartFox.send()</em> method for the request to be performed.
	 *
	 * @param	settings	An object containing the SFSGame configuration settings.
	 * 
	 * @see		com.smartfoxserver.v3.SmartFox#send
	 * @see		SFSGameSettings
	 */
	public function new(settings:SFSGameSettings) 
	{
		super(BaseRequest.CreateSFSGame);
		this.settings = settings;
		createRoomRequest = new CreateRoomRequest(settings, false, null);
	}

	/**
	 * @internal
	 */
	public function validate(sfs:ISmartFox):Void
	{
		var errors = new Array<String>();

		// Execute the parent Request and grab the populated SFSObject
		try 
		{
			createRoomRequest.validate(sfs);
		}
		
		catch (err:SFSValidationException) 
		{
			// Take the current errors and continue checking...
			for (e in err.getErrors()) {
                errors.push(e);
            }
		}

		if (settings.getMinPlayersToStartGame() > settings.getMaxUsers()) 
			errors.push("minPlayersToStartGame cannot be greater than maxUsers");

		if (settings.getInvitationExpiryTime() < InviteUsersRequest.MIN_EXPIRY_TIME || settings.getInvitationExpiryTime() > InviteUsersRequest.MAX_EXPIRY_TIME) 
			errors.push("Expiry time value is out of range (" + InviteUsersRequest.MIN_EXPIRY_TIME + "-" + InviteUsersRequest.MAX_EXPIRY_TIME + ")");

		if (settings.getInvitedPlayers() != null && settings.getInvitedPlayers().length > InviteUsersRequest.MAX_INVITATIONS_FROM_CLIENT_SIDE) 
			errors.push("Cannot invite more than " + InviteUsersRequest.MAX_INVITATIONS_FROM_CLIENT_SIDE + " players from client side");

		if (errors.length > 0) 
			throw new SFSValidationException("CreateSFSGameRoom request error", errors);
	}

	/**
	 * @internal
	 */
	public function execute(sfs:ISmartFox):Void
	{
		// Execute the parent Request and grab the populated SFSObject
		createRoomRequest.execute(sfs);
		sfso = cast createRoomRequest.getRequest().getContent();

		// Proceed populating the other fields in the child class
		sfso.putBool(KEY_IS_PUBLIC, settings.isPublic());
		sfso.putShort(KEY_MIN_PLAYERS, settings.getMinPlayersToStartGame());
		sfso.putShort(KEY_INVITATION_EXPIRY, settings.getInvitationExpiryTime());
		sfso.putBool(KEY_LEAVE_ROOM, settings.getLeaveLastJoinedRoom());
		sfso.putBool(KEY_NOTIFY_GAME_STARTED, settings.getNotifyGameStarted());

		if (settings.getPlayerMatchExpression() != null) 
			sfso.putSFSArray(KEY_PLAYER_MATCH_EXP, settings.getPlayerMatchExpression().toSFSArray());
		
		if (settings.getSpectatorMatchExpression() != null) 
			sfso.putSFSArray(KEY_SPECTATOR_MATCH_EXP, settings.getSpectatorMatchExpression().toSFSArray());

		// Invited players
		var invitedPlayers:Array<Dynamic> = settings.getInvitedPlayers();
		if (invitedPlayers != null) 
		{
			var playerIds = new Array<Int>();

			for (player in invitedPlayers) 
			{
				if (Std.isOfType(player, User)) 
					playerIds.push(cast(player, User).getId());
				
				else if (Std.isOfType(player, Buddy)) 
					playerIds.push(cast(player, Buddy).getId());
			}
			
			sfso.putIntArray(KEY_INVITED_PLAYERS, playerIds);
		}

		// Searchable rooms
		var searchableRooms:Array<String> = settings.getSearchableRooms();
		if (searchableRooms != null) 
			sfso.putStringArray(KEY_SEARCHABLE_ROOMS, searchableRooms);

		// Invitation params
		if (settings.getInvitationParams() != null) 
			sfso.putSFSObject(KEY_INVITATION_PARAMS, settings.getInvitationParams());
		
	}
}
