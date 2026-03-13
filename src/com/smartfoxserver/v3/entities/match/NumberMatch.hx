package com.smartfoxserver.v3.entities.match;

/**
 * The <em>NumberMatch</em> class is used in matching expressions to check numeric conditions.
 *
 * @see MatchExpression
 */
class NumberMatch implements IMatcher
{
	/** Condition: number1 == number2 */
	public static final EQUALS:NumberMatch = new NumberMatch("==");
	/** Condition: number1 != number2 */
	public static final NOT_EQUALS:NumberMatch = new NumberMatch("!=");
	/** Condition: number1 > number2 */
	public static final GREATER_THAN:NumberMatch = new NumberMatch(">");
	/** Condition: number1 >= number2 */
	public static final GREATER_THAN_OR_EQUAL_TO:NumberMatch = new NumberMatch(">=");
	/** Condition: number1 < number2 */
	public static final LESS_THAN:NumberMatch = new NumberMatch("<");
	/** Condition: number1 <= number2 */
	public static final LESS_THAN_OR_EQUAL_TO:NumberMatch = new NumberMatch("<=");

	static inline final TYPE_ID:Int = 1;

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
