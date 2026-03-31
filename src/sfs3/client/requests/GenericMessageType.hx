package sfs3.client.requests;

/**
 * <b>*Private*</b>
 */
@:expose("SFS3.GenericMessageType")
class GenericMessageType 
{
	/**
	 * <b>*Private*</b>
	 */
	public static final PUBLIC_MSG:Int = 0;

	/**
	 * <b>*Private*</b>
	 */
	public static final PRIVATE_MSG:Int = 1;

	/**
	 * <b>*Private*</b>
	 */
	public static final MODERATOR_MSG:Int = 2;

	/**
	 * <b>*Private*</b>
	 */
	public static final ADMIN_MSG:Int = 3;

	/**
	 * <b>*Private*</b>
	 */
	public static final OBJECT_MSG:Int = 4;

	/**
	 * <b>*Private*</b>
	 */
	public static final BUDDY_MSG:Int = 5;

}
