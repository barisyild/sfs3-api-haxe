#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Simple Chat - SmartFoxServer 3 style UI (Tkinter).
Uses SFS3_API_PY for connect, login, rooms, public chat, and room topic.
Based on: https://docs2x.smartfoxserver.com/ExamplesJS/simple-chat
"""

import tkinter as tk
from tkinter import ttk, scrolledtext, font as tkfont

# SFS3 API (single file, long names)
import SFS3_API_PY as SFS3

# Default connection
DEFAULT_HOST = "127.0.0.1"
DEFAULT_PORT = 9977
DEFAULT_WS_PORT = 8088
DEFAULT_ZONE = "Playground"


def main():
    root = tk.Tk()
    root.title("SmartFoxServer 3 Examples - Simple Chat")
    root.minsize(800, 520)
    root.geometry("900x580")

    # --- SFS instance and state (new instance on every Connect) ---
    sfs_ref = [None]  # current SmartFox instance; new one created each Connect
    room_list_refs = []  # list of SFSRoom so we can join by selection index
    sample_messages_shown = [True]  # mutable so inner fns can clear

    # --- Styles ---
    style = ttk.Style()
    style.configure("Header.TFrame", background="#f0f0f0")

    # --- Top header / control panel ---
    header = ttk.Frame(root, style="Header.TFrame", padding=(8, 6))
    header.pack(fill=tk.X)

    left_header = ttk.Frame(header)
    left_header.pack(side=tk.LEFT)
    ttk.Label(left_header, text="SmartFoxServer 3™ massive multiplayer platform", style="Header.TFrame").pack(
        side=tk.LEFT, padx=(0, 20)
    )

    ctrl_frame = ttk.Frame(header)
    ctrl_frame.pack(side=tk.LEFT, padx=10)
    ws_var = tk.BooleanVar(value=False)
    ttk.Checkbutton(ctrl_frame, text="WS", variable=ws_var).pack(side=tk.LEFT, padx=(0, 2))
    connect_bt = ttk.Button(ctrl_frame, text="Connect", width=10)
    connect_bt.pack(side=tk.LEFT, padx=2)
    username_var = tk.StringVar(value="Bax")
    ttk.Entry(ctrl_frame, textvariable=username_var, width=12).pack(side=tk.LEFT, padx=2)
    login_bt = ttk.Button(ctrl_frame, text="Login", width=8)
    login_bt.pack(side=tk.LEFT, padx=2)
    logout_bt = ttk.Button(ctrl_frame, text="Logout", width=8)
    logout_bt.pack(side=tk.LEFT, padx=2)
    disconnect_bt = ttk.Button(ctrl_frame, text="Disconnect", width=10)
    disconnect_bt.pack(side=tk.LEFT, padx=2)


    right_header = ttk.Frame(header)
    right_header.pack(side=tk.RIGHT)
    ttk.Label(right_header, text="SmartFoxServer 3 Examples  |  Simple Chat").pack(side=tk.RIGHT)

    # --- Main content ---
    content = ttk.Frame(root, padding=(8, 8))
    content.pack(fill=tk.BOTH, expand=True)

    # --- Chat panel ---
    chat_frame = ttk.LabelFrame(content, text="Chat", padding=(8, 6))
    chat_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=(0, 6))

    topic_label_var = tk.StringVar(value="Topic is '(not set)'")
    topic_row = ttk.Frame(chat_frame)
    topic_row.pack(fill=tk.X)
    ttk.Label(topic_row, textvariable=topic_label_var).pack(side=tk.LEFT)

    chat_history = scrolledtext.ScrolledText(
        chat_frame,
        wrap=tk.WORD,
        height=18,
        font=("Segoe UI", 10),
        bg="white",
        fg="#333",
        insertbackground="black",
        state=tk.DISABLED,
    )
    chat_history.pack(fill=tk.BOTH, expand=True, pady=(6, 8))
    bold_font = tkfont.Font(chat_history, chat_history.cget("font"))
    bold_font.configure(weight="bold")
    chat_history.tag_configure("system", foreground="#666")
    chat_history.tag_configure("bold", font=bold_font)

    # All UI mutations must happen on the main thread. SFS callbacks come from
    # background threads, so we schedule them with root.after(). Functions below
    # that are prefixed with _ui_ assume they are ALREADY on the main thread and
    # must NOT call root.after() again to avoid double-queuing.

    def _ui_write_chat(text, tag=None):
        chat_history.config(state=tk.NORMAL)
        if sample_messages_shown[0]:
            sample_messages_shown[0] = False
            chat_history.delete("1.0", tk.END)
        chat_history.insert(tk.END, text + "\n", tag or "")
        chat_history.config(state=tk.DISABLED)
        chat_history.see(tk.END)

    # Message input
    msg_frame = ttk.Frame(chat_frame)
    msg_frame.pack(fill=tk.X, pady=(0, 6))
    msg_var = tk.StringVar()
    msg_entry = ttk.Entry(msg_frame, textvariable=msg_var, width=50)
    msg_entry.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 6))
    send_bt = ttk.Button(msg_frame, text="Send", width=8)
    send_bt.pack(side=tk.LEFT)

    # Chat topic
    topic_frame = ttk.Frame(chat_frame)
    topic_frame.pack(fill=tk.X)
    ttk.Label(topic_frame, text="Chat topic:").pack(side=tk.LEFT, padx=(0, 6))
    topic_var = tk.StringVar(value="Movies")
    ttk.Entry(topic_frame, textvariable=topic_var, width=20).pack(side=tk.LEFT, padx=(0, 6))
    set_topic_bt = ttk.Button(topic_frame, text="Set", width=6)
    set_topic_bt.pack(side=tk.LEFT)

    # --- Side panel: Rooms & Users ---
    side_frame = ttk.Frame(content, width=220)
    side_frame.pack(side=tk.RIGHT, fill=tk.Y, padx=(6, 0))
    side_frame.pack_propagate(False)

    rooms_lf = ttk.LabelFrame(side_frame, text="Rooms", padding=(6, 4))
    rooms_lf.pack(fill=tk.BOTH, expand=True, pady=(0, 6))
    rooms_list = tk.Listbox(
        rooms_lf,
        font=("Segoe UI", 9),
        selectbackground="#ff9933",
        selectforeground="white",
        activestyle="none",
        highlightthickness=0,
    )
    rooms_list.pack(fill=tk.BOTH, expand=True)
    rooms_list.insert(tk.END, "(connect and login to see rooms)")

    users_lf = ttk.LabelFrame(side_frame, text="Users", padding=(6, 4))
    users_lf.pack(fill=tk.BOTH, expand=True)
    users_list = tk.Listbox(
        users_lf,
        font=("Segoe UI", 9),
        selectbackground="#ff9933",
        selectforeground="white",
        activestyle="none",
        highlightthickness=0,
    )
    users_list.pack(fill=tk.BOTH, expand=True)
    users_list.insert(tk.END, "(no users)")

    # --- UI state helpers (called on main thread only) ---
    def _ui_set_connected(connected):
        login_bt.config(state=tk.NORMAL if connected else tk.DISABLED)
        logout_bt.config(state=tk.DISABLED)
        disconnect_bt.config(state=tk.NORMAL if connected else tk.DISABLED)
        connect_bt.config(state=tk.DISABLED if connected else tk.NORMAL)

    def _ui_set_logged_in(logged_in):
        logout_bt.config(state=tk.NORMAL if logged_in else tk.DISABLED)
        if logged_in:
            _ui_populate_rooms()

    def _ui_set_chat_enabled(enabled):
        state = tk.NORMAL if enabled else tk.DISABLED
        msg_entry.config(state=state)
        send_bt.config(state=state)
        set_topic_bt.config(state=state)

    def _ui_populate_rooms():
        sfs = sfs_ref[0]
        room_list_refs.clear()
        rooms_list.delete(0, tk.END)
        if sfs is None:
            return
        rm = sfs.getRoomManager()
        if rm is None:
            return
        rooms = rm.getRoomList()
        if rooms is None:
            return
        for r in rooms:
            name = r.getName()
            uc = r.getUserCount()
            mu = r.getMaxUsers()
            rooms_list.insert(tk.END, "{}  ({}/{})".format(name, uc, mu))
            room_list_refs.append(r)
        if not room_list_refs:
            rooms_list.insert(tk.END, "(no rooms)")

    def _ui_populate_users():
        users_list.delete(0, tk.END)
        sfs = sfs_ref[0]
        if sfs is None:
            users_list.insert(tk.END, "(no connection)")
            return
        room = sfs.getLastJoinedRoom()
        if room is None:
            users_list.insert(tk.END, "(no room)")
            return
        for u in room.getUserList():
            name = u.getName()
            suffix = " (you)" if u.getIsItMe() else ""
            users_list.insert(tk.END, name + suffix)
        if users_list.size() == 0:
            users_list.insert(tk.END, "(no users)")

    def _ui_show_room_topic(room):
        if room is None:
            topic_label_var.set("Topic is '(not set)'")
            return
        v = room.getVariable("topic") if room.containsVariable("topic") else None
        if v is None:
            topic_label_var.set("Topic is '(not set)'")
        else:
            val = v.getValue()
            topic_label_var.set("Topic is '{}'".format(val if val is not None else ""))

    # --- SFS event handlers (called from background threads) ---
    # Each schedules ONE root.after() call that does all UI work in a single batch.

    def on_connection(evt):
        success = evt.getParam(SFS3.EventParam.Success)
        if success:
            def _ui():
                _ui_set_connected(True)
                _ui_write_chat("Connected to SmartFoxServer 3.", "system")
            root.after(0, _ui)
        else:
            msg = evt.getParam(SFS3.EventParam.ErrorMessage) or "Connection failed"
            def _ui():
                _ui_set_connected(False)
                _ui_write_chat("Connection failed: " + str(msg), "system")
            root.after(0, _ui)

    def on_connection_lost(evt):
        reason = evt.getParam(SFS3.EventParam.DisconnectionReason)
        def _ui():
            sfs_ref[0] = None
            _ui_set_connected(False)
            _ui_set_logged_in(False)
            _ui_set_chat_enabled(False)
            _ui_write_chat("Disconnected. " + (str(reason) if reason else ""), "system")
        root.after(0, _ui)

    def on_login(evt):
        def _ui():
            _ui_set_logged_in(True)
            _ui_write_chat("Logged in.", "system")
        root.after(0, _ui)

    def on_login_error(evt):
        msg = evt.getParam(SFS3.EventParam.ErrorMessage) or "Login failed"
        root.after(0, lambda: _ui_write_chat("Login error: " + str(msg), "system"))

    def on_logout(evt):
        def _ui():
            _ui_set_logged_in(False)
            _ui_set_chat_enabled(False)
            room_list_refs.clear()
            rooms_list.delete(0, tk.END)
            rooms_list.insert(tk.END, "(logout - select room after login)")
            users_list.delete(0, tk.END)
            users_list.insert(tk.END, "(no users)")
            topic_label_var.set("Topic is '(not set)'")
            _ui_write_chat("Logged out.", "system")
        root.after(0, _ui)

    def on_room_join(evt):
        room = evt.getParam(SFS3.EventParam.Room)
        if room:
            def _ui():
                _ui_set_chat_enabled(True)
                _ui_write_chat("You entered room '{}'".format(room.getName()), "system")
                _ui_show_room_topic(room)
                v = room.getVariable("topic") if room.containsVariable("topic") else None
                topic_var.set((v.getValue() or "") if v else "")
                _ui_populate_users()
            root.after(0, _ui)

    def on_room_join_error(evt):
        msg = evt.getParam(SFS3.EventParam.ErrorMessage) or "Join failed"
        root.after(0, lambda: _ui_write_chat("Room join error: " + str(msg), "system"))

    def on_user_enter_room(evt):
        u = evt.getParam(SFS3.EventParam.User)
        def _ui():
            _ui_populate_users()
            if u and not u.getIsItMe():
                _ui_write_chat("User {} entered the room.".format(u.getName()), "system")
        root.after(0, _ui)

    def on_user_exit_room(evt):
        root.after(0, _ui_populate_users)

    def on_user_count_change(evt):
        root.after(0, _ui_populate_rooms)

    def on_public_message(evt):
        sender = evt.getParam(SFS3.EventParam.Sender)
        message = evt.getParam(SFS3.EventParam.Message)
        if sender is None or message is None:
            return
        name = "You" if sender.getIsItMe() else sender.getName()
        def _ui():
            chat_history.config(state=tk.NORMAL)
            if sample_messages_shown[0]:
                sample_messages_shown[0] = False
                chat_history.delete("1.0", tk.END)
            chat_history.insert(tk.END, "{} said: ".format(name), "bold")
            chat_history.insert(tk.END, message + "\n", "")
            chat_history.config(state=tk.DISABLED)
            chat_history.see(tk.END)
        root.after(0, _ui)

    def on_room_variables_update(evt):
        room = evt.getParam(SFS3.EventParam.Room)
        changed = evt.getParam(SFS3.EventParam.ChangedVars)
        if room and changed and "topic" in changed:
            def _ui():
                _ui_show_room_topic(room)
                v = room.getVariable("topic") if room.containsVariable("topic") else None
                topic_var.set((v.getValue() or "") if v else "")
            root.after(0, _ui)

    def add_listeners(sfs):
        sfs.addEventListener(SFS3.SFSEvent.CONNECTION, on_connection)
        sfs.addEventListener(SFS3.SFSEvent.CONNECTION_LOST, on_connection_lost)
        sfs.addEventListener(SFS3.SFSEvent.LOGIN, on_login)
        sfs.addEventListener(SFS3.SFSEvent.LOGIN_ERROR, on_login_error)
        sfs.addEventListener(SFS3.SFSEvent.LOGOUT, on_logout)
        sfs.addEventListener(SFS3.SFSEvent.ROOM_JOIN, on_room_join)
        sfs.addEventListener(SFS3.SFSEvent.ROOM_JOIN_ERROR, on_room_join_error)
        sfs.addEventListener(SFS3.SFSEvent.USER_ENTER_ROOM, on_user_enter_room)
        sfs.addEventListener(SFS3.SFSEvent.USER_EXIT_ROOM, on_user_exit_room)
        sfs.addEventListener(SFS3.SFSEvent.USER_COUNT_CHANGE, on_user_count_change)
        sfs.addEventListener(SFS3.SFSEvent.PUBLIC_MESSAGE, on_public_message)
        sfs.addEventListener(SFS3.SFSEvent.ROOM_VARIABLES_UPDATE, on_room_variables_update)

    # --- Button actions (called on main thread by Tkinter) ---
    def do_connect():
        sfs_ref[0] = SFS3.SmartFox()
        add_listeners(sfs_ref[0])
        cfg = SFS3.ConfigData()
        cfg.host = DEFAULT_HOST
        cfg.zone = DEFAULT_ZONE
        cfg.blueBox.isActive = False

        use_ws = ws_var.get()
        if use_ws:
            cfg.useWebSocket = True
            cfg.httpPort = DEFAULT_WS_PORT
            cfg.port = DEFAULT_WS_PORT
        else:
            cfg.port = DEFAULT_PORT

        proto = "WebSocket" if use_ws else "TCP"
        port = cfg.httpPort if use_ws else cfg.port
        connect_bt.config(state=tk.DISABLED)
        _ui_write_chat("Connecting via {} to {}:{} ...".format(proto, cfg.host, port), "system")
        try:
            sfs_ref[0].connect(cfg)
        except Exception as e:
            _ui_write_chat("Connect error: " + str(e), "system")
            connect_bt.config(state=tk.NORMAL)
            sfs_ref[0] = None

    def do_disconnect():
        if sfs_ref[0] is not None:
            sfs_ref[0].disconnect()

    def do_login():
        if sfs_ref[0] is None:
            return
        user = (username_var.get() or "").strip() or "Guest"
        sfs_ref[0].send(SFS3.LoginRequest(user, "", DEFAULT_ZONE))

    def do_logout():
        if sfs_ref[0] is not None:
            sfs_ref[0].send(SFS3.LogoutRequest())

    def on_room_select(evt):
        if sfs_ref[0] is None:
            return
        sel = rooms_list.curselection()
        if not sel or sel[0] >= len(room_list_refs):
            return
        room = room_list_refs[sel[0]]
        if sfs_ref[0].getLastJoinedRoom() is None or sfs_ref[0].getLastJoinedRoom().getId() != room.getId():
            sfs_ref[0].send(SFS3.JoinRoomRequest(room))

    def do_send():
        msg = (msg_var.get() or "").strip()
        if not msg:
            return
        if sfs_ref[0] is None or sfs_ref[0].getLastJoinedRoom() is None:
            _ui_write_chat("Join a room first.", "system")
            return
        sfs_ref[0].send(SFS3.PublicMessageRequest(msg))
        msg_var.set("")

    def do_set_topic():
        if sfs_ref[0] is None:
            return
        t = (topic_var.get() or "").strip()
        room = sfs_ref[0].getLastJoinedRoom()
        if room is None:
            _ui_write_chat("Join a room first.", "system")
            return
        var = SFS3.SFSRoomVariable("topic", t if t else None)
        sfs_ref[0].send(SFS3.SetRoomVariablesRequest([var], room))
        if t:
            _ui_write_chat("Room topic set to '{}'".format(t), "system")

    connect_bt.config(command=do_connect)
    disconnect_bt.config(command=do_disconnect)
    login_bt.config(command=do_login)
    logout_bt.config(command=do_logout)
    send_bt.config(command=do_send)
    set_topic_bt.config(command=do_set_topic)
    rooms_list.bind("<<ListboxSelect>>", on_room_select)

    # Initial UI state
    _ui_set_connected(False)
    _ui_set_chat_enabled(False)
    logout_bt.config(state=tk.DISABLED)

    root.mainloop()


if __name__ == "__main__":
    main()
