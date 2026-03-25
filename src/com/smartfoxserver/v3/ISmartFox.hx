package com.smartfoxserver.v3;

import com.smartfoxserver.v3.core.IEventListener;
import com.smartfoxserver.v3.util.NetDebugLevel;
import com.smartfoxserver.v3.core.ApiEvent;
import com.smartfoxserver.v3.util.LagMonitor;
import hx.concurrent.executor.Executor;
import com.smartfoxserver.v3.entities.managers.IRoomManager;
import com.smartfoxserver.v3.entities.Room;
import com.smartfoxserver.v3.entities.managers.IUserManager;
import com.smartfoxserver.v3.entities.managers.IBuddyManager;
import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.entities.User;
import com.smartfoxserver.v3.requests.IClientRequest;
import com.smartfoxserver.v3.bitswarm.BitSwarmClient;

interface ISmartFox {
	public function getVersion():String;

	public function getExecutor():Executor;
	public function setExecutor(service:Executor):Void;
	public function getScheduler():Executor;

	public function addEventListener<T:ApiEvent>(eventType:String, listener:IEventListener<T>):Void;
	public function removeEventListener<T:ApiEvent>(eventType:String, listener:IEventListener<T>):Void;
	public function removeAllEventListeners():Void;

	public function getLastJoinedRoom():Room;
	public function getNetDebugLevel():NetDebugLevel;

	public function getRoomManager():IRoomManager;
	public function getUserManager():IUserManager;
	public function getBuddyManager():IBuddyManager;

	public function dispatchEvent(event:ApiEvent):Void;
	public function handleHandShake(sobj:ISFSObject):Void;
	public function handleLogout():Void;

	public function setJoining(value:Bool):Void;
	public function setLastJoinedRoom(room:Room):Void;

	public function connect(cfgData:ConfigData):Void;

	public function disconnect():Void;
	public function killConnection():Void;

	public function connectUdp():Void;
	public function disconnectUdp():Void;

	public function setMySelf(u:User):Void;
	public function getMySelf():User;
	public function setReconnectionSeconds(sec:Int):Void;
	public function setClientDetails(platformId:String, version:String):Void;

	public function getLagMonitor():LagMonitor;
	public function getJoinedRooms():Array<Room>;
	public function getConfig():ConfigData;
	public function getSessionToken():String;
	public function getConnectionMode():String;

	public function isConnected():Bool;
	public function isUdpConnected():Bool;

	public function send(req:IClientRequest):Void;
	public function getBitSwarm():BitSwarmClient;

	public function getNodeId():String;
	public function setNodeId(value:String):Void;
}
