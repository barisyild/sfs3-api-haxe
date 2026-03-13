package com.smartfoxserver.v3.entities;

import com.smartfoxserver.v3.entities.variables.BuddyVariable;

/**
 * <p>In the SmartFoxServer 3 client API this interface is implemented by the <em>SFSBuddy</em> class. 
 * </p>
 *
 * @see com.smartfoxserver.v3.entities.SFSBuddy
 */
interface Buddy 
{
	/**
	 * The buddy id.
	 * This is equal to the id assigned by SmartFoxServer to the corresponding User.
	 *
	 * @see		com.smartfoxserver.v3.entities.User#getId()
	 */
	function getId():Int;

	/**
	 * The name of this buddy.
	 * This is equal to the login name of the corresponding User.
	 *
	 * @see		com.smartfoxserver.v3.entities.User#getName()
	 */
	function getName():String;
	
	/**
	 * If a Buddy nickname exists returns that nickname, otherwise returns the User's login name. 
	 * @return the nickname (if any), otherwise the User's name.
	 */
	function getDisplayName():String;

	/**
	 * Indicates whether this buddy is blocked in the current user's buddies list or not.
	 * A buddy can be blocked by means of a <em>BlockBuddyRequest</em> request.
	 *
	 * @see com.smartfoxserver.v3.requests.buddylist.BlockBuddyRequest
	 */
	function isBlocked():Bool;

	/**
	 * Indicates whether this buddy is online in the Buddy List system or not.
	 */
	function isOnline():Bool;

	/**
	 * Indicates whether this buddy is temporary (non-persistent) in the current user's buddies list or not.
	 */
	function isTemp():Bool;

	/**
	 * Returns the custom state of this buddy.
	 * Examples of custom states are "Available", "Busy", "Be right back", etc. If the custom state is not set, <code>null</code> is returned.
	 * <p/>
	 * <p>The list of available custom states is returned by the <em>IBuddyManager.buddyStates</em> property.</p>
	 *
	 * @see		com.smartfoxserver.v3.entities.managers.IBuddyManager#getBuddyStates()
	 */
	function getState():String;

	/**
	 * Returns the nickname of this buddy.
	 * If the nickname is not set, <code>null</code> is returned.
	 */
	function getNickName():String;

	/**
	 * Returns a list of <em>BuddyVariable</em> objects associated with the buddy.
	 *
	 * @see		com.smartfoxserver.v3.entities.variables.BuddyVariable
	 * @see		#getVariable()
	 */
	function getVariables():Array<BuddyVariable>;

	/**
	 * Retrieves a Buddy Variable from its name.
	 *
	 * @param	varName	The name of the Buddy Variable to be retrieved.
	 * @return The <em>BuddyVariable</em> object representing the Buddy Variable, or <code>null</code> if no Buddy Variable with the passed name is associated with this buddy.
	 * 
	 * @see		#getVariables()
	 * @see 	com.smartfoxserver.v3.requests.buddylist.SetBuddyVariablesRequest
	 */
	function getVariable(varName:String):BuddyVariable;


	/**
	 * Indicates whether this buddy has the specified Buddy Variable set or not.
	 *
	 * @param	varName	The name of the Buddy Variable whose existence must be checked.
	 * @return	<code>true</code> if a Buddy Variable with the passed name is set for this buddy.
	 */
	function containsVariable(varName:String):Bool;

	/**
	 * Retrieves the list of persistent Buddy Variables of this buddy.
	 *
	 * @return A List of <em>BuddyVariable</em> objects.
	 * 
	 * @see		com.smartfoxserver.v3.entities.variables.BuddyVariable#isOffline
	 */
	function getOfflineVariables():Array<BuddyVariable>;

	/**
	 * Retrieves the list of non-persistent Buddy Variables of this buddy.
	 *
	 * @return A List of <em>BuddyVariable</em> objects.
	 * 
	 * @see		com.smartfoxserver.v3.entities.variables.BuddyVariable#isOffline
	 */
	function getOnlineVariables():Array<BuddyVariable>;

	/**
	 * @internal
	 */
	function setVariable(bVar:BuddyVariable):Void;

	/**
	 * @internal
	 */
	function setVariables(variables:Array<BuddyVariable>):Void;

	/**
	 * @internal
	 */
	function setId(id:Int):Void;

	/**
	 * @internal
	 */
	function setBlocked(blocked:Bool):Void;

	/**
	 * @internal
	 */
	function removeVariable(varName:String):Void;

	/**
	 * @internal
	 */
	function clearVolatileVariables():Void;
}
