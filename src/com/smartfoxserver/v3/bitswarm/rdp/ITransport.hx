package com.smartfoxserver.v3.bitswarm.rdp;

import com.smartfoxserver.v3.bitswarm.rdp.data.EndPoint;
import haxe.io.Bytes;

interface ITransport {
    function init():Void;
    function destroy():Void;
    function getCfg():TransportConfig;
    function dataReceived(data:Bytes, sender:EndPoint):Void;
    function sendData(data:Bytes, mode:TxpMode, sender:EndPoint):Void;
    function sendPing(sender:EndPoint):Void;
    function getIncomingDataHandler():TxpCallback;
    function getOutgoingDataHandler():TxpCallback;
    function setIncomingDataHandler(handler:TxpCallback):Void;
    function setOutgoingDataHandler(handler:TxpCallback):Void;
    function getIncomingPingCallback():PingCallback;
    function setIncomingPingCallback(callback:PingCallback):Void;
    function getReliableErrorCallback():Void->Void;
    function setReliableErrorCallback(callback:Void->Void):Void;
    function addInBytes(value:Float):Void;
    function addOutBytes(value:Float):Void;
    function addInPacket():Void;
    function addOutPacket():Void;
    function addRtx():Void;
    function getAverageRTT():Float;
    function getAverageReliableRTT():Float;
    function getAverageUnreliableRTT():Float;
    function version():String;
    function getLastPingSendTime():Float;
}
