package sfs3.client.controllers;
import sfs3.client.bitswarm.io.IResponse;
import haxe.Exception;
import sfs3.client.requests.BaseRequest;
import sfs3.client.bitswarm.BitSwarmClient;
import sfs3.client.controllers.system.ResHandshake;
import sfs3.client.controllers.system.ResLogin;
import sfs3.client.controllers.system.ResLogout;
import sfs3.client.controllers.system.ResJoinRoom;
import sfs3.client.controllers.system.ResCreateRoom;
import sfs3.client.controllers.system.ResGenericMessage;
import sfs3.client.controllers.system.ResChangeRoomName;
import sfs3.client.controllers.system.ResChangeRoomPassword;
import sfs3.client.controllers.system.ResChangeRoomCapacity;
import sfs3.client.controllers.system.ResSetRoomVariables;
import sfs3.client.controllers.system.ResSetUserVariables;
import sfs3.client.controllers.system.ResSubscribeRoomGroup;
import sfs3.client.controllers.system.ResUnsubscribeRoomGroup;
import sfs3.client.controllers.system.ResSpectatorToPlayer;
import sfs3.client.controllers.system.ResPlayerToSpectator;
import sfs3.client.controllers.system.ResInitBuddyList;
import sfs3.client.controllers.system.ResAddBuddy;
import sfs3.client.controllers.system.ResRemoveBuddy;
import sfs3.client.controllers.system.ResBlockBuddy;
import sfs3.client.controllers.system.ResGoOnline;
import sfs3.client.controllers.system.ResSetBuddyVariables;
import sfs3.client.controllers.system.ResFindRooms;
import sfs3.client.controllers.system.ResFindUsers;
import sfs3.client.controllers.system.ResInviteUsers;
import sfs3.client.controllers.system.ResInvitationReply;
import sfs3.client.controllers.system.ResQuickJoinGame;
import sfs3.client.controllers.system.ResPingPong;
import sfs3.client.controllers.system.ResSetUserPosition;
import sfs3.client.controllers.system.ResUdpInit;
import sfs3.client.controllers.system.ResGameServerConnectionRequired;
import sfs3.client.controllers.system.ResUserEnterRoom;
import sfs3.client.controllers.system.ResUserCountChange;
import sfs3.client.controllers.system.ResUserLost;
import sfs3.client.controllers.system.ResRoomLost;
import sfs3.client.controllers.system.ResUserExitRoom;
import sfs3.client.controllers.system.ResClientDisconnect;
import sfs3.client.controllers.system.ResSetMMOItemVariable;

typedef ResponseHandlerTypedef = {
    name:String,
    instance:IResponseHandler
}

class SystemController extends BaseController
{
    public static final CONTROLLER_ID:Int = 0;
    private var responseHandlers:Map<Int, ResponseHandlerTypedef>;

    private final  smartFox:ISmartFox;

    public function new(bitSwarmClient:BitSwarmClient)
    {
        super(CONTROLLER_ID, bitSwarmClient);
        this.smartFox = bitSwarmClient.getSmartFox();

        initRequestHandlers();
    }

