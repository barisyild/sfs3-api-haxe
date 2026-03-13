package com.smartfoxserver.v3.entities.managers;

import com.smartfoxserver.v3.exceptions.SFSException;

import com.smartfoxserver.v3.entities.Buddy;
import com.smartfoxserver.v3.entities.variables.BuddyVariable;

/**
 * The <em>IBuddyManager</em> interface defines all the methods and properties exposed by the client-side manager of the SmartFoxServer <b>Buddy List</b> system.
 * <p>In the SmartFoxServer 3 client API this interface is implemented by the <em>SFSBuddyManager</em> class. Read the class description for additional informations.</p>
 *
 * @see com.smartfoxserver.v3.entities.managers.SFSBuddyManager
 */
interface IBuddyManager
{
    /**
	 * Indicates whether the client's Buddy List system is initialized or not.
	 * If not, an <em>InitBuddyListRequest</em> request should be sent to the server in order to retrieve the persistent Buddy List data.
	 * <p/>
	 * <p>No Buddy List related operations are allowed until the system is initialized.</p>
	 *
	 * @see com.smartfoxserver.v3.requests.buddylist.InitBuddyListRequest
	 */
    public function isInited():Bool;

    /**
	 * @internal
	 */
    public function setInited(inited:Bool):Void;

    /**
	 * @internal
	 */
    public function addBuddy(buddy:Buddy):Void;

    /**
	 * @internal
	 */
    public function removeBuddyById(id:Int):Buddy;

    /**
	 * @internal
	 */
    public function removeBuddyByName(name:String):Buddy;

    /**
	 * Indicates whether a buddy exists in user's buddies list or not.
	 *
	 * @param	name	The name of the buddy whose presence in the buddies list is to be tested.
	 * @return	<code>true</code> if the specified buddy exists in the buddies list.
	 *
	 * @see		com.smartfoxserver.v3.entities.Buddy#getName()
	 */
    public function containsBuddy(name:String):Bool;

    /**
	 * Retrieves a <em>Buddy</em> object from its <em>id</em> property.
	 *
	 * @param	id	The id of the buddy to be found.
	 * @return The <em>Buddy</em> object representing the buddy, or <code>null</code> if no buddy with the passed id exists in the buddies list.
	 *
	 * @see		com.smartfoxserver.v3.entities.Buddy#getId()
	 * @see		#getBuddyByName
	 * @see		#getBuddyByNickName
	 */
    public function getBuddyById(id:Int):Buddy;

    /**
	 * Retrieves a <em>Buddy</em> object from its <em>name</em> property.
	 *
	 * @param	name	The name of the buddy to be found.
	 * @return The <em>Buddy</em> object representing the buddy, or <code>null</code> if no buddy with the passed name exists in the buddies list.
	 *
	 * @see		com.smartfoxserver.v3.entities.Buddy#getName()
	 * @see		#getBuddyById
	 * @see		#getBuddyByNickName
	 */
    public function getBuddyByName(name:String):Buddy;

    /**
	 * Retrieves a <em>Buddy</em> object from its <em>nickName</em> property (if set).
	 *
	 * @param	nickName	The nickName of the buddy to be found.
	 * @return The <em>Buddy</em> object representing the buddy, or <code>null</code> if no buddy with the passed nickName exists in the buddies list.
	 *
	 * @see		com.smartfoxserver.v3.entities.Buddy#getNickName()
	 * @see		#getBuddyById
	 * @see		#getBuddyByName
	 */
    public function getBuddyByNickName(nickName:String):Buddy;

    /**
	 * Returns a list of <em>Buddy</em> objects representing all the offline buddies in the user's buddies list.
	 *
	 * @see		com.smartfoxserver.v3.entities.Buddy#isOnline()
	 */
    public function getOfflineBuddies():Array<Buddy>;

    /**
	 * Returns a list of <em>Buddy</em> objects representing all the online buddies in the user's buddies list.
	 *
	 * @see		com.smartfoxserver.v3.entities.Buddy#isOnline()
	 */
    public function getOnlineBuddies():Array<Buddy>;

    /**
	 * Returns a list of <em>Buddy</em> objects representing all the buddies in the user's buddies list.
	 * The list is <code>null</code> if the Buddy List system is not initialized.
	 *
	 * @see #isInited
	 */
    public function getBuddyList():Array<Buddy>;

