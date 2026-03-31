package sfs3.client.entities.variables;

import sfs3.client.entities.data.ISFSArray;

@:expose("SFS3.SFSBuddyVariable")
class SFSBuddyVariable extends BaseVariable implements BuddyVariable
{
	public static inline var OFFLINE_PREFIX:String = "$";

	public static function fromSFSArray(sfsa:ISFSArray):BuddyVariable
	{
		return new SFSBuddyVariable(
			sfsa.getShortString(0),
			sfsa.getElementAt(2),
			VariableType.fromId(sfsa.getByte(1))
		);
	}

	public function new(name:String, ?val:Dynamic, ?type:VariableType)
	{
		super(name, val, type);
	}

	public function isOffline():Bool return StringTools.startsWith(name, OFFLINE_PREFIX);
}
