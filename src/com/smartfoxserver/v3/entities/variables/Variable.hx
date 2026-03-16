package com.smartfoxserver.v3.entities.variables;

import com.smartfoxserver.v3.entities.data.ISFSArray;
import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.entities.data.SFSVector2;
import com.smartfoxserver.v3.entities.data.SFSVector3;
import com.smartfoxserver.v3.entities.data.PlatformInt64;

interface Variable
{
	function getName():String;
	function getType():VariableType;
	function getValue():Dynamic;
	function getBoolValue():Bool;
	function getByteValue():Int;
	function getShortValue():Int;
	function getIntValue():Int;
	function getLongValue():PlatformInt64;
	function getFloatValue():Float;
	function getDoubleValue():Float;
	function getStringValue():String;
	function getSFSObjectValue():ISFSObject;
	function getSFSArrayValue():ISFSArray;
	function getSFSVector2Value():SFSVector2;
	function getSFSVector3Value():SFSVector3;
	function isNull():Bool;
	function toSFSArray():ISFSArray;
}
