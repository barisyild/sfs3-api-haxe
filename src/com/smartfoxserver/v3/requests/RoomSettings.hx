package com.smartfoxserver.v3.requests;

import com.smartfoxserver.v3.entities.SFSRoom;
import com.smartfoxserver.v3.entities.variables.RoomVariable;

/**
 * The <em>RoomSettings</em> class is a container for the settings required to
 * create a Room using the <em>CreateRoomRequest</em> request.
 *
 * @see CreateRoomRequest
 * @see com.smartfoxserver.v3.entities.Room
 */
class RoomSettings
{
	private var name:String;
	private var password:String;
	private var groupId:String;
	private var _isGame:Bool;
	private var maxUsers:Int;
	private var maxSpectators:Int;
	private var maxVariables:Int;
	private var variables:Array<RoomVariable>;
	private var permissions:RoomPermissions;
	private var events:RoomEvents;
	private var extension:RoomExtension;
	private var allowOwnerInvitation:Bool;

	/**
	 * Creates a new <em>RoomSettings</em> instance. The instance must be passed to
	 * the <em>CreateRoomRequest</em> class constructor.
	 *
	 * @param name The name of the Room to be created.
	 * 
	 * @see CreateRoomRequest
	 */
	public function new(name:String)
	{
		// Default settings

		this.name = name;
		password = "";
		_isGame = false;
		maxUsers = 10;
		maxSpectators = 0;
		maxVariables = 5;
		groupId = SFSRoom.DEFAULT_GROUP_ID;
		variables = new Array<RoomVariable>();
		allowOwnerInvitation = true;
	}

	/**
	 * Defines the name of the Room.
	 */
	public function getName():String
	{
		return name;
	}

	/**
	 * @see #getName()
	 */
	public function setName(name:String):Void
	{
		this.name = name;
	}

	/**
	 * Defines the password of the Room. If the password is set to an empty string,
	 * the Room won't be password protected.
	 * <p/>
	 * <p>
	 * The default value is an empty string.
	 * </p>
	 */
	public function getPassword():String
	{
		return password;
	}

	/**
	 * @see #getPassword()
	 */
	public function setPassword(password:String):Void
	{
		this.password = password;
	}

	/**
	 * Indicates whether the Room is a Game Room or not.
	 * <p/>
	 * The default value is <code>false</code>
	 */
	public function isGame():Bool
	{
		return _isGame;
	}

	/**
	 * @see #isGame
	 */
	public function setGame(game:Bool):RoomSettings
	{
		_isGame = game;
		return this;
	}

	/**
	 * Defines the maximum number of users allowed in the Room. In case of Game
	 * Rooms, this is the maximum number of players.
	 * <p/>
	 * The default value is <code>10</code>
	 *
	 * @see #getMaxSpectators()
	 */
	public function getMaxUsers():Int
	{
		return maxUsers;
	}

	/**
	 * @see #getMaxUsers()
	 */
	public function setMaxUsers(maxUsers:Int):RoomSettings
	{
		this.maxUsers = maxUsers;
		return this;
	}

	/**
	 * Defines the maximum number of Room Variables allowed for the Room.
	 * <p/>
	 * The default value is <code>5</code>
	 */
	public function getMaxVariables():Int
	{
		return maxVariables;
	}

	/**
	 * @see #getMaxVariables()
	 */
	public function setMaxVariables(maxVariables:Int):RoomSettings
	{
		this.maxVariables = maxVariables;
		return this;
	}

	/**
	 * Defines the maximum number of spectators allowed in the Room (only for Game
	 * Rooms).
	 * <p/>
	 * The default value is <code>0</code>
	 *
	 * @see #getMaxUsers()
	 */
	public function getMaxSpectators():Int
	{
		return maxSpectators;
	}

	/**
	 * @see #getMaxSpectators()
	 */
	public function setMaxSpectators(maxSpectators:Int):RoomSettings
	{
		this.maxSpectators = maxSpectators;
		return this;
	}

	/**
	 * Defines a list of <em>RooomVariable</em> objects to be attached to the Room.
	 * <p/>
	 * The default value is <code>null</code>
	 *
	 * @see com.smartfoxserver.v3.entities.variables.RoomVariable RoomVariable
	 */
	public function getVariables():Array<RoomVariable>
	{
		return variables;
	}

	/**
	 * @see #getVariables()
	 */
	public function setVariables(variables:Array<RoomVariable>):RoomSettings
	{
		this.variables = variables.copy();
		return this;
	}

	/**
	 * Defines the flags indicating which operations are permitted on the Room.
	 * <p/>
	 * <p>
	 * Permissions include: name and password change, maximum users change and
	 * public messaging. If set to <code>null</code>, the permissions configured on
	 * the server-side are used (see the SmartFoxServer 3 Administration Tool
	 * documentation).
	 * </p>
	 * <p/>
	 * The default value is <code>null</code>
	 */
	public function getPermissions():RoomPermissions
	{
		return permissions;
	}

	/**
	 * @see #getPermissions()
	 */
	public function setPermissions(permissions:RoomPermissions):RoomSettings
	{
		this.permissions = permissions;
		return this;
	}

	/**
	 * Defines the flags indicating which events related to the Room are dispatched
	 * by the <em>SmartFox</em> client.
	 * <p/>
	 * <p>
	 * Room events include: users entering or leaving the room, user count change
	 * and user variables update. If set to <code>null</code>, the events configured
	 * on the server-side are used (see the SmartFoxServer 3 Administration Tool
	 * documentation).
	 * </p>
	 * <p/>
	 * The default value is <code>null</code>
	 */
	public function getEvents():RoomEvents
	{
		return events;
	}

	/**
	 * @see #getEvents()
	 */
	public function setEvents(events:RoomEvents):RoomSettings
	{
		this.events = events;
		return this;
	}

	/**
	 * Defines the Extension that must be attached to the Room on the server-side,
	 * and its settings.
	 */
	public function getExtension():RoomExtension
	{
		return extension;
	}

	/**
	 * @see #getExtension()
	 */
	public function setExtension(extension:RoomExtension):RoomSettings
	{
		this.extension = extension;
		return this;
	}

	/**
	 * Defines the id of the Group to which the Room should belong. If the Group
	 * doesn't exist yet, a new one is created before assigning the Room to it.
	 * <p/>
	 * The default value is <code>default</code>
	 *
	 * @see com.smartfoxserver.v3.entities.Room#getGroupId()
	 */
	public function getGroupId():String
	{
		return groupId;
	}

	/**
	 * @see #getGroupId()
	 */
	public function setGroupId(groupId:String):RoomSettings
	{
		this.groupId = groupId;
		return this;
	}

	/**
	 * Specifies if the Room allows "Join Room" Invitations sent by any User or just
	 * by its owner
	 * <p>
	 * Default = true (only the creator is allowed to send invitations)
	 * 
	 * @see com.smartfoxserver.v3.requests.invitation.JoinRoomInvitationRequest
	 * @since 1.7.0
	 */
	public function allowOwnerOnlyInvitation():Bool
	{
		return allowOwnerInvitation;
	}

	/**
	 * Specifies if the Room allows "Join Room" Invitations sent by any User or just
	 * by its owner
	 * <p>
	 * Default = true (only the creator is allowed to send invitations)
	 * 
	 * @see com.smartfoxserver.v3.requests.invitation.JoinRoomInvitationRequest
	 * @since 1.7.0
	 */
	public function setAllowOwnerOnlyInvitation(value:Bool):RoomSettings
	{
		allowOwnerInvitation = value;
		return this;
	}
}
