package sfs3.client.entities.managers;

import sfs3.client.entities.data.ISFSArray;
import sfs3.client.entities.Room;
import sfs3.client.entities.SFSUser;
import sfs3.client.entities.User;
import sfs3.client.entities.variables.SFSUserVariable;
import sfs3.client.entities.variables.UserVariable;
import sfs3.client.exceptions.SFSException;
import sfs3.client.entities.data.Set;

/**
 * Aggregates Users from all joined Rooms and always includes the current user (smartFox.mySelf)
 * if the client is logged in.
 *
 * NOTE: Methods that change the content of the UserManager are ignored as this is only a view in the
 * underlying data distributed in all joined Rooms.
 */
class SFSGlobalUserManager extends SFSUserManager
{
	public function new(smartFox:ISmartFox)
	{
		super(smartFox);
	}

	override public function containsUser(user:User):Bool
	{
		var joined = smartFox.getJoinedRooms();
		if (joined != null)
		{
			for (r in joined)
			{
				if (r.containsUser(user)) return true;
			}
		}
		return false;
	}

	override public function containsUserName(userName:String):Bool
	{
		var joined = smartFox.getJoinedRooms();
		if (joined != null)
		{
			for (r in joined)
			{
				if (r.getUserByName(userName) != null) return true;
			}
		}
		return false;
	}

	override public function containsUserId(userId:Int):Bool
	{
		var joined = smartFox.getJoinedRooms();
		if (joined != null)
		{
			for (r in joined)
			{
				if (r.getUserById(userId) != null) return true;
			}
		}
		return false;
	}

	override public function getUserById(userId:Int):User
	{
		if (smartFox.getMySelf() != null && smartFox.getMySelf().getId() == userId)
			return smartFox.getMySelf();

		var joined = smartFox.getJoinedRooms();
		if (joined != null)
		{
			for (r in joined)
			{
				var user = r.getUserById(userId);
				if (user != null) return user;
			}
		}
		return null;
	}

	override public function getUserByName(userName:String):User
	{
		if (smartFox.getMySelf() != null && smartFox.getMySelf().getName() == userName)
			return smartFox.getMySelf();

		var joined = smartFox.getJoinedRooms();
		if (joined != null)
		{
			for (r in joined)
			{
				var user = r.getUserByName(userName);
				if (user != null) return user;
			}
		}
		return null;
	}

	override public function getUserList():Array<User>
	{
		var joined = smartFox.getJoinedRooms();
		if (joined == null || joined.length == 0)
		{
			if (smartFox.getMySelf() != null)
				return [smartFox.getMySelf()];
			else
				return [];
		}

		var uniqueUsers = new Set<User>();
		for (r in joined)
		{
			for (u in r.getUserList())
				uniqueUsers.push(u);
		}
		return uniqueUsers.toArray();
	}

	override public function getUserCount():Int
	{
		return getUserList().length;
	}

	override public function addUser(user:User):Void {}
	override public function removeUser(user:User):Void {}
	override public function removeUserById(id:Int):Void {}

	public function getOrCreateUser(userObj:ISFSArray, room:Room):User
	{
		var uId = userObj.getInt(0);
		var user = getUserById(uId);

		if (user == null)
		{
			user = SFSUser.fromSFSArray(userObj, room);
			user.setUserManager(this);
		}
		else if (room != null)
		{
			user.setPlayerId(userObj.getShort(3), room);
			var uVars = userObj.getSFSArray(4);
			var vars = new Array<UserVariable>();
			for (i in 0...uVars.size())
			{
				vars.push(SFSUserVariable.fromSFSArray(uVars.getSFSArray(i)));
			}
			(cast user : SFSUser).replaceVariables(vars);
		}

		return user;
	}
}
