package;

import openfl.display.Sprite;
import openfl.display.Shape;
import openfl.display.StageAlign;
import openfl.display.StageScaleMode;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.KeyboardEvent;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;
import openfl.ui.Keyboard;

import sfs3.client.SmartFox;
import sfs3.client.ConfigData;
import sfs3.client.core.SFSEvent;
import sfs3.client.core.EventParam;
import sfs3.client.core.ApiEvent;
import sfs3.client.requests.LoginRequest;
import sfs3.client.requests.LogoutRequest;
import sfs3.client.requests.JoinRoomRequest;
import sfs3.client.requests.PublicMessageRequest;
import sfs3.client.requests.SetRoomVariablesRequest;
import sfs3.client.requests.ExtensionRequest;
import sfs3.client.entities.variables.SFSRoomVariable;
import sfs3.client.entities.data.SFSObject;
import sfs3.client.bitswarm.TransportType;
import sfs3.client.core.Logger;
import haxe.Int64;

class SimpleChat extends Sprite {

    private static inline var DEFAULT_HOST:String = "127.0.0.1";
    private static inline var DEFAULT_TCP_PORT:Int = 9977;
    private static inline var DEFAULT_WS_PORT:Int = 8088;
    private static inline var DEFAULT_ZONE:String = "Playground";

    private static inline var PAD:Int = 8;
    private static inline var HEADER_H:Int = 36;
    private static inline var BTN_W:Int = 80;
    private static inline var BTN_H:Int = 24;
    private static inline var INPUT_H:Int = 22;

    private static inline var CLR_BG:UInt = 0xF0F0F0;
    private static inline var CLR_BORDER:UInt = 0xCCCCCC;
    private static inline var CLR_BTN:UInt = 0xE8E8E8;
    private static inline var CLR_BTN_DIS:UInt = 0xD8D8D8;
    private static inline var CLR_TEXT:UInt = 0x333333;
    private static inline var CLR_SYSTEM:UInt = 0x666666;
    private static inline var CLR_ACCENT:UInt = 0xFF9933;
    private static inline var CLR_WHITE:UInt = 0xFFFFFF;

    private var sfs:SmartFox;

    private var transportIsTcp:Bool = true;
    private var transportBtn:Sprite;
    private var transportLabel:TextField;

    private var connectBtn:Sprite;
    private var loginBtn:Sprite;
    private var logoutBtn:Sprite;
    private var disconnectBtn:Sprite;
    private var initUdpBtn:Sprite;
    private var udpPingBtn:Sprite;
    private var udpStatusLabel:TextField;

    private var usernameInput:TextField;

    private var chatHistory:TextField;
    private var msgInput:TextField;
    private var useUdpCb:Sprite;
    private var useUdpChecked:Bool = false;
    private var useUdpLabel:TextField;
    private var sendBtn:Sprite;

    private var topicLabel:TextField;
    private var topicInput:TextField;
    private var setTopicBtn:Sprite;

    private var roomsList:TextField;
    private var usersList:TextField;
    private var roomRefs:Array<Dynamic> = [];
    private var selectedRoomIdx:Int = -1;

    private var titleLabel:TextField;

    private var stageW:Int = 920;
    private var stageH:Int = 600;

    public function new() {
        super();
        if (stage != null) {
            init();
        } else {
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }
    }

    private function onAddedToStage(e:Event):Void {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        init();
    }

    private function init():Void {
        stage.align = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stageW = Std.int(stage.stageWidth);
        stageH = Std.int(stage.stageHeight);

        buildUI();
        setConnected(false);
        setChatEnabled(false);

        stage.addEventListener(Event.RESIZE, onResize);
    }

    // =========================================================================
    // UI BUILD
    // =========================================================================

