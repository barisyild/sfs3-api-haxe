package sfs3.client.bitswarm;
import sfs3.client.core.IDispatchable;
import sfs3.client.util.NetDebugLevel;
import sfs3.client.bitswarm.io.ClientCoreConfig;
import hx.concurrent.executor.Executor;

interface IBitSwarmClient extends IDispatchable
{
    function init(config:ClientCoreConfig):Void;
    function getThreadPool():Executor;
    function getScheduler():Executor;
    function getSmartFox():ISmartFox;
    function getIOHandler():IOHandler;
    function getConfigData():ConfigData;

    function connect(cfgData:ConfigData):Void;
    function isConnected():Bool;

    function connectUdp(udpHost:String, udpPort:Int):Void;
    function isUdpConnected():Bool;

    // TODO: WebSocket support is currently not implemented in the client, but these methods are defined for future use.
    //function connectWebSocket(wsHost:String, wsPort:Int):Void;
    //function isWebSocketConnected():Bool;

    function getNetDebugLevel():NetDebugLevel;
    function isBBoxDebug():Bool;
    function getConnectionMode():ConnectionMode;

    function disconnect(?reason:String = null):Void;
    function disconnectUdp():Void;
    function killConnection():Void;

    function completeReconnection(success:Bool):Void;
}