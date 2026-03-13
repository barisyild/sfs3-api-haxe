package com.smartfoxserver.v3.requests;
import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.entities.data.SFSObject;
import com.smartfoxserver.v3.bitswarm.TransportType;
import com.smartfoxserver.v3.bitswarm.io.IRequest;
import com.smartfoxserver.v3.bitswarm.io.Request;
import com.smartfoxserver.v3.ISmartFox;

abstract class BaseRequest implements IClientRequest
{
    /**
	 * <b>*Private*</b>
	 */
    public static final Handshake:Int = 0;

    /**
	 * <b>*Private*</b>
	 */
    public static final Login:Int = 1;

    /**
	 * <b>*Private*</b>
	 */
    public static final Logout:Int = 2;

    /**
	 * <b>*Private*</b>
	 */
    public static final GetRoomList:Int = 3;

    /**
	 * <b>*Private*</b>
	 */
    public static final JoinRoom:Int = 4;

    /**
	 * <b>*Private*</b>
	 */
    public static final AutoJoin:Int = 5;

    /**
	 * <b>*Private*</b>
	 */
    public static final CreateRoom:Int = 6;

    /**
	 * <b>*Private*</b>
	 */
    public static final GenericMessage:Int = 7;

    /**
	 * <b>*Private*</b>
	 */
    public static final ChangeRoomName:Int = 8;

    /**
	 * <b>*Private*</b>
	 */
    public static final ChangeRoomPassword:Int = 9;

    /**
	 * <b>*Private*</b>
	 */
    public static final ObjectMessage:Int = 10;

    /**
	 * <b>*Private*</b>
	 */
    public static final SetRoomVariables:Int = 11;

    /**
	 * <b>*Private*</b>
	 */
    public static final SetUserVariables:Int = 12;

    /**
	 * <b>*Private*</b>
	 */
    public static final CallExtension:Int = 0; // Extension ReqID is ignored

    /**
	 * <b>*Private*</b>
	 */
    public static final LeaveRoom:Int = 14;

    /**
	 * <b>*Private*</b>
	 */
    public static final SubscribeRoomGroup:Int = 15;

    /**
	 * <b>*Private*</b>
	 */
    public static final UnsubscribeRoomGroup:Int = 16;

    /**
	 * <b>*Private*</b>
	 */
    public static final SpectatorToPlayer:Int = 17;

    /**
	 * <b>*Private*</b>
	 */
    public static final PlayerToSpectator:Int = 18;

    /**
	 * <b>*Private*</b>
	 */
    public static final ChangeRoomCapacity:Int = 19;

    /**
	 * <b>*Private*</b>
	 */
    public static final PublicMessage:Int = 20;

    /**
	 * <b>*Private*</b>
	 */
    public static final PrivateMessage:Int = 21;

    /**
	 * <b>*Private*</b>
	 */
    public static final ModeratorMessage:Int = 22;

    /**
	 * <b>*Private*</b>
	 */
    public static final AdminMessage:Int = 23;

    /**
	 * <b>*Private*</b>
	 */
    public static final KickUser:Int = 24;

    /**
	 * <b>*Private*</b>
	 */
    public static final BanUser:Int = 25;

    /**
	 * <b>*Private*</b>
	 */
    public static final ManualDisconnection:Int = 26;

    /**
	 * <b>*Private*</b>
	 */
    public static final FindRooms:Int = 27;

    /**
	 * <b>*Private*</b>
	 */
    public static final FindUsers:Int = 28;

    /**
	 * <b>*Private*</b>
	 */
    public static final PingPong:Int = 29;

    /**
	 * <b>*Private*</b>
	 */
    public static final SetUserPosition:Int = 30;

    /**
	 * <b>*Private*</b>
	 */
    public static final QuickJoinOrCreateRoom:Int = 31;

    /**
	 * <b>*Private*</b>
	 */
    public static final UdpInit:Int = 32;

    // --- Buddy List API Requests -------------------------------------------------

    /**
	 * <b>*Private*</b>
	 */
    public static final InitBuddyList:Int = 200;

    /**
	 * <b>*Private*</b>
	 */
    public static final AddBuddy:Int = 201;

    /**
	 * <b>*Private*</b>
	 */
    public static final BlockBuddy:Int = 202;

    /**
	 * <b>*Private*</b>
	 */
    public static final RemoveBuddy:Int = 203;

    /**
	 * <b>*Private*</b>
	 */
    public static final SetBuddyVariables:Int = 204;

    /**
	 * <b>*Private*</b>
	 */
    public static final GoOnline:Int = 205;

    // --- Game API Requests
    // --------------------------------------------------------

    /**
	 * <b>*Private*</b>
	 */
    public static final InviteUser:Int = 300;

    /**
	 * <b>*Private*</b>
	 */
    public static final InvitationReply:Int = 301;

    /**
	 * <b>*Private*</b>
	 */
    public static final CreateSFSGame:Int = 302;

    /**
	 * <b>*Private*</b>
	 */
    public static final QuickJoinGame:Int = 303;

    /**
	 * <b>*Private*</b>
	 */
    public static final JoinRoomInvite:Int = 304;

    // --- Cluster API Requests
    // --------------------------------------------------------

    public static final ClusterJoinOrCreate:Int = 500;
    public static final ClusterInviteUsers:Int = 502;

    public static final GameServerConnectionRequired:Int = 600;

    // --------------------------------------------------------------------------------
    // --------------------------------------------------------------------------------

    /**
	 * <b>*Private*</b>
	 */
    public static final KEY_ERROR_CODE:String = "ec";

    /**
	 * <b>*Private*</b>
	 */
    public static final KEY_ERROR_PARAMS:String = "ep";

    /**
	 * <b>*Private*</b>
	 */
    private var sfso:ISFSObject;

    /**
	 * <b>*Private*</b>
	 */
    private var id:Int;

    /**
	 * <b>*Private*</b>
	 */
    private var targetController:Int;

    /**
	 * <b>*Private*</b>
	 */
    private var isEncrypted:Bool;

	/**
	 * <b>*Private*</b>
	 */
    private var txType:TransportType = TransportType.TCP;

    public function new(id:Int)
    {
        sfso = SFSObject.newInstance();
        targetController = 0;
        isEncrypted = false;
        this.id = id;
    }

	abstract public function validate(sfs:ISmartFox):Void;
	
	abstract public function execute(sfs:ISmartFox):Void;

    public function getId():Int
    {
        return id;
    }

    public function setId(id:Int):Void
    {
        this.id = id;
    }

    public function getTransportType():TransportType
    {
        return txType;
    }

    public function setTransportType(txType:TransportType):Void
    {
        this.txType = txType;
    }

    public function getRequest():IRequest
    {
        var req:IRequest = new Request(targetController, id);
        req.setEncrypted(isEncrypted);
        req.setContent(sfso);
        req.setTransport(txType);

        return req;
    }

    public function getTargetController():Int
    {
        return targetController;
    }

    public function setTargetController(target:Int):Void
    {
        targetController = target;
    }
}