    private function buildUI():Void {
        var headerBg = new Shape();
        headerBg.name = "headerBg";
        addChild(headerBg);

        var cx:Int = PAD;
        var cy:Int = 6;

        titleLabel = makeLabel("SFS3™ massive multiplayer platform", 11, true);
        titleLabel.x = cx;
        titleLabel.y = cy + 2;
        addChild(titleLabel);
        cx += Std.int(titleLabel.width) + 12;

        transportBtn = makeButton("TCP", 52);
        transportBtn.x = cx;
        transportBtn.y = cy;
        addChild(transportBtn);
        transportLabel = cast(transportBtn.getChildByName("lbl"), TextField);
        transportBtn.addEventListener(MouseEvent.CLICK, onTransportToggle);
        cx += 58;

        connectBtn = makeButton("Connect", BTN_W);
        connectBtn.x = cx;
        connectBtn.y = cy;
        addChild(connectBtn);
        connectBtn.addEventListener(MouseEvent.CLICK, onConnect);
        cx += BTN_W + 6;

        usernameInput = makeInput(80, INPUT_H);
        usernameInput.text = "Bax";
        usernameInput.x = cx;
        usernameInput.y = cy + 1;
        addChild(usernameInput);
        cx += 86;

        loginBtn = makeButton("Login", 56);
        loginBtn.x = cx;
        loginBtn.y = cy;
        addChild(loginBtn);
        loginBtn.addEventListener(MouseEvent.CLICK, onLogin);
        cx += 62;

        logoutBtn = makeButton("Logout", 56);
        logoutBtn.x = cx;
        logoutBtn.y = cy;
        addChild(logoutBtn);
        logoutBtn.addEventListener(MouseEvent.CLICK, onLogout);
        cx += 62;

        disconnectBtn = makeButton("Disconnect", 76);
        disconnectBtn.x = cx;
        disconnectBtn.y = cy;
        addChild(disconnectBtn);
        disconnectBtn.addEventListener(MouseEvent.CLICK, onDisconnect);
        cx += 82;

        var sep = new Shape();
        sep.graphics.beginFill(CLR_BORDER);
        sep.graphics.drawRect(0, 0, 1, 20);
        sep.graphics.endFill();
        sep.x = cx;
        sep.y = cy + 2;
        addChild(sep);
        cx += 7;

        initUdpBtn = makeButton("Init UDP", 64);
        initUdpBtn.x = cx;
        initUdpBtn.y = cy;
        addChild(initUdpBtn);
        initUdpBtn.addEventListener(MouseEvent.CLICK, onInitUdp);
        cx += 70;

        udpPingBtn = makeButton("UDP Ping", 68);
        udpPingBtn.x = cx;
        udpPingBtn.y = cy;
        addChild(udpPingBtn);
        udpPingBtn.addEventListener(MouseEvent.CLICK, onUdpPing);
        cx += 74;

        udpStatusLabel = makeLabel("UDP: off", 11, false, CLR_SYSTEM);
        udpStatusLabel.x = cx;
        udpStatusLabel.y = cy + 4;
        addChild(udpStatusLabel);

        var contentY:Int = HEADER_H + PAD;
        var sideW:Int = 210;
        var chatW:Int = stageW - sideW - PAD * 3;
        var contentH:Int = stageH - HEADER_H - PAD * 2;

        topicLabel = makeLabel("Topic is '(not set)'", 12, false, CLR_SYSTEM);
        topicLabel.x = PAD;
        topicLabel.y = contentY;
        addChild(topicLabel);

        chatHistory = new TextField();
        chatHistory.defaultTextFormat = new TextFormat("_sans", 12, CLR_TEXT);
        chatHistory.multiline = true;
        chatHistory.wordWrap = true;
        chatHistory.selectable = true;
        chatHistory.border = true;
        chatHistory.borderColor = CLR_BORDER;
        chatHistory.background = true;
        chatHistory.backgroundColor = CLR_WHITE;
        chatHistory.x = PAD;
        chatHistory.y = contentY + 20;
        chatHistory.width = chatW;
        chatHistory.height = contentH - 80;
        addChild(chatHistory);

        var msgY:Int = Std.int(chatHistory.y + chatHistory.height) + 4;
        msgInput = makeInput(chatW - BTN_W - 80, INPUT_H);
        msgInput.x = PAD;
        msgInput.y = msgY;
        addChild(msgInput);
        msgInput.addEventListener(KeyboardEvent.KEY_DOWN, onMsgKeyDown);

        useUdpCb = new Sprite();
        useUdpCb.x = msgInput.x + msgInput.width + 6;
        useUdpCb.y = msgY;
        drawCheckbox(useUdpCb, false);
        addChild(useUdpCb);
        useUdpCb.addEventListener(MouseEvent.CLICK, onToggleUdpCb);
        useUdpCb.buttonMode = true;
        useUdpCb.useHandCursor = true;

        useUdpLabel = makeLabel("UDP", 11, false, CLR_TEXT);
        useUdpLabel.x = useUdpCb.x + 18;
        useUdpLabel.y = msgY + 2;
        addChild(useUdpLabel);

        sendBtn = makeButton("Send", BTN_W);
        sendBtn.x = PAD + chatW - BTN_W;
        sendBtn.y = msgY;
        addChild(sendBtn);
        sendBtn.addEventListener(MouseEvent.CLICK, onSend);

        var topicY:Int = msgY + INPUT_H + 6;
        var topicLbl = makeLabel("Chat topic:", 12, false, CLR_TEXT);
        topicLbl.x = PAD;
        topicLbl.y = topicY + 2;
        addChild(topicLbl);

        topicInput = makeInput(140, INPUT_H);
        topicInput.text = "Movies";
        topicInput.x = PAD + 80;
        topicInput.y = topicY;
        addChild(topicInput);

        setTopicBtn = makeButton("Set", 40);
        setTopicBtn.x = Std.int(topicInput.x + topicInput.width) + 6;
        setTopicBtn.y = topicY;
        addChild(setTopicBtn);
        setTopicBtn.addEventListener(MouseEvent.CLICK, onSetTopic);

        var sideX:Int = stageW - sideW - PAD;
        var halfH:Int = Std.int((contentH - PAD) / 2);

        var roomsTitle = makeLabel("Rooms", 12, true, CLR_SYSTEM);
        roomsTitle.x = sideX;
        roomsTitle.y = contentY;
        addChild(roomsTitle);

        roomsList = new TextField();
        roomsList.defaultTextFormat = new TextFormat("_sans", 12, CLR_TEXT);
        roomsList.multiline = true;
        roomsList.wordWrap = true;
        roomsList.selectable = true;
        roomsList.border = true;
        roomsList.borderColor = CLR_BORDER;
        roomsList.background = true;
        roomsList.backgroundColor = CLR_WHITE;
        roomsList.x = sideX;
        roomsList.y = contentY + 18;
        roomsList.width = sideW;
        roomsList.height = halfH - 18;
        roomsList.addEventListener(MouseEvent.CLICK, onRoomClick);
        addChild(roomsList);

        var usersTitle = makeLabel("Users", 12, true, CLR_SYSTEM);
        usersTitle.x = sideX;
        usersTitle.y = contentY + halfH + 4;
        addChild(usersTitle);

        usersList = new TextField();
        usersList.defaultTextFormat = new TextFormat("_sans", 12, CLR_TEXT);
        usersList.multiline = true;
        usersList.wordWrap = true;
        usersList.selectable = true;
        usersList.border = true;
        usersList.borderColor = CLR_BORDER;
        usersList.background = true;
        usersList.backgroundColor = CLR_WHITE;
        usersList.x = sideX;
        usersList.y = contentY + halfH + 22;
        usersList.width = sideW;
        usersList.height = halfH - 22;
        addChild(usersList);

        drawHeaderBg();
    }

