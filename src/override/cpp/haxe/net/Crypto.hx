package haxe.net;

import haxe.io.Bytes;
import haxe.crypto.random.SecureRandom;

/**
 * cpp-target override: uses Math.random() instead of /dev/urandom
 * which does not exist on Windows.
 */
class Crypto {
	public static function getSecureRandomBytes(length:Int):Bytes {
		try {
			return SecureRandom.bytes(length);
		} catch (e:Dynamic) {
			// Fallback to Math.random() if SecureRandom is not available
			var out = Bytes.alloc(length);
			for (i in 0...length)
				out.set(i, Std.int(Math.random() * 256));
			return out;
		}
	}

	public static function getRandomString(length:Int, ?charactersToUse = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"):String {
		var str = "";
		for (i in 0...length)
			str += charactersToUse.charAt(Std.int(Math.random() * charactersToUse.length));
		return str;
	}
}
