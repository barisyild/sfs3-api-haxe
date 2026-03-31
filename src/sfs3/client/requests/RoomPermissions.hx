package sfs3.client.requests;

/**
 * The <em>RoomPermissions</em> class contains a specific subset of the
 * <em>RoomSettings</em> required to create a Room. It defines which operations
 * users will be able to execute on the Room after its creation.
 *
 * @see sfs3.client.requests.RoomSettings#getPermissions()
 * @see CreateRoomRequest
 */
@:expose("SFS3.RoomPermissions")
class RoomPermissions
{
	private var allowNameChange:Bool;
	private var allowPasswordStateChange:Bool;
	private var allowPublicMessages:Bool;
	private var allowResizing:Bool;

	/**
	 * Creates a new <em>RoomPermissions</em> instance. The
	 * <em>RoomSettings.permissions</em> property must be set to this instance
	 * during Room creation.
	 *
	 * @see RoomSettings#getPermissions()
	 */
	public function new() { }

	/**
	 * Indicates whether changing the Room name after its creation is allowed or
	 * not.
	 * <p/>
	 * <p>
	 * The Room name can be changed by means of the <em>ChangeRoomNameRequest</em>
	 * request.
	 * </p>
	 * <p/>
	 * The default value is <code>false</code>
	 *
	 * @see ChangeRoomNameRequest
	 */
	public function getAllowNameChange():Bool
	{
		return allowNameChange;
	}

	/**
	 * @see #getAllowNameChange()
	 */
	public function setAllowNameChange(allowNameChange:Bool):RoomPermissions
	{
		this.allowNameChange = allowNameChange;
		return this;
	}

	/**
	 * Indicates whether changing (or removing) the Room password after its creation
	 * is allowed or not.
	 * <p/>
	 * <p>
	 * The Room password can be changed by means of the
	 * <em>ChangeRoomPasswordStateRequest</em> request.
	 * </p>
	 * <p/>
	 * The default value is <code>false</code>
	 *
	 * @see ChangeRoomPasswordStateRequest
	 */
	public function getAllowPasswordStateChange():Bool
	{
		return allowPasswordStateChange;
	}

	/**
	 * @see #getAllowPasswordStateChange()
	 */
	public function setAllowPasswordStateChange(allowPasswordStateChange:Bool):RoomPermissions
	{
		this.allowPasswordStateChange = allowPasswordStateChange;
		return this;
	}

	/**
	 * Indicates whether users inside the Room are allowed to send public messages
	 * or not.
	 * <p/>
	 * <p>
	 * Public messages can be sent by means of the <em>PublicMessageRequest</em>
	 * request.
	 * </p>
	 * <p/>
	 * The default value is <code>false</code>
	 *
	 * @see PublicMessageRequest
	 */
	public function getAllowPublicMessages():Bool
	{
		return allowPublicMessages;
	}

	/**
	 * @see #getAllowPublicMessages()
	 */
	public function setAllowPublicMessages(allowPublicMessages:Bool):RoomPermissions
	{
		this.allowPublicMessages = allowPublicMessages;
		return this;
	}

	/**
	 * Indicates whether the Room capacity can be changed after its creation or not.
	 * <p/>
	 * <p>
	 * The capacity is the maximum number of users and spectators (in Game Rooms)
	 * allowed to enter the Room. It can be changed by means of the
	 * <em>ChangeRoomCapacityRequest</em> request.
	 * </p>
	 * <p/>
	 * The default value is <code>false</code>
	 *
	 * @see ChangeRoomCapacityRequest
	 */
	public function getAllowResizing():Bool
	{
		return allowResizing;
	}

	/**
	 * @see #getAllowResizing()
	 */
	public function setAllowResizing(allowResizing:Bool):RoomPermissions
	{
		this.allowResizing = allowResizing;
		return this;
	}
}
