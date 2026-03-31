package sfs3.client.requests;

import sfs3.client.entities.data.ISFSObject;
import sfs3.client.entities.data.SFSObject;

import sfs3.client.ISmartFox;
import sfs3.client.bitswarm.TransportType;
import sfs3.client.entities.Room;

/**
 * An alternative version of ExtensionRequest that can be run asynchronously on the server side.
 * While all requests are processed and executed sequentially, in the order they're sent to the server side, there can be a few situations where
 * running requests in parallel could be useful.
 * 
 * <p>
 * For instance if you're sending fast updates to the server in a real-time game and you need to send the occasional request
 * that talks to a database or other slow-responding services, you may disrupt the timing of the updates.<br>
 * 
 * To avoid this use the ExtensionAsyncRequest, which will run on a separate virtual thread and don't block the subsequent requests
 * 
 * @see ExtensionRequest
 */
@:expose("SFS3.ExtensionAsyncRequest")
class ExtensionAsyncRequest extends ExtensionRequest
{
	private static final KEY_ASYNC:String = "a";
	
	public function new(extCmd:String, ?params:ISFSObject = null, ?room:Room = null, ?txType:TransportType = null)
	{
        if (params == null) params = new SFSObject();
        if (txType == null) txType = TransportType.TCP;

		super(extCmd, params, room, txType);
	}
	
	/**
	 * @internal
	 */
	override public function execute(sfs:ISmartFox):Void
	{
		super.execute(sfs);
		sfso.putNull(KEY_ASYNC);
	}
}
