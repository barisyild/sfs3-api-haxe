package sfs3.client.requests.game;

import sfs3.client.entities.data.ISFSObject;

import sfs3.client.entities.match.MatchExpression;
import sfs3.client.requests.RoomSettings;


/**
 * The <em>SFSGameSettings</em> class is a container for the settings required to create a Game Room using the <em>CreateSFSGameRequest</em> request.
 * <p/>
 * <p>On the server-side, a Game Room is represented by the <em>SFSGame</em> Java class which extends the <em>Room</em> class
 * providing new advanced features such as player matching, game invitations, public and private games, quick game joining etc.
 * On the client side Game Rooms are available as a regular Rooms, with their <em>isGame</em> property set to <code>true</code>.</p>
 *
 * @see 	CreateSFSGameRequest
 * @see		sfs3.client.entities.Room
 */
@:expose("SFS3.SFSGameSettings")
class SFSGameSettings extends RoomSettings 
{
	private var _isPublic:Bool;
	private var minPlayersToStartGame:Int;
	private var invitedPlayers:Array<Dynamic>;
	private var searchableRooms:Array<String>;
	private var playerMatchExpression:MatchExpression;
	private var spectatorMatchExpression:MatchExpression;
	private var invitationExpiryTime:Int;
	private var leaveJoinedLastRoom:Bool;
	private var notifyGameStarted:Bool;
	private var invitationParams:ISFSObject;

	/**
	 * Creates a new <em>SFSGameSettings</em> instance.
	 * The instance must be passed to the <em>CreateSFSGameRequest</em> class constructor.
	 *
	 * @param	name	The name of the Game Room to be created.
	 * 
	 * @see		CreateSFSGameRequest
	 */
	public function new(name:String) {
		super(name);

		_isPublic = true;
		minPlayersToStartGame = 2;
		invitationExpiryTime = 15;
		leaveJoinedLastRoom = true;

		invitedPlayers = new Array<Dynamic>();
		searchableRooms = new Array<String>();
	}

	/**
	 * Indicates whether the game is public or private.
	 * <p>A public game can be joined by any player whose User Variables match the <em>playerMatchExpression</em> assigned to the Game Room.
	 * A private game can be joined by users invited by the game creator by means of <em>invitedPlayers</em> list.</p>
	 * <p/>
	 * The default value is <code>true</code>.
	 *
	 * @see		#getPlayerMatchExpression()
	 * @see		#getInvitedPlayers()
	 */
	public function isPublic():Bool {
		return _isPublic;
	}

	/**
	 * Defines the minimum number of players required to start the game.
	 * If the <em>notifyGameStarted</em> property is set to <code>true</code>, when this number is reached, the game start is notified.
	 * <p/>
	 * The default value is <code>2</code>.
	 *
	 * @see		#getNotifyGameStarted()
	 */
	public function getMinPlayersToStartGame():Int {
		return minPlayersToStartGame;
	}

	/**
	 * In private games, defines a list of <em>User</em> objects representing players to be invited to join the game.
	 * <p/>
	 * <p>If the invitations are less than the minimum number of players required to start the game (see the <em>minPlayersToStartGame</em> property),
	 * the server will send additional invitations automatically, searching users in the Room Groups specified in the <em>searchableRooms</em> list
	 * and filtering them by means of the object passed to the <em>playerMatchExpression</em> property.</p>
	 * <p/>
	 * <p>The game matching criteria contained in the <em>playerMatchExpression</em> property do not apply to the users specified in this list.</p>
	 * <p/>
	 * The default value is <code>null</code>.
	 *
	 * @see 	#minPlayersToStartGame
	 * @see 	#searchableRooms
	 * @see 	#playerMatchExpression
	 * @see		sfs3.client.entities.User
	 */
	public function getInvitedPlayers():Array<Dynamic> {
		return invitedPlayers;
	}

	/**
	 * In private games, defines a list of Groups names where to search players to invite.
	 * <p/>
	 * <p>If the users invited to join the game (specified through the <em>invitedPlayers</em> property) are less than the minimum number of
	 * players required to start the game (see the <em>minPlayersToStartGame</em> property),
	 * the server will invite others automatically, searching them in Rooms belonging to the Groups specified in this list
	 * and filtering them by means of the object passed to the <em>playerMatchExpression</em> property.</p>
	 * <p/>
	 * The default value is <code>null</code>.
	 *
	 * @see		#getInvitedPlayers()
	 * @see		#getMinPlayersToStartGame()
	 * @see 	#getPlayerMatchExpression()
	 */
	public function getSearchableRooms():Array<String> {
		return searchableRooms;
	}

	/**
	 * In private games, defines the number of seconds that the users invited to join the game have to reply to the invitation.
	 * The suggested range is 10 to 40 seconds.
	 * <p/>
	 * The default value is <code>15</code>.
	 */
	public function getInvitationExpiryTime():Int {
		return invitationExpiryTime;
	}

	/**
	 * In private games, indicates whether the players must leave the previous Room when joining the game or not.
	 * <p/>
	 * <p>This setting applies to private games only because users join the Game Room automatically when they accept the invitation to play,
	 * while public games require a <em>JoinRoomRequest</em> request to be sent, where this behavior can be determined manually.</p>
	 * <p/>
	 * The default value is <code>true</code>.
	 */
	public function getLeaveLastJoinedRoom():Bool {
		return leaveJoinedLastRoom;
	}

