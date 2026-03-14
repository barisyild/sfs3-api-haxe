package com.smartfoxserver.v3.requests.game;

import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.exceptions.SFSValidationException;
import com.smartfoxserver.v3.entities.Room;
import com.smartfoxserver.v3.entities.match.MatchExpression;
import com.smartfoxserver.v3.requests.BaseRequest;

/**
 * Quickly joins the current user in a public game.
 * <p/>
 * <p>
 * By providing a matching expression and a list of Rooms or Groups,
 * SmartFoxServer can search for a matching public Game Room and immediately
 * join the user into that Room as a player.
 * </p>
 * <p/>
 * <p>
 * If a game could be found and joined, the <em>roomJoin</em> event is
 * dispatched to the requester's client.
 * </p>
 *
 * @see com.smartfoxserver.v3.core.SFSEvent#ROOM_JOIN
 * @see com.smartfoxserver.v3.entities.match.MatchExpression
 * @see com.smartfoxserver.v3.requests.JoinRoomRequest
 */

@:expose("SFS3.QuickJoinGameRequest")
class QuickJoinGameRequest extends BaseRequest
{
	private static final MAX_ROOMS:Int = 32;

	/**
	 * @internal
	 */
	public static final KEY_ROOM_LIST:String = "rl";

	/**
	 * @internal
	 */
	public static final KEY_GROUP_LIST:String = "gl";

	/**
	 * @internal
	 */
	public static final KEY_ROOM_TO_LEAVE:String = "tl";

	/**
	 * @internal
	 */
	public static final KEY_MATCH_EXPRESSION:String = "me";

	private var whereToSearch:Array<Dynamic>;
	private var matchExpression:MatchExpression;
	private var roomToLeave:Room;

	/**
	 * Creates a new <em>QuickJoinGameRequest</em> instance. The instance must be
	 * passed to the <em>SmartFox.send()</em> method for the request to be
	 * performed.
	 *
	 * @param matchExpression A matching expression that the system will use to
	 *                        search a Game Room where to join the current user.
	 * @param whereToSearch   An array of <em>Room</em> objects or an array of Group
	 *                        names to which the matching expression should be
	 *                        applied. The maximum number of elements that this
	 *                        array can contain is 32.
	 * @param roomToLeave     A <em>Room</em> object representing the Room that the
	 *                        user should leave when joining the game.
	 * 
	 * @see com.smartfoxserver.v3.SmartFox#send
	 * @see com.smartfoxserver.v3.entities.Room
	 */
	public function new(matchExpression:MatchExpression, whereToSearch:Array<Dynamic>, ?roomToLeave:Room = null)
	{
		super(BaseRequest.QuickJoinGame);

		this.matchExpression = matchExpression;
		this.roomToLeave = roomToLeave;

		this.whereToSearch = whereToSearch;
	}

	/**
	 * @internal
	 */
	public function validate(sfs:ISmartFox):Void
	{
		var errors = new Array<String>();

		// NOTE: match expression can be null, in which case the first Room found is
		// going to be good
		if (whereToSearch == null || whereToSearch.length == 0)
			errors.push("Missing whereToSearch parameter");

		else if (whereToSearch.length > MAX_ROOMS)
			errors.push("Too many Rooms specified in the whereToSearch parameter. Client limit is: " + MAX_ROOMS);

		if (errors.length > 0)
			throw new SFSValidationException("QuickJoinGame request error", errors);
	}

	/**
	 * @internal
	 */
	public function execute(sfs:ISmartFox):Void
	{
		// Auto detect whereToSearch types --->> String, GroupId
		if (Std.isOfType(whereToSearch[0], Room))
		{
			var roomIds = new Array<Int>();

			// --->> Room
			for (room in whereToSearch)
			{
				roomIds.push(cast(room, Room).getId());
			}

			sfso.putIntArray(KEY_ROOM_LIST, roomIds);
		}
		
		else
		{
            var groupList = new Array<String>();
            for(item in whereToSearch) {
                groupList.push(Std.string(item));
            }
			sfso.putStringArray(KEY_GROUP_LIST, groupList);
        }

		if (roomToLeave != null)
			sfso.putInt(KEY_ROOM_TO_LEAVE, roomToLeave.getId());

		if (matchExpression != null)
			sfso.putSFSArray(KEY_MATCH_EXPRESSION, matchExpression.toSFSArray());
	}
}
