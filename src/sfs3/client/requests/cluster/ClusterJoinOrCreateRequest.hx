package sfs3.client.requests.cluster;

import sfs3.client.entities.data.ISFSObject;

import sfs3.client.ISmartFox;
import sfs3.client.exceptions.SFSValidationException;
import sfs3.client.entities.Buddy;
import sfs3.client.entities.User;
import sfs3.client.entities.match.MatchExpression;
import sfs3.client.requests.BaseRequest;
import sfs3.client.requests.CreateRoomRequest;
import sfs3.client.requests.RoomSettings;
import sfs3.client.requests.invitation.InviteUsersRequest;
import sfs3.client.requests.mmo.MMORoomSettings;

/**
 *  Creates a new <em>ClusterJoinOrCreateRequest</em> instance.
 *  <p>See constructors for all the details.</p>
 *  
 */
@:expose("SFS3.ClusterJoinOrCreateRequest")
class ClusterJoinOrCreateRequest extends BaseRequest 
{
	/**
	 * @internal
	 */
	public static final KEY_GROUP_LIST:String = "gl";

	/**
	 * @internal
	 */
	public static final KEY_ROOM_SETTINGS:String = "rs";

	/**
	 * @internal
	 */
	public static final KEY_MATCH_EXPRESSION:String = "me";
	
	// -----------------------------------------------------------------------
	// -----------------------------------------------------------------------
	
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
	public static final KEY_INVITATION_EXPIRY:String = "gie";

	/**
	 * @internal
	 */
	public static final KEY_NOTIFY_GAME_STARTED:String = "gns";

	/**
	 * @internal
	 */
	public static final KEY_INVITATION_PARAMS:String = "ip";
	
	// -----------------------------------------------------------------------
	// -----------------------------------------------------------------------
	
	private var matchExpression:MatchExpression;
	private var groupNames:Array<String>;
	private var settings:RoomSettings;
	private var createRoomRequest:CreateRoomRequest;
	
	/**
	 * Creates a new <em>ClusterJoinOrCreateRequest</em> instance.
	 * The instance must be passed to the <em>SmartFox.send()</em> method for the request to be performed.
	 * <p>
	 * The Lobby will search for a game Room that meets the desire criteria via the provided MatchExpression. If none is found it will proceed by creating
	 * a new Game Room, if the passes <em>settings</em> parameter is not null. 
	 * <p>
	 * You can also skip the search entirely and force the Lobby to create the Room on the next available Game Node, by passing a null MatchExpression or 
	 * by using the specialized constructor.
	 * 
	 * @param	matchExpression		A match expression to filter Rooms
	 * @param	groupNames			List of group names to further filter the search, if null all groups will be searched
	 * @param	settings			If no Rooms are found a new Room with the passed settings will be created and the User will auto-join it.
	 * 
	 * @see		sfs3.client.SmartFox#send
	 * @see		ClusterRoomSettings
	 * @see		sfs3.client.entities.User
	 * @see		sfs3.client.entities.data.SFSObject
	 */
	public function new(?matchExpression:MatchExpression = null, ?groupNames:Array<String> = null, ?settings:RoomSettings = null) 
	{
		super(BaseRequest.ClusterJoinOrCreate);  
		
		this.matchExpression = matchExpression;
		this.groupNames = groupNames;
		this.settings = settings;
		
		if (settings != null)
			createRoomRequest = new CreateRoomRequest(settings, false, null);
	}
	
	public function validate(sfs:ISmartFox):Void
	{
		var errors = new Array<String>();
		
		// Execute the parent Request and grab the populated SFSObject
		if (this.settings != null)
		{
			// Room Settings must be either ClusterRoom or MMORoom			
			var isClusterRoom:Bool = Std.isOfType(settings, ClusterRoomSettings);
			var isMMORoom:Bool = Std.isOfType(settings, MMORoomSettings);
			
			if (!isClusterRoom && !isMMORoom)
				errors.push("Unsupported RoomSetting type: " + Type.getClassName(Type.getClass(settings)) + ". Accepted types are: ClusterRoomSettings and MMORoomSettings");
			
			else
			{
				// Validate super class parameters
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
				
				// Validate implementation specific parameters
				if (isClusterRoom)
					validateClusterRoom(cast settings, errors);
			}
		}

		if (errors.length > 0) 
			throw new SFSValidationException("ClusterJoinOrCreateRequest request error", errors);
	}
	
	private function validateClusterRoom(settings:ClusterRoomSettings, errors:Array<String>):Void
	{
		if (settings.getMinPlayersToStartGame() > settings.getMaxUsers()) 
			errors.push("minPlayersToStartGame cannot be greater than maxUsers");

		if (settings.getInvitationExpiryTime() < InviteUsersRequest.MIN_EXPIRY_TIME || settings.getInvitationExpiryTime() > InviteUsersRequest.MAX_EXPIRY_TIME)
			errors.push("Expiry time value is out of range (" + InviteUsersRequest.MIN_EXPIRY_TIME + "-" + InviteUsersRequest.MAX_EXPIRY_TIME + ")");

		if (settings.getInvitedPlayers() != null && settings.getInvitedPlayers().length > InviteUsersRequest.MAX_INVITATIONS_FROM_CLIENT_SIDE) 
			errors.push("Cannot invite more than " + InviteUsersRequest.MAX_INVITATIONS_FROM_CLIENT_SIDE + " players from client side");
	}
	

	public function execute(sfs:ISmartFox):Void
	{
		if (matchExpression != null)
			sfso.putSFSArray(KEY_MATCH_EXPRESSION, matchExpression.toSFSArray());
		
		if (groupNames != null && groupNames.length > 0)
			sfso.putStringArray(KEY_GROUP_LIST, groupNames);
		
		if (settings != null)
		{
			// Execute the parent Request and obtain the populated SFSObject
			createRoomRequest.execute(sfs);
			var roomParams:ISFSObject = cast createRoomRequest.getRequest().getContent();
			
			// If we're creating a ClusterRoom, proceed with populating the other fields in the child class
			if (Std.isOfType(settings, ClusterRoomSettings))
			{
				var crSettings:ClusterRoomSettings = cast settings;
				
				roomParams.putBool(KEY_IS_PUBLIC, crSettings.isPublic());
				roomParams.putShort(KEY_MIN_PLAYERS, crSettings.getMinPlayersToStartGame());
				roomParams.putShort(KEY_INVITATION_EXPIRY, crSettings.getInvitationExpiryTime());
				roomParams.putBool(KEY_NOTIFY_GAME_STARTED, crSettings.getNotifyGameStarted());
				
				// Invited players
				var invitedPlayers:Array<Dynamic> = crSettings.getInvitedPlayers();
				
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

					roomParams.putIntArray(KEY_INVITED_PLAYERS, playerIds);
				}
				
				// Invitation params
				if (crSettings.getInvitationParams() != null) 
					roomParams.putSFSObject(KEY_INVITATION_PARAMS, crSettings.getInvitationParams());
			}
			
			sfso.putSFSObject(KEY_ROOM_SETTINGS, roomParams);
		}
	}
}
