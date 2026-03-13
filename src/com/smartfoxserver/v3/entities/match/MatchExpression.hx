package com.smartfoxserver.v3.entities.match;

import com.smartfoxserver.v3.entities.data.ISFSArray;
import com.smartfoxserver.v3.entities.data.SFSArray;

/**
 * The <em>MatchExpression</em> class represents a matching expression used to compare custom variables or predefined properties when searching for users or Rooms.
 *
 * @see RoomProperties
 * @see UserProperties
 * @see MatchExpression
 */
class MatchExpression
{
	private var varName:String;
	private var condition:IMatcher;
	private var value:Dynamic;
	private var logicOp:LogicOperator;
	private var parent:MatchExpression;
	private var next:MatchExpression;

	/**
	 * Creates a new <em>MatchExpression</em> instance.
	 *
	 * @param	varName		Name of the variable or property to match.
	 * @param	condition	The matching condition.
	 * @param	value		The value to compare against the variable or property during the matching.
	 */
	public function new(varName:String, condition:IMatcher, value:Dynamic)
	{
		this.varName = varName;
		this.condition = condition;
		this.value = value;
	}

	/**
	 * Concatenates the current expression with a new one using the logical <b>AND</b> operator.
	 */
	public function and(varName:String, condition:IMatcher, value:Dynamic):MatchExpression
	{
		next = new MatchExpression(varName, condition, value);
		next.logicOp = LogicOperator.AND;
		next.parent = this;
		return next;
	}

	/**
	 * Concatenates the current expression with a new one using the logical <b>OR</b> operator.
	 */
	public function or(varName:String, condition:IMatcher, value:Dynamic):MatchExpression
	{
		next = new MatchExpression(varName, condition, value);
		next.logicOp = LogicOperator.OR;
		next.parent = this;
		return next;
	}

	public function getVarName():String
		return varName;

	public function getCondition():IMatcher
		return condition;

	public function getValue():Dynamic
		return value;

	public function getLogicOp():LogicOperator
		return logicOp;

	public function hasNext():Bool
		return next != null;

	public function getNext():MatchExpression
		return next;

	/**
	 * Moves the iterator cursor to the first matching expression in the chain.
	 */
	public function rewind():MatchExpression
	{
		var currNode:MatchExpression = this;
		while (currNode.parent != null)
			currNode = currNode.parent;
		return currNode;
	}

	/**
	 * @internal
	 */
	public function asString():String
	{
		var sb = new StringBuf();
		if (logicOp != null)
		{
			sb.add(" ");
			sb.add(logicOp.getId());
			sb.add(" ");
		}
		sb.add("(");
		sb.add(varName);
		sb.add(" ");
		sb.add(condition.getSymbol());
		sb.add(" ");
		sb.add(Std.isOfType(value, String) ? ("'" + value + "'") : Std.string(value));
		sb.add(")");
		return sb.toString();
	}

	public function toString():String
	{
		var expr = rewind();
		var sb = new StringBuf();
		sb.add(expr.asString());
		while (expr.hasNext())
		{
			expr = expr.getNext();
			sb.add(expr.asString());
		}
		return sb.toString();
	}

	/**
	 * @internal
	 */
	public function toSFSArray():ISFSArray
	{
		var expr = rewind();
		var sfsa = new SFSArray();
		sfsa.addSFSArray(expr.expressionAsSFSArray());
		while (expr.hasNext())
		{
			expr = expr.getNext();
			sfsa.addSFSArray(expr.expressionAsSFSArray());
		}
		return sfsa;
	}

	private function expressionAsSFSArray():ISFSArray
	{
		var expr = new SFSArray();
		// 0 -> Logic operator
		if (logicOp != null)
			expr.addString(logicOp.getId());
		else
			expr.addNull();
		// 1 -> Var name
		expr.addString(varName);
		// 2 -> Matcher type
		expr.addByte(condition.getType());
		// 3 -> Condition symbol
		expr.addString(condition.getSymbol());
		// 4 -> Value to match against
		if (condition.getType() == 0) // BoolMatch
			expr.addBool((value : Bool));
		else if (condition.getType() == 1) // NumberMatch
			expr.addDouble((value : Float));
		else
			expr.addString(Std.string(value));
		return expr;
	}
}
