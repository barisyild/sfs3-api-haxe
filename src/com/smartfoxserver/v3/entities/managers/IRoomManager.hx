package com.smartfoxserver.v3.entities.managers;

import com.smartfoxserver.v3.entities.data.ISFSArray;

import com.smartfoxserver.v3.entities.Room;
import com.smartfoxserver.v3.entities.User;

/**
 * The <em>IRoomManager</em> interface defines all the methods and properties
 * exposed by the client-side manager of the SmartFoxServer Room entities.
 * <p>
 * In the SmartFoxServer 3 client API this interface is implemented by the
 * <em>SFSRoomManager</em> class. Read the class description for additional
 * informations.
 * </p>
 *
 * @see com.smartfoxserver.v3.entities.managers.SFSRoomManager
 */
interface IRoomManager
{
    /**
	 * @internal
	 */
    public function addRoom(room:Room, addGroupIfMissing:Bool = true):Void;

    /**
	 * @internal
	 */
    public function addGroup(groupId:String):Void;

    /**
	 * @internal
	 */
    public function updateRoomList(roomList:ISFSArray):Void;

    /**
	 * @internal
	 */
    public function removeGroup(groupId:String):Void;

    /**
	 * Indicates whether the specified Group has been subscribed by the client or
	 * not.
	 *
	 * @param groupId The name of the Group.
	 * @return <code>true</code> if the client subscribed the passed Group.
	 */
    public function containsGroup(groupId:String):Bool;

    /**
	 * Indicates whether a Room exists in the Rooms list or not.
	 *
	 * @param id The id of the <em>Room</em> object whose presence in the Rooms list
	 *           is to be tested.
	 * @return <code>true</code> if the passed Room exists in the Rooms list.
	 *
	 * @see sfs3.client.entities.Room#getId()
	 */
    public function containsRoom(id:Dynamic):Bool;

    /**
	 * Indicates whether the Rooms list contains a Room belonging to the specified
	 * Group or not.
	 *
	 * @param roomId  The id of the <em>Room</em> object whose presence in the Rooms
	 *                list is to be tested.
	 * @param groupId The name of the Group to which the specified Room must belong.
	 * @return <code>true</code> if the Rooms list contains the passed Room and it
	 *         belongs to the specified Group.
	 *
	 * @see sfs3.client.entities.Room#getId()
	 * @see sfs3.client.entities.Room#getGroupId()
	 */
    public function containsRoomInGroup(room:Dynamic, groupId:String):Bool;

    /**
	 * @internal
	 */
    public function changeRoomName(room:Room, newName:String):Void;

    /**
	 * @internal
	 */
    public function changeRoomPasswordState(room:Room, isPassProtected:Bool):Void;

    /**
	 * @internal
	 */
    public function changeRoomCapacity(room:Room, maxUsers:Int, maxSpect:Int):Void;

    /**
	 * Retrieves a <em>Room</em> object from its id.
	 *
	 * @param id The id of the Room.
	 * @return An object representing the requested Room; <code>null</code> if no
	 *         <em>Room</em> object with the passed id exists in the Rooms list.
	 *
	 *         <p/>
	 *         <b>Example</b><br/>
	 *         The following example retrieves a <em>Room</em> object and traces its
	 *         name:
	 *
	 *         <pre>
	 *         {@code
	 *         	int roomId = 3;
	 *         	Room room = sfs.getRoomById(roomId);
	 *         	System.out.println("The name of Room " + roomId + " is " + room.getName());
	 *         }
	 *         </pre>
	 *
	 * @see #getRoomByName(String)
	 */
    public function getRoomById(id:Int):Room;

    /**
	 * Retrieves a <em>Room</em> object from its name.
	 *
	 * @param name The name of the Room.
	 * @return An object representing the requested Room; <code>null</code> if no
	 *         <em>Room</em> object with the passed name exists in the Rooms list.
	 *
	 *         <p/>
	 *         <b>Example</b><br/>
	 *         The following example retrieves a <em>Room</em> object and traces its
	 *         id:
	 *
	 *         <pre>
	 *         {@code
	 *         	String roomName = "The Lobby";
	 *         	Room room = sfs.getRoomByName(roomName);
	 *         	System.out.println("The ID of Room '" + roomName + "' is " + room.getId());
	 *         }
	 *         </pre>
	 *
	 * @see #getRoomById(int)
	 */
    public function getRoomByName(name:String):Room;

    /**
	 * Returns a list of Rooms currently "known" by the client. The list contains
	 * all the Rooms that are currently joined and all the Rooms belonging to the
	 * Room Groups that have been subscribed.
	 * <p/>
	 * <p>
	 * <b>NOTE</b>: at login time, the client automatically subscribes all the Room
	 * Groups specified in the Zone's <b>Default Room Groups</b> setting.
	 * </p>
	 *
	 * @return The list of the available <em>Room</em> objects.
	 *
	 * @see sfs3.client.entities.Room
	 * @see sfs3.client.requests.JoinRoomRequest
	 * @see sfs3.client.requests.SubscribeRoomGroupRequest
	 * @see sfs3.client.requests.UnsubscribeRoomGroupRequest
	 */
    public function getRoomList():Array<Room>;

    /**
	 * Returns the current number of Rooms in the Rooms list.
	 *
	 * @return The number of Rooms in the Rooms list.
	 */
    public function getRoomCount():Int;

    /**
	 * Returns the names of Room Groups currently subscribed by the client.
	 * <p/>
	 * <p>
	 * <b>NOTE</b>: at login time, the client automatically subscribes all the Room
	 * Groups specified in the Zone's <b>Default Room Groups</b> setting.
	 * </p>
	 *
	 * @return A list of Room Group names.
	 *
	 * @see sfs3.client.entities.Room#getGroupId()
	 * @see sfs3.client.requests.SubscribeRoomGroupRequest
	 * @see sfs3.client.requests.UnsubscribeRoomGroupRequest
	 */
    public function getRoomGroups():Array<String>;

    /**
	 * Retrieves the list of Rooms which are part of the specified Room Group.
	 *
	 * @param groupId The name of the Group.
	 * @return The list of <em>Room</em> objects belonging to the passed Room Group.
	 *
	 * @see sfs3.client.entities.Room
	 */
    public function getRoomListFromGroup(groupId:String):Array<Room>;

    /**
	 * Returns a list of Rooms currently joined by the client.
	 *
	 * @return The list of <em>Room</em> objects representing the Rooms currently
	 *         joined by the client.
	 *
	 * @see sfs3.client.entities.Room
	 * @see sfs3.client.requests.JoinRoomRequest
	 */
    public function getJoinedRooms():Array<Room>;

    /**
	 * Retrieves a list of Rooms joined by the specified user. The list contains
	 * only those Rooms "known" by the Room Manager; the user might have joined
	 * others the client is not aware of.
	 *
	 * @param user A <em>User</em> object representing the user to look for in the
	 *             current Rooms list.
	 * @return The list of Rooms joined by the passed user.
	 */
    public function getUserRooms(user:User):Array<Room>;

    /**
	 * @internal
	 */
    public function removeRoom(room:Room):Void;

    /**
	 * @internal
	 */
    public function removeRoomById(id:Int):Void;

    /**
	 * @internal
	 */
    public function removeRoomByName(name:String):Void;

    /**
	 * @internal
	 */
    public function removeUser(user:User):Void;

    /**
	 * @internal
	 */
    public function getSmartFox():ISmartFox;
}
