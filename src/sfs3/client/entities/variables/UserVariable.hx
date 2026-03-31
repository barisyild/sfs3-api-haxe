package sfs3.client.entities.variables;

interface UserVariable extends Variable
{
	function isPrivate():Bool;
	function setPrivate(value:Bool):Void;
}
