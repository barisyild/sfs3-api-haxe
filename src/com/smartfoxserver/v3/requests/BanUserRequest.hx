package com.smartfoxserver.v3.requests;

import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.exceptions.SFSValidationException;

/**
 * Banishes a user from the server.
 * <p/>
 * <p>
 * The current user must have administration or moderation privileges in order
 * to be able to ban another user (see the <em>User.privilegeId</em> property).
 * The user can be banned by name or by IP address (see the <em>BanMode</em>
 * class). Also, the request allows sending a message to the banned user (to
 * make clear the reason of the following disconnection) which is delivered by
 * means of the <em>moderatorMessage</em> event.
 * </p>
 * <p/>
 * <p>
 * Differently from the user being kicked (see the <em>KickUserRequest</em>
 * request), a banned user won't be able to connect to the SmartFoxServer
 * instance until the banishment expires (after 24 hours for client-side
 * banning) or an administrator removes his name/IP address from the list of
 * banned users by means of the SmartFoxServer 3 Administration Tool.
 * </p>
 * <p/>
 * <p/>
 *
 * @see com.smartfoxserver.v3.core.SFSEvent#MODERATOR_MESSAGE
 * @see com.smartfoxserver.v3.entities.User#getPrivilegeId()
 * @see BanMode
 * @see KickUserRequest
 */
@:expose("SFS3.BanUserRequest")
class BanUserRequest extends BaseRequest
{
	/**
	 * @internal
	 */
	public static final KEY_USER_ID:String = "u";

	/**
	 * @internal
	 */
	public static final KEY_MESSAGE:String = "m";

	/**
	 * @internal
	 */
	public static final KEY_DELAY:String = "d";

	/**
	 * @internal
	 */
	public static final KEY_BAN_MODE:String = "b";

	/**
	 * @internal
	 */
	public static final KEY_BAN_DURATION_HOURS:String = "dh";

	private var userId:Int;
	private var message:String;
	private var delay:Int;
	private var banMode:Int;
	private var durationHours:Int;

	/**
	 * Creates a new <em>BanUserRequest</em> instance. The instance must be passed
	 * to the <em>SmartFox.send()</em> method for the request to be performed.
	 *
	 * @param userId        The id of the user to be banned.
	 * @param message       A custom message to be delivered to the user before
	 *                      banning him; if <code>null</code>, the default message
	 *                      configured in the SmartFoxServer 3 Administration Tool
	 *                      is used.
	 * @param banMode       One of the ban modes defined in the <em>BanMode</em>
	 *                      class.
	 * @param delaySeconds  The number of seconds after which the user is banned
	 *                      after receiving the ban message.
	 * @param durationHours The duration of the banishment, expressed in hours.
	 * 
	 * @see com.smartfoxserver.v3.SmartFox#send
	 * @see BanMode
	 */
	public function new(userId:Int, ?message:String = null, ?banMode:Int = 1, ?delaySeconds:Int = 5, ?durationHours:Int = 0)
	{
		super(BaseRequest.BanUser);

		this.userId = userId;
		this.message = message;
		this.banMode = banMode;
		this.delay = delaySeconds;
		this.durationHours = durationHours;
	}

	/**
	 * @internal
	 */
	public function validate(sfs:ISmartFox):Void
	{
		var errors = new Array<String>();
		
		if (delay < 0)
			errors.push("Ban delay value must be positive");
		
		if (durationHours < 1)
			errors.push("Ban duration value must be > 0");
		
		if (errors.length > 0)
			throw new SFSValidationException("BanUser request error", errors);
	}

	/**
	 * @internal
	 */
	public function execute(sfs:ISmartFox):Void
	{
		sfso.putInt(KEY_USER_ID, userId);
		sfso.putInt(KEY_DELAY, delay);
		sfso.putInt(KEY_BAN_MODE, banMode);
		sfso.putInt(KEY_BAN_DURATION_HOURS, durationHours);

		if (message != null && message.length > 0)
			sfso.putString(KEY_MESSAGE, message);
	}
}
