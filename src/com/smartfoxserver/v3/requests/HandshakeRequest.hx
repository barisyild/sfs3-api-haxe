package com.smartfoxserver.v3.requests;

@:expose("SFS3.HandshakeRequest")
class HandshakeRequest extends BaseRequest
{
    /**
	 * <b>*Private*</b>
	 */
    public static final KEY_SESSION_TOKEN:String = "tk";

    /**
	 * <b>*Private*</b>
	 */
    public static final KEY_API:String = "api";

    /**
	 * <b>*Private*</b>
	 */
    public static final KEY_COMPRESSION_THRESHOLD:String = "ct";

    /**
	 * <b>*Private*</b>
	 */
    public static final KEY_RECONNECTION_TOKEN:String = "rt";

    /**
	 * <b>*Private*</b>
	 */
    public static final KEY_CLIENT_TYPE:String = "cl";

    /**
	 * <b>*Private*</b>
	 */
    public static final KEY_MAX_MESSAGE_SIZE:String = "ms";

    public function new(apiVersion:String, reconnectionToken:String, clientType:String)
    {
        super(BaseRequest.Handshake);

        // api version
        sfso.putShortString(KEY_API, apiVersion);

        // client signature (platform + version, e.g. "Android Client 2.0")
        sfso.putShortString(KEY_CLIENT_TYPE, clientType);

        // send reconnection token, if any
        if (reconnectionToken != null)
            sfso.putShortString(KEY_RECONNECTION_TOKEN, reconnectionToken);
    }

    public function validate(sfs:ISmartFox):Void {
    }

    public function execute(sfs:ISmartFox):Void {
    }
}
