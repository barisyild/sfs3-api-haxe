package sfs3.client.entities.managers;

import sfs3.client.ISmartFox;
import sfs3.client.entities.Buddy;
import sfs3.client.entities.variables.BuddyVariable;
import sfs3.client.entities.variables.ReservedBuddyVariables;
import sfs3.client.entities.variables.SFSBuddyVariable;
import hx.concurrent.collection.SynchronizedMap;

/**
 * The <em>SFSBuddyManager</em> class is the entity in charge of managing the current user's <b>Buddy List</b> system.
 *
 * @see sfs3.client.SmartFox#getBuddyManager
 */
class SFSBuddyManager implements IBuddyManager
{
	private var buddiesByName:SynchronizedMap<String, Buddy>;
	private var myVariables:SynchronizedMap<String, BuddyVariable>;
	private var inited:Bool = false;
	private var buddyStates:Array<String>;
	private var sfs:ISmartFox;

	public function new(sfs:ISmartFox)
	{
		this.sfs = sfs;
		buddiesByName = SynchronizedMap.newStringMap();
		myVariables = SynchronizedMap.newStringMap();
	}

	public function isInited():Bool return inited;
	public function setInited(inited:Bool):Void this.inited = inited;

	public function addBuddy(buddy:Buddy):Void
	{
		buddiesByName.set(buddy.getName(), buddy);
	}

	public function removeBuddyById(id:Int):Buddy
	{
		var buddy = getBuddyById(id);
		if (buddy != null)
			buddiesByName.remove(buddy.getName());
		return buddy;
	}

	public function removeBuddyByName(name:String):Buddy
	{
		var buddy = getBuddyByName(name);
		if (buddy != null)
			buddiesByName.remove(buddy.getName());
		return buddy;
	}

	public function containsBuddy(name:String):Bool
	{
		return buddiesByName.exists(name);
	}

	public function getBuddyById(id:Int):Buddy
	{
		if (id > -1)
		{
			for (buddy in buddiesByName)
			{
				if (buddy.getId() == id) return buddy;
			}
		}
		return null;
	}

	public function getBuddyByName(name:String):Buddy
	{
		return buddiesByName.exists(name) ? buddiesByName.get(name) : null;
	}

	public function getBuddyByNickName(nickName:String):Buddy
	{
		for (buddy in buddiesByName)
		{
			if (buddy.getNickName() == nickName) return buddy;
		}
		return null;
	}

	public function getOfflineBuddies():Array<Buddy>
	{
		var list = new Array<Buddy>();
		for (buddy in buddiesByName)
			if (!buddy.isOnline()) list.push(buddy);
		return list;
	}

	public function getOnlineBuddies():Array<Buddy>
	{
		var list = new Array<Buddy>();
		for (buddy in buddiesByName)
			if (buddy.isOnline()) list.push(buddy);
		return list;
	}

	public function getBuddyList():Array<Buddy>
	{
		var list = new Array<Buddy>();
		for (b in buddiesByName) list.push(b);
		return list;
	}

	public function getBuddyStates():Array<String>
	{
		return buddyStates;
	}

	public function getMyVariable(varName:String):BuddyVariable
	{
		return myVariables.exists(varName) ? myVariables.get(varName) : null;
	}

	public function getMyVariables():Array<BuddyVariable>
	{
		var list = new Array<BuddyVariable>();
		for (v in myVariables) list.push(v);
		return list;
	}

	public function getMyOnlineState():Bool
	{
		if (!inited) return false;
		var onlineVar = getMyVariable(ReservedBuddyVariables.BV_ONLINE);
		return (onlineVar == null) ? true : onlineVar.getBoolValue();
	}

	public function getMyNickName():String
	{
		var nickNameVar = getMyVariable(ReservedBuddyVariables.BV_NICKNAME);
		return (nickNameVar != null) ? nickNameVar.getStringValue() : null;
	}

	public function getMyState():String
	{
		var stateVar = getMyVariable(ReservedBuddyVariables.BV_STATE);
		return (stateVar != null) ? stateVar.getStringValue() : null;
	}

	public function getMyDisplayName():String
	{
		var nickName = getMyNickName();
		return (nickName != null) ? nickName : sfs.getMySelf().getName();
	}

	public function setMyVariable(bVar:BuddyVariable):Void
	{
		myVariables.set(bVar.getName(), bVar);
	}

	public function setMyVariables(variables:Array<BuddyVariable>):Void
	{
		for (bVar in variables) setMyVariable(bVar);
	}

	public function setMyOnlineState(isOnline:Bool):Void
	{
		setMyVariable(new SFSBuddyVariable(ReservedBuddyVariables.BV_ONLINE, isOnline));
	}

	public function setMyNickName(nickName:String):Void
	{
		setMyVariable(new SFSBuddyVariable(ReservedBuddyVariables.BV_NICKNAME, nickName));
	}

	public function setMyState(state:String):Void
	{
		setMyVariable(new SFSBuddyVariable(ReservedBuddyVariables.BV_STATE, state));
	}

	public function setBuddyStates(states:Array<String>):Void
	{
		buddyStates = states;
	}

	public function clearAll():Void
	{
		buddiesByName.clear();
	}
}
