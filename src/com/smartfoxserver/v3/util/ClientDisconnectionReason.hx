package com.smartfoxserver.v3.util;

/**
 * The <em>ClientDisconnectionReason</em> class contains the constants
 * describing the possible reasons why a disconnection from the server occurred.
 */
@:expose("SFS3.ClientDisconnectionReason")
class ClientDisconnectionReason
{

    /**
	 * Client was disconnected because it was idle for too long. The connection
	 * timeout depends on the server settings.
	 */
    public static final IDLE:String = "Idle";

    /**
	 * Client was kicked out of the server. Kicking can occur automatically (i.e.
	 * for swearing, if the words filter is active) or due to the intervention of a
	 * user with enough privileges (i.e. an administrator or a moderator).
	 */
    public static final KICKED:String = "Kicked";

    /**
	 * Client was banned from the server. Banning can occur automatically (i.e. for
	 * flooding, if the flood filter is active) or due to the intervention of a user
	 * with enough privileges (i.e. an administrator or a moderator).
	 */
    public static final BANNED:String = "Banned";

    /**
	 * The client manually disconnected from the server. The <em>disconnect</em>
	 * method on the <b>SmartFox</b> class was called.
	 */
    public static final MANUAL:String = "Manual";

    /**
	 * The client reconnection system was not able to re-establish a connection
	 * to the server successfully.
	 */
    public static final RECONNECTION_FAILURE:String = "Reconnection failure";

    /**
	 * The client is loosing too many packets and the RDP config does not handle
	 * packet loss.
	 */
    public static final UNSTABLE_UDP_CONNECTION:String = "Unstable UDP Connection";

    /**
	 * The client did not send data for a while and got disconnected.
	 * To keep the connection alive set the Zone's udpKeepAlive setting to 'true'
	 */
    public static final UDP_TIMEOUT:String = "UDP Connection timed out";

    /**
	 * A generic network error occurred, and the client is unable to determine the
	 * cause of the disconnection. The server-side log should be checked for
	 * possible error messages or warnings.
	 */
    public static final UNKNOWN:String = "Unknown";

    /*
	 * This is used to rebuild a reason's from an int code, sent by the server
	 * The server only sends the following four states. The others are only accessed locally by the client API.
	 */
    private static final reasons:Array<String> = [IDLE, KICKED, BANNED, UNKNOWN];

    /**
	 * @internal
	 */
    public static function getReason(reasonId:Int):String
    {
        return reasons[reasonId];
    }
}