package com.smartfoxserver.v3.requests;

import com.smartfoxserver.v3.entities.data.ISFSArray;
import com.smartfoxserver.v3.entities.data.SFSArray;

import com.smartfoxserver.v3.ISmartFox;
import com.smartfoxserver.v3.exceptions.SFSValidationException;
import com.smartfoxserver.v3.entities.Room;
import com.smartfoxserver.v3.entities.variables.RoomVariable;
import com.smartfoxserver.v3.requests.mmo.MMORoomSettings;

/**
 * Creates a new Room in the current Zone.
 * <p/>
 * <p>If the creation is successful, a <em>roomAdd</em> event is dispatched to all the users who subscribed the Group to which the Room is associated, including the Room creator.
 * Otherwise, a <em>roomCreationError</em> event is returned to the creator's client.</p>
 * <p/>
 * <p/>
 *
 * @see		com.smartfoxserver.v3.core.SFSEvent#ROOM_ADD
 * @see		com.smartfoxserver.v3.core.SFSEvent#ROOM_CREATION_ERROR
 */
@:expose("SFS3.CreateRoomRequest")
class CreateRoomRequest extends BaseRequest {
	/**
	 * @internal
	 */
	public static final KEY_ROOM:String = "r";

	/**
	 * @internal
	 */
	public static final KEY_NAME:String = "n";

	/**
	 * @internal
	 */
	public static final KEY_PASSWORD:String = "p";

	/**
	 * @internal
	 */
	public static final KEY_GROUP_ID:String = "g";

	/**
	 * @internal
	 */
	public static final KEY_ISGAME:String = "ig";

	/**
	 * @internal
	 */
	public static final KEY_MAXUSERS:String = "mu";

	/**
	 * @internal
	 */
	public static final KEY_MAXSPECTATORS:String = "ms";

	/**
	 * @internal
	 */
	public static final KEY_MAXVARS:String = "mv";

	/**
	 * @internal
	 */
	public static final KEY_ROOMVARS:String = "rv";

	/**
	 * @internal
	 */
	public static final KEY_PERMISSIONS:String = "pm";

	/**
	 * @internal
	 */
	public static final KEY_EVENTS:String = "ev";

	/**
	 * @internal
	 */
	public static final KEY_EXTID:String = "xn";

	/**
	 * @internal
	 */
	public static final KEY_EXTCLASS:String = "xc";

	/**
	 * @internal
	 */
	public static final KEY_EXTPROP:String = "xp";

	/**
	 * @internal
	 */
	public static final KEY_AUTOJOIN:String = "aj";

	/**
	 * @internal
	 */
	public static final KEY_ROOM_TO_LEAVE:String = "rl";
	
	/**
	 * @internal
	 */
	public static final KEY_ALLOW_JOIN_INVITATION_BY_OWNER:String = "aji";
	
	//--- MMORoom Params --------------------------------------------------------
	
	/**
	 * @internal
	 */
	public static final KEY_MMO_DEFAULT_AOI:String = "maoi";
	
	/**
	 * @internal
	 */
	public static final KEY_MMO_MAP_LOW_LIMIT:String = "mllm";
	
	/**
	 * @internal
	 */
	public static final KEY_MMO_MAP_HIGH_LIMIT:String = "mlhm";
	
	/**
	 * @internal
	 */
	public static final KEY_MMO_USER_MAX_LIMBO_SECONDS:String = "muls";
	
	/**
	 * @internal
	 */
	public static final KEY_MMO_PROXIMITY_UPDATE_MILLIS:String = "mpum";
	
	/**
	 * @internal
	 */
	public static final KEY_MMO_SEND_ENTRY_POINT:String = "msep";


	private var settings:RoomSettings;
	private var autoJoin:Bool;
	private var roomToLeave:Room;


	/**
	 * Creates a new <em>CreateRoomRequest</em> instance.
	 * The instance must be passed to the <em>SmartFox.send()</em> method for the request to be performed.
	 *
	 * @param	settings	An object containing the Room configuration settings.
	 * @param	autoJoin	If <code>true</code>, the Room is joined as soon as it is created.
	 * @param	roomToLeave	A <em>Room</em> object representing the Room that should be left if the new Room is auto-joined.
	 * 
	 * @see		com.smartfoxserver.v3.SmartFox#send
	 * @see		RoomSettings
	 * @see		com.smartfoxserver.v3.entities.Room
	 */
	public function new(settings:RoomSettings, ?autoJoin:Bool = false, ?roomToLeave:Room = null) 
	{
		super(BaseRequest.CreateRoom);

		this.settings = settings;
		this.autoJoin = autoJoin;
		this.roomToLeave = roomToLeave;
	}

	/**
	 * @internal
	 */
	public function validate(sfs:ISmartFox):Void
	{
		var errors = new Array<String>();
	
		if (settings.getName() == null || settings.getName().length == 0) 
			errors.push("Missing room name");

		if (settings.getMaxUsers() <= 0) 
			errors.push("maxUsers must be > 0");

		if (settings.getExtension() != null) 
		{
			if (settings.getExtension().getClassName() == null || settings.getExtension().getClassName().length == 0) 
				errors.push("Missing Extension class name");

			if (settings.getExtension().getId() == null || settings.getExtension().getId().length == 0) 
				errors.push("Missing Extension id");
		}

		// ::: MMO Room Settings :::::::::::::::::::::::::::::::::::
		if (Std.isOfType(settings, MMORoomSettings))
		{
			var mmoSettings:MMORoomSettings = cast settings;
			
			if (mmoSettings.getDefaultAOI() == null)
				errors.push("Missing default AOI (area of interest)");
			
			if (mmoSettings.getMapLimits() != null && (mmoSettings.getMapLimits().getLowerLimit() == null || mmoSettings.getMapLimits().getHigherLimit() == null))
				errors.push("Map limits must be both defined");
		}
		
		
		if (errors.length > 0) 
			throw new SFSValidationException("CreateRoom request error", errors);
	}

