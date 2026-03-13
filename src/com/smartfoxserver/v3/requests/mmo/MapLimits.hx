package com.smartfoxserver.v3.requests.mmo;

import com.smartfoxserver.v3.entities.MMORoom;
import com.smartfoxserver.v3.entities.data.Vec3D;
import haxe.Exception;

/**
 * The class describes the lowest and highest 2D/3D coordinates available inside an MMORoom 
 *
 * @see MMORoomSettings
 * @see com.smartfoxserver.v3.entities.MMORoom
 * @see com.smartfoxserver.v3.entities.data.Vec3D
 */
class MapLimits
{
	private var lowerLimit:Vec3D<Any>;
	private var higherLimit:Vec3D<Any>;
	
	/**
	 * Default constructor
	 * 
	 * @param low	the lower coordinate limit
	 * @param high	the higher coordinate limit
	 */
	public function new(low:Vec3D<Any>, high:Vec3D<Any>)
    {
		if (low != null && high != null)
		{
			this.lowerLimit = low;
			this.higherLimit = high;
		}
		else
			throw new Exception("Map Limits arguments must be both non null!");
    }
	
	/**
	 * Obtain the lower coordinate limit
	 * @return the lowest coordinate possible in the map
	 */
	public function getLowerLimit():Vec3D<Any>
    {
    	return lowerLimit;
    }
	
	/**
	 * Obtain the higher coordinate limit
	 * @return the highest coordinate possible in the map
	 */
	public function getHigherLimit():Vec3D<Any>
    {
    	return higherLimit;
    }
}
