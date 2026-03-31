package sfs3.client.requests;

import sfs3.client.ISmartFox;
import sfs3.client.exceptions.SFSValidationException;

/**
 * Kicks a user out of the server.
 * <p/>
 * <p>The current user must have administration or moderation privileges in order to be able to kick another user (see the <em>User.privilegeId</em> property).
 * The request allows sending a message to the kicked user (to make clear the reason of the following disconnection) which is delivered by means of the <em>moderatorMessage</em> event.</p>
 * <p/>
 * <p>Differently from the user being banned (see the <em>BanUserRequest</em> request), a kicked user will be able to reconnect to the SmartFoxServer instance immediately.</p>
 * <p/>
 * <p/>
 *
 * @see		sfs3.client.core.SFSEvent#MODERATOR_MESSAGE
 * @see		sfs3.client.entities.User#getPrivilegeId()
 * @see		BanUserRequest
 */
@:expose("SFS3.KickUserRequest")
class KickUserRequest extends BaseRequest 
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

	private var userId:Int;
	private var message:String;
	private var delay:Int;


	/**
	 * Creates a new <em>KickUserRequest</em> instance.
	 * The instance must be passed to the <em>SmartFox.send()</em> method for the request to be performed.
	 *
	 * @param	userId			The id of the user to be kicked.
	 * @param	message			A custom message to be delivered to the user before kicking him;
	 * 							if <code>null</code>, the default message configured in the SmartFoxServer 3 Administration Tool is used.
	 * @param	delaySeconds	The number of seconds after which the user is kicked after receiving the kick message.
	 * 
	 * @see		sfs3.client.SmartFox#send
	 */
	public function new(userId:Int, ?message:String = null, ?delaySeconds:Int = 5) 
	{
		super(BaseRequest.KickUser);

		this.userId = userId;
		this.message = message;
		this.delay = delaySeconds;

		// avoid negatives
		if (delay < 0) 
			delay = 0;
	}

	/**
	 * @internal
	 */
	public function validate(sfs:ISmartFox):Void
	{
//		var errors = new Array<String>(); 
//
//		if (errors.length > 0) 
//			throw new SFSValidationException("KickUser request error", errors);
	}

	/**
	 * @internal
	 */
	public function execute(sfs:ISmartFox):Void {
		sfso.putInt(KEY_USER_ID, userId);
		sfso.putInt(KEY_DELAY, delay);

		if (message != null && message.length > 0) 
			sfso.putString(KEY_MESSAGE, message);
	}
}
