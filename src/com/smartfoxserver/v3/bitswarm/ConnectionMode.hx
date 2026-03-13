package com.smartfoxserver.v3.bitswarm;

/**
 * The <em>ConnectionMode</em> class contains the constants defining the possible connection modes of the client with the server.
 *
 * @see		com.smartfoxserver.v3.SmartFox#getConnectionMode()
 */
enum abstract ConnectionMode(Int)
{
    /**
	 * A socket connection is established between client and server
	 */
    var SOCKET = 0;

    /**
	 * A http-tunnel connection is established between client and server
	 */
    var HTTP = 1;

    /**
        * A websocket connection is established between client and server
    **/
    var WEBSOCKET = 2;

    public function name():String {
        return switch (this) {
            case 0: "SOCKET";
            case 1: "HTTP";
            case 2: "WEBSOCKET";
            default: throw 'Unknown name for ConnectionMode: $this';
        }
    }
}
