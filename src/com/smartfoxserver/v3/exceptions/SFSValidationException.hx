package com.smartfoxserver.v3.exceptions;

class SFSValidationException extends SFSException
{
	private var errors:Array<String>;

	public function new(message:String, errors:Array<String>)
	{
		super(message);
		this.errors = errors != null ? errors : [];
	}

	public function getErrors():Array<String>
	{
		return errors.copy();
	}
}
