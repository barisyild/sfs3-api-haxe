package sfs3.client.requests;

/**
 * The <em>BanMode</em> class contains the constants describing the possible banning modalities for a <em>BanUserRequest</em>.
 *
 * @see		BanUserRequest
 */
@:expose("SFS3.BanMode")
class BanMode 
{
	/**
	 * User is banned by IP address.
	 */
	public static final BY_ADDRESS:Int = 0;

	/**
	 * User is banned by name.
	 */
	public static final BY_NAME:Int = 1;
}
