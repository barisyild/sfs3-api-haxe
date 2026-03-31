package sfs3.client.requests;

import sfs3.client.ISmartFox;
import sfs3.client.exceptions.SFSValidationException;
import sfs3.client.entities.match.MatchExpression;

/**
 * Retrieves a list of Rooms from the server which match the specified criteria.
 * <p/>
 * <p>By providing a matching expression and a search scope (a Group or the entire Zone), SmartFoxServer can find those Rooms
 * matching the passed criteria and return them by means of the <em>roomFindResult</em> event.</p>
 * <p/>
 * <p/>
 *
 * @see		sfs3.client.entities.match.MatchExpression MatchExpression
 * @see		sfs3.client.core.SFSEvent#ROOM_FIND_RESULT
 */
@:expose("SFS3.FindRoomsRequest")
class FindRoomsRequest extends BaseRequest 
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
	public static final KEY_LIMIT:String = "l";

	/**
	 * @internal
	 */
	public static final KEY_FILTERED_ROOMS:String = "fr";

	private var matchExpr:MatchExpression;
	private var groupId:String;
	private var limit:Int;

	/**
	 * Creates a new <em>FindRoomsRequest</em> instance.
	 * The instance must be passed to the <em>SmartFox.send()</em> method for the request to be performed.
	 *
	 * @param	expr	A matching expression that the system will use to retrieve the Rooms.
	 * @param	groupId	The name of the Group where to search for matching Rooms; if <code>null</code>, the search is performed in the whole Zone.
	 * @param	limit	The maximum size of the list of Rooms that will be returned by the <em>roomFindResult</em> event. If <code>0</code>, all the found Rooms are returned.
	 * 
	 * @see		sfs3.client.SmartFox#send
	 * @see		sfs3.client.core.SFSEvent#ROOM_FIND_RESULT
	 */
	public function new(expr:MatchExpression, ?groupId:String = null, ?limit:Int = 0) 
	{
		super(BaseRequest.FindRooms);

		matchExpr = expr;
		this.groupId = groupId;
		this.limit = limit;
	}

	/**
	 * @internal
	 */
	public function validate(sfs:ISmartFox):Void
	{
		var errors = new Array<String>();

		if (matchExpr == null)
			errors.push("Missing Match Expression");

		if (errors.length > 0)
			throw new SFSValidationException("FindRooms request error", errors);
	}

	/**
	 * @internal
	 */
	public function execute(sfs:ISmartFox):Void
	{
		sfso.putSFSArray(KEY_EXPRESSION, matchExpr.toSFSArray());

		if (groupId != null)
			sfso.putString(KEY_GROUP, groupId);

		if (limit > 0)
			sfso.putShort(KEY_LIMIT, limit);
	}
}
