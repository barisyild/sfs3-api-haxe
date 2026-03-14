package com.smartfoxserver.v3.requests;

import com.smartfoxserver.v3.entities.data.ISFSObject;
import com.smartfoxserver.v3.entities.data.SFSObject;

import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.exceptions.SFSValidationException;
import com.smartfoxserver.v3.bitswarm.TransportType;
import com.smartfoxserver.v3.entities.Room;

/**
 * <p>
 * Sends a command to the server-side Extension attached to the Zone or to a
 * Room.
 * <p/>
 * 
 * <p>
 * This request is used to send custom commands from the client to a server-side
 * Extension, be it a Zone-level or Room-level Extension. Also, the
 * <em>extensionResponse</em> event is used by the server to send Extension
 * commands/responses to the client.
 * </p>
 * 
 * <p>
 * Read the SmartFoxServer 3 documentation about server-side Extension for more
 * informations.
 * </p>
 * <p>
 * By default <em>ExtensionRequest</em> is sent via TCP but it's also possible to use UDP protocol instead,
 * provided a UDP connection is already established. (see the <em>SmartFox.isUdpConnected()</em>).
 * </p>
 *
 * @see com.smartfoxserver.v3.SmartFox#connectUdp()
 * @see com.smartfoxserver.v3.SmartFox#isUdpConnected()
 * @see com.smartfoxserver.v3.core.SFSEvent#EXTENSION_RESPONSE
 */
@:expose("SFS3.ExtensionRequest")
class ExtensionRequest extends BaseRequest
{
	/**
	 * @internal
	 */
	public static final KEY_CMD:String = "c";

	/**
	 * @internal
	 */
	public static final KEY_PARAMS:String = "p";

	/**
	 * @internal
	 */
	public static final KEY_ROOM:String = "r";
	
	/*
	 * Special key for UDP messages to only.
	 * It encodes the sender's userId
	 */
	private static final KEY_USER:String = "u";

	private var extCmd:String;
	private var params:ISFSObject;
	private var room:Room;

	/**
	 * Creates a new <em>ExtensionRequest</em> instance. The instance must be passed
	 * to the <em>SmartFox.send()</em> method for the request to be performed.
	 *
	 * @param extCmd The name of the command which identifies an action that should
	 *               be executed by the server-side Extension.
	 * @param params An instance of <em>ISFSObject</em> containing custom data to be
	 *               sent to the Extension. Can be null if no data needs to be sent.
	 * @param room   If <code>null</code>, the specified command is sent to the
	 *               current Zone server-side Extension; if not <code>null</code>,
	 *               the command is sent to the server-side Extension attached to
	 *               the passed Room.
	 * @param txType specify the protocol to use. Default is TCP.
	 * 
	 * @see com.smartfoxserver.v3.SmartFox#send
	 * @see com.smartfoxserver.v3.entities.data.SFSObject SFSObject
	 */
	public function new(extCmd:String, ?params:ISFSObject = null, ?room:Room = null, ?txType:TransportType = null)
	{
		super(BaseRequest.CallExtension);
		targetController = 1;

		this.extCmd = extCmd;
		this.params = params;
		this.room = room;

        if (txType != null)
		    setTransportType(txType);
        else
            setTransportType(TransportType.TCP);

		if (this.params == null)
			this.params = new SFSObject();
	}

	/**
	 * @internal
	 */
	public function validate(sfs:ISmartFox):Void
	{
		var errors = new Array<String>();

		if (extCmd == null || extCmd.length == 0)
			errors.push("Missing extension command");

		if (errors.length > 0)
			throw new SFSValidationException("ExtensionCall request error", errors);
	}

	/**
	 * @internal
	 */
	public function execute(sfs:ISmartFox):Void
	{
		sfso.putString(KEY_CMD, extCmd);
		sfso.putSFSObject(KEY_PARAMS, params);
		
		if (room != null)
			sfso.putInt(KEY_ROOM, room.getId());
			
		// Necessary only for UDP
		if (getTransportType() != TransportType.TCP)
			sfso.putInt(KEY_USER, sfs.getMySelf().getId());
	}
}
