package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.events.TimerEvent;

	import sfs3.client.*;
	import sfs3.client.core.*;
	import sfs3.client.requests.*;
	import sfs3.client.entities.data.*;
	import sfs3.client.bitswarm.*;
	import sfs3.client.core._Logger.LogLevel_Impl_;

	/**
	 * Sends echo packets across all TransportTypes (TCP, UDP, UDP_RELIABLE, UDP_UNRELIABLE)
	 * with small / medium / large payloads, then validates the returned data byte-by-byte.
	 */
	public class TransportValidator extends Sprite
	{
		private static var _instance:TransportValidator;

		private var sfs:SmartFox;
		private var cfg:ConfigData;
		private var tfDebug:TextField;

		private static const PAYLOAD_SMALL:int  = 64;
		private static const PAYLOAD_MEDIUM:int = 4096;
		private static const PAYLOAD_LARGE:int  = 32768;

		private static const TRANSPORT_TYPES:Array = [
			TransportType.TCP,
			TransportType.UDP,
			TransportType.UDP_RELIABLE,
			TransportType.UDP_UNRELIABLE
		];

		private static const TRANSPORT_NAMES:Array = [
			"TCP",
			"UDP",
			"UDP_RELIABLE",
			"UDP_UNRELIABLE"
		];

		private static const PAYLOAD_SIZES:Array  = [PAYLOAD_SMALL, PAYLOAD_MEDIUM, PAYLOAD_LARGE];
		private static const PAYLOAD_LABELS:Array  = ["SMALL", "MEDIUM", "LARGE"];

		private var testQueue:Array = [];
		private var pendingTests:Object = {};
		private var nextPacketId:int = 0;

		private var totalTests:int = 0;
		private var passedTests:int = 0;
		private var failedTests:int = 0;

		private var testTimer:Timer;
		private var timeoutTimer:Timer;

		public function TransportValidator()
		{
			super();
			_instance = this;

			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			tfDebug = new TextField();
			tfDebug.multiline = true;
			tfDebug.autoSize = TextFieldAutoSize.LEFT;
			tfDebug.defaultTextFormat = new TextFormat("Menlo", 14, 0x333333);
			tfDebug.text = "=== SFS3 Transport Validator ===\n";
			addChild(tfDebug);

			testTimer = new Timer(150);
			testTimer.addEventListener(TimerEvent.TIMER, onTestTick);

			timeoutTimer = new Timer(15000, 1);
			timeoutTimer.addEventListener(TimerEvent.TIMER, onTimeout);

			sfs = new SmartFox();
			cfg = new ConfigData();

			sfs.addEventListener(SFSEvent.CONNECTION, onConnection);
			sfs.addEventListener(SFSEvent.CONNECTION_LOST, onConnectionLost);
			sfs.addEventListener(SFSEvent.UDP_CONNECTION, onUdpConnection);
			sfs.addEventListener(SFSEvent.UDP_CONNECTION_LOST, onUdpConnectionLost);
			sfs.addEventListener(SFSEvent.LOGIN, onLogin);
			sfs.addEventListener(SFSEvent.EXTENSION_RESPONSE, onExtensionResponse);

			cfg.host = "127.0.0.1";
			cfg.port = 9977;
			cfg.zone = "Playground";

			Logger.setLevel(LogLevel_Impl_.WARN);
			Logger.setShowPosition(true);

			debug("SFS3 API version: " + sfs.getVersion());
			debug("Connecting to " + cfg.host + ":" + cfg.port + " ...");
			sfs.connect(cfg);
		}

		// -----------------------------------------------------------------
		//  Connection lifecycle
		// -----------------------------------------------------------------

		private function onConnection(evt:ApiEvent):void
		{
			if (evt.params[EventParam.Success])
			{
				debug("[OK] TCP connected");
				sfs.send(new LoginRequest(""));
			}
			else
			{
				debug("[FAIL] TCP connection failed");
			}
		}

		private function onLogin(evt:ApiEvent):void
		{
			debug("[OK] Logged in as: " + sfs.mySelf);

			if (!sfs.isConnected())
			{
				debug("[FAIL] Not connected — cannot init UDP");
				return;
			}

			try
			{
				debug("Initializing UDP ...");
				sfs.connectUdp();
			}
			catch (err:Error)
			{
				debug("[FAIL] UDP init error: " + err.message);
				debug("Running TCP-only tests ...");
				buildTestQueue(true);
				startTests();
			}
		}

		private function onUdpConnection(evt:ApiEvent):void
		{
			if (evt.params[EventParam.Success])
			{
				debug("[OK] UDP connected");
				buildTestQueue(false);
				startTests();
			}
			else
			{
				debug("[WARN] UDP connection failed — running TCP-only tests");
				buildTestQueue(true);
				startTests();
			}
		}

		private function onConnectionLost(evt:ApiEvent):void
		{
			debug("[WARN] TCP connection lost");
			testTimer.stop();
			timeoutTimer.stop();
		}

		private function onUdpConnectionLost(evt:ApiEvent):void
		{
			debug("[WARN] UDP connection lost");
		}

		// -----------------------------------------------------------------
		//  Test queue builder
		// -----------------------------------------------------------------

		private function buildTestQueue(tcpOnly:Boolean):void
		{
			testQueue = [];
			var tLen:int = tcpOnly ? 1 : TRANSPORT_TYPES.length;

			for (var t:int = 0; t < tLen; t++)
			{
				for (var s:int = 0; s < PAYLOAD_SIZES.length; s++)
				{
					testQueue.push({
						txType:  TRANSPORT_TYPES[t],
						txName:  TRANSPORT_NAMES[t],
						size:    PAYLOAD_SIZES[s],
						label:   PAYLOAD_LABELS[s]
					});
				}
			}

			totalTests = testQueue.length;
			debug("\n--- " + totalTests + " tests queued ---\n");
		}

		// -----------------------------------------------------------------
		//  Test execution
		// -----------------------------------------------------------------

		private function startTests():void
		{
			timeoutTimer.start();
			testTimer.start();
		}

		private function onTestTick(e:TimerEvent):void
		{
			if (testQueue.length == 0)
			{
				testTimer.stop();
				return;
			}

			var test:Object = testQueue.shift();
			sendTestPacket(test);
		}

		private function sendTestPacket(test:Object):void
		{
			var id:int = nextPacketId++;
			var payload:ByteArray = buildPayload(test.size, id);

			var sfso:SFSObject = new SFSObject();
			sfso.putInt("id", id);
			sfso.putLong("ts", getTimer());
			sfso.putString("tx", test.txName);
			sfso.putString("sz", test.label);
			sfso.putInt("len", test.size);
			sfso.putByteArray("ba", payload);

			pendingTests[id] = {
				txName:  test.txName,
				label:   test.label,
				size:    test.size,
				sentAt:  getTimer(),
				payload: payload
			};

			sfs.send(new ExtensionRequest("echo", sfso, null, test.txType));

			debug("  SEND #" + id + "  " + padRight(test.txName, 16) +
				  padRight(test.label, 8) +
				  "(" + test.size + " B)");
		}

		// -----------------------------------------------------------------
		//  Echo response & validation
		// -----------------------------------------------------------------

		private function onExtensionResponse(evt:ApiEvent):void
		{
			var cmd:String = String(evt.params[EventParam.Cmd]);
			if (cmd != "echo") return;

			var data:SFSObject = evt.params[EventParam.ExtParams] as SFSObject;
			if (data == null) return;

			var id:int = int(data.getInt("id"));
			var pending:Object = pendingTests[id];
			if (pending == null)
			{
				debug("  [?] Received unknown echo id=" + id);
				return;
			}

			delete pendingTests[id];

			var rtt:int = getTimer() - int(pending.sentAt);
			var received:ByteArray = data.getByteArray("ba");
			var sent:ByteArray = pending.payload as ByteArray;

			var result:String = validatePayload(sent, received);

			if (result == "OK")
			{
				passedTests++;
				debug("  RECV #" + id + "  " + padRight(pending.txName, 16) +
					  padRight(pending.label, 8) +
					  "RTT=" + rtt + "ms  [PASS]");
			}
			else
			{
				failedTests++;
				debug("  RECV #" + id + "  " + padRight(pending.txName, 16) +
					  padRight(pending.label, 8) +
					  "RTT=" + rtt + "ms  [FAIL] " + result);
			}

			checkComplete();
		}

		private function validatePayload(sent:ByteArray, received:ByteArray):String
		{
			if (received == null)
				return "No payload returned";

			if (sent.length != received.length)
				return "Length mismatch: sent=" + sent.length + " recv=" + received.length;

			sent.position = 0;
			received.position = 0;

			for (var i:int = 0; i < sent.length; i++)
			{
				if (sent.readByte() != received.readByte())
					return "Byte mismatch at offset " + i;
			}

			return "OK";
		}

		// -----------------------------------------------------------------
		//  Completion / timeout
		// -----------------------------------------------------------------

		private function checkComplete():void
		{
			if (passedTests + failedTests < totalTests) return;

			timeoutTimer.stop();
			testTimer.stop();
			printSummary();
		}

		private function onTimeout(e:TimerEvent):void
		{
			testTimer.stop();

			var timedOut:int = 0;
			for (var key:String in pendingTests)
			{
				timedOut++;
				var p:Object = pendingTests[key];
				debug("  TIMEOUT #" + key + "  " + padRight(p.txName, 16) +
					  padRight(p.label, 8) + "[FAIL] No response");
			}
			failedTests += timedOut;
			pendingTests = {};

			printSummary();
		}

		private function printSummary():void
		{
			debug("\n========================================");
			debug("  TOTAL : " + totalTests);
			debug("  PASS  : " + passedTests);
			debug("  FAIL  : " + failedTests);
			debug("========================================");

			if (failedTests == 0)
				debug("  ALL TESTS PASSED");
			else
				debug("  SOME TESTS FAILED");

			debug("========================================\n");
		}

		// -----------------------------------------------------------------
		//  Helpers
		// -----------------------------------------------------------------

		/**
		 * Deterministic payload: each byte = (seed + index) & 0xFF
		 * so the echo server can return the same bytes for validation.
		 */
		private function buildPayload(size:int, seed:int):ByteArray
		{
			var ba:ByteArray = new ByteArray();
			for (var i:int = 0; i < size; i++)
			{
				ba.writeByte((seed + i) & 0xFF);
			}
			ba.position = 0;
			return ba;
		}

		private function padRight(str:String, len:int):String
		{
			while (str.length < len) str += " ";
			return str;
		}

		public static function debug(msg:String):void
		{
			if (_instance != null)
				_instance.tfDebug.text += msg + "\n";
		}
	}
}
