package com.smartfoxserver.v3.entities;

import com.smartfoxserver.v3.entities.data.Vec3D;
import hx.concurrent.collection.SynchronizedMap;

/**
 * The <em>MMORoom</em> object represents a specialized type of Room entity on the client.
 * 
 * <p>The MMORoom is ideal for huge virtual worlds and MMO games because it works with proximity lists instead of "regular" users lists.
 * This allows thousands of users to interact with each other based on their Area of Interest (AoI). The AoI represents a range around the user
 * that is affected by server and user events, outside which no other events are received.</p>
 * 
 * <p>The size of the AoI is set at Room creation time and it is the same for all users who joined it.
 * Supposing that the MMORoom hosts a 3D virtual world, setting an AoI of (x=100, y=100, z=40) for the Room tells the server to transmit updates and broadcast
 * events to and from those users that fall within the AoI range around the current user; this means the area within +/- 100 units on the X axis, +/- 100 units on the Y axis
 * and +/- 40 units on the Z axis.</p>
 * 
 * <p>As the user moves around in the virtual environment, he can update his position in the corresponding MMORoom and thus continuously receive events
 * about other users (and items - see below) entering and leaving his AoI.
 * The player will be able to update his position via the <em>SetUserPositionRequest</em> request and receive updates on his current proximity list by means of the
 * <em>SFSEvent.PROXIMITY_LIST_UPDATE</em> event.</p>
 * 
 * <p>Finally, MMORooms can also host any number of "MMOItems" which represent dynamic non-player objects that users can interact with.
 * They are handled by the MMORoom using the same rules of visibility described before.</p>
 * 
 * @see com.smartfoxserver.v3.requests.CreateRoomRequest
 * @see com.smartfoxserver.v3.requests.mmo.MMORoomSettings
 * @see com.smartfoxserver.v3.requests.SetUserVariablesRequest
 * @see com.smartfoxserver.v3.core.SFSEvent#PROXIMITY_LIST_UPDATE
 * @see MMOItem
 */ 
class MMORoom extends SFSRoom
{
	private var defaultAOI:Vec3D<Any>;
	private var lowerMapLimit:Vec3D<Any>;
	private var higherMapLimit:Vec3D<Any>;
	private var itemsById:SynchronizedMap<Int, IMMOItem> = SynchronizedMap.newIntMap();
	
	/**
	 * Creates a new <em>MMORoom</em> instance.
	 * <p/>
	 * <p><b>NOTE</b>: developers never instantiate a <em>SFSRoom</em> manually: this is done by the SmartFoxServer 3 API internally.</p>
	 *
	 * @param id      The Room id.
	 * @param name    The Room name.
	 * @param groupId The id of the Group to which the Room belongs.
	 */
	public function new(id:Int, name:String, ?groupId:String = "default")
    {
		super(id, name, groupId);
    }
	
	/**
	 * Returns the default Area of Interest (AoI) of this MMORoom.
	 * @return the default Area of Interest (AoI) of this MMORoom.
	 * 
	 * @see	com.smartfoxserver.v3.requests.mmo.MMORoomSettings#setDefaultAOI()
	 */
	public function getDefaultAOI():Vec3D<Any>
    {
	    return defaultAOI;
    }
	
	/**
	 * Returns the lower coordinates limit of the virtual environment represented by the MMORoom along the X,Y,Z axes.
	 * If <b>null</b> is returned, no limits were set at Room creation time.
	 * 
	 * @return the lower map coordinates limit
	 * 
	 * @see	com.smartfoxserver.v3.requests.mmo.MMORoomSettings#setMapLimits()
	 */
	public function getLowerMapLimit():Vec3D<Any>
    {
	    return lowerMapLimit;
    }
	
	/**
	 * Returns the higher coordinates limit of the virtual environment represented by the MMORoom along the X,Y,Z axes.
	 * If <b>null</b> is returned, no limits were set at Room creation time.
	 * 
	 * @return the higher map coordinates limit
	 * @see	com.smartfoxserver.v3.requests.mmo.MMORoomSettings#setMapLimits()
	 */
	public function getHigherMapLimit():Vec3D<Any>
    {
	    return higherMapLimit;
    }
	
	/** <b>API internal usage only</b> */
	public function setDefaultAOI(defaultAOI:Vec3D<Any>):Void
    {
		if (this.defaultAOI != null)
			throw new haxe.Exception("This value is read-only");
		
	    this.defaultAOI = defaultAOI;
    }
	
	/** <b>API internal usage only</b> */
	public function setLowerMapLimit(lowerMapLimit:Vec3D<Any>):Void
    {
		if (this.lowerMapLimit != null)
			throw new haxe.Exception("This value is read-only");
		
	    this.lowerMapLimit = lowerMapLimit;
    }
	
	/** <b>API internal usage only</b> */
	public function setHigherMapLimit(higherMapLimit:Vec3D<Any>):Void
    {
		if (this.higherMapLimit != null)
			throw new haxe.Exception("This value is read-only");
		
	    this.higherMapLimit = higherMapLimit;
    }
	
	/**
	 * Retrieves an <em>MMOItem</em> object from its <em>id</em> property.
	 * The item is available to the current user if it falls within his Area of Interest only.
	 * 
	 * @param	id	The id of the item to be retrieved.
	 * 
	 * @return	An <em>MMOItem</em> object, or <b>null</b> if the item with the passed id is not in proximity of the current user.
	 * 
	 * @see MMOItem
	 */ 
	public function getMMOItem(id:Int):IMMOItem
	{
		return itemsById.get(id);
	}

	/**
	 * Retrieves all <em>MMOItem</em> object in the MMORoom that fall within the current user's Area of Interest. 
	 * 
	 * @return	A list of <em>MMOItem</em> objects, or an empty list if no item is in proximity of the current user.
	 * 
	 * @see	MMOItem
	 */
	public function getMMOItems():Array<IMMOItem>
	{
		var items = new Array<IMMOItem>();
		
		for (item in itemsById) {
            items.push(item);
        }
		
		return items;
	}
	
	// ::: PRIVATE, Internal Only :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

	/** <b>API internal usage only</b> */
	public function addMMOItem(item:IMMOItem):Void
	{
		itemsById.set(item.getId(), item);
	}
	
	/** <b>API internal usage only</b> */
	public function removeItem(id:Int):Void
	{
		itemsById.remove(id);
	}
}