    private function initRequestHandlers():Void
    {
        responseHandlers = new Map<Int, ResponseHandlerTypedef>();

        responseHandlers.set(BaseRequest.Handshake, {name: "ResHandshake", instance: new ResHandshake()});
        responseHandlers.set(BaseRequest.Login, {name: "ResLogin", instance: new ResLogin()});
        responseHandlers.set(BaseRequest.Logout, {name: "ResLogout", instance: new ResLogout()});
        responseHandlers.set(BaseRequest.JoinRoom, {name: "ResJoinRoom", instance: new ResJoinRoom()});
        responseHandlers.set(BaseRequest.CreateRoom, {name: "ResCreateRoom", instance: new ResCreateRoom()});
        responseHandlers.set(BaseRequest.GenericMessage, {name: "ResGenericMessage", instance: new ResGenericMessage()});
        responseHandlers.set(BaseRequest.ChangeRoomName, {name: "ResChangeRoomName", instance: new ResChangeRoomName()});
        responseHandlers.set(BaseRequest.ChangeRoomPassword, {name: "ResChangeRoomPassword", instance: new ResChangeRoomPassword()});
        responseHandlers.set(BaseRequest.ChangeRoomCapacity, {name: "ResChangeRoomCapacity", instance: new ResChangeRoomCapacity()});
        responseHandlers.set(BaseRequest.SetRoomVariables, {name: "ResSetRoomVariables", instance: new ResSetRoomVariables()});
        responseHandlers.set(BaseRequest.SetUserVariables, {name: "ResSetUserVariables", instance: new ResSetUserVariables()});
        responseHandlers.set(BaseRequest.SubscribeRoomGroup, {name: "ResSubscribeRoomGroup", instance: new ResSubscribeRoomGroup()});
        responseHandlers.set(BaseRequest.UnsubscribeRoomGroup, {name: "ResUnsubscribeRoomGroup", instance: new ResUnsubscribeRoomGroup()});
        responseHandlers.set(BaseRequest.SpectatorToPlayer, {name: "ResSpectatorToPlayer", instance: new ResSpectatorToPlayer()});
        responseHandlers.set(BaseRequest.PlayerToSpectator, {name: "ResPlayerToSpectator", instance: new ResPlayerToSpectator()});
        responseHandlers.set(BaseRequest.InitBuddyList, {name: "ResInitBuddyList", instance: new ResInitBuddyList()});
        responseHandlers.set(BaseRequest.AddBuddy, {name: "ResAddBuddy", instance: new ResAddBuddy()});
        responseHandlers.set(BaseRequest.RemoveBuddy, {name: "ResRemoveBuddy", instance: new ResRemoveBuddy()});
        responseHandlers.set(BaseRequest.BlockBuddy, {name: "ResBlockBuddy", instance: new ResBlockBuddy()});
        responseHandlers.set(BaseRequest.GoOnline, {name: "ResGoOnline", instance: new ResGoOnline()});
        responseHandlers.set(BaseRequest.SetBuddyVariables, {name: "ResSetBuddyVariables", instance: new ResSetBuddyVariables()});
        responseHandlers.set(BaseRequest.FindRooms, {name: "ResFindRooms", instance: new ResFindRooms()});
        responseHandlers.set(BaseRequest.FindUsers, {name: "ResFindUsers", instance: new ResFindUsers()});
        responseHandlers.set(BaseRequest.InviteUser, {name: "ResInviteUsers", instance: new ResInviteUsers()});
        responseHandlers.set(BaseRequest.InvitationReply, {name: "ResInvitationReply", instance: new ResInvitationReply()});
        responseHandlers.set(BaseRequest.QuickJoinGame, {name: "ResQuickJoinGame", instance: new ResQuickJoinGame()});
        responseHandlers.set(BaseRequest.PingPong, {name: "ResPingPong", instance: new ResPingPong()});
        responseHandlers.set(BaseRequest.SetUserPosition, {name: "ResSetUserPosition", instance: new ResSetUserPosition()});
        responseHandlers.set(BaseRequest.UdpInit, {name: "ResUdpInit", instance: new ResUdpInit()});

        // Cluster events
        responseHandlers.set(BaseRequest.GameServerConnectionRequired, {name: "ResGameServerConnectionRequired", instance: new ResGameServerConnectionRequired()});

        // Response only codes
        responseHandlers.set(1000, {name: "ResUserEnterRoom", instance: new ResUserEnterRoom()});
        responseHandlers.set(1001, {name: "ResUserCountChange", instance: new ResUserCountChange()});
        responseHandlers.set(1002, {name: "ResUserLost", instance: new ResUserLost()});
        responseHandlers.set(1003, {name: "ResRoomLost", instance: new ResRoomLost()});
        responseHandlers.set(1004, {name: "ResUserExitRoom", instance: new ResUserExitRoom()});
        responseHandlers.set(1005, {name: "ResClientDisconnect", instance: new ResClientDisconnect()});
        responseHandlers.set(1007, {name: "ResSetMMOItemVariable", instance: new ResSetMMOItemVariable()});

        // Cluster response-only codes
        //responseHandlers.set(1600, {name: "ResLoadBalancerError", instance: new ResLoadBalancerError()});
    }

    override public function handleMessage(resp:IResponse):Void
    {
        if(log.isDebugEnabled())
            log.debug("System Request: " + getEvtName(resp.getId()) + " " + resp);

        var resHandlerTypedef:ResponseHandlerTypedef = responseHandlers.get(resp.getId());

        if (resHandlerTypedef != null)
        {
            try
            {
                var resHandler:IResponseHandler = resHandlerTypedef.instance;

                // Execute
                resHandler.handleResponse(smartFox, resp);
            }
            catch (ex:Exception)
            {
                log.warn("Error in handling event: " + ex, ex);
            }
        }
        else
        {
            log.warn("Unknown request id: " + resp.getId());
        }
    }

    private function getEvtName(id:Int):String
    {
        return responseHandlers.get(id).name;
    }
}
