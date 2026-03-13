package com.smartfoxserver.v3.bitswarm.io.protocol;
class ControllerData {
    public var controllerId(default, null):Int;
    public var actionId(default, null):Int;

    public function new(controllerId:Int, actionId:Int)
    {
        this.controllerId = controllerId;
        this.actionId = actionId;
    }

    public function toString():String
    {
        return '[CtrlId: $controllerId, ActionId: $actionId]';
    }
}