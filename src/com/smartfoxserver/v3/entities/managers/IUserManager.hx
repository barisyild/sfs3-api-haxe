package com.smartfoxserver.v3.entities.managers;

import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.entities.User;

/**
 * The <em>IUserManager</em> interface defines all the methods and properties exposed by the client-side manager of the SmartFoxServer User entities.
 * <p>In the SmartFoxServer 3 client API this interface is implemented by the <em>SFSUserManager</em> class. Read the class description for additional informations.</p>
 *
 * @see SFSUserManager
 */
interface IUserManager
{
    /**
	 * Indicates whether a user exists in the local users list or not from the name.
	 *
	 * @param	userName	The name of the user whose presence in the users list is to be tested.
	 * @return	<code>true</code> if the passed user exists in the users list.
	 *
	 * @see		sfs3.client.entities.User#getName()
	 */
    public function containsUserName(userName:String):Bool;

    /**
	 * Indicates whether a user exists in the local users list or not from the id.
	 *
	 * @param	userId	The id of the user whose presence in the users list is to be tested.
	 * @return	<code>true</code> if the passed user exists in the users list.
	 *
	 * @see		sfs3.client.entities.User#getId()
	 */
    public function containsUserId(userId:Int):Bool;

    /**
	 * Indicates whether a user exists in the local users list or not.
	 *
	 * @param	user	The <em>User</em> object representing the user whose presence in the users list is to be tested.
	 * @return	<code>true</code> if the passed user exists in the users list.
	 */
    public function containsUser(user:User):Bool;

    /**
	 * Retrieves a <em>User</em> object from its <em>name</em> property.
	 *
	 * @param	userName	The name of the user to be found.
	 * @return The <em>User</em> object representing the user, or <code>null</code> if no user with the passed name exists in the local users list.
	 *
	 * @see		sfs3.client.entities.User#getName()
	 * @see		#getUserById
	 */
    public function getUserByName(userName:String):User;

    /**
	 * Retrieves a <em>User</em> object from its <em>id</em> property.
	 *
	 * @param	userId	The id of the user to be found.
	 * @return The <em>User</em> object representing the user, or <code>null</code> if no user with the passed id exists in the local users list.
	 *
	 * @see		sfs3.client.entities.User#getId()
	 * @see		#getUserByName
	 */
    public function getUserById(userId:Int):User;

    /**
	 * @internal
	 */
    public function addUser(user:User):Void;

    /**
	 * @internal
	 */
    public function removeUser(user:User):Void;

    /**
	 * @internal
	 */
    public function removeUserById(id:Int):Void;

    /**
	 * Returns the total number of users in the local users list.
	 */
    public function getUserCount():Int;

    /**
	 * Get the whole list of users inside the Rooms joined by the client.
	 *
	 * @return The list of <em>User</em> objects representing the users in the local users list.
	 */
    public function getUserList():Array<User>;

    /**
	 * @internal
	 */
    public function getSmartFox():ISmartFox;
}
