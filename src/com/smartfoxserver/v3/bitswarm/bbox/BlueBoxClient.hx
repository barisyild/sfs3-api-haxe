package com.smartfoxserver.v3.bitswarm.bbox;

import haxe.Exception;
import haxe.crypto.Base64;
import haxe.io.Bytes;
import haxe.Http;

import com.smartfoxserver.v3.core.ApiEvent;
import com.smartfoxserver.v3.util.WebServices;
import com.smartfoxserver.v3.core.IDispatchable;
import com.smartfoxserver.v3.core.EventDispatcher;
import com.smartfoxserver.v3.bitswarm.SocketState;
import com.smartfoxserver.v3.core.IEventListener;
import com.smartfoxserver.v3.util.ClientDisconnectionReason;
import com.smartfoxserver.v3.core.EventParam;
import hx.concurrent.executor.Executor;
import com.smartfoxserver.v3.bitswarm.io.SysParam;
import hx.concurrent.executor.Schedule;

class BlueBoxClient implements IDispatchable
{
    private final POLLING_TIMEOUT:Int = 45 * 1000;
    private final POLL_MONITOR_INTERVAL:Int = 10; // Seconds

    private final BB_SERVLET:String = '${WebServices.BASE_SERVLET}/${WebServices.BLUE_BOX}';
    private final BB_NULL:String = "null";

    private final CMD_CONNECT:String = "connect";
    private final CMD_POLL:String = "poll";
    private final CMD_DATA:String = "data";
    private final ERR_INVALID_SESSION:String = "err01";

    private final SFS_HTTP:String = "sfsHttp";
    private final SEP:String = "|";

    private final MIN_POLL_SPEED:Int = 50; // ms
    private final MAX_POLL_SPEED:Int = 5000; // ms
    private final DEFAULT_POLL_SPEED:Int = 300; // ms

    // ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    // Getters / Setters
    // ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    private var bbUrl:String;
    private var sessId:String = null;
    private var pollSpeed:Int;
    private var lastPollingTime:Float = 0;

    private var dispatcher:EventDispatcher;

    private var threadPool:Executor;
    private var scheduler:Executor;
    private var timeoutMonitorTask:TaskFuture<Dynamic>;
    private var pollNextTask:TaskFuture<Dynamic>;

    private var bbEndPoint:String;
    private var bitswarm:BitSwarmClient;
    private var socketState:SocketState;

    /*
     * -->> Testing only constructor <<--
     */
    public function new(es:Executor, ses:Executor, ?bitSwarm:BitSwarmClient)
    {
        this.pollSpeed = DEFAULT_POLL_SPEED;
        this.bitswarm = bitSwarm;

        if (bitSwarm != null)
        {
            this.scheduler = bitSwarm.getScheduler();
            this.threadPool = bitSwarm.getThreadPool();
        }
        else
        {
            this.threadPool = es;
            this.scheduler = ses;
        }

        if (dispatcher == null)
            dispatcher = new EventDispatcher(this);

        this.socketState = SocketState.Disconnected;
    }

    public function isConnecting():Bool
    {
        return socketState == SocketState.Connecting;
    }

    public function isConnected():Bool
    {
        return socketState == SocketState.Connected;
    }

    public function setPollSpeed(pollSpeed:Int):Void
    {
        this.pollSpeed = (pollSpeed >= MIN_POLL_SPEED && pollSpeed <= MAX_POLL_SPEED) ? pollSpeed : DEFAULT_POLL_SPEED;
    }

    public function getDispatcher():EventDispatcher
    {
        return this.dispatcher;
    }

    public function addEventListener(eventType:String, listener:ApiEvent->Void):Void
    {
        this.dispatcher.addEventListener(eventType, listener);
    }

    public function removeEventListener(eventType:String, listener:ApiEvent->Void):Void
    {
        this.dispatcher.removeEventListener(eventType, listener);
    }

    public function removeAllEventListeners():Void
    {
        this.dispatcher.removeAll();
    }

