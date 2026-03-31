package sfs3.client.util;

import haxe.crypto.Sha256;
import haxe.io.Bytes;

@:expose("SFS3.PasswordUtil")
/**
 * Helper class for logging in with a pre-hashed password.<br>
 * You will need it if your server-side database store User passwords hashed with MD5/SHA256
 * <p>
 *
 */
class PasswordUtil {
    /**
	 * Generates a SHA256 hash of the user password, represented as hex string of 64 characters.
	 * For more info see: https://en.wikipedia.org/wiki/SHA-2
	 * <p>
	 * <b>Example</b><br> The following example shows how to send a pre-hashed password:
	 * <pre>
	 * {@code
	 * 	String userName = "MyUserName";
	 * 	String userPass = "MyPassword123";
	 *
	 * 	String shaPass = PasswordUtil.SHA256Password(userPass);
	 * 	sfs.send(new LoginRequest(userName, shaPass, sfs.getConfig().getZone()));
	 * }
	 * </pre>
	 *
	 * @param pass 	the password in clear
	 * @return		the hashed password
	 */
    public static function SHA256Password(pass:String):String {
        return Sha256.encode(pass).toUpperCase();
    }

    public static function bytesToHexString(bytes:Bytes):String {
        return bytes.toHex().toUpperCase();
    }
}
