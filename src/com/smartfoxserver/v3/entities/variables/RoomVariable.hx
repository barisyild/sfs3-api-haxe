package com.smartfoxserver.v3.entities.variables;

interface RoomVariable extends Variable
{
	function isPrivate():Bool;
	function isPersistent():Bool;
	function setPrivate(setPrivate:Bool):Void;
	function setPersistent(persistent:Bool):Void;
}
