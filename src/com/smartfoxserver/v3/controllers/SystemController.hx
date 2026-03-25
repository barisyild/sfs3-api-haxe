package com.smartfoxserver.v3.controllers;
import com.smartfoxserver.v3.bitswarm.io.IResponse;
import haxe.Exception;
import com.smartfoxserver.v3.requests.BaseRequest;
import com.smartfoxserver.v3.bitswarm.BitSwarmClient;
import com.smartfoxserver.v3.controllers.system.ResHandshake;
import com.smartfoxserver.v3.controllers.system.ResLogin;
import com.smartfoxserver.v3.controllers.system.ResLogout;
import com.smartfoxserver.v3.controllers.system.ResJoinRoom;
import com.smartfoxserver.v3.controllers.system.ResCreateRoom;
import com.smartfoxserver.v3.controllers.system.ResGenericMessage;
import com.smartfoxserver.v3.controllers.system.ResChangeRoomName;
import com.smartfoxserver.v3.controllers.system.ResChangeRoomPassword;
import com.smartfoxserver.v3.controllers.system.ResChangeRoomCapacity;
import com.smartfoxserver.v3.controllers.system.ResSetRoomVariables;
import com.smartfoxserver.v3.controllers.system.ResSetUserVariables;
import com.smartfoxserver.v3.controllers.system.ResSubscribeRoomGroup;
import com.smartfoxserver.v3.controllers.system.ResUnsubscribeRoomGroup;
import com.smartfoxserver.v3.controllers.system.ResSpectatorToPlayer;
import com.smartfoxserver.v3.controllers.system.ResPlayerToSpectator;
import com.smartfoxserver.v3.controllers.system.ResInitBuddyList;
import com.smartfoxserver.v3.controllers.system.ResAddBuddy;
import com.smartfoxserver.v3.controllers.system.ResRemoveBuddy;
import com.smartfoxserver.v3.controllers.system.ResBlockBuddy;
import com.smartfoxserver.v3.controllers.system.ResGoOnline;
import com.smartfoxserver.v3.controllers.system.ResSetBuddyVariables;
import com.smartfoxserver.v3.controllers.system.ResFindRooms;
import com.smartfoxserver.v3.controllers.system.ResFindUsers;
import com.smartfoxserver.v3.controllers.system.ResInviteUsers;
import com.smartfoxserver.v3.controllers.system.ResInvitationReply;
import com.smartfoxserver.v3.controllers.system.ResQuickJoinGame;
import com.smartfoxserver.v3.controllers.system.ResPingPong;
import com.smartfoxserver.v3.controllers.system.ResSetUserPosition;
import com.smartfoxserver.v3.controllers.system.ResUdpInit;
import com.smartfoxserver.v3.controllers.system.ResGameServerConnectionRequired;
import com.smartfoxserver.v3.controllers.system.ResUserEnterRoom;
import com.smartfoxserver.v3.controllers.system.ResUserCountChange;
import com.smartfoxserver.v3.controllers.system.ResUserLost;
import com.smartfoxserver.v3.controllers.system.ResRoomLost;
import com.smartfoxserver.v3.controllers.system.ResUserExitRoom;
import com.smartfoxserver.v3.controllers.system.ResClientDisconnect;
import com.smartfoxserver.v3.controllers.system.ResSetMMOItemVariable;

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
