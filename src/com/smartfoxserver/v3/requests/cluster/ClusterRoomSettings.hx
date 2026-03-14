package com.smartfoxserver.v3.requests.cluster;

import com.smartfoxserver.v3.entities.data.ISFSObject;

import com.smartfoxserver.v3.entities.match.MatchExpression;
import com.smartfoxserver.v3.requests.RoomSettings;

@:expose("SFS3.ClusterRoomSettings")
class ClusterRoomSettings extends RoomSettings
{
	private var _isPublic:Bool;
	private var minPlayersToStartGame:Int;
	private var invitedPlayers:Array<Dynamic>;
	private var playerMatchExpression:MatchExpression;
	private var spectatorMatchExpression:MatchExpression;
	private var invitationExpiryTime:Int;
	private var notifyGameStarted:Bool;
	private var invitationParams:ISFSObject;
	
	public function new(name:String) 
	{
		super(name);

		_isPublic = true;
		minPlayersToStartGame = 2;
		invitationExpiryTime = 30;
	
		invitedPlayers = new Array<Dynamic>();
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
	public function isPublic():Bool
	{
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
	public function getMinPlayersToStartGame():Int 
	{
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
	 * @see		com.smartfoxserver.v3.entities.User
	 */
	public function getInvitedPlayers():Array<Dynamic> 
	{
		return invitedPlayers;
	}
	
	/**
	 * In private games, defines the number of seconds that the users invited to join the game have to reply to the invitation.
	 * The suggested range is 30 to 60 seconds.
	 * <p/>
	 * The default value is <code>40</code>.
	 */
	public function getInvitationExpiryTime():Int 
	{
		return invitationExpiryTime;
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
	 * @see 	com.smartfoxserver.v3.entities.variables.ReservedRoomVariables#RV_GAME_STARTED
	 * @see		com.smartfoxserver.v3.core.SFSEvent#ROOM_VARIABLES_UPDATE
	 * @see		com.smartfoxserver.v3.entities.variables.SFSRoomVariable
	 */
	public function getNotifyGameStarted():Bool 
	{
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
	public function getPlayerMatchExpression():MatchExpression 
	{
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
	 * @see		com.smartfoxserver.v3.entities.data.SFSObject
	 */
	public function getInvitationParams():ISFSObject 
	{
		return invitationParams;
	}

	/**
	 * @see		#isPublic()
	 */
	public function setPublic(isPublic:Bool):ClusterRoomSettings 
	{
		this._isPublic = isPublic;
		return this;
	}

	/**
	 * @see 	#getMinPlayersToStartGame()
	 */
	public function setMinPlayersToStartGame(minPlayersToStartGame:Int):ClusterRoomSettings 
	{
		this.minPlayersToStartGame = minPlayersToStartGame;
		return this;
	}

	/**
	 * @see		#getInvitedPlayers()
	 */
	public function setInvitedPlayers(invitedPlayers:Array<Dynamic>):ClusterRoomSettings 
	{
		this.invitedPlayers = invitedPlayers.copy();
		return this;
	}

	/**
	 * @see		#getInvitationExpiryTime()
	 */
	public function setInvitationExpiryTime(invitationExpiryTime:Int):ClusterRoomSettings 
	{
		this.invitationExpiryTime = invitationExpiryTime;
		return this;
	}

	/**
	 * @see		#getNotifyGameStarted()
	 */
	public function setNotifyGameStarted(notifyGameStarted:Bool):ClusterRoomSettings 
	{
		this.notifyGameStarted = notifyGameStarted;
		return this;
	}

	/**
	 * @see		#getPlayerMatchExpression()
	 */
	public function setPlayerMatchExpression(playerMatchExpression:MatchExpression):ClusterRoomSettings 
	{
		this.playerMatchExpression = playerMatchExpression;
		return this;
	}

	/**
	 * @see		#getSpectatorMatchExpression()
	 */
	public function setSpectatorMatchExpression(spectatorMatchExpression:MatchExpression):ClusterRoomSettings 
	{
		this.spectatorMatchExpression = spectatorMatchExpression;
		return this;
	}

	/**
	 * @see		#getInvitationParams()
	 */
	public function setInvitationParams(invitationParams:ISFSObject):ClusterRoomSettings 
	{
		this.invitationParams = invitationParams;
		return this;
	}
}
