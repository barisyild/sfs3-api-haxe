package sfs3.client.entities;

import sfs3.client.entities.data.ISFSArray;
import sfs3.client.entities.variables.BuddyVariable;
import hx.concurrent.collection.SynchronizedMap;
import sfs3.client.entities.variables.ReservedBuddyVariables;
import sfs3.client.entities.variables.SFSBuddyVariable;

/**
 * The <em>SFSBuddy</em> object represents a buddy in the current user's buddy list.
 *
 * @see sfs3.client.entities.variables.BuddyVariable
 */
class SFSBuddy implements Buddy
{
	private var name:String;
	private var id:Int;
	private var _isBlocked:Bool;
	private var variables:SynchronizedMap<String, BuddyVariable>;
	private var _isTemp:Bool;

	/**
	 * @internal
	 */
	public static function fromSFSArray(arr:ISFSArray):Buddy
	{
		var buddy:Buddy = new SFSBuddy(arr.getInt(0), // id
		        arr.getShortString(1), // name
		        arr.getBool(2), // blocked
		        arr.size() > 4 ? arr.getBool(4) : false // isTemp is optional, we have to check
		);

		var bVarsData:ISFSArray = arr.getSFSArray(3); // variables data array

		for (j in 0...bVarsData.size())
		{
			var bv:BuddyVariable = SFSBuddyVariable.fromSFSArray(bVarsData.getSFSArray(j));
			buddy.setVariable(bv);
		}

		return buddy;
	}

	/**
	 * Creates a new <em>SFSBuddy</em> instance.
	 * <p>
	 * <b>NOTE</b>: never instantiate a <em>SFSBuddy</em> manually: this is done by the SmartFoxServer 3 API internally.
	 */
	public function new(id:Int, name:String, ?isBlocked:Bool = false, ?isTemp:Bool = false)
	{
		this.name = name;
		this.id = id;
		this._isBlocked = isBlocked;
		this._isTemp = isTemp;
		variables = SynchronizedMap.newStringMap();
	}

	public function getId():Int
	{
		return id;
	}

	public function getName():String
	{
		return name;
	}
	
	public function getDisplayName():String
	{
		var nick = getNickName();
		return (nick != null && nick != "") ? nick : name;
	}

	public function isBlocked():Bool
	{
		return _isBlocked;
	}

	public function isOnline():Bool
	{
		var bv:BuddyVariable = getVariable(ReservedBuddyVariables.BV_ONLINE);

		// An non-inited ONLINE state == online
		var onlineStateVar = (bv == null) ? true : bv.getBoolValue();

		/*
		 * The buddy is considered ONLINE if 1. he is connectected in the system 2. his online variable is set to true
		 */
		return onlineStateVar && id > -1;
	}

	public function isTemp():Bool
	{
		return _isTemp;
	}

	public function getState():String
	{
		var bv:BuddyVariable = getVariable(ReservedBuddyVariables.BV_STATE);
		return (bv == null) ? null : bv.getStringValue();
	}

	public function getNickName():String
	{
		var bv:BuddyVariable = getVariable(ReservedBuddyVariables.BV_NICKNAME);
		return (bv == null) ? null : bv.getStringValue();
	}

	public function getVariables():Array<BuddyVariable>
	{
		var vars = new Array<BuddyVariable>();
		for(v in variables) vars.push(v);
		return vars;
	}

	public function getVariable(varName:String):BuddyVariable
	{
		return variables.exists(varName) ? variables.get(varName) : null;
	}

	public function containsVariable(varName:String):Bool
	{
		return variables.exists(varName);
	}

	public function getOfflineVariables():Array<BuddyVariable>
	{
		var offlineVars = new Array<BuddyVariable>();

		for (item in variables)
		{
			if (StringTools.startsWith(item.getName(), SFSBuddyVariable.OFFLINE_PREFIX))
			{
				offlineVars.push(item);
			}
		}

		return offlineVars;
	}

	public function getOnlineVariables():Array<BuddyVariable>
	{
		var onlineVars = new Array<BuddyVariable>();

		for (item in variables)
		{
			if (!StringTools.startsWith(item.getName(), SFSBuddyVariable.OFFLINE_PREFIX))
			{
				onlineVars.push(item);
			}
		}

		return onlineVars;
	}

	public function setVariable(bVar:BuddyVariable):Void
	{
		/*
		 * Variables deletion is not supported
		 * Setting an existing variable to null will only change its value, but won't remove it 
		 */
		variables.set(bVar.getName(), bVar);
	}

	public function setVariables(variables:Array<BuddyVariable>):Void
	{
		for (bVar in variables)
		{
			setVariable(bVar);
		}
	}

	public function setId(id:Int):Void
	{
		this.id = id;
	}

	public function setBlocked(blocked:Bool):Void
	{
		_isBlocked = blocked;
	}

	public function removeVariable(varName:String):Void
	{
		variables.remove(varName);
	}

	public function clearVolatileVariables():Void
	{
		var keysToRemove = new Array<String>();
		for (key in variables.keys())
		{
			var bVar = variables.get(key);
			if (!StringTools.startsWith(bVar.getName(), SFSBuddyVariable.OFFLINE_PREFIX))
				keysToRemove.push(key);
		}
		for(key in keysToRemove) variables.remove(key);
	}
	
	/*
	 * We do not rely on the id because it can be -1
	 * if the relative User is offline
	 */
	public function equals(that:Dynamic):Bool
	{
		if (Std.isOfType(that, Buddy))
		{
			var otherBuddy:Buddy = cast that;
			return this.name == otherBuddy.getName();
		}
		else 
			return false;
	}
	
	public function toString():String
	{
		return '[Buddy: $name, id: $id]';
	}
}