    private function drawHeaderBg():Void {
        var bg:Shape = cast(getChildByName("headerBg"), Shape);
        if (bg == null) return;
        bg.graphics.clear();
        bg.graphics.beginFill(CLR_BG);
        bg.graphics.drawRect(0, 0, stageW, HEADER_H);
        bg.graphics.endFill();
        bg.graphics.lineStyle(1, CLR_BORDER);
        bg.graphics.moveTo(0, HEADER_H);
        bg.graphics.lineTo(stageW, HEADER_H);
    }

    private function onResize(e:Event):Void {
        stageW = Std.int(stage.stageWidth);
        stageH = Std.int(stage.stageHeight);
        drawHeaderBg();
    }

    // =========================================================================
    // UI HELPERS
    // =========================================================================

    private function makeLabel(text:String, size:Int = 12, bold:Bool = false, color:UInt = 0x333333):TextField {
        var tf = new TextField();
        tf.defaultTextFormat = new TextFormat("_sans", size, color, bold);
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.selectable = false;
        tf.mouseEnabled = false;
        tf.text = text;
        return tf;
    }

    private function makeInput(w:Int, h:Int):TextField {
        var tf = new TextField();
        tf.type = TextFieldType.INPUT;
        tf.defaultTextFormat = new TextFormat("_sans", 12, CLR_TEXT);
        tf.border = true;
        tf.borderColor = 0xBBBBBB;
        tf.background = true;
        tf.backgroundColor = CLR_WHITE;
        tf.width = w;
        tf.height = h;
        return tf;
    }

