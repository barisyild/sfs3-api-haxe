package com.smartfoxserver.v3.entities.variables;

import com.smartfoxserver.v3.entities.data.ISFSArray;
import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.entities.data.SFSArray;
import com.smartfoxserver.v3.entities.data.SFSVector2;
import com.smartfoxserver.v3.entities.data.SFSVector3;
import haxe.Int64;
import haxe.Exception;
import com.smartfoxserver.v3.entities.data.PlatformInt64;
import com.smartfoxserver.v3.entities.variables.VariableType;

class BaseVariable implements Variable
{
	private var name:String;
	private var type:VariableType;
	private var val:Dynamic;

	public function new(name:String, value:Null<Dynamic>, type:Null<VariableType>)
	{
		if(type == null)
			type = VariableType.NULL;

		this.name = name;
		this.val = value;
		this.type = type;

		if(value == null && type != VariableType.NULL)
			throw new Exception("");
		else if(value != null && type == VariableType.NULL)
		{
			// TODO: Handle types automatically.
			if(value is String)
				value = VariableType.STRING;
			else if(value is Bool)
				value = VariableType.BOOL;
			else if(value is Float)
				value = VariableType.FLOAT;
			else if(value is Int)
				value = VariableType.INT;
			else throw "Undefined Variable Type.";
		}
	}

	public function getName():String return name;
	public function getType():VariableType return type;
	public function getValue():Dynamic return val;

	public function getBoolValue():Bool return cast val;
	public function getByteValue():Int return cast val;
	public function getShortValue():Int return cast val;
	public function getIntValue():Int return cast val;
	public function getLongValue():PlatformInt64 return cast val;
	public function getFloatValue():Float return cast val;
	public function getDoubleValue():Float return cast val;
	public function getStringValue():String return cast val;
	public function getSFSObjectValue():ISFSObject return cast val;
	public function getSFSArrayValue():ISFSArray return cast val;
	public function getSFSVector2Value():SFSVector2 return cast val;
	public function getSFSVector3Value():SFSVector3 return cast val;

	public function isNull():Bool return type == VariableType.NULL;

	public function toSFSArray():ISFSArray
	{
		var sfsa = new SFSArray();
		sfsa.addShortString(name);
		sfsa.addByte(type.getId());
		populateArrayWithValue(sfsa);
		return sfsa;
	}

	private function populateArrayWithValue(arr:ISFSArray):Void
	{
		switch (type)
		{
			case NULL: arr.addNull();
			case BOOL: arr.addBool(getBoolValue());
			case BYTE: arr.addByte(getByteValue());
			case SHORT: arr.addShort(getShortValue());
			case INT: arr.addInt(getIntValue());
			case LONG: arr.addLong(getLongValue());
			case FLOAT: arr.addFloat(getFloatValue());
			case DOUBLE: arr.addDouble(getDoubleValue());
			case STRING: arr.addShortString(getStringValue());
			case OBJECT: arr.addSFSObject(getSFSObjectValue());
			case ARRAY: arr.addSFSArray(getSFSArrayValue());
			case VECTOR3: arr.addVector3(getSFSVector3Value());
			case VECTOR2: arr.addVector2(getSFSVector2Value());
			default: throw "Unsupported Variable type: " + type;
		}
	}

	public function toString():String return '[Var] ${type} $name: $val';
}
