package com.smartfoxserver.v3.entities;

import com.smartfoxserver.v3.entities.data.ISFSArray;
import com.smartfoxserver.v3.entities.data.Vec3D;
import com.smartfoxserver.v3.entities.variables.IMMOItemVariable;
import com.smartfoxserver.v3.entities.variables.MMOItemVariable;
import hx.concurrent.collection.SynchronizedMap;

/**
 * An <em>MMOItem</em> represents an active non-player entity inside an MMORoom.
 * 
 * <p>MMOItems can be used to represent bonuses, triggers, bullets, etc, or any other non-player entity that will be handled using the MMORoom's rules of visibility.
 * This means that whenever one or more MMOItems fall within the Area of Interest of a user, their presence will be notified to that user by means of the
 * <em>SFSEvent.PROXIMITY_LIST_UPDATE</em> event.</p>
 * <p>MMOItems are identified by a unique ID and can have one or more MMOItem Variables associated to store custom data.</p>
 * 
 * <p><b>NOTE:</b> MMOItems can be created in a server side Extension only; client side creation is not allowed.</p>
 * 
 * @see	MMORoom
 * @see MMOItemVariable
 */
class MMOItem implements IMMOItem
{
	// NOTE: Use SynchronizedMap for thread-safe access (java: synchronized blocks on variables)
	private var variables:SynchronizedMap<String, IMMOItemVariable>;
	private var aoiEntryPoint:Vec3D<Any>;
	private var id:Int;

	public static function fromSFSArray(encodedItem:ISFSArray):IMMOItem
	{
		// Create the MMO Item with the server side ID (Index = 0 of the SFSArray)
		var item:IMMOItem = new MMOItem(encodedItem.getInt(0));
		
		// Decode ItemVariables (Index = 1 of the SFSArray)
		var encodedVars:ISFSArray = encodedItem.getSFSArray(1);
		
		for (i in 0...encodedVars.size())
		{
			item.setVariable(MMOItemVariable.fromSFSArray(encodedVars.getSFSArray(i)));
		}
		
		return item;
	}
	
	public function new(id:Int)
    {
		this.id = id;
		variables = SynchronizedMap.newStringMap();
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
	
	public function getId():Int
    {
	    return id;
    }
	
    public function getVariable(name:String):IMMOItemVariable
    {
		return variables.get(name);
    }

    public function getVariables():Array<IMMOItemVariable>
    {
	    var vars = new Array<IMMOItemVariable>();
        for (v in variables) {
            vars.push(v);
        }
	    return vars;
    }

    public function setVariable(vr:IMMOItemVariable):Void
    {
		/*
		 * Variables deletion is not supported
		 * Setting an existing variable to null will only change its value, but won't remove it 
		 */
	    variables.set(vr.getName(), vr);
    }

    public function setVariables(varList:Array<IMMOItemVariable>):Void
    {
	    for (itemVar in varList)
	    {
	    	variables.set(itemVar.getName(), itemVar);
	    }
    }
	
	public function equals(that:Dynamic):Bool
	{
		if (Std.isOfType(that, IMMOItem))
			return this.id == cast(that, IMMOItem).getId();
		else 
			return false;
	}
	
	// No straightforward hashCode equivalent, or just return id
	public function toString():String
	{
	    return '[MMOItem id: ${id}, variables: ${variables} ]';
	}
}
