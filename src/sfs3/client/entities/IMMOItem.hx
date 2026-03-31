package sfs3.client.entities;

import sfs3.client.entities.data.Vec3D;
import sfs3.client.entities.variables.IMMOItemVariable;

interface IMMOItem
{
	/**
	 * The unique ID of this item
	 */
	function getId():Int;

	/**
	 * Retrieves all the Variables of this Item
	 * 
	 * @return	The list of <em>ItemVariable</em> objects associated with the Item
	 * 
	 * @see		sfs3.client.entities.variables.MMOItemVariable
	 * @see		#getVariable()
	 */ 
	function getVariables():Array<IMMOItemVariable>;

	/**
	 * Retrieves a User Variable from its name.
	 * 
	 * @param	name	The name of the User Variable to be retrieved.
	 * @return	The MMOItemVariable, or <b>null</b> if no MMOItemVariable with the passed name is associated with this MMOItem.
	 * 
	 * @see		#getVariables()
	 * @see		sfs3.client.entities.variables.MMOItemVariable
	 */ 
	function getVariable(name:String):IMMOItemVariable;

	/** private */
	function setVariable(itemVariable:IMMOItemVariable):Void;

	/** private */
	function setVariables(itemVariables:Array<IMMOItemVariable>):Void;

	/**
	 * Indicates whether this MMOItem has the specified Item Variable set or not.
	 * 
	 * @param	name	The name of the MMOItemVariable whose existence must be checked.
	 * 
	 * @return	<b>true</b> if a MMOItemVariable with the passed name exists for this MMOItem.
	 */
	function containsVariable(name:String):Bool;
		
	/**
	 * Returns the entry point within the User's AOI where this object "appeared" with the last
	 * PROXIMITY_LIST_UPDATE event. This field is populated only if the MMORoom is configured to receive this data.
	 * 
	 * @see sfs3.client.requests.mmo.MMORoomSettings#setSendAOIEntryPoint()
	 * @see sfs3.client.core.SFSEvent#PROXIMITY_LIST_UPDATE
	 */
	function getAOIEntryPoint():Vec3D<Any>;
}
