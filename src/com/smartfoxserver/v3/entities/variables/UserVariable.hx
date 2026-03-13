package com.smartfoxserver.v3.entities.variables;

interface UserVariable extends Variable
{
	function isPrivate():Bool;
	function setPrivate(value:Bool):Void;
}
