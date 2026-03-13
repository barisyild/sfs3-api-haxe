package com.smartfoxserver.v3.entities;

/**
 * <b>*Private*</b>
 * Provide information on the Online Status of the Buddy
 */
class BuddyOnlineState 
{
	/**
	 * The Buddy is online
	 */
	public static final ONLINE:Int = 0;

	/**
	 * The Buddy is offline in the Buddy system
	 */
	public static final OFFLINE:Int = 1;

	/**
	 * The Buddy left the server
	 */
	public static final LEFT_THE_SERVER:Int = 2;
}
