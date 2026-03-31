package sfs3.client.util;

import haxe.Timer;
import sfs3.client.SmartFox;
import sfs3.client.requests.PingPongRequest;

/**
 * <b>*Private*</b>
 * Ported to use haxe.Timer for cross-platform compatibility.
 */
class LagMonitor
{
    private var lastReqTime:Float = 0;
    private var valueQueue:Array<Float>;
    private var interval:Int;
    private var queueSize:Int;
    private var timer:Timer;
    private var sfs:SmartFox;

    private var maxValue:Float = 0;
    private var minValue:Float = 1000000.0; // High initial value for comparison

    public function new(sfs:SmartFox, interval:Int = 4, queueSize:Int = 10)
    {
        if (interval < 1)
            interval = 1;

        this.sfs = sfs;
        this.valueQueue = [];
        this.interval = interval;
        this.queueSize = queueSize;
    }

    /**
     * Starts the lag monitoring process.
     */
    public function start():Void
    {
        if (!isRunning)
        {
            if(timer != null)
                timer.stop();

            // Convert interval from seconds to milliseconds
            timer = new Timer(interval * 1000);
            timer.run = lagMonitorRunner;

            // Trigger the first ping immediately
            lagMonitorRunner();
        }
    }

    /**
     * Stops the lag monitoring process.
     */
    public function stop():Void
    {
        if (timer != null)
        {
            timer.stop();
            timer = null;
        }
    }

    /**
     * Checks if the monitor is currently running.
     */
    public var isRunning(get, null):Bool;
    private function get_isRunning():Bool
    {
        return timer != null;
    }

    /**
     * Called when a PingPong response is received from the server.
     * Updates statistics and returns the average ping time.
     */
    public function onPingPong():Float
    {
        // Calculate lag in milliseconds
        var lagValue:Float = (Timer.stamp() - lastReqTime) * 1000;

        // Update statistics
        if (minValue > lagValue)
            minValue = lagValue;

        if (maxValue < lagValue)
            maxValue = lagValue;

        // Manage queue size
        if (valueQueue.length >= queueSize)
            valueQueue.shift();

        valueQueue.push(lagValue);

        return averagePingTime;
    }

    // --- Getters ---

    /**
     * Returns the lag value of the last ping request.
     */
    public var lastPingTime(get, null):Float;
    private function get_lastPingTime():Float
    {
        return (valueQueue.length > 0) ? valueQueue[valueQueue.length - 1] : 0;
    }

    /**
     * Returns the average lag value from the stored queue.
     */
    public var averagePingTime(get, null):Float;
    private function get_averagePingTime():Float
    {
        if (valueQueue.length == 0) return 0;

        var total:Float = 0;
        for (val in valueQueue)
            total += val;

        return total / valueQueue.length;
    }

    /**
     * Returns the minimum lag value recorded during the session.
     */
    public function getMinValue():Float { return minValue; }

    /**
     * Returns the maximum lag value recorded during the session.
     */
    public function getMaxValue():Float { return maxValue; }

    // :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

    /**
     * Sends a ping request and records the timestamp.
     */
    private function lagMonitorRunner():Void
    {
        lastReqTime = Timer.stamp();

        if (sfs != null && sfs.isConnected())
        {
            sfs.send(new PingPongRequest());
        }
    }
}