    private function makeButton(label:String, w:Int = 80):Sprite {
        var sp = new Sprite();
        sp.buttonMode = true;
        sp.useHandCursor = true;

        sp.graphics.beginFill(CLR_WHITE);
        sp.graphics.lineStyle(1, 0xAAAAAA);
        sp.graphics.drawRoundRect(0, 0, w, BTN_H, 4, 4);
        sp.graphics.endFill();

        var lbl = makeLabel(label, 11, false, CLR_TEXT);
        lbl.name = "lbl";
        lbl.x = (w - lbl.width) / 2;
        lbl.y = (BTN_H - lbl.height) / 2;
        sp.addChild(lbl);

        return sp;
    }

    private function setBtnEnabled(btn:Sprite, enabled:Bool):Void {
        btn.mouseEnabled = enabled;
        btn.mouseChildren = enabled;
        btn.alpha = enabled ? 1.0 : 0.45;
        btn.buttonMode = enabled;
    }

    private function drawCheckbox(sp:Sprite, checked:Bool):Void {
        sp.graphics.clear();
        sp.graphics.lineStyle(1, 0xAAAAAA);
        sp.graphics.beginFill(CLR_WHITE);
        sp.graphics.drawRect(0, 2, 14, 14);
        sp.graphics.endFill();
        if (checked) {
            sp.graphics.lineStyle(2, CLR_ACCENT);
            sp.graphics.moveTo(3, 9);
            sp.graphics.lineTo(6, 13);
            sp.graphics.lineTo(12, 4);
        }
    }

    // =========================================================================
    // STATE MANAGEMENT
    // =========================================================================

    private function setConnected(connected:Bool):Void {
        setBtnEnabled(connectBtn, !connected);
        setBtnEnabled(transportBtn, !connected);
        setBtnEnabled(loginBtn, connected);
        setBtnEnabled(logoutBtn, false);
        setBtnEnabled(disconnectBtn, connected);
        setBtnEnabled(initUdpBtn, false);
        setBtnEnabled(udpPingBtn, false);
        udpStatusLabel.text = "UDP: off";
        useUdpChecked = false;
        drawCheckbox(useUdpCb, false);
        setBtnEnabled(useUdpCb, false);
    }

    private function setLoggedIn(loggedIn:Bool):Void {
        setBtnEnabled(logoutBtn, loggedIn);
        setBtnEnabled(initUdpBtn, loggedIn);
        if (!loggedIn) {
            udpStatusLabel.text = "UDP: off";
        }
        if (loggedIn) populateRooms();
    }

