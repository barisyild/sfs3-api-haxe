package sfs3.client.entities.variables;

import sfs3.client.entities.data.ISFSArray;
import sfs3.client.entities.data.ISFSObject;
import sfs3.client.entities.data.SFSVector2;
import sfs3.client.entities.data.SFSVector3;
import sfs3.client.entities.data.PlatformInt64;

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
