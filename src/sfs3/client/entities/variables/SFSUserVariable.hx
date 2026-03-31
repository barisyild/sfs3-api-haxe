package sfs3.client.entities.variables;

import sfs3.client.entities.data.ISFSArray;

@:expose("SFS3.SFSUserVariable")
class SFSUserVariable extends BaseVariable implements UserVariable
{
	private var _isPrivate:Bool = false;

	public static function fromSFSArray(sfsa:ISFSArray):UserVariable
	{
		var uv = new SFSUserVariable(
			sfsa.getShortString(0),
			sfsa.getElementAt(2),
			VariableType.fromId(sfsa.getByte(1))
		);
		uv.setPrivate(sfsa.getBool(3));
		return uv;
	}

	public function new(name:String, ?val:Dynamic, ?type:VariableType)
	{
		super(name, val, type);
	}

	public function isPrivate():Bool return _isPrivate;
	public function setPrivate(value:Bool):Void _isPrivate = value;

	override public function toSFSArray():ISFSArray
	{
		var sfsa = super.toSFSArray();
		sfsa.addBool(_isPrivate);
		return sfsa;
	}
}
