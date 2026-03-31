package sfs3.client.entities.managers;

import sfs3.client.ISmartFox;
import sfs3.client.entities.data.ISFSArray;
import sfs3.client.entities.MMORoom;
import sfs3.client.entities.Room;
import sfs3.client.entities.SFSRoom;
import sfs3.client.entities.User;
import sfs3.client.exceptions.SFSException;
import hx.concurrent.collection.SynchronizedMap;
import hx.concurrent.lock.RLock;

/**
 * The <em>SFSRoomManager</em> class is the entity in charge of managing the client-side Rooms list.
 *
 * @see sfs3.client.SmartFox#getRoomManager
 */
class SFSRoomManager implements IRoomManager
{
	private var groups:SynchronizedMap<String, Bool>; // Set<String> semantics
	private var roomsById:SynchronizedMap<Int, Room>;
	private var roomsByName:SynchronizedMap<String, Room>;
	private var globalLock:RLock;
	public var smartFox:ISmartFox;

	public function new(smartFox:ISmartFox)
	{
		this.smartFox = smartFox;
		groups = SynchronizedMap.newStringMap();
		roomsById = SynchronizedMap.newIntMap();
		roomsByName = SynchronizedMap.newStringMap();
		globalLock = new RLock();
	}

	public function addRoom(room:Room, addGroupIfMissing:Bool = true):Void
	{
		globalLock.execute(() -> {
			roomsById.set(room.getId(), room);
			roomsByName.set(room.getName(), room);
			if (addGroupIfMissing)
				addGroup(room.getGroupId());
			else
				room.setManaged(false);
		});
	}

	public function addGroup(groupId:String):Void
	{
		groups.set(groupId, true);
	}

	public function updateRoomList(roomList:ISFSArray):Void
	{
		for (j in 0...roomList.size())
		{
			var roomObj:ISFSArray = roomList.getSFSArray(j);
			var newRoom:Room = SFSRoom.fromSFSArray(roomObj);
			addRoom(newRoom, true);
		}
	}

	public function removeGroup(groupId:String):Void
	{
		groups.remove(groupId);
		var roomsInGroup = getRoomListFromGroup(groupId);
		for (room in roomsInGroup)
		{
			if (!room.getJoined())
				removeRoom(room);
			else
				room.setManaged(false);
		}
	}

	public function containsGroup(groupId:String):Bool
	{
		return groups.exists(groupId);
	}

	public function containsRoom(id:Dynamic):Bool
	{
		return globalLock.execute(() -> {
			if (Std.isOfType(id, Int))
				return roomsById.exists(cast id);
			else if (Std.isOfType(id, String))
				return roomsByName.exists(cast id);
			return false;
		});
	}

	public function containsRoomInGroup(room:Dynamic, groupId:String):Bool
	{
		var roomList = getRoomListFromGroup(groupId);
		if (Std.isOfType(room, Int))
		{
			for (r in roomList) if (r.getId() == cast room) return true;
		}
		else if (Std.isOfType(room, String))
		{
			for (r in roomList) if (r.getName() == cast room) return true;
		}
		return false;
	}

	public function changeRoomName(room:Room, newName:String):Void
	{
		globalLock.execute(() -> {
			var oldName = room.getName();
			room.setName(newName);
			roomsByName.set(newName, room);
			roomsByName.remove(oldName);
		});
	}

	public function changeRoomPasswordState(room:Room, isPassProtected:Bool):Void
	{
		room.setPasswordProtected(isPassProtected);
	}

	public function changeRoomCapacity(room:Room, maxUsers:Int, maxSpect:Int):Void
	{
		room.setMaxUsers(maxUsers);
		room.setMaxSpectators(maxSpect);
	}

	public function getRoomById(id:Int):Room
	{
		return globalLock.execute(() -> roomsById.exists(id) ? roomsById.get(id) : null);
	}

	public function getRoomByName(name:String):Room
	{
		return globalLock.execute(() -> roomsByName.exists(name) ? roomsByName.get(name) : null);
	}

	public function getRoomList():Array<Room>
	{
		return globalLock.execute(() -> {
			var list = new Array<Room>();
			for (r in roomsById) list.push(r);
			return list;
		});
	}

	public function getRoomCount():Int
	{
		return globalLock.execute(() -> {
			var len = 0;
			for (_ in roomsById) len++;
			return len;
		});
	}

	public function getRoomGroups():Array<String>
	{
		var list = new Array<String>();
		for (k in groups.keys()) list.push(k);
		return list;
	}

	public function getRoomListFromGroup(groupId:String):Array<Room>
	{
		return globalLock.execute(() -> {
			var roomList = new Array<Room>();
			for (room in roomsById)
			{
				if (room.getGroupId() == groupId)
					roomList.push(room);
			}
			return roomList;
		});
	}

	public function getJoinedRooms():Array<Room>
	{
		return globalLock.execute(() -> {
			var rooms = new Array<Room>();
			for (room in roomsById)
			{
				if (room.getJoined())
					rooms.push(room);
			}
			return rooms;
		});
	}

	public function getUserRooms(user:User):Array<Room>
	{
		return globalLock.execute(() -> {
			var rooms = new Array<Room>();
			for (room in roomsById)
			{
				if (room.containsUser(user))
					rooms.push(room);
			}
			return rooms;
		});
	}

	public function removeRoom(room:Room):Void
	{
		removeRoomById(room.getId());
	}

	public function removeRoomById(id:Int):Void
	{
		globalLock.execute(() -> {
			if (!roomsById.exists(id)) return;
			var room = roomsById.get(id);
			roomsById.remove(id);
			roomsByName.remove(room.getName());
		});
	}

	public function removeRoomByName(name:String):Void
	{
		globalLock.execute(() -> {
			if (!roomsByName.exists(name)) return;
			var room = roomsByName.get(name);
			roomsById.remove(room.getId());
			roomsByName.remove(name);
		});
	}

	public function removeUser(user:User):Void
	{
		globalLock.execute(() -> {
			for (room in roomsById)
			{
				if (Std.isOfType(room, MMORoom))
					continue;
				if (room.containsUser(user))
					room.removeUser(user);
			}
		});
	}

	public function getSmartFox():ISmartFox
	{
		return smartFox;
	}
}
