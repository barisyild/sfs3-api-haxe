package sfs3.client.controllers;
import sfs3.client.entities.data.ISFSObject;
import sfs3.client.bitswarm.io.IResponse;
import sfs3.client.core.EventParam;
import sfs3.client.core.SFSEvent;
import sfs3.client.bitswarm.BitSwarmClient;
import sfs3.client.requests.ExtensionRequest;
import sfs3.client.entities.data.PlatformStringMap;

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
