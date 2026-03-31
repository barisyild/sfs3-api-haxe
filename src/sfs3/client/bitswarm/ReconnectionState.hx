package sfs3.client.bitswarm;

class ReconnectionState
{
    private var isPending:Bool;
    private var firstAttemptTime:Float;
    private var counter:Int;

    /*
	 * @param isPending 				true if a reconnection is ongoing
	 * @param firstAttemptTime			timestamp of first reconnection attempt
	 * @param counter					keeps track of number of attempts
	 */
    public function new(isPending:Bool = true, firstAttemptTime:Null<Float> = null, counter:Int = 1)
    {
        if(firstAttemptTime == null)
            firstAttemptTime = Date.now().getTime();

        this.isPending = isPending;
        this.firstAttemptTime = firstAttemptTime;
        this.counter = counter;
    }

    public function getPending():Bool
    {
        return isPending;
    }

    public function getFirstAttemptTime():Float
    {
        return firstAttemptTime;
    }

    public function getCounter():Int
    {
        return counter;
    }

    public function incCounter():Void
    {
        counter++;
    }

    public function toString():String
    {
        return '{ Pending: ${isPending}, Counter: ${counter} }';
    }
}
