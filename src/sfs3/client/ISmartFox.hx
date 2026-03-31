package sfs3.client;

import sfs3.client.core.IEventListener;
import sfs3.client.util.NetDebugLevel;
import sfs3.client.core.ApiEvent;
import sfs3.client.util.LagMonitor;
import hx.concurrent.executor.Executor;
import sfs3.client.entities.managers.IRoomManager;
import sfs3.client.entities.Room;
import sfs3.client.entities.managers.IUserManager;
import sfs3.client.entities.managers.IBuddyManager;
import sfs3.client.entities.data.ISFSObject;
import sfs3.client.entities.User;
import sfs3.client.requests.IClientRequest;
import sfs3.client.bitswarm.BitSwarmClient;

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
