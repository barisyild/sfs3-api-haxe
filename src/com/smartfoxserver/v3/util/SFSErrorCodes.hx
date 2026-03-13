package com.smartfoxserver.v3.util;
class SFSErrorCodes {
    private static var errorMap:Map<Int, String> = new Map();

    static function __init__():Void {
        errorMap.set(0, "Client API version is obsolete: %s; required version: %s"); 										// 0
        errorMap.set(1, "Requested Zone %s does not exist");
        errorMap.set(2, "User name not recognized or length is out of bounds: %s");
        errorMap.set(3, "Wrong password for user %s");
        errorMap.set(4, "User %s is banned");
        errorMap.set(5, "Zone %s is full");																					// 5
        errorMap.set(6, "User %s is already logged in Zone %s");
        errorMap.set(7, "The server is full");
        errorMap.set(8, "Zone %s is currently inactive");
        errorMap.set(9, "User name %s contains bad words; filtered: %s");
        errorMap.set(10, "Guest users not allowed in Zone %s");																// 10
        errorMap.set(11, "IP address %s is banned");
        errorMap.set(12, "A Room with the same name already exists: %s");
        errorMap.set(13, "Requested Group is not available - Room: %s; Group: %s");
        errorMap.set(14, "Bad Room name length -  Min: %s; max: %s; passed name length: %s");
        errorMap.set(15, "Room name contains bad words: %s");																// 15
        errorMap.set(16, "Zone is full; can't add Rooms anymore");
        errorMap.set(17, "You have exceeded the number of Rooms that you can create per session: %s");
        errorMap.set(18, "Room creation failed, wrong parameter: %s");
        errorMap.set(19, "User %s already joined in Room");
        errorMap.set(20, "Room %s is full");																				// 20
        errorMap.set(21, "Wrong password for Room %s");
        errorMap.set(22, "Requested Room does not exist");
        errorMap.set(23, "Room %s is locked");
        errorMap.set(24, "Group %s is already subscribed");
        errorMap.set(25, "Group %s does not exist");																		// 25
        errorMap.set(26, "Group %s is not subscribed");
        errorMap.set(27, "Group %s does not exist");
        errorMap.set(28, "%s");
        errorMap.set(29, "Room permission error; Room %s cannot be renamed");
        errorMap.set(30, "Room permission error; Room %s cannot change password statee");									// 30
        errorMap.set(31, "Room permission error; Room %s cannot change capacity");
        errorMap.set(32, "Switch user error; no player slots available in Room %s");
        errorMap.set(33, "Switch user error; no spectator slots available in Room %s");
        errorMap.set(34, "Switch user error; Room %s is not a Game Room");
        errorMap.set(35, "Switch user error; you are not joined in Room %s");												// 35
        errorMap.set(36, "Buddy Manager initialization error, could not load buddy list: %s");
        errorMap.set(37, "Buddy Manager error, your buddy list is full; size is %s");
        errorMap.set(38, "Buddy Manager error, was not able to block buddy %s because offline");
        errorMap.set(39, "Buddy Manager error, you are attempting to set too many Buddy Variables; limit is %s");
        errorMap.set(40, "Game %s access denied, user does not match access criteria");										// 40
        errorMap.set(41, "QuickJoinGame action failed: no matching Rooms were found");
        errorMap.set(42, "Your previous invitation reply was invalid or arrived too late");
    }


    /**
	 * Sets the text of the error message corresponding to the passed error code.
	 * </p>
	 * <b>NOTE:</b> you have to make sure you maintain all the placeholders while modifying the messages.
	 *
	 * @param	code		The code of the error message to be modified.
	 * @param	message		The new error message, including the placeholders for runtime informations.
	 *
	 * <p/>
	 * <b>Example</b><br/> The following example shows how to translate error 13 to French language retaining the required placeholders::
	 * <pre>
	 * {@code
	 * private void someMethod() {
	 *     SFSErrorCodes.setErrorMessage(13, "Le Groupe demandé n'est pas disponible - Salle: {0}; Groupe: {1}");
	 * }
	 * }
	 * </pre>
	 */
    public static function setErrorMessage(code:Int, message:String):Void
    {
        errorMap.set(code, message);
    }

    /**
	 * @internal
	 */
    public static function getErrorMessage(code:Int, params:Array<Dynamic> = null):String
    {
        return stringFormat(errorMap.get(code), params);
    }

    private static function stringFormat(ss:String, params:Array<Dynamic>):String
    {
        if(ss==null)
            return "";

        if(params !=null)
        {
            for(j in 0...params.length)
            {
                var src:String = "{" + j + "}";
                ss = StringTools.replace(ss,src, params[j]);
            }
        }

        return ss;
    }
}
