package com.smartfoxserver.v3.bitswarm;

import haxe.Http;
import com.smartfoxserver.v3.core.LoggerFactory;
import com.smartfoxserver.v3.core.Logger;
import com.smartfoxserver.v3.entities.data.SFSObject;
import com.smartfoxserver.v3.bitswarm.io.SysParam;
import com.smartfoxserver.v3.core.EventDispatcher;
import com.smartfoxserver.v3.core.EventParam;
import com.smartfoxserver.v3.core.IDispatchable;
import com.smartfoxserver.v3.util.WebServices;
import haxe.crypto.Base64;

/*
 * Some of the methods here are not referenced directly in this project but they are used
 * when the API are imported by our BitSmasher tool.
 * 
 * In particular the two-arguments constructor and the setCryptoStorageWrapper() method
 */
class CryptoInitializer implements IDispatchable
{
	private static final KEY_SESSION_TOKEN:String = "SessToken";
	private static final KEY_BINARY_KEYS:String = "BinKeys";
	
	private static var TARGET_SERVLET(get, never):String;
	private static function get_TARGET_SERVLET():String {
		return "/" + WebServices.BASE_SERVLET + "/" + WebServices.CRYPTO_MANAGER;
	}
	
	private var dispatcher:EventDispatcher;
	private var log:Logger;
	private var bitSwarm:BitSwarmClient;
	
	/*
	 * This is used to access the CryptoKey.
	 * We need a wrapper because regular API will hold the key at BitSwarm level while BitSmasher
	 * overrides the BitSwarm engine with its own implementation.
	 */
	private var storage:ICryptoStorage;
	
	public function new(bitSwarmClient:BitSwarmClient, ?wrapper:ICryptoStorage)
	{
		this.log = LoggerFactory.getLogger(Type.getClass(this));
		this.storage = new DefaultCryptoKeyStorage(bitSwarmClient);
		
		this.bitSwarm = bitSwarmClient;
		this.dispatcher = new EventDispatcher(this);
		
		if (wrapper != null)
			this.storage = wrapper;
		
		if (storage.getKey() != null)
			throw new haxe.Exception("Cryptography is already initialized!");
	}
	
	public function init():Void
	{
		var runner = function() {
			try {
				var targetUrl = "https://" +
								storage.getHttpHost() + ":" +
								storage.getHttpPort() +
								TARGET_SERVLET;
								
				var req = new Http(targetUrl);
				var token = bitSwarm.getSmartFox().getSessionToken();
				var query = KEY_SESSION_TOKEN + "=" + StringTools.urlEncode(token);
				
				req.setHeader("Content-length", Std.string(query.length));
				req.setHeader("Content-Type", "application/x-www-form-urlencoded");
				req.setPostData(query);
				
				req.onData = function(data:String) {
					onHttpResponse(data);
				};
				
				req.onError = function(error:String) {
					onHttpError(error);
				};
				
				req.request(true);
			} catch (ex:Dynamic) {
				onHttpError(Std.string(ex));
			}
		};
		
		bitSwarm.getThreadPool().submit(runner);
	}
	
	public function getDispatcher():EventDispatcher
	{
		return dispatcher;
	}
	
	/*
	 * Allows to pass a custom implementation of the storage, used by BitSmasher to override default behavior
	 */
	public function setCryptoStorageWrapper(wrapper:ICryptoStorage):Void
	{
		storage = wrapper;
	}
	
	/*
	 * Thread Run Code
	 */
	
	private function onHttpResponse(response:String):Void
	{
		try
		{
			var bytes = Base64.decode(response);
			
			var sfso = SFSObject.newFromBinaryData(bytes);
			
			var binKeys = sfso.getByteArray(KEY_BINARY_KEYS);
			var newToken = sfso.getString(KEY_SESSION_TOKEN);
			
			var ck = new CryptoKey(binKeys);
			storage.setKey(ck);
			
			var params = new Map<String, Dynamic>();
			params.set(EventParam.Success, true);
			params.set(SysParam.SessionToken, newToken);
			
			dispatcher.dispatchEvent(new CryptoEvent(CryptoEvent.Init, params));
		}
		catch (ex:Dynamic)
		{
			onHttpError(Std.string(ex));
		}
	}
	
	private function onHttpError(message:String):Void
	{
		log.warn("SSL Init Error: " + message);
		
		var params = new Map<String, Dynamic>();
		params.set(EventParam.Success, false);
		params.set(EventParam.ErrorMessage, message);
		
		dispatcher.dispatchEvent(new CryptoEvent(CryptoEvent.Init, params));
	}
}

/*
 * Default implementation of the CryptoKeyStorage
 */
class DefaultCryptoKeyStorage implements ICryptoStorage
{
	private var bitSwarm:BitSwarmClient;
	
	public function new(bitSwarm:BitSwarmClient)
	{
		this.bitSwarm = bitSwarm;
	}
	
	public function getKey():CryptoKey
	{
		return bitSwarm.getCryptoKey();
	}

	public function setKey(key:CryptoKey):Void
	{
		bitSwarm.setCryptoKey(key);
	}
	
	public function getHttpHost():String
	{
		return bitSwarm.getConfigData().host;
	}
	
	public function getHttpPort():Int
	{
		return bitSwarm.getConfigData().httpsPort;
	}
}
