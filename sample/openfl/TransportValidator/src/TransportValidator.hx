package;

import openfl.display.Sprite;
import openfl.display.StageAlign;
import openfl.display.StageScaleMode;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.utils.ByteArray;
import openfl.Lib;

import sfs3.client.SmartFox;
import sfs3.client.ConfigData;
import sfs3.client.core.SFSEvent;
import sfs3.client.core.EventParam;
import sfs3.client.core.ApiEvent;
import sfs3.client.core.Logger;
import sfs3.client.requests.LoginRequest;
import sfs3.client.requests.ExtensionRequest;
import sfs3.client.entities.data.SFSObject;
import sfs3.client.bitswarm.TransportType;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import haxe.io.BytesData;
import haxe.Int64;

/**
 * Sends echo packets across all TransportTypes (TCP, UDP, UDP_RELIABLE, UDP_UNRELIABLE)
 * with small / medium / large payloads, then validates the returned data byte-by-byte.
 */
class TransportValidator extends Sprite {

    private static var _instance:TransportValidator;

    private var sfs:SmartFox;
    private var cfg:ConfigData;
    private var tfDebug:TextField;

    private static inline var PAYLOAD_SMALL:Int = 64;
    private static inline var PAYLOAD_MEDIUM:Int = 4096;
    private static inline var PAYLOAD_LARGE:Int = 32768;

    private static var TRANSPORT_TYPES:Array<TransportType> = [
        TransportType.TCP,
        TransportType.UDP,
        TransportType.UDP_RELIABLE,
        TransportType.UDP_UNRELIABLE
    ];

    private static var TRANSPORT_NAMES:Array<String> = [
        "TCP",
        "UDP",
        "UDP_RELIABLE",
        "UDP_UNRELIABLE"
    ];

    private static var PAYLOAD_SIZES:Array<Int> = [PAYLOAD_SMALL, PAYLOAD_MEDIUM, PAYLOAD_LARGE];
    private static var PAYLOAD_LABELS:Array<String> = ["SMALL", "MEDIUM", "LARGE"];

    private var testQueue:Array<TestDef> = [];
    private var pendingTests:Map<Int, PendingTest> = new Map();
    private var nextPacketId:Int = 0;

    private var totalTests:Int = 0;
    private var passedTests:Int = 0;
    private var failedTests:Int = 0;

    private var testTimerRunning:Bool = false;
    private var timeoutTimerRunning:Bool = false;
    private var timeoutStart:Int = 0;

    public function new() {
        super();
        _instance = this;

        if (stage != null) {
            init();
        } else {
            addEventListener(openfl.events.Event.ADDED_TO_STAGE, function(_) {
                init();
            });
        }
    }

    private function init():Void {
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;

        tfDebug = new TextField();
        tfDebug.multiline = true;
        tfDebug.autoSize = TextFieldAutoSize.LEFT;
        tfDebug.defaultTextFormat = new TextFormat("Menlo", 14, 0x333333);
        tfDebug.text = "=== SFS3 Transport Validator ===\n";
        addChild(tfDebug);

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

        Logger.setLevel(LogLevel.WARN);
        Logger.setShowPosition(true);

        debug("SFS3 API version: " + sfs.getVersion());
        debug("Connecting to " + cfg.host + ":" + cfg.port + " ...");
        sfs.connect(cfg);
    }

    // -----------------------------------------------------------------
    //  Connection lifecycle
    // -----------------------------------------------------------------

    private function onConnection(evt:ApiEvent):Void {
        if (evt.getParam(EventParam.Success)) {
            debug("[OK] TCP connected");
            sfs.send(new LoginRequest(""));
        } else {
            debug("[FAIL] TCP connection failed");
        }
    }

    private function onLogin(evt:ApiEvent):Void {
        debug("[OK] Logged in as: " + sfs.getMySelf());

        if (!sfs.isConnected()) {
            debug("[FAIL] Not connected — cannot init UDP");
            return;
        }

        try {
            debug("Initializing UDP ...");
            sfs.connectUdp();
        } catch (err:Dynamic) {
            debug("[FAIL] UDP init error: " + Std.string(err));
            debug("Running TCP-only tests ...");
            buildTestQueue(true);
            startTests();
        }
    }

    private function onUdpConnection(evt:ApiEvent):Void {
        if (evt.getParam(EventParam.Success)) {
            debug("[OK] UDP connected");
            buildTestQueue(false);
            startTests();
        } else {
            debug("[WARN] UDP connection failed — running TCP-only tests");
            buildTestQueue(true);
            startTests();
        }
    }

    private function onConnectionLost(evt:ApiEvent):Void {
        debug("[WARN] TCP connection lost");
        stopTestTimer();
        stopTimeoutTimer();
    }

    private function onUdpConnectionLost(evt:ApiEvent):Void {
        debug("[WARN] UDP connection lost");
    }

    // -----------------------------------------------------------------
    //  Test queue builder
    // -----------------------------------------------------------------

    private function buildTestQueue(tcpOnly:Bool):Void {
        testQueue = [];
        var tLen:Int = tcpOnly ? 1 : TRANSPORT_TYPES.length;

        for (t in 0...tLen) {
            for (s in 0...PAYLOAD_SIZES.length) {
                testQueue.push({
                    txType: TRANSPORT_TYPES[t],
                    txName: TRANSPORT_NAMES[t],
                    size: PAYLOAD_SIZES[s],
                    label: PAYLOAD_LABELS[s]
                });
            }
        }

        totalTests = testQueue.length;
        debug("\n--- " + totalTests + " tests queued ---\n");
    }

