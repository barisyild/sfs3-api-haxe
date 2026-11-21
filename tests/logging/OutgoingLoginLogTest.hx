import haxe.io.Bytes;
import sfs3.client.bitswarm.BitSwarmClient;
import sfs3.client.bitswarm.IProtocolCodec;
import sfs3.client.bitswarm.TransportType;
import sfs3.client.bitswarm.io.BaseIOHandler;
import sfs3.client.bitswarm.io.IRequest;
import sfs3.client.bitswarm.io.Request;
import sfs3.client.bitswarm.io.SFSIOHandler;
import sfs3.client.bitswarm.io.SFSProtocolCodec;
import sfs3.client.controllers.SystemController;
import sfs3.client.core.Logger;
import sfs3.client.entities.data.SFSObject;
import sfs3.client.requests.BaseRequest;
import sfs3.client.requests.LoginRequest;
import sfs3.client.util.NetDebugLevel;

/** Runs the real outgoing pipeline; only the final socket write is replaced. */
class OutgoingLoginLogTest {
    static inline var MARKER = "PublicLoginLogTestValue32Letters";
    static var messages:Array<String> = [];

    static function check(ok:Bool, message:String):Void {
        if (!ok) throw message;
    }

    static function packet(link:CaptureLink, handler:SFSIOHandler, controller:Int, action:Int):Bytes {
        var params = new SFSObject();
        params.putString("csk", MARKER);
        var envelope = new SFSObject();
        envelope.putSFSObject(LoginRequest.KEY_PARAMS, params);
        var request = new Request(controller, action);
        request.setContent(envelope);
        messages = [];
        link.wire = null;
        handler.getCodec().onPacketWrite(request);
        check(link.wire != null, "missing socket write");
        return link.wire;
    }

    static function checkNoTransportDump(link:CaptureLink):Void {
        messages = [];
        var params = new SFSObject();
        params.putString("csk", MARKER);
        new sfs3.client.SmartFox().send(new LoginRequest("", MARKER, "offline", params));
        var warning = messages.join("\n");
        check(warning.indexOf("Client is not connected") >= 0 && warning.indexOf(MARKER) < 0,
            "disconnected login exposed its arguments");

        messages = [];
        // The formatter needs only the link and session; keep the test independent of HTTP executors.
        var box = Type.createEmptyInstance(sfs3.client.bitswarm.bbox.BlueBoxClient);
        @:privateAccess box.bitswarm = link;
        var session = "test-bluebox-session";
        @:privateAccess box.sessId = session;
        var bytes = Bytes.ofString(MARKER);
        var base64 = haxe.crypto.Base64.encode(bytes);
        var request = @:privateAccess box.encodeRequest("data", bytes);
        check(request.indexOf(base64) >= 0 && request.indexOf(session) >= 0, "BlueBox request changed");
        var log = messages.join("\n");
        check(log.indexOf("data") >= 0 && log.indexOf(bytes.length + " bytes") >= 0 &&
            log.indexOf(base64) < 0 && log.indexOf(session) < 0, "BlueBox logged a session or payload");
    }

    public static function main():Void {
        var link = new CaptureLink();
        var handler = new SFSIOHandler(link);
        var login = new LoginRequest().getRequest();
        var previousTrace = haxe.Log.trace;
        var previousLevel = Logger.getLevel();
        haxe.Log.trace = function(value:Dynamic, ?pos:haxe.PosInfos) messages.push(Std.string(value));
        Logger.setLevel(DEBUG);
        link.level = OFF;
        var reference = packet(link, handler, login.getControllerId(), login.getId());
        check(reference.toHex().indexOf(Bytes.ofString(MARKER).toHex()) >= 0, "wire must carry the test ID");
        for (level in [NetDebugLevel.PACKET, NetDebugLevel.PROTOCOL]) {
            link.level = level;
            var wire = packet(link, handler, login.getControllerId(), login.getId());
            var log = messages.join("\n");
            check(wire.compare(reference) == 0, "diagnostics changed packet bytes");
            check(log.indexOf(MARKER) < 0 && log.indexOf("Binary size:") < 0, "login payload was logged");
            check(log.indexOf("Dump omitted") >= 0, "missing packet size diagnostic");
        }
        for (control in [{controller:SystemController.CONTROLLER_ID + 1, action:BaseRequest.Login},
                         {controller:SystemController.CONTROLLER_ID, action:BaseRequest.Logout}]) {
            packet(link, handler, control.controller, control.action);
            var log = messages.join("\n");
            check(log.indexOf(MARKER) >= 0 && log.indexOf("Binary size:") >= 0, "ordinary dumps were suppressed");
        }

        // The raw codec can log before framing, even at INFO. Keep this edge independent of the transport.
        var sink = new RawSink(link);
        var raw = new Request(login.getControllerId(), login.getId());
        raw.setRaw(true);
        raw.setContent(Bytes.ofString(MARKER));
        messages = [];
        Logger.setLevel(INFO);
        new SFSProtocolCodec(sink).onPacketWrite(raw);
        check(sink.received == raw && messages.length == 0, "raw login dumped or lost");
        checkNoTransportDump(link);
        Logger.setLevel(previousLevel);
        haxe.Log.trace = previousTrace;
        trace("PASS: outgoing login content and hex dumps omitted; wire and other diagnostics preserved");
    }
}

private class CaptureLink extends BitSwarmClient {
    public var level:NetDebugLevel = OFF;
    public var wire:Bytes;
    public function new() super(null);
    override public function isBBoxDebug():Bool return true;
    override public function getNetDebugLevel():NetDebugLevel return level;
    override public function writeToSocket(data:Bytes, transport:TransportType):Void { wire = data; }
}

private class RawSink extends BaseIOHandler {
    public var received:IRequest;
    public function new(link:BitSwarmClient) super(link);
    public function onDataWrite(request:IRequest):Void { received = request; }
    public function onDataRead(data:Bytes, transport:TransportType):Void {}
    public function getCodec():IProtocolCodec return null;
}
