package sfs3.client.entities.data;


import sfs3.client.entities.data.ISFSArray;
import sfs3.client.entities.data.SFSDataType;
import sfs3.client.entities.data.SFSDataWrapper;

import sfs3.client.exceptions.IllegalArgumentException;

/**
 * A vector 3D class used for defining coordinates in the MMORoom virtual world. The class supports either Integers or Floats.
 * <p>
 * It provides constructors for 2D and 3D coordinates systems. (In 2D values Z == 0)
 *
 * @see MMORoom
 * @see MMORoomSettings
 */
abstract class Vec3D<T>
{
    private final px:T;
    private final py:T;
    private final pz:T;
    private var useFloat:Bool;

    @SuppressWarnings("unchecked")
    public static function fromArray(element:SFSDataWrapper):Vec3D<Any>
    {
        var typeId:SFSDataType = element.getTypeId();

        /*
		 * This is only for JSON protocol.
		 *
		 * While we don't support JSON encoding/decoding in the API we need it for the WebSocket
		 * portion of BitSmasher.
		 */
        if (typeId == SFSDataType.SFS_ARRAY)
        {
            var tempArr:ISFSArray = cast(element.getObject(), ISFSArray);

            // Determine element type
            var itemType:SFSDataType = tempArr.get(0).getTypeId();

            if (itemType == SFSDataType.INT)
                return new Vec3DInt(tempArr.getInt(0), tempArr.getInt(1), tempArr.getInt(2));

            else
                return new Vec3DFloat(tempArr.getFloat(0), tempArr.getFloat(1), tempArr.getFloat(2));
        }
        // ---------------------------------------------------------------------------------------

        if (typeId == SFSDataType.INT_ARRAY)
            return fromIntArray(cast element.getObject());

        else if (typeId == SFSDataType.FLOAT_ARRAY)
            return fromFloatArray(cast element.getObject());

        else throw new IllegalArgumentException("Invalid Array Type, cannot convert to Vec3D!");
    }

    /** private */
    private static function fromIntArray(array:Array<Int>):Vec3D<Int>
    {
        if (array.length != 3)
            throw new IllegalArgumentException("Wrong array size. Vec3D requires an array with 3 parameters (x,y,z)");

        return new Vec3DInt(array[0], array[1], array[2]);
    }

    /** private */
    private static function fromFloatArray(array:Array<Float>):Vec3D<Float>
    {
        if (array.length != 3)
            throw new IllegalArgumentException("Wrong array size. Vec3D requires an array with 3 parameters (x,y,z)");

        return new Vec3DFloat(array[0], array[1], array[2]);
    }

    /**
	 * Constructor for integer-based 3D coordinates
	 */
    public function new(ix:T, iy:T, iz:T)
    {
        px = ix; py = iy; pz = iz;
    }

    /**
	 * Detect whether this object uses floating point numbers or integers
	 * @return true if it uses floating point numbers
	 */
    public function isFloat():Bool
    {
        return useFloat;
    }

    /**
	 * Get the X coordinate as float
	 */
    public function floatX():Float
    {
        return cast px;
    }

    /**
	 * Get the Y coordinate as float
	 */
    public function floatY():Float
    {
        return cast py;
    }

    /**
	 * Get the Z coordinate as float
	 */
    public function floatZ():Float
    {
        return cast pz;
    }

    /**
	 * Get the X coordinate as integer
	 */
    public function intX():Int
    {
        return cast px;
    }

    /**
	 * Get the Y coordinate as integer
	 */
    public function intY():Int
    {
        return cast py;
    }

    /**
	 * Get the Z coordinate as integer
	 */
    public function intZ():Int
    {
        return cast pz;
    }

    public function toString():String
    {
        return '($px, $py, $pz)';
    }

    /** private */
    public function toIntArray():Array<Int>
    {
        return [intX(), intY(), intZ()];
    }

    /** private */
    public function toFloatArray():Array<Float>
    {
        return [floatX(), floatY(), floatZ()];
    }
}