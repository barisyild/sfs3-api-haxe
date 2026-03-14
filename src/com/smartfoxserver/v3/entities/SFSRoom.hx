package com.smartfoxserver.v3.entities;
                
import com.smartfoxserver.v3.entities.data.ISFSArray;
import com.smartfoxserver.v3.entities.data.Vec3D;
import com.smartfoxserver.v3.entities.managers.IRoomManager;
import com.smartfoxserver.v3.entities.managers.IUserManager;
import com.smartfoxserver.v3.entities.managers.SFSUserManager;
import com.smartfoxserver.v3.entities.variables.RoomVariable;
import com.smartfoxserver.v3.entities.variables.SFSRoomVariable;
import hx.concurrent.collection.SynchronizedMap;

/**
 * The <em>SFSRoom</em> object represents a SmartFoxServer Room on the
 * client.
 * <p/>
 * <p>
 * The SmartFoxServer 3 client API doesn't know all of the Rooms existing
 * on the server side, but only those that are joined by the user and those
 * in the Room Groups that have been subscribed. 
 * <p>
 * Subscribing to one or more Groups allows to listen to Room events for all Rooms belonging to that Group.
 * </p>
 * <p/>
 * <p>
 * A list of available Rooms is created after a successful login and it is
 * kept updated by the server.
 * </p>
 *
 * @see com.smartfoxserver.v3.requests.CreateRoomRequest
 * @see com.smartfoxserver.v3.requests.JoinRoomRequest
 * @see com.smartfoxserver.v3.requests.SubscribeRoomGroupRequest
 * @see com.smartfoxserver.v3.requests.UnsubscribeRoomGroupRequest
 * @see com.smartfoxserver.v3.requests.ChangeRoomNameRequest
 * @see com.smartfoxserver.v3.requests.ChangeRoomPasswordStateRequest
 * @see com.smartfoxserver.v3.requests.ChangeRoomCapacityRequest
 */
@:expose("SFS3.SFSRoom")
class SFSRoom implements Room
{
	public static final DEFAULT_GROUP_ID:String = "default";
	
	private var id:Int;
	private var name:String;
	private var groupId:String;
	private var _isGame:Bool;
	private var _isHidden:Bool;
	private var _isJoined:Bool;
	private var _isPasswordProtected:Bool;
	private var _isManaged:Bool;
	private var _isAudioStreamingAllowed:Bool;
	
	private var variables:SynchronizedMap<String, RoomVariable>;
	private var userManager:IUserManager;
	private var _maxUsers:Int;
	private var _maxSpectators:Int;
	private var _userCount:Int; // only for non joined rooms
	private var specCount:Int; // only for non joined rooms
	private var roomManager:IRoomManager;

	/**
	 * @internal
	 */
	public static function fromSFSArray(sfsa:ISFSArray):Room
	{
		// An MMO Room contains more than 12 properties
		var isMMORoom = sfsa.size() > 12;
		var newRoom:Room = null;

		if (isMMORoom)
			newRoom = new MMORoom(sfsa.getInt(0), sfsa.getShortString(1), sfsa.getShortString(2));
		else
			newRoom = new SFSRoom(sfsa.getInt(0), sfsa.getShortString(1), sfsa.getShortString(2));

		newRoom.setGame(sfsa.getBool(3));
		newRoom.setHidden(sfsa.getBool(4));
		newRoom.setPasswordProtected(sfsa.getBool(5));
		newRoom.setUserCount(sfsa.getShort(6));
		newRoom.setMaxUsers(sfsa.getShort(7));

		// Room vars
		var varsList:ISFSArray = sfsa.getSFSArray(8);
		if (varsList.size() > 0)
		{
			var vars = new Array<RoomVariable>();

			for (j in 0...varsList.size())
			{
				vars.push(SFSRoomVariable.fromSFSArray(varsList.getSFSArray(j)));
			}

			newRoom.setVariables(vars);
		}
		
		newRoom.setAudioStreamingAllowed(sfsa.getBool(9));

		if (newRoom.isGame())
		{
			newRoom.setSpectatorCount(sfsa.getShort(10));
			newRoom.setMaxSpectators(sfsa.getShort(11));
		}

		// Configure MMORoom
		if (isMMORoom)
		{
			var mmoRoom:MMORoom = cast newRoom;
			mmoRoom.setDefaultAOI(Vec3D.fromArray(sfsa.get(12)));

			// Check if map limits are non null
			if (!sfsa.isNull(13))
			{
				mmoRoom.setLowerMapLimit(Vec3D.fromArray(sfsa.get(13)));
				mmoRoom.setHigherMapLimit(Vec3D.fromArray(sfsa.get(14)));
			}
		}

		return newRoom;
	}

	/**
	 * <p>
	 * <b>NOTE</b>: never instantiate a <em>SFSRoom</em> manually: this
	 * is done by the SmartFoxServer 3 API internally.
	 */
	public function new(id:Int, name:String, ?groupId:String = "default")
	{
		this.id = id;
		this.name = name;
		this.groupId = groupId;

		// default flags
		_isJoined = _isGame = _isHidden = false;
		_isManaged = true;
		_isAudioStreamingAllowed = false;

		// counters
		_userCount = specCount = 0;

		variables = SynchronizedMap.newStringMap();
		userManager = new SFSUserManager(null);
	}

