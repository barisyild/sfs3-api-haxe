package com.smartfoxserver.v3;
import com.smartfoxserver.v3.util.NetDebugLevel;

/**
 * ConfigData contains all the settings for the connection. It must be passed to the {@link SmartFox} class to initiate a connection
 * to the Server.
 * @see SmartFox#connect(ConfigData)
 */
@:expose("SFS3.ConfigData")
final class ConfigData
{
    /** The host to connect to */
    public var host:String	 				= "127.0.0.1";

    /** The TCP port used for the connection */
    public var port:Int 					= 9977;

    /** The UDP port used for a UDP connection */
    public var udpPort:Int					= 9977;

    /** The HTTP port to be used for HTTP calls */
    public var httpPort:Int 				= 8088;

    /** The HTTPS port to be used for HTTP calls */
    public var httpsPort:Int 				= 8843;

    /** The amount of time (in milliseconds) after which the client should give up if there's no response from the server side */
    public var tcpConnectionTimeout:Int 	= 2000; // Milliseconds

    /** The name of the Zone to connect to */
    public var zone:String;

    /** Settings to configure the HTTP tunnel, used when a TCP connection cannot be established */
    public var blueBox:BlueBoxCfg 			= new BlueBoxCfg();

    /**
	 * Debug settings to show more information about the data exchange between client and server
	 * <ul>
	 * <li>OFF: no extra info logged</li>
	 * <li>PACKET: additional packet hex dump is logged</li>
	 * <li>PROTOCOL: as above, plus each request/response structure is also dumped</li>
	 * </ul>
	 */
    public var netDebugLevel:NetDebugLevel	= NetDebugLevel.OFF;

    /**
	 * Enables protocol encryption.
	 * This requires that the server is configured accordingly and a valid SSL/TLS certificate is installed
	 * For more details check the online documentation, under Getting Started &gt; Configuring TLS/SSL
	 */
    public var useSSL:Bool 				= false;

    /** When sending data via UDP, if the UDP connection failed, it will use TCP instead */
    public var useTcpFallback:Bool 		= false;

    /**
	 * Toggles the Nagle algorithm for the TCP connection
	 * More on this here: https://en.wikipedia.org/wiki/Nagle's_algorithm
	 */
    public var useTcpNoDelay:Bool 		= true;

    public function new(){}
}

final class BlueBoxCfg
{
    /** When active if the TCP connection fails an attempt to use an HTTP tunnel will be made */
    public var isActive:Bool 		= true;

    /** Logs debug information in the logs */
    public var debug:Bool	 		= false;

    /**
     * Adjusts the polling rate between "long polls".
     * The default value is recommended, shorter values can be use to increase response times but can have adverse performance effects
     */
    public var pollingRateMs:Int 		= 700;

    public function new(){}
}