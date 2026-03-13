package com.smartfoxserver.v3.entities.match;

/**
 * The <em>StringMatch</em> class is used in matching expressions to check string conditions.
 *
 * @see MatchExpression
 */
class StringMatch implements IMatcher
{
	/** Condition: string1 == string2 */
	public static final EQUALS:StringMatch = new StringMatch("==");
	/** Condition: string1 != string2 */
	public static final NOT_EQUALS:StringMatch = new StringMatch("!=");
	/** Condition: string1.indexOf(string2) != -1 */
	public static final CONTAINS:StringMatch = new StringMatch("contains");
	/** Condition: string1 starts with string2 */
	public static final STARTS_WITH:StringMatch = new StringMatch("startsWith");
	/** Condition: string1 ends with string2 */
	public static final ENDS_WITH:StringMatch = new StringMatch("endsWith");

	static inline final TYPE_ID:Int = 2;

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
