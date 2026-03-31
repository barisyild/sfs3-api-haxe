package sfs3.client.requests;

/**
 * The <em>RoomEvents</em> class contains a specific subset of the
 * <em>RoomSettings</em> required to create a Room. It defines which events
 * related to the Room will be fired by the <em>SmartFox</em> client.
 *
 * @see sfs3.client.requests.RoomSettings#getEvents()
 * @see CreateRoomRequest
 */
@:expose("SFS3.RoomEvents")
class RoomEvents
{
	private var allowUserEnter:Bool;
	private var allowUserExit:Bool;
	private var allowUserCountChange:Bool;
	private var allowUserVariablesUpdate:Bool;

	/**
	 * Creates a new <em>RoomEvents</em> instance. The <em>RoomSettings.events</em>
	 * property must be set to this instance during Room creation.
	 *
	 * @see sfs3.client.requests.RoomSettings#getEvents()
	 */
	public function new()
	{
		allowUserEnter = false;
		allowUserExit = false;
		allowUserCountChange = false;
		allowUserVariablesUpdate = false;
	}

	/**
	 * Indicates whether the <em>userEnterRoom</em> event should be dispatched
	 * whenever a user joins the Room or not.
	 * <p/>
	 * The default value is <code>false</code>
	 *
	 * @see sfs3.client.core.SFSEvent#USER_ENTER_ROOM
	 */
	public function getAllowUserEnter():Bool
	{
		return allowUserEnter;
	}

	/**
	 * @see #getAllowUserEnter()
	 */
	public function setAllowUserEnter(allowUserEnter:Bool):Void
	{
		this.allowUserEnter = allowUserEnter;
	}

	/**
	 * Indicates whether the <em>userExitRoom</em> event should be dispatched
	 * whenever a user leaves the Room or not.
	 * <p/>
	 * The default value is <code>false</code>
	 *
	 * @see sfs3.client.core.SFSEvent#USER_EXIT_ROOM
	 */
	public function getAllowUserExit():Bool
	{
		return allowUserExit;
	}

	/**
	 * @see #getAllowUserExit()
	 */
	public function setAllowUserExit(allowUserExit:Bool):Void
	{
		this.allowUserExit = allowUserExit;
	}

	/**
	 * Indicates whether or not the <em>userCountChange</em> event should be
	 * dispatched whenever the users (or players+spectators) count changes in the
	 * Room.
	 * <p/>
	 * The default value is <code>false</code>
	 *
	 * @see sfs3.client.core.SFSEvent#USER_COUNT_CHANGE
	 */
	public function getAllowUserCountChange():Bool
	{
		return allowUserCountChange;
	}

	/**
	 * @see #getAllowUserCountChange()
	 */
	public function setAllowUserCountChange(allowUserCountChange:Bool):Void
	{
		this.allowUserCountChange = allowUserCountChange;
	}

	/**
	 * Indicates whether or not the <em>userVariablesUpdate</em> event should be
	 * dispatched whenever a user in the Room updates his User Variables.
	 * <p/>
	 * The default value is <code>false</code>
	 *
	 * @see sfs3.client.core.SFSEvent#USER_VARIABLES_UPDATE
	 */
	public function getAllowUserVariablesUpdate():Bool
	{
		return allowUserVariablesUpdate;
	}

	/**
	 * @see #getAllowUserVariablesUpdate()
	 */
	public function setAllowUserVariablesUpdate(allowUserVariablesUpdate:Bool):Void
	{
		this.allowUserVariablesUpdate = allowUserVariablesUpdate;
	}
}
