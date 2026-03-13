package com.smartfoxserver.v3.controllers;
import com.smartfoxserver.v3.bitswarm.io.IResponse;
import com.smartfoxserver.v3.exceptions.ClassNotFoundException;
import haxe.Exception;
import com.smartfoxserver.v3.requests.BaseRequest;
import com.smartfoxserver.v3.bitswarm.BitSwarmClient;

class SystemController extends BaseController
{
    public static final CONTROLLER_ID:Int = 0;
    private static final RES_HANDLERS_PACKAGE:String = "com.smartfoxserver.v3.controllers.system.";
    private var responseHandlers:Map<Int, String>;

    private var responseHandlerCache:Map<String, IResponseHandler>;
    private final  smartFox:ISmartFox;

    public function new(bitSwarmClient:BitSwarmClient)
    {
        super(CONTROLLER_ID, bitSwarmClient);
        this.smartFox = bitSwarmClient.getSmartFox();

        initRequestHandlers();
    }

    private function initRequestHandlers():Void
    {
        responseHandlers = new Map<Int, String>();
        responseHandlerCache = new Map<String, IResponseHandler>();

        responseHandlers.set(BaseRequest.Handshake, "ResHandshake");
        responseHandlers.set(BaseRequest.Login, "ResLogin");
        responseHandlers.set(BaseRequest.Logout, "ResLogout");
        responseHandlers.set(BaseRequest.JoinRoom, "ResJoinRoom");
        responseHandlers.set(BaseRequest.CreateRoom, "ResCreateRoom");
        responseHandlers.set(BaseRequest.GenericMessage, "ResGenericMessage");
        responseHandlers.set(BaseRequest.ChangeRoomName, "ResChangeRoomName");
        responseHandlers.set(BaseRequest.ChangeRoomPassword, "ResChangeRoomPassword");
        responseHandlers.set(BaseRequest.ChangeRoomCapacity, "ResChangeRoomCapacity");
        responseHandlers.set(BaseRequest.SetRoomVariables, "ResSetRoomVariables");
        responseHandlers.set(BaseRequest.SetUserVariables, "ResSetUserVariables");
        responseHandlers.set(BaseRequest.SubscribeRoomGroup, "ResSubscribeRoomGroup");
        responseHandlers.set(BaseRequest.UnsubscribeRoomGroup, "ResUnsubscribeRoomGroup");
        responseHandlers.set(BaseRequest.SpectatorToPlayer, "ResSpectatorToPlayer");
        responseHandlers.set(BaseRequest.PlayerToSpectator, "ResPlayerToSpectator");
        responseHandlers.set(BaseRequest.InitBuddyList, "ResInitBuddyList");
        responseHandlers.set(BaseRequest.AddBuddy, "ResAddBuddy");
        responseHandlers.set(BaseRequest.RemoveBuddy, "ResRemoveBuddy");
        responseHandlers.set(BaseRequest.BlockBuddy, "ResBlockBuddy");
        responseHandlers.set(BaseRequest.GoOnline, "ResGoOnline");
        responseHandlers.set(BaseRequest.SetBuddyVariables, "ResSetBuddyVariables");
        responseHandlers.set(BaseRequest.FindRooms, "ResFindRooms");
        responseHandlers.set(BaseRequest.FindUsers, "ResFindUsers");
        responseHandlers.set(BaseRequest.InviteUser, "ResInviteUsers");
        responseHandlers.set(BaseRequest.InvitationReply, "ResInvitationReply");
        responseHandlers.set(BaseRequest.QuickJoinGame, "ResQuickJoinGame");
        responseHandlers.set(BaseRequest.PingPong, "ResPingPong");
        responseHandlers.set(BaseRequest.SetUserPosition, "ResSetUserPosition");
        responseHandlers.set(BaseRequest.UdpInit, "ResUdpInit");

        // Cluster events
        responseHandlers.set(BaseRequest.GameServerConnectionRequired, "ResGameServerConnectionRequired");

        // Response only codes
        responseHandlers.set(1000, "ResUserEnterRoom");
        responseHandlers.set(1001, "ResUserCountChange");
        responseHandlers.set(1002, "ResUserLost");
        responseHandlers.set(1003, "ResRoomLost");
        responseHandlers.set(1004, "ResUserExitRoom");
        responseHandlers.set(1005, "ResClientDisconnect");
        responseHandlers.set(1007, "ResSetMMOItemVariable");

        // Cluster response-only codes
        responseHandlers.set(1600, "ResLoadBalancerError");
    }

    @Override
    override public function handleMessage(resp:IResponse):Void
    {
        if(log.isDebugEnabled())
            log.debug("System Request: " + getEvtName(resp.getId()) + " " + resp);

        var resHandlerName:String = responseHandlers.get(resp.getId());

        if (resHandlerName != null)
        {
            try
            {
                var resHandler:IResponseHandler;

                if (responseHandlerCache.exists(resHandlerName))
                    resHandler = responseHandlerCache.get(resHandlerName);

                else
                {
                    var handlerClass:Class<IResponseHandler> = cast Type.getClass(RES_HANDLERS_PACKAGE + resHandlerName);
                    if(handlerClass == null)
                        throw new ClassNotFoundException("Handler class not found: " + RES_HANDLERS_PACKAGE + resHandlerName);
                    resHandler = Type.createInstance(handlerClass, []);
                    responseHandlerCache.set(resHandlerName, resHandler);
                }

                // Execute
                resHandler.handleResponse(smartFox, resp);
            }

            catch (e:ClassNotFoundException)
            {
                log.warn('Cannot instantiate handler for eventId: ${resp.getId()}, ${resHandlerName}, Class: ${RES_HANDLERS_PACKAGE}.${resHandlerName}');
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
        return responseHandlers.get(id);
    }
}
