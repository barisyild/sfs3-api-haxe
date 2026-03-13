package com.smartfoxserver.v3.entities;

import com.smartfoxserver.v3.entities.data.ISFSArray;
import com.smartfoxserver.v3.entities.managers.IUserManager;
import com.smartfoxserver.v3.entities.variables.SFSUserVariable;
import com.smartfoxserver.v3.entities.variables.UserVariable;
import com.smartfoxserver.v3.entities.data.Vec3D;
import hx.concurrent.collection.SynchronizedMap;

/**
 * The <em>SFSUser</em> object represents a client logged in SmartFoxServer.
 * <p/>
 * <p>
 * The SmartFoxServer 3 client API are not aware of all the clients (users) connected to the server, but only of those that are in the same Rooms joined by the current client; this reduces the traffic between the client and the server considerably. In order to interact with other users the client
 * should join other Rooms or use the Buddy List system to keep track of and interact with friends.
 * </p>
 *
 * @see com.smartfoxserver.v3.requests.JoinRoomRequest
 */
class SFSUser implements User
{
	private var id:Int = -1;
	private var privilegeId:Int = 0;
	private var name:String;
	private var _isItMe:Bool;
	private var variables:SynchronizedMap<String, UserVariable>;
	private var playerIdByRoomId:SynchronizedMap<Int, Int>;
	private var userManager:IUserManager;
	private var aoiEntryPoint:Vec3D<Any>;

	/**
	 * @internal
	 */
	public static function fromSFSArray(sfsa:ISFSArray, ?room:Room = null):User
	{
		// Pass id and name
		var newUser:User = new SFSUser(sfsa.getInt(0), sfsa.getShortString(1));

		// Set privileges
		newUser.setPrivilegeId(sfsa.getShort(2));

		// Set playerId
		if (room != null)
			newUser.setPlayerId(sfsa.getShort(3), room);

		// Populate variables
		var uVars:ISFSArray = sfsa.getSFSArray(4);
		for (i in 0...uVars.size())
		{
			newUser.setVariable(SFSUserVariable.fromSFSArray(uVars.getSFSArray(i)));
		}

		return newUser;
	}

	public function new(id:Int, name:String, ?isItMe:Bool = false)
	{
		this.id = id;
		this.name = name;
		this._isItMe = isItMe;
		variables = SynchronizedMap.newStringMap();
		playerIdByRoomId = SynchronizedMap.newIntMap();
	}

	public function getId():Int
	{
		return id;
	}

	public function getName():String
	{
		return name;
	}

	public function getPlayerId():Int
	{
		if(userManager != null && userManager.getSmartFox() != null && userManager.getSmartFox().getLastJoinedRoom() != null)
			return getPlayerIdByRoom(userManager.getSmartFox().getLastJoinedRoom());
		return 0;
	}

	public function isPlayer():Bool
	{
		return this.getPlayerId() > 0;
	}

	public function isSpectator():Bool
	{
		return !this.isPlayer();
	}

	public function getPlayerIdByRoom(room:Room):Int
	{
		var pId:Int = 0;
		var rid = room.getId();
		if (playerIdByRoomId.exists(rid))
			pId = playerIdByRoomId.get(rid);
		return pId;
	}

	public function setPlayerId(id:Int, room:Room):Void
	{
		playerIdByRoomId.set(room.getId(), id);
	}

	public function removePlayerId(room:Room):Void
	{
		playerIdByRoomId.remove(room.getId());
	}

	public function getPrivilegeId():Int
	{
		return privilegeId;
	}

	public function setPrivilegeId(privilegeId:Int):Void
	{
		this.privilegeId = privilegeId;
	}

	public function getUserManager():IUserManager
	{
		return userManager;
	}

	public function setUserManager(userManager:IUserManager):Void
	{
		this.userManager = userManager;
	}

	public function isGuest():Bool
	{
		return privilegeId == UserPrivileges.GUEST;
	}

	public function isStandardUser():Bool
	{
		return privilegeId == UserPrivileges.STANDARD;
	}

	public function isModerator():Bool
	{
		return privilegeId == UserPrivileges.MODERATOR;
	}

	public function isAdmin():Bool
	{
		return privilegeId == UserPrivileges.ADMINISTRATOR;
	}

	public function isPlayerInRoom(room:Room):Bool
	{
		var rid = room.getId();
		return playerIdByRoomId.exists(rid) && playerIdByRoomId.get(rid) > 0;
	}

	public function isSpectatorInRoom(room:Room):Bool
	{
		var rid = room.getId();
		return playerIdByRoomId.exists(rid) && playerIdByRoomId.get(rid) < 0;
	}

	public function isJoinedInRoom(room:Room):Bool
	{
		return room.containsUser(this);
	}

	public function isItMe():Bool
	{
		return _isItMe;
	}

	public function getVariables():Array<UserVariable>
	{
		var vars = new Array<UserVariable>();
		for(v in variables) {
			vars.push(v);
		}
		return vars;
	}

	public function getVariable(varName:String):UserVariable
	{
		return variables.exists(varName) ? variables.get(varName) : null;
	}

	public function setVariable(userVariable:UserVariable):Void
	{
		if (userVariable != null)
		{
			if (userVariable.isNull())
				variables.remove(userVariable.getName());
			else
				variables.set(userVariable.getName(), userVariable);
		}
	}

	public function setVariables(userVariables:Array<UserVariable>):Void
	{
		for (userVar in userVariables)
		{
			setVariable(userVar);
		}
	}

	public function containsVariable(name:String):Bool
	{
		return variables.exists(name);
	}

	public function getAOIEntryPoint():Vec3D<Any>
	{
		return aoiEntryPoint;
	}

	public function setAOIEntryPoint(aoiEntryPoint:Vec3D<Any>):Void
	{
		this.aoiEntryPoint = aoiEntryPoint;
	}
	
	public function equals(that:Dynamic):Bool
	{
		if (Std.isOfType(that, User))
			return this.id == cast(that, User).getId();
		else 
			return false;
	}
	
	public function toString():String
	{
		return '[User: $name, id: $id, isMe: $_isItMe]';
	}
	
	public function replaceVariables(vars:Array<UserVariable>):Void
	{
		variables.clear();
		for (v in vars) setVariable(v);
	}
}