    private function setChatEnabled(enabled:Bool):Void {
        msgInput.type = enabled ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
        msgInput.selectable = enabled;
        setBtnEnabled(sendBtn, enabled);
        topicInput.type = enabled ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
        topicInput.selectable = enabled;
        setBtnEnabled(setTopicBtn, enabled);
    }

    // =========================================================================
    // CHAT OUTPUT
    // =========================================================================

    private function writeChat(text:String, isSystem:Bool = false):Void {
        var fmt = new TextFormat("_sans", 12, isSystem ? CLR_SYSTEM : CLR_TEXT);
        var start:Int = chatHistory.text.length;
        chatHistory.appendText(text + "\n");
        chatHistory.setTextFormat(fmt, start, chatHistory.text.length);
        chatHistory.scrollV = chatHistory.maxScrollV;
    }

    private function writeChatBold(sender:String, message:String):Void {
        var start:Int = chatHistory.text.length;
        chatHistory.appendText(sender + " " + message + "\n");
        var boldFmt = new TextFormat("_sans", 12, CLR_TEXT, true);
        chatHistory.setTextFormat(boldFmt, start, start + sender.length);
        chatHistory.scrollV = chatHistory.maxScrollV;
    }

    // =========================================================================
    // ROOMS / USERS
    // =========================================================================

    private function populateRooms():Void {
        roomRefs = [];
        selectedRoomIdx = -1;
        roomsList.text = "";
        if (sfs == null) return;
        var rm = sfs.getRoomManager();
        if (rm == null) return;
        var rooms = rm.getRoomList();
        if (rooms == null || rooms.length == 0) {
            roomsList.text = "(no rooms)";
            return;
        }
        var lines:Array<String> = [];
        for (i in 0...rooms.length) {
            var r = rooms[i];
            roomRefs.push(r);
            lines.push(r.getName() + "  (" + r.getUserCount() + "/" + r.getMaxUsers() + ")");
        }
        roomsList.text = lines.join("\n");
    }

    private function populateUsers():Void {
        usersList.text = "";
        if (sfs == null) { usersList.text = "(no connection)"; return; }
        var room = sfs.getLastJoinedRoom();
        if (room == null) { usersList.text = "(no room)"; return; }
        var users = room.getUserList();
        if (users == null || users.length == 0) { usersList.text = "(no users)"; return; }
        var lines:Array<String> = [];
        for (i in 0...users.length) {
            var u = users[i];
            lines.push(u.getName() + (u.getIsItMe() ? " (you)" : ""));
        }
        usersList.text = lines.join("\n");
    }

    private function showRoomTopic(room:Dynamic):Void {
        if (room == null || !room.containsVariable("topic")) {
            topicLabel.text = "Topic is '(not set)'";
            return;
        }
        var v = room.getVariable("topic");
        var val:String = v != null ? v.getValue() : null;
        topicLabel.text = "Topic is '" + (val != null ? val : "") + "'";
    }

    // =========================================================================
    // ROOM CLICK
    // =========================================================================

    private function onRoomClick(e:MouseEvent):Void {
        if (sfs == null || roomRefs.length == 0) return;
        var lineIdx:Int = roomsList.getLineIndexAtPoint(e.localX, e.localY);
        if (lineIdx < 0 || lineIdx >= roomRefs.length) return;

        var current = sfs.getLastJoinedRoom();
        var room = roomRefs[lineIdx];
        if (current != null && current.getId() == room.getId()) return;

        selectedRoomIdx = lineIdx;
        sfs.send(new JoinRoomRequest(room));
    }

    // =========================================================================
    // SFS EVENT HANDLERS
    // =========================================================================

