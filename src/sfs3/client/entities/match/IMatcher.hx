package sfs3.client.entities.match;

/**
 * The <em>IMatcher</em> interface defines the properties of an object representing a condition to be used in a matching expression exposes.
 *
 * @see		MatchExpression
 * @see		BoolMatch
 * @see		NumberMatch
 * @see		StringMatch
 */
interface IMatcher
{
    /**
	 * Returns the condition symbol of this matcher.
	 */
    public function getSymbol():String;


    /**
	 * Returns the type id of this matcher.
	 */
    public function getType():Int;
}
