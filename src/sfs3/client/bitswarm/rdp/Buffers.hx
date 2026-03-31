package sfs3.client.bitswarm.rdp;

import haxe.io.Bytes;

/**
 * Buffer allocation utilities for RDP layer.
 * In Haxe we use haxe.io.Bytes; the useHeap flag is kept for API compatibility
 * but may not affect behavior on all targets.
 */
class Buffers
{
	public static var useHeap:Bool = true;

	/**
	 * Allocates a byte buffer of the given size.
	 */
	public static function allocate(size:Int):Bytes
	{
		return Bytes.alloc(size);
	}
}