	public function getId():Int
	{
		return id;
	}

	public function getName():String
	{
		return name;
	}

	public function setName(name:String):Void
	{
		this.name = name;
	}

	public function getGroupId():String
	{
		return groupId;
	}

	public function isJoined():Bool
	{
		return _isJoined;
	}

	public function isGame():Bool
	{
		return _isGame;
	}

	public function isHidden():Bool
	{
		return _isHidden;
	}

	public function isPasswordProtected():Bool
	{
		return _isPasswordProtected;
	}

	public function setPasswordProtected(passwordProtected:Bool):Void
	{
		_isPasswordProtected = passwordProtected;
	}

	public function isManaged():Bool
	{
		return _isManaged;
	}
	
	public function isAudioStreamingAllowed():Bool
	{
		return _isAudioStreamingAllowed;
	}
	
	public function setAudioStreamingAllowed(value:Bool):Void
	{
		_isAudioStreamingAllowed = value;
	}

	public function getUserCount():Int
	{
		if (!_isJoined)
		{
			return _userCount;
		} else
		{
			// For game rooms, return only player count
			if (_isGame)
			{
				return getPlayerList().length;
			}
			// For regular rooms, return the full user count
			else
			{
				return userManager.getUserCount();
			}
		}
	}

	public function getMaxUsers():Int
	{
		return _maxUsers;
	}

	public function getSpectatorCount():Int
	{
		if (!_isGame)
		{
			return 0;
		}

		// Joined Room? Dynamically calculate spectators
		if (_isJoined)
		{
			return getSpectatorList().length;
		}
		// Not joined, use the static value sent by the server
		else
		{
			return specCount;
		}
	}

	public function getMaxSpectators():Int
	{
		return _maxSpectators;
	}

	public function getCapacity():Int
	{
		return _maxUsers + _maxSpectators;
	}

	public function setJoined(joined:Bool):Void
	{
		_isJoined = joined;
	}

	public function setGame(game:Bool):Void
	{
		_isGame = game;
	}

	public function setHidden(hidden:Bool):Void
	{
		_isHidden = hidden;
	}

	public function setManaged(managed:Bool):Void
	{
		_isManaged = managed;
	}

	public function setUserCount(userCount:Int):Void
	{
		this._userCount = userCount;
	}

	public function setMaxUsers(maxUsers:Int):Void
	{
		this._maxUsers = maxUsers;
	}

	public function setSpectatorCount(spectatorCount:Int):Void
	{
		specCount = spectatorCount;
	}

	public function setMaxSpectators(maxSpectators:Int):Void
	{
		this._maxSpectators = maxSpectators;
	}

	public function addUser(user:User):Void
	{
		userManager.addUser(user);
	}

	public function removeUser(user:User):Void
	{
		userManager.removeUser(user);
	}

	public function containsUser(user:User):Bool
	{
		return userManager.containsUser(user);
	}

	public function getUserByName(name:String):User
	{
		return userManager.getUserByName(name);
	}

	public function getUserById(id:Int):User
	{
		return userManager.getUserById(id);
	}
	
	public function getUserList():Array<User>
	{
		return userManager.getUserList();
	}

	public function getPlayerList():Array<User>
	{
		var playerList = new Array<User>();

		for (user in userManager.getUserList())
		{
			if (user.isPlayerInRoom(this))
			{
				playerList.push(user);
			}
		}

		return playerList;
	}

	public function getSpectatorList():Array<User>
	{
		var spectatorList = new Array<User>();

		for (user in userManager.getUserList())
		{
			if (user.isSpectatorInRoom(this))
			{
				spectatorList.push(user);
			}
		}

		return spectatorList;
	}

	public function getVariable(name:String):RoomVariable
	{
		return variables.exists(name) ? variables.get(name) : null;
	}

	public function getVariables():Array<RoomVariable>
	{
		var vars = new Array<RoomVariable>();
		for(v in variables) vars.push(v);
		return vars;
	}

	public function setVariable(roomVariable:RoomVariable):Void
	{
		/*
		 * Existing variables set to null will trigger the deletion of said variables
		 * on the server side. 
		 */
		if (roomVariable.isNull())
			variables.remove(roomVariable.getName());
		else
			variables.set(roomVariable.getName(), roomVariable);
	}

	public function setVariables(roomVariables:Array<RoomVariable>):Void
	{
		for (roomVar in roomVariables)
		{
			setVariable(roomVar);
		}
	}

	public function containsVariable(name:String):Bool
	{
		return variables.exists(name);
	}

	public function getRoomManager():IRoomManager
	{
		return roomManager;
	}

	public function setRoomManager(manager:IRoomManager):Void
	{
		if (roomManager != null)
			throw new haxe.Exception("Room manager already assigned. Room: " + this);

		roomManager = manager;
	}

	public function equals(that:Dynamic):Bool
	{
		if (Std.isOfType(that, Room))
			return this.id == cast(that, Room).getId();
		else 
			return false;
	}
	
	public function toString():String
	{
		return '[Room: $name, Id: $id, GroupId: $groupId]';
	}
}