	/**
	 * @internal
	 */
	public function execute(sfs:ISmartFox):Void
	{
		sfso.putString(KEY_NAME, settings.getName());
		sfso.putString(KEY_GROUP_ID, settings.getGroupId());
		sfso.putString(KEY_PASSWORD, settings.getPassword());
		sfso.putBool(KEY_ISGAME, settings.isGame());
		sfso.putShort(KEY_MAXUSERS, settings.getMaxUsers());
		sfso.putShort(KEY_MAXSPECTATORS, settings.getMaxSpectators());
		sfso.putShort(KEY_MAXVARS, settings.getMaxVariables());
		sfso.putBool(KEY_ALLOW_JOIN_INVITATION_BY_OWNER, settings.allowOwnerOnlyInvitation());

		// Room Variables
		if (settings.getVariables() != null && settings.getVariables().length > 0) 
		{
			var roomVars:ISFSArray = new SFSArray();

			for (rVar in settings.getVariables()) 
			{
				roomVars.addSFSArray(rVar.toSFSArray());
			}

			sfso.putSFSArray(KEY_ROOMVARS, roomVars);
		}

		// Handle Permissions
		if (settings.getPermissions() != null) 
		{
			var sfsPermissions = new Array<Bool>();
			sfsPermissions.push(settings.getPermissions().getAllowNameChange());
			sfsPermissions.push(settings.getPermissions().getAllowPasswordStateChange());
			sfsPermissions.push(settings.getPermissions().getAllowPublicMessages());
			sfsPermissions.push(settings.getPermissions().getAllowResizing());

			sfso.putBoolArray(KEY_PERMISSIONS, sfsPermissions);
		}

		// Handle Events
		if (settings.getEvents() != null) 
		{
			var sfsEvents = new Array<Bool>();
			sfsEvents.push(settings.getEvents().getAllowUserEnter());
			sfsEvents.push(settings.getEvents().getAllowUserExit());
			sfsEvents.push(settings.getEvents().getAllowUserCountChange());
			sfsEvents.push(settings.getEvents().getAllowUserVariablesUpdate());

			sfso.putBoolArray(KEY_EVENTS, sfsEvents);
		}

		// Handle Extension data
		if (settings.getExtension() != null) 
		{
			sfso.putString(KEY_EXTID, settings.getExtension().getId());
			sfso.putString(KEY_EXTCLASS, settings.getExtension().getClassName());

			// Send the properties file only if was specified
			if (settings.getExtension().getPropertiesFile() != null && settings.getExtension().getPropertiesFile().length > 0) 
				sfso.putString(KEY_EXTPROP, settings.getExtension().getPropertiesFile());
		}
		
		//--- MMO Rooms ------------------------------------------------------------------------
		if (Std.isOfType(settings, MMORoomSettings))
		{
			var mmoSettings:MMORoomSettings = cast settings;
			var useFloats:Bool = mmoSettings.getDefaultAOI().isFloat();
			
			if (useFloats)
			{
				sfso.putFloatArray(KEY_MMO_DEFAULT_AOI, mmoSettings.getDefaultAOI().toFloatArray());

				if (mmoSettings.getMapLimits() != null)
				{
					sfso.putFloatArray(KEY_MMO_MAP_LOW_LIMIT, mmoSettings.getMapLimits().getLowerLimit().toFloatArray());
					sfso.putFloatArray(KEY_MMO_MAP_HIGH_LIMIT, mmoSettings.getMapLimits().getHigherLimit().toFloatArray());
				}
			}
			else
			{
				sfso.putIntArray(KEY_MMO_DEFAULT_AOI, mmoSettings.getDefaultAOI().toIntArray());

				if (mmoSettings.getMapLimits() != null)
				{
					sfso.putIntArray(KEY_MMO_MAP_LOW_LIMIT, mmoSettings.getMapLimits().getLowerLimit().toIntArray());
					sfso.putIntArray(KEY_MMO_MAP_HIGH_LIMIT, mmoSettings.getMapLimits().getHigherLimit().toIntArray());
				}
			}
			
			sfso.putShort(KEY_MMO_USER_MAX_LIMBO_SECONDS, mmoSettings.getUserMaxLimboSeconds());
			sfso.putShort(KEY_MMO_PROXIMITY_UPDATE_MILLIS, mmoSettings.getProximityListUpdateMillis());
			sfso.putBool(KEY_MMO_SEND_ENTRY_POINT, mmoSettings.isSendAOIEntryPoint());
		}

		// AutoJoin
		sfso.putBool(KEY_AUTOJOIN, autoJoin);

		// Room to leave
		if (roomToLeave != null) 
			sfso.putInt(KEY_ROOM_TO_LEAVE, roomToLeave.getId());
		
	}
}
