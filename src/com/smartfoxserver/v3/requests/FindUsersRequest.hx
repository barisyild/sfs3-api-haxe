package com.smartfoxserver.v3.requests;

import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.exceptions.SFSValidationException;
import com.smartfoxserver.v3.entities.Room;
import com.smartfoxserver.v3.entities.match.MatchExpression;

/**
 * Retrieves a list of users from the server which match the specified criteria.
 * <p/>
 * <p>By providing a matching expression and a search scope (a Room, a Group or the entire Zone), SmartFoxServer can find those users
 * matching the passed criteria and return them by means of the <em>userFindResult</em> event.</p>
 * <p/>
 * <p/>
 *
 * @see		com.smartfoxserver.v3.entities.match.MatchExpression
 * @see		com.smartfoxserver.v3.core.SFSEvent#USER_FIND_RESULT
 */
class FindUsersRequest extends BaseRequest 
{
	/**
	 * @internal
	 */
	public static final KEY_EXPRESSION:String = "e";

	/**
	 * @internal
	 */
	public static final KEY_GROUP:String = "g";

	/**
	 * @internal
	 */
	public static final KEY_ROOM:String = "r";

	/**
	 * @internal
	 */
	public static final KEY_LIMIT:String = "l";

	/**
	 * @internal
	 */
	public static final KEY_FILTERED_USERS:String = "fu";

	private var matchExpr:MatchExpression;
	private var target:Dynamic;
	private var limit:Int;

	/**
	 * Creates a new <em>FindUsersRequest</em> instance.
	 * The instance must be passed to the <em>SmartFox.send()</em> method for the request to be performed.
	 *
	 * @param	matchExpr	A matching expression that the system will use to retrieve the users.
	 * @param	target	The name of a Group or a single <em>Room</em> object where to search for matching users; if <code>null</code>, the search is performed in the whole Zone.
	 * @param	limit	The maximum size of the list of users that will be returned by the <em>userFindResult</em> event. If <code>0</code>, all the found users are returned.
	 * 
	 * @see		com.smartfoxserver.v3.SmartFox#send
	 * @see		com.smartfoxserver.v3.entities.Room
	 * @see		com.smartfoxserver.v3.core.SFSEvent#USER_FIND_RESULT
	 */
	public function new(matchExpr:MatchExpression, ?target:Dynamic = null, ?limit:Int = 0) 
	{
		super(BaseRequest.FindUsers);

		this.limit = limit;
		this.target = target;
		this.matchExpr = matchExpr;
	}

	/**
	 * @internal
	 */
	public function validate(sfs:ISmartFox):Void
	{
		var errors = new Array<String>();

		if (matchExpr == null) {
			errors.push("Missing Match Expression");
		}

		if (errors.length > 0) {
			throw new SFSValidationException("FindUsers request error", errors);
		}
	}

	/**
	 * @internal
	 */
	public function execute(sfs:ISmartFox):Void
	{
		sfso.putSFSArray(KEY_EXPRESSION, matchExpr.toSFSArray());

		if (target != null) 
		{
			if (Std.isOfType(target, Room)) 
				sfso.putInt(KEY_ROOM, (cast target:Room).getId());
			
			else if (Std.isOfType(target, String)) 
				sfso.putString(KEY_GROUP, cast target);
		}

		if (limit > 0)
			sfso.putShort(KEY_LIMIT, limit);
	}
}
