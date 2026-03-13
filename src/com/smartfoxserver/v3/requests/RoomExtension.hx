package com.smartfoxserver.v3.requests;

/**
 * The <em>RoomExtension</em> class contains a specific subset of the
 * <em>RoomSettings</em> required to create a Room. It defines which server-side
 * Extension should be attached to the Room upon creation.
 * <p/>
 * <p>
 * The client can communicate with the Room Extension by means of the
 * <em>ExtensionRequest</em> request.
 * </p>
 *
 * @see com.smartfoxserver.v3.requests.RoomSettings#getExtension()
 * @see CreateRoomRequest
 * @see ExtensionRequest
 */
class RoomExtension
{
	private var id:String; 				// <-- mandatory
	private var className:String; 		// <-- mandatory
	private var propertiesFile:String; 	// <-- optional

	/**
	 * Creates a new <em>RoomExtension</em> instance. The
	 * <em>RoomSettings.extension</em> property must be set to this instance during
	 * Room creation.
	 *
	 * @param id        The name of the Extension as deployed on the server; it's
	 *                  the name of the folder containing the Extension classes
	 *                  inside the main
	 *                  <em>server/extensions/</em> folder.
	 * @param className The fully qualified name of the main class of the Extension.
	 * 
	 * @see com.smartfoxserver.v3.requests.RoomSettings#getExtension()
	 */
	public function new(id:String, className:String)
	{
		this.id = id;
		this.className = className;
		propertiesFile = "";
	}

	/**
	 * Returns the name of the Extension to be attached to the Room. It's the name
	 * of the server-side folder containing the Extension classes inside the main
	 * <em>server/extensions</em> folder.
	 *
	 * @see #RoomExtension(String, String)
	 */
	public function getId():String
	{
		return id;
	}

	/**
	 * Returns the fully qualified name of the main class of the Extension.
	 *
	 * @see #RoomExtension(String, String)
	 */
	public function getClassName():String
	{
		return className;
	}

	/**
	 * Defines the name of an optional properties file that should be loaded on the
	 * server-side during the Extension initialization. The file must be located in
	 * the server-side folder containing the Extension classes (see the <em>id</em>
	 * property).
	 *
	 * @see #getId()
	 */
	public function getPropertiesFile():String
	{
		return propertiesFile;
	}

	/**
	 * @see #getPropertiesFile()
	 */
	public function setPropertiesFile(fileName:String):Void
	{
		propertiesFile = fileName;
	}
}
