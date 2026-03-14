package com.smartfoxserver.v3.entities.variables;

import com.smartfoxserver.v3.entities.data.ISFSArray;

@:expose("SFS3.SFSRoomVariable")
class SFSRoomVariable extends BaseVariable implements RoomVariable
{
	private var _isPersistent:Bool = false;
	private var _isPrivate:Bool = false;

	public static function fromSFSArray(sfsa:ISFSArray):RoomVariable
	{
		var rv = new SFSRoomVariable(
			sfsa.getShortString(0),
			sfsa.getElementAt(2),
			VariableType.fromId(sfsa.getByte(1))
		);
		rv.setPrivate(sfsa.getBool(3));
		rv.setPersistent(sfsa.getBool(4));
		return rv;
	}

	public function new(name:String, ?val:Dynamic, ?type:VariableType)
	{
		super(name, val, type);
	}

	public function isPersistent():Bool return _isPersistent;
	public function isPrivate():Bool return _isPrivate;
	public function setPrivate(v:Bool):Void _isPrivate = v;
	public function setPersistent(v:Bool):Void _isPersistent = v;

	override public function toSFSArray():ISFSArray
	{
		var arr = super.toSFSArray();
		arr.addBool(_isPrivate);
		arr.addBool(_isPersistent);
		return arr;
	}
}