    private function onSfsConnection(evt:ApiEvent):Void {
        var success:Bool = evt.getParam(EventParam.Success);
        if (success) {
            setConnected(true);
            var proto:String = transportIsTcp ? "TCP" : "WebSocket";
            writeChat("Connected to SmartFoxServer 3 via " + proto + ".", true);
        } else {
            var msg:String = evt.getParam(EventParam.ErrorMessage);
            if (msg == null) msg = "Connection failed";
            setConnected(false);
            writeChat("Connection failed: " + msg, true);
        }
    }

    private function onSfsConnectionLost(evt:ApiEvent):Void {
        var reason:String = evt.getParam(EventParam.DisconnectionReason);
        sfs = null;
        setConnected(false);
        setLoggedIn(false);
        setChatEnabled(false);
        writeChat("Disconnected. " + (reason != null ? reason : ""), true);
    }

    private function onSfsLogin(evt:ApiEvent):Void {
        setLoggedIn(true);
        writeChat("Logged in.", true);
    }

    private function onSfsLoginError(evt:ApiEvent):Void {
        var msg:String = evt.getParam(EventParam.ErrorMessage);
        if (msg == null) msg = "Login failed";
        writeChat("Login error: " + msg, true);
    }

    private function onSfsLogout(evt:ApiEvent):Void {
        setLoggedIn(false);
        setChatEnabled(false);
        roomRefs = [];
        roomsList.text = "(logout)";
        usersList.text = "(no users)";
        topicLabel.text = "Topic is '(not set)'";
        writeChat("Logged out.", true);
    }

    private function onSfsRoomJoin(evt:ApiEvent):Void {
        var room = evt.getParam(EventParam.Room);
        if (room == null) return;
        setChatEnabled(true);
        writeChat("You entered room '" + room.getName() + "'", true);
        showRoomTopic(room);
        var v = room.containsVariable("topic") ? room.getVariable("topic") : null;
        topicInput.text = (v != null && v.getValue() != null) ? v.getValue() : "";
        populateUsers();
    }

    private function onSfsRoomJoinError(evt:ApiEvent):Void {
        var msg:String = evt.getParam(EventParam.ErrorMessage);
        if (msg == null) msg = "Join failed";
        writeChat("Room join error: " + msg, true);
    }

    private function onSfsUserEnterRoom(evt:ApiEvent):Void {
        var u = evt.getParam(EventParam.User);
        populateUsers();
        if (u != null && !u.getIsItMe()) writeChat("User " + u.getName() + " entered the room.", true);
    }

    private function onSfsUserExitRoom(evt:ApiEvent):Void {
        populateUsers();
    }

    private function onSfsUserCountChange(evt:ApiEvent):Void {
        populateRooms();
    }

    private function onSfsPublicMessage(evt:ApiEvent):Void {
        var sender = evt.getParam(EventParam.Sender);
        var message:String = evt.getParam(EventParam.Message);
        if (sender == null || message == null) return;
        var name:String = sender.getIsItMe() ? "You" : sender.getName();
        writeChatBold(name + " said:", message);
    }

    private function onSfsRoomVariablesUpdate(evt:ApiEvent):Void {
        var room = evt.getParam(EventParam.Room);
        var changed:Array<String> = evt.getParam(EventParam.ChangedVars);
        if (room != null && changed != null && changed.indexOf("topic") >= 0) {
            showRoomTopic(room);
            var v = room.containsVariable("topic") ? room.getVariable("topic") : null;
            topicInput.text = (v != null && v.getValue() != null) ? v.getValue() : "";
        }
    }

    private function onSfsUdpConnection(evt:ApiEvent):Void {
        var success:Bool = evt.getParam(EventParam.Success);
        if (success) {
            udpStatusLabel.text = "UDP: on";
            setBtnEnabled(initUdpBtn, false);
            setBtnEnabled(udpPingBtn, true);
            setBtnEnabled(useUdpCb, true);
            writeChat("UDP connection established. You can now send via UDP.", true);
        } else {
            var msg:String = evt.getParam(EventParam.ErrorMessage);
            if (msg == null) msg = "UDP init failed";
            udpStatusLabel.text = "UDP: failed";
            setBtnEnabled(udpPingBtn, false);
            setBtnEnabled(useUdpCb, false);
            useUdpChecked = false;
            drawCheckbox(useUdpCb, false);
            writeChat("UDP init error: " + msg, true);
        }
    }

