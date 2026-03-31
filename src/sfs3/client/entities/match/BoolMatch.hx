package sfs3.client.entities.match;

/**
 * The <em>BoolMatch</em> class is used in matching expressions to check boolean conditions.
 *
 * @see MatchExpression
 */
@:expose("SFS3.BoolMatch")
class BoolMatch implements IMatcher
{
	/** Condition: bool1 == bool2 */
	public static final EQUALS:BoolMatch = new BoolMatch("==");
	/** Condition: bool1 != bool2 */
	public static final NOT_EQUALS:BoolMatch = new BoolMatch("!=");

	static inline final TYPE_ID:Int = 0;

	private var symbol:String;

	private function new(symbol:String)
	{
		this.symbol = symbol;
	}

	public function getSymbol():String
		return symbol;

	public function getType():Int
		return TYPE_ID;
}
