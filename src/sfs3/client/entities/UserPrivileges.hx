package sfs3.client.entities;

@:expose("SFS3.UserPrivileges")
/**
 * The <em>UserPrivileges</em> class contains the constants describing the
 * default user types known by SmartFoxServer. The server assigns one of these
 * values or a custom-defined one to the <em>User.privilegeId</em> property
 * whenever a user logs in.
 * <p/>
 * <p>
 * Read the SmartFoxServer 3 documentation for more information about privilege
 * profiles and their permissions.
 * </p>
 *
 * @see sfs3.client.entities.User#getPrivilegeId()
 */
class UserPrivileges
{
	/**
	 * The Guest user is usually the lowest level in the privilege profiles scale.
	 */
	public static final GUEST:Int = 0;

	/**
	 * The standard user is usually registered in the application custom login
	 * system; uses a unique name and password to login.
	 */
	public static final STANDARD:Int = 1;

	/**
	 * The moderator user can send dedicated "moderator messages", kick and ban
	 * users.
	 *
	 * @see sfs3.client.requests.ModeratorMessageRequest
	 * @see sfs3.client.requests.KickUserRequest
	 * @see sfs3.client.requests.BanUserRequest
	 */
	public static final MODERATOR:Int = 2;

	/**
	 * The administrator user can send dedicated "administrator messages", kick and
	 * ban users.
	 *
	 * @see sfs3.client.requests.ModeratorMessageRequest
	 * @see sfs3.client.requests.KickUserRequest
	 * @see sfs3.client.requests.BanUserRequest
	 */
	public static final ADMINISTRATOR:Int = 3;
}
