package com.smartfoxserver.v3.bitswarm;

class ReconnectionState
{
    private var _isPending:Bool;
    private var _firstAttemptTime:Int;
    private var _counter:Int;

    /*
	 * @param isPending 				true if a reconnection is ongoing
	 * @param firstAttemptTime			timestamp of first reconnection attempt
	 * @param counter					keeps track of number of attempts
	 */
    public function new(isPending:Bool = true, firstAttemptTime:Null<Int> = null, counter:Int = 1)
    {
        if(firstAttemptTime == null)
            firstAttemptTime = Std.int(Date.now().getTime());

        this._isPending = isPending;
        this._firstAttemptTime = firstAttemptTime;
        this._counter = counter;
    }

    public function isPending():Bool
    {
        return _isPending;
    }

    public function firstAttemptTime():Int
    {
        return _firstAttemptTime;
    }

    public function counter():Int
    {
        return _counter;
    }

    public function incCounter():Void
    {
        _counter++;
    }

    public function toString():String
    {
        return '{ Pending: ${_isPending}, Counter: ${_counter} }';
    }
}