    public function connect(host:String, port:Int):Void
    {
        if (isConnecting())
            throw new Exception("A connection attempt is already ongoing");

        if (isConnected())
            throw new Exception("Already connected");

        this.socketState = SocketState.Connecting;

        /*
        * NOTE we always use HTTP even when using protocol encryption This is because
        * packets are already encrypted at the wire-level If used HTTPS we would
        * encrypt packets twice, which is more resource intensive and adds latency
        */
        bbUrl = 'http://${host}:${port}/${BB_SERVLET}';
        bbEndPoint = bbUrl;

        // Init HttpClient

        sendRequest(CMD_CONNECT);
    }

    public function send(data:Bytes):Void
    {
        if (!isConnected())
            throw new Exception("Cant' send data without being connected first");

        try
        {
            sendRequest(CMD_DATA, data);
        }
        catch (ex:Dynamic)
        {
            trace("WARN: BlueBox send error: " + ex);
        }
    }

    public function disconnect(reason:String, errMessage:String):Void
    {
        if (socketState == SocketState.Disconnected)
            throw new Exception("The BlueBox client is already disconnected");

        handleConnectionLost(reason, errMessage);
    }

    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    // Private handlers and methods
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    private function onHttpError(e:Dynamic):Void
    {
        handleConnectionLost(ClientDisconnectionReason.UNKNOWN, Std.string(e));
    }

    private function onHttpResponse(response:String):Void
    {
        try
        {
            // Obtain split params
            var reqBits:Array<String> = response.split(SEP);

            // Wrong formatted response or empty line --> ignore
            if (reqBits.length < 2)
            {
                onHttpError(new Exception("Unexpected BlueBox response: " + response));
                return;
            }

            var cmd:String = reqBits[0];
            var data:String = reqBits[1];

            if (cmd == CMD_CONNECT)
            {
                sessId = data;
                socketState = SocketState.Connected;

                var params:Map<String, Dynamic> = [EventParam.Success => true, SysParam.IsReconnection => false];
                var connEvt = new BlueBoxEvent(BlueBoxEvent.Connected, params);
                dispatchEvent(connEvt);

                // Activate polling timeout monitor
                lastPollingTime = Date.now().getTime();
                timeoutMonitorTask = scheduler.submit(pollTimeOutMonitorRun, FIXED_RATE(POLL_MONITOR_INTERVAL, 0));

                // Next polling cycle
                pollNext();
            }
            else if (cmd == CMD_POLL)
            {
                var binData:Bytes = null;

                // Decode Base64 string --> bytes
                if (data != BB_NULL)
                    binData = decodeResponse(data);

                // Pre-launch next polling request
                pollNext();

                // Dispatch the event
                if (binData != null)
                {
                    var parameters:Map<String, Dynamic> = [EventParam.Data => binData];
                    dispatchEvent(new BlueBoxEvent(BlueBoxEvent.DataReceived, parameters));
                }
            }
            else if (cmd == ERR_INVALID_SESSION)
            {
                onHttpError(new Exception("Invalid BlueBox session!"));
            }
        }
        catch (e:Dynamic)
        {
            socketState = SocketState.Disconnected;
            onHttpError(e);
        }
    }

    private function pollTimeOutMonitorRun():Void
    {
        if (Date.now().getTime() > lastPollingTime + POLLING_TIMEOUT)
        {
            var params:Map<String, Dynamic> = [EventParam.DisconnectionReason => ClientDisconnectionReason.UNKNOWN];
            dispatchEvent(new BlueBoxEvent(BlueBoxEvent.Disconnected, params));

            if (timeoutMonitorTask != null) {
                timeoutMonitorTask.cancel(); // false
            }
        }
    }

    private function pollNext():Void
    {
        if (isConnected())
        {
            pollNextTask = scheduler.submit(poll, ONCE(pollSpeed)); //scheduler.schedule(poll, pollSpeed, TimeUnit.MILLISECONDS);
        }
    }

