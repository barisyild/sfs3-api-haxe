package com.smartfoxserver.v3.entities.match;

/**
 * The <em>LogicOperator</em> class is used to concatenate two matching expressions using the <b>AND</b> or <b>OR</b> logical operator.
 *
 * @see MatchExpression
 */
@:expose("SFS3.LogicOperator")
class LogicOperator
{
	/** AND logical operator */
	public static final AND:LogicOperator = new LogicOperator("AND");
	/** OR logical operator */
	public static final OR:LogicOperator = new LogicOperator("OR");

	private var id:String;

	private function new(id:String)
	{
		this.id = id;
	}

	public function getId():String
		return id;
}