	/**
	 * Indicates if a game state change must be notified when the minimum number of players is reached.
	 * <p/>
	 * <p>If this setting is <code>true</code>, the game state (started or stopped) is handled by means of the reserved Room Variable
	 * represented by the <em>ReservedRoomVariables.RV_GAME_STARTED</em> constant. Listening to the <em>roomVariablesUpdate</em> event for this variable
	 * allows clients to be notified when the game can start due to minimum number of players being reached.</p>
	 * <p/>
	 * <p>As the used Room Variable is created as <em>global</em> (see the <em>SFSRoomVariable</em> class description), its update is broadcast outside the Room too:
	 * this can be used on the client-side, for example, to show the game state in a list of available games.</p>
	 * <p/>
	 * The default value is <code>false</code>.
	 *
	 * @see 	sfs3.client.entities.variables.ReservedRoomVariables#RV_GAME_STARTED
	 * @see		sfs3.client.core.SFSEvent#ROOM_VARIABLES_UPDATE
	 * @see		sfs3.client.entities.variables.SFSRoomVariable
	 */
	public function getNotifyGameStarted():Bool {
		return notifyGameStarted;
	}

	/**
	 * Defines the game matching expression to be used to filters players.
	 * <p/>
	 * <p>Filtering is applied when:
	 * <ol>
	 * <li>users try to join a public Game Room as players (their User Variables must match the matching criteria);</li>
	 * <li>the server selects additional users to be invited to join a private game (see the <em>searchableRooms</em> property).</li>
	 * </ol>
	 * </p>
	 * <p/>
	 * <p>Filtering is not applied to users invited by the creator to join a private game (see the <em>invitedPlayers</em> property).</p>
	 * <p/>
	 * The default value is <code>null</code>.
	 *
	 * @see		#getSearchableRooms()
	 * @see		#getInvitedPlayers()
	 * @see 	#getSpectatorMatchExpression()
	 */
	public function getPlayerMatchExpression():MatchExpression {
		return playerMatchExpression;
	}

	/**
	 * Defines the game matching expression to be used to filters spectators.
	 * <p/>
	 * <p>Filtering is applied when users try to join a public Game Room as spectators (their User Variables must match the matching criteria).</p>
	 * <p/>
	 * The default value is <code>null</code>.
	 *
	 * @see 	#getPlayerMatchExpression()
	 */
	public function getSpectatorMatchExpression():MatchExpression {
		return spectatorMatchExpression;
	}

	/**
	 * In private games, defines an optional object containing additional custom parameters to be sent together with the invitation.
	 * <p>This object must be an instance of <em>SFSObject</em>. Possible custom parameters to be transferred to the invitees are
	 * a message for the recipient, the game details (title, type...), the inviter details, etc.</p>
	 * <p/>
	 * The default value is <code>null</code>.
	 *
	 * @see		sfs3.client.entities.data.SFSObject
	 */
	public function getInvitationParams():ISFSObject {
		return invitationParams;
	}

	/**
	 * @see		#isPublic()
	 */
	public function setPublic(isPublic:Bool):SFSGameSettings 
	{
		this._isPublic = isPublic;
		return this;
	}

	/**
	 * @see 	#getMinPlayersToStartGame()
	 */
	public function setMinPlayersToStartGame(minPlayersToStartGame:Int):SFSGameSettings 
	{
		this.minPlayersToStartGame = minPlayersToStartGame;
		return this;
	}

	/**
	 * @see		#getInvitedPlayers()
	 */
	public function setInvitedPlayers(invitedPlayers:Array<Dynamic>):SFSGameSettings 
	{
		this.invitedPlayers = invitedPlayers.copy();
		return this;
	}

	/**
	 * @see 	#getSearchableRooms()
	 */
	public function setSearchableRooms(searchableRooms:Array<String>):SFSGameSettings 
	{
		this.searchableRooms = searchableRooms.copy();
		return this;
	}

	/**
	 * @see		#getInvitationExpiryTime()
	 */
	public function setInvitationExpiryTime(invitationExpiryTime:Int):SFSGameSettings 
	{
		this.invitationExpiryTime = invitationExpiryTime;
		return this;
	}

	/**
	 * @see		#getLeaveLastJoinedRoom()
	 */
	public function setLeaveLastJoinedRoom(leaveLastJoinedRoom:Bool):SFSGameSettings 
	{
		leaveJoinedLastRoom = leaveLastJoinedRoom;
		return this;
	}

	/**
	 * @see		#getNotifyGameStarted()
	 */
	public function setNotifyGameStarted(notifyGameStarted:Bool):SFSGameSettings 
	{
		this.notifyGameStarted = notifyGameStarted;
		return this;
	}

	/**
	 * @see		#getPlayerMatchExpression()
	 */
	public function setPlayerMatchExpression(playerMatchExpression:MatchExpression):SFSGameSettings 
	{
		this.playerMatchExpression = playerMatchExpression;
		return this;
	}

	/**
	 * @see		#getSpectatorMatchExpression()
	 */
	public function setSpectatorMatchExpression(spectatorMatchExpression:MatchExpression):SFSGameSettings 
	{
		this.spectatorMatchExpression = spectatorMatchExpression;
		return this;
	}

	/**
	 * @see		#getInvitationParams()
	 */
	public function setInvitationParams(invitationParams:ISFSObject):SFSGameSettings 
	{
		this.invitationParams = invitationParams;
		return this;
	}
}