    private function poll():Void
    {
        if (isConnected())
        {
            lastPollingTime = Date.now().getTime();
            sendRequest(CMD_POLL);
        }
    }

    /*
     * Uses separate thread-pool thread to avoid Android
     * using the main with HTTP calls
     * * Also: may require refactoring in future updates of the HttpClient lib
     * due to deprecation warn below.
     */
    private function sendRequest(cmd:String, ?data:Bytes):Void
    {
        threadPool.submit(function() {
            try
            {
                var requestData = encodeRequest(cmd, data);
                var req = new Http(bbEndPoint);

                req.setParameter(SFS_HTTP, requestData);

                req.onData = function(httpResponse:String) {
                    if (bitswarm != null && bitswarm.isBBoxDebug())
                        trace("INFO: BB Incoming: " + httpResponse);

                    onHttpResponse(httpResponse);
                };

                req.onError = function(errorMsg:String) {
                    if (socketState == SocketState.Connecting)
                    {
                        trace("WARN: " + errorMsg);
                        socketState = SocketState.Disconnected;

                        var params:Map<String, Dynamic> = [EventParam.ErrorMessage => "BlueBox connection failed"];
                        var connEvt = new BlueBoxEvent(BlueBoxEvent.Error, params);
                        dispatchEvent(connEvt);
                    }
                    else
                    {
                        trace("WARN: BlueBox Request error: " + cmd + " -> " + errorMsg);
                        socketState = SocketState.Disconnected;
                        onHttpError(new Exception(errorMsg));
                    }
                };

                // Set ContentType
                req.setHeader("Content-Type", "application/x-www-form-urlencoded");

                req.request(true);
            }
            catch (ex:Dynamic)
            {
                if (socketState == SocketState.Connecting)
                {
                    trace("WARN: " + ex);
                    socketState = SocketState.Disconnected;

                    var connEvt = new BlueBoxEvent(BlueBoxEvent.Error, [EventParam.ErrorMessage => "BlueBox connection failed"]);
                    dispatchEvent(connEvt);
                }
                else
                {
                    trace("WARN: BlueBox Request error: " + cmd + " " + ex);
                    socketState = SocketState.Disconnected;

                    onHttpError(ex);
                }
            }
        });
    }

    private function handleConnectionLost(reason:String, errMessage:String):Void
    {
        sessId = null;
        socketState = SocketState.Disconnected;
        shutDownRunningTasks();

        var params:Map<String, Dynamic> = [
            EventParam.DisconnectionReason => reason,
            EventParam.ErrorMessage => errMessage
        ];

        dispatchEvent(new BlueBoxEvent(BlueBoxEvent.Disconnected, params));
    }

    // ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    // Message Codec
    // ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

    private function encodeRequest(cmd:String, data:Bytes):String
    {
        var encodedData:String;

        if (cmd == null)
            cmd = BB_NULL;

        // If no data is provided we use the default representation
        if (data == null)
            encodedData = BB_NULL;
            // Encode in Base64
        else
            encodedData = toBase64String(data);

        var reqSessId = (sessId == null) ? BB_NULL : sessId;
        var request = reqSessId + SEP + cmd + SEP + encodedData;

        if (bitswarm != null && bitswarm.isBBoxDebug())
            trace("INFO: BB Outgoing: " + request);

        return StringTools.urlEncode(request);
    }

    private function toBase64String(bytes:Bytes):String
    {
        return Base64.encode(bytes);
    }

    private function decodeResponse(rawData:String):Bytes
    {
        return Base64.decode(rawData);
    }

    private function dispatchEvent(evt:ApiEvent):Void
    {
        this.dispatcher.dispatchEvent(evt);
    }

    private function shutDownRunningTasks():Void
    {
        if (pollNextTask != null)
        {
            pollNextTask.cancel(); // true
        }

        if (timeoutMonitorTask != null)
        {
            timeoutMonitorTask.cancel(); // true
        }
    }
}