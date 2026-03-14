package com.smartfoxserver.v3.requests.mmo;

import com.smartfoxserver.v3.core.SFSEvent;
import com.smartfoxserver.v3.entities.MMOItem;
import com.smartfoxserver.v3.entities.MMORoom;
import com.smartfoxserver.v3.entities.User;
import com.smartfoxserver.v3.requests.CreateRoomRequest;
import com.smartfoxserver.v3.requests.RoomSettings;
import com.smartfoxserver.v3.entities.data.Vec3D;

/**
 * The <em>MMORoomSettings</em> class is a container for the settings required to create an MMORoom using the <em>CreateRoomRequest</em> request.
 * 
 * @see 	CreateRoomRequest
 * @see		MMORoom
 */
@:expose("SFS3.MMORoomSettings")
class MMORoomSettings extends RoomSettings
{
	private var defaultAOI:Vec3D<Any>;
	private var mapLimits:MapLimits;
	private var userMaxLimboSeconds:Int = 50;
	private var proximityListUpdateMillis:Int = 250;
	private var sendAOIEntryPoint:Bool = true;
	
	/**
	 * Creates a new <em>MMORoomSettings</em> instance.
	 * The instance must be passed to the <em>CreateRoomRequest</em> class constructor.
	 * 
	 * @param	name	The name of the MMORoom to be created.
	 * 
	 * @see		CreateRoomRequest
	 */
	public function new(name:String, defaultAOI:Vec3D<Any>)
    {
		super(name);
		this.defaultAOI = defaultAOI;
    }
	
	/**
	 * Defines the Area of Interest (AoI) for the MMORoom.
	 * 
	 * <p>This value represents the area/range around the user that will be affected by server events and other users events.
	 * It is represented by a <em>Vec3D</em> object providing 2D or 3D coordinates.</p>
	 * 
	 * <p>Setting this value is mandatory.</p>
	 * 
	 * <p><b>Example #1:</b> a Vec3D(50,50) describes a range of 50 units (e.g. pixels) in all four directions (top, bottom, left, right) with respect to the user position in a 2D coordinates system.</p>
	 * 
	 * <p><b>Example #2:</b> Vec3D(120,120,60) describes a range of 120 units in all four directions (top, bottom, left, right) and 60 units along the two Z-axis directions (backward, forward) with respect to the user position in a 3D coordinates system.</p>
	 * 
	 * @see com.smartfoxserver.v3.entities.data.Vec3D
	 */
	public function getDefaultAOI():Vec3D<Any>
    {
    	return defaultAOI;
    }
	
	/** @see #getDefaultAOI() */
	public function setDefaultAOI(defaultAOI:Vec3D<Any>):MMORoomSettings
    {
    	this.defaultAOI = defaultAOI;
    	return this;
    }
	
	/**
	 * Defines the limits of the virtual environment represented by the MMORoom.
	 * 
	 * <p>When specified, this property must contain two non-null <em>Vec3D</em> objects representing the minimum and maximum limits of the 2D/3D coordinates systems.
	 * Any positional value that falls outside the provided limit will be refused by the server.</p>
	 * 
	 * <p>This setting is optional but its usage is highly recommended.</p>
	 * 
	 * @see MapLimits
	 */
	public function getMapLimits():MapLimits
    {
    	return mapLimits;
    }
	
	/** @see #getMapLimits() */
	public function setMapLimits(mapLimits:MapLimits):MMORoomSettings
    {
    	this.mapLimits = mapLimits;
    	return this;
    }

	/**
	 * Defines the time limit before a user without a physical position set inside the MMORoom is kicked from the Room.
	 * 
	 * <p>As soon as the MMORoom is joined, the user still doesn't have a physical position set in the coordinates system, therefore it is
	 * considered in a "limbo" state. At this point the user is expected to set his position (via the <em>SetUserPositionRequest</em> request) within the
	 * amount of seconds expressed by this value.</p>
	 * 
	 * <p>Default is 50 seconds</p>
	 */
	public function getUserMaxLimboSeconds():Int
    {
    	return userMaxLimboSeconds;
    }
	
	/** @see #getUserMaxLimboSeconds() */
	public function setUserMaxLimboSeconds(userMaxLimboSeconds:Int):MMORoomSettings
    {
    	this.userMaxLimboSeconds = userMaxLimboSeconds;
    	return this;
    }

	/**
	 * Configures the speed at which the <em>SFSEvent.PROXIMITY_LIST_UPDATE</em> event is sent by the server.
	 * 
	 * <p>In an MMORoom, the regular users list is replaced by a proximity list, which keeps an updated view of the users currently within the Area of Interest 
	 * of the current user. The speed at which these updates are fired by the server is regulated by this parameter, which sets the minimum time between two subsequent updates.</p>
	 * 
	 * <p><b>NOTE:</b> values below the default might be unnecessary for most applications unless they are in realtime.</p>
	 * 
	 * <p>Default: 250 milliseconds</p>
	 * 
	 * @see		com.smartfoxserver.v3.core.SFSEvent#PROXIMITY_LIST_UPDATE
	 */
	public function getProximityListUpdateMillis():Int
    {
    	return proximityListUpdateMillis;
    }
	
	/** @see #getProximityListUpdateMillis() */
	public function setProximityListUpdateMillis(proximityListUpdateMillis:Int):MMORoomSettings
    {
    	this.proximityListUpdateMillis = proximityListUpdateMillis;
    	return this;
    }

	/**
	 * Sets if the users entry points in the current user's Area of Interest should be transmitted in the <em>SFSEvent.PROXIMITY_LIST_UPDATE</em> event.
	 * 
	 * <p>If this setting is set to <code>true</code>, when a user enters the AoI of another user, the server will also send the coordinates
	 * at which the former "appeared" within the AoI. This option should be turned off in case these coordinates are not needed, in order to save bandwidth.</p>
	 * 
	 * <p>Default: true</p>
	 * 
	 * @see com.smartfoxserver.v3.entities.User#getAOIEntryPoint()
	 * @see com.smartfoxserver.v3.entities.MMOItem#getAOIEntryPoint()
	 * @see com.smartfoxserver.v3.core.SFSEvent#PROXIMITY_LIST_UPDATE
	 */
	public function isSendAOIEntryPoint():Bool
    {
    	return sendAOIEntryPoint;
    }

	/** @see #isSendAOIEntryPoint()() */
	public function setSendAOIEntryPoint(sendAOIEntryPoint:Bool):MMORoomSettings
    {
    	this.sendAOIEntryPoint = sendAOIEntryPoint;
    	return this;
    }
}
