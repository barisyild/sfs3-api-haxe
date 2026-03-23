package com.smartfoxserver.v3.controllers;
import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.bitswarm.io.IResponse;
import com.smartfoxserver.v3.core.EventParam;
import com.smartfoxserver.v3.core.SFSEvent;
import com.smartfoxserver.v3.bitswarm.BitSwarmClient;
import com.smartfoxserver.v3.requests.ExtensionRequest;
import com.smartfoxserver.v3.entities.data.PlatformStringMap;

class ExtensionController extends BaseController
{
    public static final CONTROLLER_ID:Int = 1;
    private final sfs:ISmartFox;

    public function new(bitSwarm:BitSwarmClient)
    {
        super(CONTROLLER_ID, bitSwarm);
        this.sfs = bitSwarm.getSmartFox();
    }

    override public function handleMessage(resp:IResponse):Void
    {
        var sfso:ISFSObject = resp.getContent();

        var evtParams = new PlatformStringMap<Dynamic>();
        evtParams.set(EventParam.Cmd, sfso.getString(ExtensionRequest.KEY_CMD));
        evtParams.set(EventParam.ExtParams, sfso.getSFSObject(ExtensionRequest.KEY_PARAMS));
        evtParams.set(EventParam.TxType, resp.getTransportType());

        if (sfso.containsKey(ExtensionRequest.KEY_ROOM))
        {
            var roomId:Int = sfso.getInt(ExtensionRequest.KEY_ROOM);
            evtParams.set(EventParam.RoomId, roomId);
            evtParams.set(EventParam.Room, sfs.getRoomManager().getRoomById(roomId));
        }

        sfs.dispatchEvent(new SFSEvent(SFSEvent.EXTENSION_RESPONSE, evtParams));
    }
}