    // -----------------------------------------------------------------
    //  Test execution (using ENTER_FRAME as timer substitute)
    // -----------------------------------------------------------------

    private var testTickAccum:Int = 0;
    private var lastTickTime:Int = 0;

    private function startTests():Void {
        timeoutStart = Lib.getTimer();
        timeoutTimerRunning = true;
        testTimerRunning = true;
        lastTickTime = Lib.getTimer();
        testTickAccum = 0;
        addEventListener(openfl.events.Event.ENTER_FRAME, onFrame);
    }

    private function stopTestTimer():Void {
        testTimerRunning = false;
    }

    private function stopTimeoutTimer():Void {
        timeoutTimerRunning = false;
    }

    private function onFrame(_:openfl.events.Event):Void {
        var now:Int = Lib.getTimer();
        var dt:Int = now - lastTickTime;
        lastTickTime = now;

        // Check timeout (15 seconds)
        if (timeoutTimerRunning && (now - timeoutStart) >= 15000) {
            onTimeout();
            return;
        }

        // Fire test every ~150ms
        if (testTimerRunning && testQueue.length > 0) {
            testTickAccum += dt;
            while (testTickAccum >= 150 && testQueue.length > 0) {
                testTickAccum -= 150;
                sendTestPacket(testQueue.shift());
            }
        }

        if (!testTimerRunning && !timeoutTimerRunning) {
            removeEventListener(openfl.events.Event.ENTER_FRAME, onFrame);
        }
    }

    private function sendTestPacket(test:TestDef):Void {
        var id:Int = nextPacketId++;
        var payload:Bytes = buildPayload(test.size, id);

        var sfso = new SFSObject();
        sfso.putInt("id", id);
        sfso.putLong("ts", Int64.fromFloat(Lib.getTimer()));
        sfso.putString("tx", test.txName);
        sfso.putString("sz", test.label);
        sfso.putInt("len", test.size);
        sfso.putByteArray("ba", payload.getData());

        pendingTests.set(id, {
            txName: test.txName,
            label: test.label,
            size: test.size,
            sentAt: Lib.getTimer(),
            payload: payload
        });

        sfs.send(new ExtensionRequest("echo", sfso, null, test.txType));

        debug("  SEND #" + id + "  " + padRight(test.txName, 16) +
        padRight(test.label, 8) +
        "(" + test.size + " B)");
    }

    // -----------------------------------------------------------------
    //  Echo response & validation
    // -----------------------------------------------------------------

    private function onExtensionResponse(evt:ApiEvent):Void {
        var cmd:String = evt.getParam(EventParam.Cmd);
        if (cmd != "echo") return;

        var data:SFSObject = evt.getParam(EventParam.ExtParams);
        if (data == null) return;

        var id:Int = data.getInt("id");
        var pending = pendingTests.get(id);
        if (pending == null) {
            debug("  [?] Received unknown echo id=" + id);
            return;
        }

        pendingTests.remove(id);

        var rtt:Int = Lib.getTimer() - pending.sentAt;
        var received:Bytes = Bytes.ofData(data.getByteArray("ba"));
        var sent:Bytes = pending.payload;

        var result:String = validatePayload(sent, received);

        if (result == "OK") {
            passedTests++;
            debug("  RECV #" + id + "  " + padRight(pending.txName, 16) +
            padRight(pending.label, 8) +
            "RTT=" + rtt + "ms  [PASS]");
        } else {
            failedTests++;
            debug("  RECV #" + id + "  " + padRight(pending.txName, 16) +
            padRight(pending.label, 8) +
            "RTT=" + rtt + "ms  [FAIL] " + result);
        }

        checkComplete();
    }

    private function validatePayload(sent:Bytes, received:Bytes):String {
        if (received == null)
            return "No payload returned";

        if (sent.length != received.length)
            return "Length mismatch: sent=" + sent.length + " recv=" + received.length;

        for (i in 0...sent.length) {
            if (sent.get(i) != received.get(i))
                return "Byte mismatch at offset " + i;
        }

        return "OK";
    }

    // -----------------------------------------------------------------
    //  Completion / timeout
    // -----------------------------------------------------------------

    private function checkComplete():Void {
        if (passedTests + failedTests < totalTests) return;

        stopTimeoutTimer();
        stopTestTimer();
        printSummary();
    }

    private function onTimeout():Void {
        stopTestTimer();
        stopTimeoutTimer();

        var timedOut:Int = 0;
        for (key in pendingTests.keys()) {
            timedOut++;
            var p = pendingTests.get(key);
            debug("  TIMEOUT #" + key + "  " + padRight(p.txName, 16) +
            padRight(p.label, 8) + "[FAIL] No response");
        }
        failedTests += timedOut;
        pendingTests = new Map();

        printSummary();
    }

    private function printSummary():Void {
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

    private function buildPayload(size:Int, seed:Int):Bytes {
        var ba = new BytesOutput();
        for (i in 0...size) {
            ba.writeByte((seed + i) & 0xFF);
        }
        return ba.getBytes();
    }

    private function padRight(str:String, len:Int):String {
        while (str.length < len) str += " ";
        return str;
    }

    public static function debug(msg:String):Void {
        if (_instance != null)
            _instance.tfDebug.text += msg + "\n";
    }
}

typedef TestDef = {
    txType:TransportType,
    txName:String,
    size:Int,
    label:String
};

typedef PendingTest = {
    txName:String,
    label:String,
    size:Int,
    sentAt:Int,
    payload:Bytes
};