    /**
	 * Returns a list of strings representing the available custom buddy states.
	 * The custom states are received by the client upon initialization of the Buddy List system. They can be configured by means of the SmartFoxServer 3 Administration Tool.
	 *
	 * @see		com.smartfoxserver.v3.entities.Buddy#getState()
	 */
    public function getBuddyStates():Array<String>;


    /**
	 * Retrieves a Buddy Variable from its name.
	 *
	 * @param	varName	The name of the Buddy Variable to be retrieved.
	 * @return The <em>BuddyVariable</em> object representing the Buddy Variable, or <code>null</code> if no Buddy Variable with the passed name is associated with the current user.
	 *
	 * @see		#getMyVariables()
	 * @see		com.smartfoxserver.v3.requests.buddylist.SetBuddyVariablesRequest
	 */
    public function getMyVariable(varName:String):BuddyVariable;

    /**
	 * Returns all the Buddy Variables associated with the current user.
	 *
	 * @see		com.smartfoxserver.v3.entities.variables.BuddyVariable
	 * @see		#getMyVariable(String)
	 */
    public function getMyVariables():Array<BuddyVariable>;

    /**
	 * Returns the current user's online/offline state.
	 * If <code>true</code>, the user appears to be online in the buddies list of other users who have him as a buddy.
	 * <p>The online state of a user in a buddy list is handled by means of a reserved Buddy Variable (see <em>ReservedBuddyVariables</em> class);
	 * it can be changed using the dedicated <em>GoOnlineRequest</em> request.</p>
	 *
	 * @see		com.smartfoxserver.v3.entities.Buddy#isOnline()
	 * @see		com.smartfoxserver.v3.entities.variables.ReservedBuddyVariables
	 * @see		com.smartfoxserver.v3.requests.buddylist.GoOnlineRequest
	 */
    public function getMyOnlineState():Bool;

    /**
	 * Returns the current user's nickname (if set).
	 * If the nickname was never set before, <code>null</code> is returned.
	 * <p>As the nickname of a user in a buddy list is handled by means of a reserved Buddy Variable (see <em>ReservedBuddyVariables</em> class),
	 * it can be set using the <em>SetBuddyVariablesRequest</em> request.</p>
	 *
	 * @see		com.smartfoxserver.v3.entities.Buddy#getNickName()
	 * @see		com.smartfoxserver.v3.entities.variables.ReservedBuddyVariables
	 * @see 	com.smartfoxserver.v3.requests.buddylist.SetBuddyVariablesRequest
	 */
    public function getMyNickName():String;

    /**
	 * Returns the current user's custom state (if set).
	 * Examples of custom states are "Available", "Busy", "Be right back", etc. If the custom state was never set before, <code>null</code> is returned.
	 * <p>As the custom state of a user in a buddy list is handled by means of a reserved Buddy Variable (see <em>ReservedBuddyVariables</em> class),
	 * it can be set using the <em>SetBuddyVariablesRequest</em> request.</p>
	 *
	 * @see		com.smartfoxserver.v3.entities.Buddy#getState()
	 * @see		com.smartfoxserver.v3.entities.variables.ReservedBuddyVariables
	 * @see		com.smartfoxserver.v3.requests.buddylist.SetBuddyVariablesRequest
	 */
    public function getMyState():String;

    /**
	 * Gets the nickname of the current User or the User's name, if nickname is not set
	 * @return nickname of the current User or the User's name, if nickname is not set
	 */
    public function getMyDisplayName():String;

    /**
	 * @internal
	 */
    public function setMyVariable(bVar:BuddyVariable):Void;

    /**
	 * @internal
	 */
    public function setMyVariables(variables:Array<BuddyVariable>):Void;

    /**
	 * @internal
	 */
    public function setMyOnlineState(isOnline:Bool):Void;

    /**
	 * @internal
	 */
    public function setMyNickName(nickName:String):Void;

    /**
	 * @internal
	 */
    public function setMyState(state:String):Void;

    /**
	 * @internal
	 */
    public function setBuddyStates(states:Array<String>):Void;

    /**
	 * @internal
	 */
    public function clearAll():Void;
}