    private function onSfsUdpConnectionLost(evt:ApiEvent):Void {
        udpStatusLabel.text = "UDP: off";
        setBtnEnabled(initUdpBtn, sfs != null && sfs.isConnected());
        setBtnEnabled(udpPingBtn, false);
        setBtnEnabled(useUdpCb, false);
        useUdpChecked = false;
        drawCheckbox(useUdpCb, false);
        writeChat("UDP connection lost.", true);
    }

    private function onSfsExtensionResponse(evt:ApiEvent):Void {
        var cmd:String = evt.getParam(EventParam.Cmd);
        var params:SFSObject = evt.getParam(EventParam.ExtParams);

        if (cmd == "udpPing" && params != null && params.containsKey("t")) {
            var sent:Int64 = params.getLong("t");
            var rtt:Int64 = Int64.fromFloat(Date.now().getTime()) - sent;
            writeChat("[UDP Pong] RTT: " + rtt + " ms", true);
        } else if (cmd == "udpChat" && params != null && params.containsKey("msg")) {
            var senderName:String = params.containsKey("sender") ? params.getString("sender") : "?";
            var chatMsg:String = params.getString("msg");
            writeChatBold("[UDP] " + senderName + " said:", chatMsg);
        } else {
            writeChat("[ExtResponse] cmd='" + cmd + "'", true);
        }
    }

    private function addSfsListeners():Void {
        sfs.addEventListener(SFSEvent.CONNECTION, onSfsConnection);
        sfs.addEventListener(SFSEvent.CONNECTION_LOST, onSfsConnectionLost);
        sfs.addEventListener(SFSEvent.LOGIN, onSfsLogin);
        sfs.addEventListener(SFSEvent.LOGIN_ERROR, onSfsLoginError);
        sfs.addEventListener(SFSEvent.LOGOUT, onSfsLogout);
        sfs.addEventListener(SFSEvent.ROOM_JOIN, onSfsRoomJoin);
        sfs.addEventListener(SFSEvent.ROOM_JOIN_ERROR, onSfsRoomJoinError);
        sfs.addEventListener(SFSEvent.USER_ENTER_ROOM, onSfsUserEnterRoom);
        sfs.addEventListener(SFSEvent.USER_EXIT_ROOM, onSfsUserExitRoom);
        sfs.addEventListener(SFSEvent.USER_COUNT_CHANGE, onSfsUserCountChange);
        sfs.addEventListener(SFSEvent.PUBLIC_MESSAGE, onSfsPublicMessage);
        sfs.addEventListener(SFSEvent.ROOM_VARIABLES_UPDATE, onSfsRoomVariablesUpdate);
        sfs.addEventListener(SFSEvent.UDP_CONNECTION, onSfsUdpConnection);
        sfs.addEventListener(SFSEvent.UDP_CONNECTION_LOST, onSfsUdpConnectionLost);
        sfs.addEventListener(SFSEvent.EXTENSION_RESPONSE, onSfsExtensionResponse);
    }

    // =========================================================================
    // BUTTON ACTIONS
    // =========================================================================

    private function onTransportToggle(e:MouseEvent):Void {
        transportIsTcp = !transportIsTcp;
        transportLabel.text = transportIsTcp ? "TCP" : "WS";
        transportLabel.x = (52 - transportLabel.width) / 2;
    }

