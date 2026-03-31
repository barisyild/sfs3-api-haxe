package sfs3.client.entities.managers;

import sfs3.client.ISmartFox;
import sfs3.client.entities.User;
import hx.concurrent.collection.SynchronizedMap;
import hx.concurrent.lock.RLock;

/**
 * The <em>SFSUserManager</em> class is the entity in charge of managing the local (client-side) users list.
 * It keeps track of all the users that are currently joined in the same Rooms of the current user.
 *
 * @see sfs3.client.SmartFox#getUserManager
 */
class SFSUserManager implements IUserManager
{
	private var usersByName:SynchronizedMap<String, User>;
	private var usersById:SynchronizedMap<Int, User>;
	public var smartFox:ISmartFox;
	private var globalLock:RLock;

	public function new(smartFox:ISmartFox)
	{
		this.smartFox = smartFox;
		usersByName = SynchronizedMap.newStringMap();
		usersById = SynchronizedMap.newIntMap();
		globalLock = new RLock();
	}

	public function containsUserName(userName:String):Bool
	{
		return globalLock.execute(() -> usersByName.exists(userName));
	}

	public function containsUserId(userId:Int):Bool
	{
		return globalLock.execute(() -> usersById.exists(userId));
	}

	public function containsUser(user:User):Bool
	{
		return globalLock.execute(() -> {
			for (u in usersByName) if (u == user) return true;
			return false;
		});
	}

	public function getUserByName(userName:String):User
	{
		return globalLock.execute(() -> usersByName.exists(userName) ? usersByName.get(userName) : null);
	}

	public function getUserById(userId:Int):User
	{
		return globalLock.execute(() -> usersById.exists(userId) ? usersById.get(userId) : null);
	}

	public function addUser(user:User):Void
	{
		globalLock.execute(() -> {
			usersByName.set(user.getName(), user);
			usersById.set(user.getId(), user);
		});
	}

	public function removeUser(user:User):Void
	{
		globalLock.execute(() -> {
			usersByName.remove(user.getName());
			usersById.remove(user.getId());
		});
	}

	public function removeUserById(id:Int):Void
	{
		globalLock.execute(() -> {
			if (!usersById.exists(id)) return;
			var user = usersById.get(id);
			usersByName.remove(user.getName());
			usersById.remove(id);
		});
	}

	public function getUserCount():Int
	{
		return globalLock.execute(() -> {
			var len = 0;
			for (_ in usersById) len++;
			return len;
		});
	}

	public function getUserList():Array<User>
	{
		return globalLock.execute(() -> {
			var list = new Array<User>();
			for (u in usersById) list.push(u);
			return list;
		});
	}

	public function getSmartFox():ISmartFox
	{
		return smartFox;
	}
}
