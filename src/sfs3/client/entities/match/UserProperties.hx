package sfs3.client.entities.match;
/**
 * The <em>UserProperties</em> class contains the names of predefined properties that can be used in matching expressions to search/filter users.
 *
 * @see		MatchExpression
 * @see		sfs3.client.entities.User User
 */
@:expose("SFS3.UserProperties")
final class UserProperties
{
    /**
	 * The user name.
	 * Requires a <em>StringMatcher</em> to be used for values comparison.
	 */
    public static final NAME:String = "${N}";

    /**
	 * The user is a player in a Game Room.
	 * Requires a <em>BoolMatcher</em> to be used for values comparison.
	 */
    public static final IS_PLAYER:String = "${ISP}";

    /**
	 * The user is a spectator in a Game Room.
	 * Requires a <em>BoolMatcher</em> to be used for values comparison.
	 */
    public static final IS_SPECTATOR:String = "${ISS}";

    /**
	 * The user is a Non-Player Character (NPC).
	 * Requires a <em>BoolMatcher</em> to be used for values comparison.
	 */
    public static final IS_NPC:String = "${ISN}";
    /**
	 * The user privilege id.
	 * Requires a <em>NumberMatcher</em> to be used for values comparison.
	 */
    public static final PRIVILEGE_ID:String = "${PRID}";

    /**
	 * The user joined at least one room.
	 * Requires a <em>BoolMatcher</em> to be used for values comparison.
	 */
    public static final IS_IN_ANY_ROOM:String = "${IAR}";

    private function new() { }
}