    private function onConnect(e:MouseEvent):Void {
        sfs = new SmartFox();

        Logger.setLevel(3);
        Logger.setShowPosition(false);

        addSfsListeners();

        var cfg = new ConfigData();
        cfg.host = DEFAULT_HOST;
        cfg.zone = DEFAULT_ZONE;

        if (transportIsTcp) {
            cfg.port = DEFAULT_TCP_PORT;
        } else {
            cfg.useWebSocket = true;
            cfg.httpPort = DEFAULT_WS_PORT;
            cfg.port = DEFAULT_WS_PORT;
        }

        var proto:String = transportIsTcp ? "TCP" : "WebSocket";
        var port:Int = transportIsTcp ? cfg.port : cfg.httpPort;
        setBtnEnabled(connectBtn, false);
        setBtnEnabled(transportBtn, false);
        writeChat("Connecting via " + proto + " to " + cfg.host + ":" + port + " ...", true);

        try {
            sfs.connect(cfg);
        } catch (err:Dynamic) {
            writeChat("Connect error: " + Std.string(err), true);
            setBtnEnabled(connectBtn, true);
            setBtnEnabled(transportBtn, true);
            sfs = null;
        }
    }

    private function onDisconnect(e:MouseEvent):Void {
        if (sfs != null) sfs.disconnect();
    }

    private function onInitUdp(e:MouseEvent):Void {
        if (sfs == null || !sfs.isConnected()) {
            writeChat("Connect and login first.", true);
            return;
        }
        try {
            sfs.connectUdp();
            writeChat("Initializing UDP...", true);
        } catch (err:Dynamic) {
            writeChat("UDP init error: " + Std.string(err), true);
        }
    }

    private function onUdpPing(e:MouseEvent):Void {
        if (sfs == null || !sfs.isUdpConnected()) {
            writeChat("UDP not connected.", true);
            return;
        }
        var params = new SFSObject();
        params.putLong("t", Int64.fromFloat(Date.now().getTime()));
        var room = sfs.getLastJoinedRoom();
        sfs.send(new ExtensionRequest("udpPing", params, room, TransportType.UDP));
        writeChat("[UDP Ping] Sent...", true);
    }

    private function onLogin(e:MouseEvent):Void {
        if (sfs == null) return;
        var user:String = StringTools.trim(usernameInput.text);
        if (user == "") user = "Guest";
        sfs.send(new LoginRequest(user, "", DEFAULT_ZONE));
    }

    private function onLogout(e:MouseEvent):Void {
        if (sfs != null) sfs.send(new LogoutRequest());
    }

    private function onToggleUdpCb(e:MouseEvent):Void {
        useUdpChecked = !useUdpChecked;
        drawCheckbox(useUdpCb, useUdpChecked);
    }

    private function onSend(e:MouseEvent):Void {
        doSend();
    }

    private function onMsgKeyDown(e:KeyboardEvent):Void {
        if (e.keyCode == Keyboard.ENTER) doSend();
    }

    private function doSend():Void {
        var msg:String = StringTools.trim(msgInput.text);
        if (msg == "") return;
        if (sfs == null || sfs.getLastJoinedRoom() == null) {
            writeChat("Join a room first.", true);
            return;
        }

        if (useUdpChecked && sfs.isUdpConnected()) {
            var params = new SFSObject();
            params.putString("msg", msg);
            var room = sfs.getLastJoinedRoom();
            sfs.send(new ExtensionRequest("udpChat", params, room, TransportType.UDP));
            writeChatBold("[UDP] You said:", msg);
        } else {
            sfs.send(new PublicMessageRequest(msg));
        }
        msgInput.text = "";
    }

    private function onSetTopic(e:MouseEvent):Void {
        if (sfs == null) return;
        var room = sfs.getLastJoinedRoom();
        if (room == null) {
            writeChat("Join a room first.", true);
            return;
        }
        var t:String = StringTools.trim(topicInput.text);
        var v = new SFSRoomVariable("topic", t != "" ? t : null);
        sfs.send(new SetRoomVariablesRequest([v], room));
        if (t != "") writeChat("Room topic set to '" + t + "'", true);
    }
}
