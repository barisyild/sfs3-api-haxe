package com.smartfoxserver.v3.entities.data;

@:expose("SFS3.SFSDataType")
enum abstract SFSDataType(Int) from Int to Int {
	var NULL = 0;
	var BOOL = 1;
	var BYTE = 2;
	var SHORT = 3;
	var INT = 4;
	var LONG = 5;
	var FLOAT = 6;
	var DOUBLE = 7;
	var STRING = 8;
	var BOOL_ARRAY = 9;
	var BYTE_ARRAY = 10;
	var SHORT_ARRAY = 11;
	var INT_ARRAY = 12;
	var LONG_ARRAY = 13;
	var FLOAT_ARRAY = 14;
	var DOUBLE_ARRAY = 15;
	var STRING_ARRAY = 16;
	var SFS_ARRAY = 17;
	var SFS_OBJECT = 18;
	var SHORT_STRING = 19;
	var TEXT = 20;
	var SHORT_STRING_ARRAY = 21;
	var VECTOR2 = 22;
	var VECTOR3 = 23;
	var VECTOR2_ARRAY = 24;
	var VECTOR3_ARRAY = 25;

	// Java'daki getTypeID() yerine doğrudan kendisi Int olarak kullanılabilir
	public inline function getTypeID():Int {
		return this;
	}

	// Java: fromTypeId
	public static function fromTypeId(typeId:Int):SFSDataType {
		if (typeId >= 0 && typeId <= 25) {
			return cast typeId;
		}
		throw 'Unknown typeId for SFSDataType: $typeId';
	}

	public function name():String {
		return switch (this) {
			case 0: "NULL";
			case 1: "BOOL";
			case 2: "BYTE";
			case 3: "SHORT";
			case 4: "INT";
			case 5: "LONG";
			case 6: "FLOAT";
			case 7: "DOUBLE";
			case 8: "STRING";
			case 9: "BOOL_ARRAY";
			case 10: "BYTE_ARRAY";
			case 11: "SHORT_ARRAY";
			case 12: "INT_ARRAY";
			case 13: "LONG_ARRAY";
			case 14: "FLOAT_ARRAY";
			case 15: "DOUBLE_ARRAY";
			case 16: "STRING_ARRAY";
			case 17: "SFS_ARRAY";
			case 18: "SFS_OBJECT";
			case 19: "SHORT_STRING";
			case 20: "TEXT";
			case 21: "SHORT_STRING_ARRAY";
			case 22: "VECTOR2";
			case 23: "VECTOR3";
			case 24: "VECTOR2_ARRAY";
			case 25: "VECTOR3_ARRAY";
			default: throw 'Unknown typeId for SFSDataType: $this';
		}
	}
}
