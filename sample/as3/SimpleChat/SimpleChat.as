package {

import flash.display.Sprite;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.ui.Keyboard;

import com.smartfoxserver.v3.SmartFox;
import com.smartfoxserver.v3.ConfigData;
import com.smartfoxserver.v3.core.SFSEvent;
import com.smartfoxserver.v3.core.EventParam;
import com.smartfoxserver.v3.core.ApiEvent;
import com.smartfoxserver.v3.requests.LoginRequest;
import com.smartfoxserver.v3.requests.LogoutRequest;
import com.smartfoxserver.v3.requests.JoinRoomRequest;
import com.smartfoxserver.v3.requests.PublicMessageRequest;
import com.smartfoxserver.v3.requests.SetRoomVariablesRequest;
import com.smartfoxserver.v3.requests.ExtensionRequest;
import com.smartfoxserver.v3.entities.variables.SFSRoomVariable;
import com.smartfoxserver.v3.entities.data.SFSObject;
import com.smartfoxserver.v3.bitswarm.TransportType;

[SWF(width="920", height="600", backgroundColor="#ffffff", frameRate="30")]
public class SimpleChat extends Sprite {

    private static const DEFAULT_HOST:String = "127.0.0.1";
    private static const DEFAULT_TCP_PORT:int = 9977;
    private static const DEFAULT_WS_PORT:int = 8088;
    private static const DEFAULT_ZONE:String = "Playground";

    private static const PAD:int = 8;
    private static const HEADER_H:int = 36;
    private static const BTN_W:int = 80;
    private static const BTN_H:int = 24;
    private static const INPUT_H:int = 22;

    private static const CLR_BG:uint = 0xF0F0F0;
    private static const CLR_BORDER:uint = 0xCCCCCC;
    private static const CLR_BTN:uint = 0xE8E8E8;
    private static const CLR_BTN_DIS:uint = 0xD8D8D8;
    private static const CLR_TEXT:uint = 0x333333;
    private static const CLR_SYSTEM:uint = 0x666666;
    private static const CLR_ACCENT:uint = 0xFF9933;
    private static const CLR_WHITE:uint = 0xFFFFFF;

    private var sfs:SmartFox;

    // Transport dropdown simulation (toggle button)
    private var transportIsTcp:Boolean = true;
    private var transportBtn:Sprite;
    private var transportLabel:TextField;

    // Header buttons
    private var connectBtn:Sprite;
    private var loginBtn:Sprite;
    private var logoutBtn:Sprite;
    private var disconnectBtn:Sprite;
    private var initUdpBtn:Sprite;
    private var udpPingBtn:Sprite;
    private var udpStatusLabel:TextField;

    // Username
    private var usernameInput:TextField;

    // Chat
    private var chatHistory:TextField;
    private var msgInput:TextField;
    private var useUdpCb:Sprite;
    private var useUdpChecked:Boolean = false;
    private var useUdpLabel:TextField;
    private var sendBtn:Sprite;

    // Topic
    private var topicLabel:TextField;
    private var topicInput:TextField;
    private var setTopicBtn:Sprite;

    // Rooms / Users
    private var roomsList:TextField;
    private var usersList:TextField;
    private var roomRefs:Array = [];
    private var selectedRoomIdx:int = -1;

    // Title
    private var titleLabel:TextField;

    // Layout
    private var stageW:int = 920;
    private var stageH:int = 600;

    public function SimpleChat() {
        stage.align = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stageW = stage.stageWidth;
        stageH = stage.stageHeight;

        buildUI();
        setConnected(false);
        setChatEnabled(false);

        stage.addEventListener(Event.RESIZE, onResize);
    }

    // =========================================================================
    // UI BUILD
    // =========================================================================

    private function buildUI():void {
        // Header background
        var headerBg:Shape = new Shape();
        headerBg.name = "headerBg";
        addChild(headerBg);

        var cx:int = PAD;
        var cy:int = 6;

        // Title
        titleLabel = makeLabel("SFS3™ massive multiplayer platform", 11, true);
        titleLabel.x = cx;
        titleLabel.y = cy + 2;
        addChild(titleLabel);
        cx += titleLabel.width + 12;

        // Transport toggle
        transportBtn = makeButton("TCP", 52);
        transportBtn.x = cx; transportBtn.y = cy;
        addChild(transportBtn);
        transportLabel = transportBtn.getChildByName("lbl") as TextField;
        transportBtn.addEventListener(MouseEvent.CLICK, onTransportToggle);
        cx += 58;

        // Connect
        connectBtn = makeButton("Connect", BTN_W);
        connectBtn.x = cx; connectBtn.y = cy;
        addChild(connectBtn);
        connectBtn.addEventListener(MouseEvent.CLICK, onConnect);
        cx += BTN_W + 6;

        // Username input
        usernameInput = makeInput(80, INPUT_H);
        usernameInput.text = "Bax";
        usernameInput.x = cx; usernameInput.y = cy + 1;
        addChild(usernameInput);
        cx += 86;

        // Login
        loginBtn = makeButton("Login", 56);
        loginBtn.x = cx; loginBtn.y = cy;
        addChild(loginBtn);
        loginBtn.addEventListener(MouseEvent.CLICK, onLogin);
        cx += 62;

        // Logout
        logoutBtn = makeButton("Logout", 56);
        logoutBtn.x = cx; logoutBtn.y = cy;
        addChild(logoutBtn);
        logoutBtn.addEventListener(MouseEvent.CLICK, onLogout);
        cx += 62;

        // Disconnect
        disconnectBtn = makeButton("Disconnect", 76);
        disconnectBtn.x = cx; disconnectBtn.y = cy;
        addChild(disconnectBtn);
        disconnectBtn.addEventListener(MouseEvent.CLICK, onDisconnect);
        cx += 82;

        // Separator
        var sep:Shape = new Shape();
        sep.graphics.beginFill(CLR_BORDER);
        sep.graphics.drawRect(0, 0, 1, 20);
        sep.graphics.endFill();
        sep.x = cx; sep.y = cy + 2;
        addChild(sep);
        cx += 7;

        // Init UDP
        initUdpBtn = makeButton("Init UDP", 64);
        initUdpBtn.x = cx; initUdpBtn.y = cy;
        addChild(initUdpBtn);
        initUdpBtn.addEventListener(MouseEvent.CLICK, onInitUdp);
        cx += 70;

        // UDP Ping
        udpPingBtn = makeButton("UDP Ping", 68);
        udpPingBtn.x = cx; udpPingBtn.y = cy;
        addChild(udpPingBtn);
        udpPingBtn.addEventListener(MouseEvent.CLICK, onUdpPing);
        cx += 74;

        // UDP status
        udpStatusLabel = makeLabel("UDP: off", 11, false, CLR_SYSTEM);
        udpStatusLabel.x = cx; udpStatusLabel.y = cy + 4;
        addChild(udpStatusLabel);

        // --- Content area ---
        var contentY:int = HEADER_H + PAD;
        var sideW:int = 210;
        var chatW:int = stageW - sideW - PAD * 3;
        var contentH:int = stageH - HEADER_H - PAD * 2;

        // Topic label
        topicLabel = makeLabel("Topic is '(not set)'", 12, false, CLR_SYSTEM);
        topicLabel.x = PAD;
        topicLabel.y = contentY;
        addChild(topicLabel);

        // Chat history
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

        // Msg row
        var msgY:int = chatHistory.y + chatHistory.height + 4;
        msgInput = makeInput(chatW - BTN_W - 80, INPUT_H);
        msgInput.x = PAD;
        msgInput.y = msgY;
        addChild(msgInput);
        msgInput.addEventListener(KeyboardEvent.KEY_DOWN, onMsgKeyDown);

        // UDP checkbox
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

        // Topic row
        var topicY:int = msgY + INPUT_H + 6;
        var topicLbl:TextField = makeLabel("Chat topic:", 12, false, CLR_TEXT);
        topicLbl.x = PAD;
        topicLbl.y = topicY + 2;
        addChild(topicLbl);

        topicInput = makeInput(140, INPUT_H);
        topicInput.text = "Movies";
        topicInput.x = PAD + 80;
        topicInput.y = topicY;
        addChild(topicInput);

        setTopicBtn = makeButton("Set", 40);
        setTopicBtn.x = topicInput.x + topicInput.width + 6;
        setTopicBtn.y = topicY;
        addChild(setTopicBtn);
        setTopicBtn.addEventListener(MouseEvent.CLICK, onSetTopic);

        // --- Side panel ---
        var sideX:int = stageW - sideW - PAD;
        var halfH:int = (contentH - PAD) / 2;

        var roomsTitle:TextField = makeLabel("Rooms", 12, true, CLR_SYSTEM);
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

        var usersTitle:TextField = makeLabel("Users", 12, true, CLR_SYSTEM);
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

    private function drawHeaderBg():void {
        var bg:Shape = getChildByName("headerBg") as Shape;
        if (!bg) return;
        bg.graphics.clear();
        bg.graphics.beginFill(CLR_BG);
        bg.graphics.drawRect(0, 0, stageW, HEADER_H);
        bg.graphics.endFill();
        bg.graphics.lineStyle(1, CLR_BORDER);
        bg.graphics.moveTo(0, HEADER_H);
        bg.graphics.lineTo(stageW, HEADER_H);
    }

    private function onResize(e:Event):void {
        stageW = stage.stageWidth;
        stageH = stage.stageHeight;
        drawHeaderBg();
    }

    // =========================================================================
    // UI HELPERS
    // =========================================================================

    private function makeLabel(text:String, size:int = 12, bold:Boolean = false, color:uint = 0x333333):TextField {
        var tf:TextField = new TextField();
        tf.defaultTextFormat = new TextFormat("_sans", size, color, bold);
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.selectable = false;
        tf.mouseEnabled = false;
        tf.text = text;
        return tf;
    }

    private function makeInput(w:int, h:int):TextField {
        var tf:TextField = new TextField();
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

    private function makeButton(label:String, w:int = 80):Sprite {
        var sp:Sprite = new Sprite();
        sp.buttonMode = true;
        sp.useHandCursor = true;

        sp.graphics.beginFill(CLR_WHITE);
        sp.graphics.lineStyle(1, 0xAAAAAA);
        sp.graphics.drawRoundRect(0, 0, w, BTN_H, 4, 4);
        sp.graphics.endFill();

        var lbl:TextField = makeLabel(label, 11, false, CLR_TEXT);
        lbl.name = "lbl";
        lbl.x = (w - lbl.width) / 2;
        lbl.y = (BTN_H - lbl.height) / 2;
        sp.addChild(lbl);

        return sp;
    }

    private function setBtnEnabled(btn:Sprite, enabled:Boolean):void {
        btn.mouseEnabled = enabled;
        btn.mouseChildren = enabled;
        btn.alpha = enabled ? 1.0 : 0.45;
        btn.buttonMode = enabled;
    }

    private function drawCheckbox(sp:Sprite, checked:Boolean):void {
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

    private function setConnected(connected:Boolean):void {
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

    private function setLoggedIn(loggedIn:Boolean):void {
        setBtnEnabled(logoutBtn, loggedIn);
        setBtnEnabled(initUdpBtn, loggedIn);
        if (!loggedIn) {
            udpStatusLabel.text = "UDP: off";
        }
        if (loggedIn) populateRooms();
    }

    private function setChatEnabled(enabled:Boolean):void {
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

    private function writeChat(text:String, isSystem:Boolean = false):void {
        var fmt:TextFormat = new TextFormat("_sans", 12, isSystem ? CLR_SYSTEM : CLR_TEXT);
        var start:int = chatHistory.length;
        chatHistory.appendText(text + "\n");
        chatHistory.setTextFormat(fmt, start, chatHistory.length);
        chatHistory.scrollV = chatHistory.maxScrollV;
    }

    private function writeChatBold(sender:String, message:String):void {
        var start:int = chatHistory.length;
        chatHistory.appendText(sender + " " + message + "\n");
        var boldFmt:TextFormat = new TextFormat("_sans", 12, CLR_TEXT, true);
        chatHistory.setTextFormat(boldFmt, start, start + sender.length);
        chatHistory.scrollV = chatHistory.maxScrollV;
    }

    // =========================================================================
    // ROOMS / USERS
    // =========================================================================

    private function populateRooms():void {
        roomRefs = [];
        selectedRoomIdx = -1;
        roomsList.text = "";
        if (!sfs) return;
        var rm:* = sfs.getRoomManager();
        if (!rm) return;
        var rooms:* = rm.getRoomList();
        if (!rooms || rooms.length == 0) {
            roomsList.text = "(no rooms)";
            return;
        }
        var lines:Array = [];
        for (var i:int = 0; i < rooms.length; i++) {
            var r:* = rooms[i];
            roomRefs.push(r);
            lines.push(r.getName() + "  (" + r.getUserCount() + "/" + r.getMaxUsers() + ")");
        }
        roomsList.text = lines.join("\n");
    }

    private function populateUsers():void {
        usersList.text = "";
        if (!sfs) { usersList.text = "(no connection)"; return; }
        var room:* = sfs.getLastJoinedRoom();
        if (!room) { usersList.text = "(no room)"; return; }
        var users:* = room.getUserList();
        if (!users || users.length == 0) { usersList.text = "(no users)"; return; }
        var lines:Array = [];
        for (var i:int = 0; i < users.length; i++) {
            var u:* = users[i];
            lines.push(u.getName() + (u.getIsItMe() ? " (you)" : ""));
        }
        usersList.text = lines.join("\n");
    }

    private function showRoomTopic(room:*):void {
        if (!room || !room.containsVariable("topic")) {
            topicLabel.text = "Topic is '(not set)'";
            return;
        }
        var v:* = room.getVariable("topic");
        var val:String = v ? v.getValue() : null;
        topicLabel.text = "Topic is '" + (val || "") + "'";
    }

    // =========================================================================
    // ROOM CLICK (line-based selection)
    // =========================================================================

    private function onRoomClick(e:MouseEvent):void {
        if (!sfs || roomRefs.length == 0) return;
        var lineIdx:int = roomsList.getLineIndexAtPoint(e.localX, e.localY);
        if (lineIdx < 0 || lineIdx >= roomRefs.length) return;

        var current:* = sfs.getLastJoinedRoom();
        var room:* = roomRefs[lineIdx];
        if (current && current.getId() == room.getId()) return;

        selectedRoomIdx = lineIdx;
        sfs.send(new JoinRoomRequest(room));
    }

    // =========================================================================
    // SFS EVENT HANDLERS
    // =========================================================================

    private function onSfsConnection(evt:ApiEvent):void {
        var success:Boolean = evt.getParam(EventParam.Success);
        if (success) {
            setConnected(true);
            var proto:String = transportIsTcp ? "TCP" : "WebSocket";
            writeChat("Connected to SmartFoxServer 3 via " + proto + ".", true);
        } else {
            var msg:String = evt.getParam(EventParam.ErrorMessage) || "Connection failed";
            setConnected(false);
            writeChat("Connection failed: " + msg, true);
        }
    }

    private function onSfsConnectionLost(evt:ApiEvent):void {
        var reason:String = evt.getParam(EventParam.DisconnectionReason);
        sfs = null;
        setConnected(false);
        setLoggedIn(false);
        setChatEnabled(false);
        writeChat("Disconnected. " + (reason || ""), true);
    }

    private function onSfsLogin(evt:ApiEvent):void {
        setLoggedIn(true);
        writeChat("Logged in.", true);
    }

    private function onSfsLoginError(evt:ApiEvent):void {
        var msg:String = evt.getParam(EventParam.ErrorMessage) || "Login failed";
        writeChat("Login error: " + msg, true);
    }

    private function onSfsLogout(evt:ApiEvent):void {
        setLoggedIn(false);
        setChatEnabled(false);
        roomRefs = [];
        roomsList.text = "(logout)";
        usersList.text = "(no users)";
        topicLabel.text = "Topic is '(not set)'";
        writeChat("Logged out.", true);
    }

    private function onSfsRoomJoin(evt:ApiEvent):void {
        var room:* = evt.getParam(EventParam.Room);
        if (!room) return;
        setChatEnabled(true);
        writeChat("You entered room '" + room.getName() + "'", true);
        showRoomTopic(room);
        var v:* = room.containsVariable("topic") ? room.getVariable("topic") : null;
        topicInput.text = (v && v.getValue()) ? v.getValue() : "";
        populateUsers();
    }

    private function onSfsRoomJoinError(evt:ApiEvent):void {
        var msg:String = evt.getParam(EventParam.ErrorMessage) || "Join failed";
        writeChat("Room join error: " + msg, true);
    }

    private function onSfsUserEnterRoom(evt:ApiEvent):void {
        var u:* = evt.getParam(EventParam.User);
        populateUsers();
        if (u && !u.getIsItMe()) writeChat("User " + u.getName() + " entered the room.", true);
    }

    private function onSfsUserExitRoom(evt:ApiEvent):void { populateUsers(); }
    private function onSfsUserCountChange(evt:ApiEvent):void { populateRooms(); }

    private function onSfsPublicMessage(evt:ApiEvent):void {
        var sender:* = evt.getParam(EventParam.Sender);
        var message:String = evt.getParam(EventParam.Message);
        if (!sender || message == null) return;
        var name:String = sender.getIsItMe() ? "You" : sender.getName();
        writeChatBold(name + " said:", message);
    }

    private function onSfsRoomVariablesUpdate(evt:ApiEvent):void {
        var room:* = evt.getParam(EventParam.Room);
        var changed:* = evt.getParam(EventParam.ChangedVars);
        if (room && changed && changed.indexOf("topic") >= 0) {
            showRoomTopic(room);
            var v:* = room.containsVariable("topic") ? room.getVariable("topic") : null;
            topicInput.text = (v && v.getValue()) ? v.getValue() : "";
        }
    }

    private function onSfsUdpConnection(evt:ApiEvent):void {
        var success:Boolean = evt.getParam(EventParam.Success);
        if (success) {
            udpStatusLabel.text = "UDP: on";
            setBtnEnabled(initUdpBtn, false);
            setBtnEnabled(udpPingBtn, true);
            setBtnEnabled(useUdpCb, true);
            writeChat("UDP connection established. You can now send via UDP.", true);
        } else {
            var msg:String = evt.getParam(EventParam.ErrorMessage) || "UDP init failed";
            udpStatusLabel.text = "UDP: failed";
            setBtnEnabled(udpPingBtn, false);
            setBtnEnabled(useUdpCb, false);
            useUdpChecked = false;
            drawCheckbox(useUdpCb, false);
            writeChat("UDP init error: " + msg, true);
        }
    }

    private function onSfsUdpConnectionLost(evt:ApiEvent):void {
        udpStatusLabel.text = "UDP: off";
        setBtnEnabled(initUdpBtn, sfs != null && sfs.isConnected());
        setBtnEnabled(udpPingBtn, false);
        setBtnEnabled(useUdpCb, false);
        useUdpChecked = false;
        drawCheckbox(useUdpCb, false);
        writeChat("UDP connection lost.", true);
    }

    private function onSfsExtensionResponse(evt:ApiEvent):void {
        var cmd:String = evt.getParam(EventParam.Cmd);
        var params:* = evt.getParam(EventParam.ExtParams);

        if (cmd == "udpPing" && params && params.containsKey("t")) {
            var sent:Number = Number(params.getLong("t"));
            var rtt:Number = new Date().time - sent;
            writeChat("[UDP Pong] RTT: " + int(rtt) + " ms", true);
        } else if (cmd == "udpChat" && params && params.containsKey("msg")) {
            var senderName:String = params.containsKey("sender") ? params.getString("sender") : "?";
            var chatMsg:String = params.getString("msg");
            writeChatBold("[UDP] " + senderName + " said:", chatMsg);
        } else {
            writeChat("[ExtResponse] cmd='" + cmd + "'", true);
        }
    }

    private function addSfsListeners():void {
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

    private function onTransportToggle(e:MouseEvent):void {
        transportIsTcp = !transportIsTcp;
        transportLabel.text = transportIsTcp ? "TCP" : "WS";
        transportLabel.x = (52 - transportLabel.width) / 2;
    }

    private function onConnect(e:MouseEvent):void {
        sfs = new SmartFox();
        addSfsListeners();

        var cfg:ConfigData = new ConfigData();
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
        var port:int = transportIsTcp ? cfg.port : cfg.httpPort;
        setBtnEnabled(connectBtn, false);
        setBtnEnabled(transportBtn, false);
        writeChat("Connecting via " + proto + " to " + cfg.host + ":" + port + " ...", true);

        try {
            sfs.connect(cfg);
        } catch (err:Error) {
            writeChat("Connect error: " + err.message, true);
            setBtnEnabled(connectBtn, true);
            setBtnEnabled(transportBtn, true);
            sfs = null;
        }
    }

    private function onDisconnect(e:MouseEvent):void {
        if (sfs) sfs.disconnect();
    }

    private function onInitUdp(e:MouseEvent):void {
        if (!sfs || !sfs.isConnected()) { writeChat("Connect and login first.", true); return; }
        try {
            sfs.connectUdp();
            writeChat("Initializing UDP...", true);
        } catch (err:Error) {
            writeChat("UDP init error: " + err.message, true);
        }
    }

    private function onUdpPing(e:MouseEvent):void {
        if (!sfs || !sfs.isUdpConnected()) { writeChat("UDP not connected.", true); return; }
        var params:SFSObject = new SFSObject();
        params.putLong("t", new Date().time);
        var room:* = sfs.getLastJoinedRoom();
        sfs.send(new ExtensionRequest("udpPing", params, room, TransportType.UDP));
        writeChat("[UDP Ping] Sent...", true);
    }

    private function onLogin(e:MouseEvent):void {
        if (!sfs) return;
        var user:String = usernameInput.text.replace(/^\s+|\s+$/g, "") || "Guest";
        sfs.send(new LoginRequest(user, "", DEFAULT_ZONE));
    }

    private function onLogout(e:MouseEvent):void {
        if (sfs) sfs.send(new LogoutRequest());
    }

    private function onToggleUdpCb(e:MouseEvent):void {
        useUdpChecked = !useUdpChecked;
        drawCheckbox(useUdpCb, useUdpChecked);
    }

    private function onSend(e:MouseEvent):void {
        doSend();
    }

    private function onMsgKeyDown(e:KeyboardEvent):void {
        if (e.keyCode == Keyboard.ENTER) doSend();
    }

    private function doSend():void {
        var msg:String = msgInput.text.replace(/^\s+|\s+$/g, "");
        if (!msg) return;
        if (!sfs || !sfs.getLastJoinedRoom()) { writeChat("Join a room first.", true); return; }

        if (useUdpChecked && sfs.isUdpConnected()) {
            var params:SFSObject = new SFSObject();
            params.putString("msg", msg);
            var room:* = sfs.getLastJoinedRoom();
            sfs.send(new ExtensionRequest("udpChat", params, room, TransportType.UDP));
            writeChatBold("[UDP] You said:", msg);
        } else {
            sfs.send(new PublicMessageRequest(msg));
        }
        msgInput.text = "";
    }

    private function onSetTopic(e:MouseEvent):void {
        if (!sfs) return;
        var room:* = sfs.getLastJoinedRoom();
        if (!room) { writeChat("Join a room first.", true); return; }
        var t:String = topicInput.text.replace(/^\s+|\s+$/g, "");
        var v:SFSRoomVariable = new SFSRoomVariable("topic", t || null);
        sfs.send(new SetRoomVariablesRequest([v], room));
        if (t) writeChat("Room topic set to '" + t + "'", true);
    }
}
}
