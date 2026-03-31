package sfs3.client.entities.variables;

import sfs3.client.entities.data.ISFSArray;

@:expose("SFS3.MMOItemVariable")
class MMOItemVariable extends BaseVariable implements IMMOItemVariable
{
	public static function fromSFSArray(sfsa:ISFSArray):IMMOItemVariable
	{
		return new MMOItemVariable(
			sfsa.getShortString(0),
			sfsa.getElementAt(2),
			VariableType.fromId(sfsa.getByte(1))
		);
	}

	public function new(name:String, ?val:Dynamic, ?type:VariableType)
	{
		super(name, val, type);
	}
}
