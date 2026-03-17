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
import SFS3_API_PY as _api

# SFS3 namespace (use SFS3.SmartFox, SFS3.ConfigData, etc.)
class SFS3:
    SmartFox = _api.com_smartfoxserver_v3_SmartFox
    ConfigData = _api.com_smartfoxserver_v3_ConfigData
    SFSEvent = _api.com_smartfoxserver_v3_core_SFSEvent
    EventParam = _api.com_smartfoxserver_v3_core_EventParam
    LoginRequest = _api.com_smartfoxserver_v3_requests_LoginRequest
    LogoutRequest = _api.com_smartfoxserver_v3_requests_LogoutRequest
    JoinRoomRequest = _api.com_smartfoxserver_v3_requests_JoinRoomRequest
    PublicMessageRequest = _api.com_smartfoxserver_v3_requests_PublicMessageRequest
    SetRoomVariablesRequest = _api.com_smartfoxserver_v3_requests_SetRoomVariablesRequest
    SFSRoomVariable = _api.com_smartfoxserver_v3_entities_variables_SFSRoomVariable

# Default connection (change if needed; SFS3 often uses 9933, 2X used 9933/9977)
DEFAULT_HOST = "127.0.0.1"
DEFAULT_PORT = 9933
DEFAULT_ZONE = "BasicExamples"


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

    def write_chat(text, tag=None):
        def do():
            chat_history.config(state=tk.NORMAL)
            if sample_messages_shown[0]:
                sample_messages_shown[0] = False
                chat_history.delete("1.0", tk.END)
            chat_history.insert(tk.END, text + "\n", tag or "")
            chat_history.config(state=tk.DISABLED)
            chat_history.see(tk.END)

        root.after(0, do)

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

    # --- UI state ---
    def set_connected(connected):
        login_bt.config(state=tk.NORMAL if connected else tk.DISABLED)
        logout_bt.config(state=tk.DISABLED)
        disconnect_bt.config(state=tk.NORMAL if connected else tk.DISABLED)
        connect_bt.config(state=tk.DISABLED if connected else tk.NORMAL)

    def set_logged_in(logged_in):
        logout_bt.config(state=tk.NORMAL if logged_in else tk.DISABLED)
        if logged_in:
            populate_rooms_ui()

    def set_chat_enabled(enabled):
        state = tk.NORMAL if enabled else tk.DISABLED
        msg_entry.config(state=state)
        send_bt.config(state=state)
        set_topic_bt.config(state=state)

    def populate_rooms_ui():
        def do():
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

        root.after(0, do)

    def populate_users_ui():
        def do():
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
                suffix = " (you)" if u.isItMe() else ""
                users_list.insert(tk.END, name + suffix)
            if users_list.size() == 0:
                users_list.insert(tk.END, "(no users)")

        root.after(0, do)

    def show_room_topic(room):
        if room is None:
            topic_label_var.set("Topic is '(not set)'")
            return
        v = room.getVariable("topic") if room.containsVariable("topic") else None
        if v is None:
            topic_label_var.set("Topic is '(not set)'")
        else:
            val = v.getValue()
            topic_label_var.set("Topic is '{}'".format(val if val is not None else ""))

    # --- SFS event handlers ---
    def on_connection(evt):
        success = evt.getParam(SFS3.EventParam.Success)
        if success:
            root.after(0, lambda: (set_connected(True), write_chat("Connected to SmartFoxServer 3.", "system")))
        else:
            msg = evt.getParam(SFS3.EventParam.ErrorMessage) or "Connection failed"
            root.after(0, lambda: (set_connected(False), write_chat("Connection failed: " + str(msg), "system")))

    def on_connection_lost(evt):
        reason = evt.getParam(SFS3.EventParam.DisconnectionReason)
        def do():
            sfs_ref[0] = None  # allow new instance on next Connect
            set_connected(False)
            set_logged_in(False)
            set_chat_enabled(False)
            write_chat("Disconnected. " + (str(reason) if reason else ""), "system")
        root.after(0, do)

    def on_login(evt):
        root.after(0, lambda: (set_logged_in(True), write_chat("Logged in.", "system")))

    def on_login_error(evt):
        msg = evt.getParam(SFS3.EventParam.ErrorMessage) or "Login failed"
        root.after(0, lambda: write_chat("Login error: " + str(msg), "system"))

    def on_logout(evt):
        root.after(0, lambda: (
            set_logged_in(False),
            set_chat_enabled(False),
            room_list_refs.clear(),
            rooms_list.delete(0, tk.END),
            rooms_list.insert(tk.END, "(logout - select room after login)"),
            users_list.delete(0, tk.END),
            users_list.insert(tk.END, "(no users)"),
            topic_label_var.set("Topic is '(not set)'"),
            write_chat("Logged out.", "system"),
        ))

    def on_room_join(evt):
        room = evt.getParam(SFS3.EventParam.Room)
        if room:
            root.after(0, lambda: (
                set_chat_enabled(True),
                write_chat("You entered room '{}'".format(room.getName()), "system"),
                show_room_topic(room),
                topic_var.set((room.getVariable("topic").getValue() or "") if room.containsVariable("topic") else ""),
                populate_users_ui(),
            ))

    def on_room_join_error(evt):
        msg = evt.getParam(SFS3.EventParam.ErrorMessage) or "Join failed"
        root.after(0, lambda: write_chat("Room join error: " + str(msg), "system"))

    def on_user_enter_room(evt):
        root.after(0, populate_users_ui)
        u = evt.getParam(SFS3.EventParam.User)
        room = evt.getParam(SFS3.EventParam.Room)
        if u and room and not u.isItMe():
            root.after(0, lambda: write_chat("User {} entered the room.".format(u.getName()), "system"))

    def on_user_exit_room(evt):
        root.after(0, populate_users_ui)

    def on_user_count_change(evt):
        root.after(0, populate_rooms_ui)

    def on_public_message(evt):
        sender = evt.getParam(SFS3.EventParam.Sender)
        message = evt.getParam(SFS3.EventParam.Message)
        if sender is None or message is None:
            return
        name = "You" if sender.isItMe() else sender.getName()
        line = "**{} said:** {}".format(name, message)

        def do():
            chat_history.config(state=tk.NORMAL)
            if sample_messages_shown[0]:
                sample_messages_shown[0] = False
                chat_history.delete("1.0", tk.END)
            chat_history.insert(tk.END, "**{} said:** ".format(name), "bold")
            chat_history.insert(tk.END, message + "\n", "")
            chat_history.config(state=tk.DISABLED)
            chat_history.see(tk.END)

        root.after(0, do)

    def on_room_variables_update(evt):
        room = evt.getParam(SFS3.EventParam.Room)
        changed = evt.getParam(SFS3.EventParam.ChangedVars)
        if room and changed and "topic" in changed:
            def do():
                show_room_topic(room)
                v = room.getVariable("topic") if room.containsVariable("topic") else None
                topic_var.set((v.getValue() or "") if v else "")

            root.after(0, do)

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

    # --- Button actions ---
    def do_connect():
        sfs_ref[0] = SFS3.SmartFox()
        add_listeners(sfs_ref[0])
        cfg = SFS3.ConfigData()
        cfg.host = DEFAULT_HOST
        cfg.port = DEFAULT_PORT
        cfg.zone = DEFAULT_ZONE
        cfg.blueBox.isActive = False  # use TCP, not HTTP BlueBox
        connect_bt.config(state=tk.DISABLED)
        write_chat("Connecting to {}:{} ...".format(cfg.host, cfg.port), "system")
        try:
            sfs_ref[0].connect(cfg)
        except Exception as e:
            write_chat("Connect error: " + str(e), "system")
            connect_bt.config(state=tk.NORMAL)
            sfs_ref[0] = None

    def do_disconnect():
        if sfs_ref[0] is not None:
            sfs_ref[0].disconnect()

    def do_login():
        if sfs_ref[0] is None:
            return
        zone = DEFAULT_ZONE
        user = (username_var.get() or "").strip() or "Guest"
        sfs_ref[0].send(SFS3.LoginRequest(user, "", zone))

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
            write_chat("Join a room first.", "system")
            return
        sfs_ref[0].send(SFS3.PublicMessageRequest(msg))
        msg_var.set("")

    def do_set_topic():
        if sfs_ref[0] is None:
            return
        t = (topic_var.get() or "").strip()
        room = sfs_ref[0].getLastJoinedRoom()
        if room is None:
            write_chat("Join a room first.", "system")
            return
        var = SFS3.SFSRoomVariable("topic", t if t else None)
        sfs_ref[0].send(SFS3.SetRoomVariablesRequest([var], room))
        if t:
            write_chat("Room topic set to '{}'".format(t), "system")

    connect_bt.config(command=do_connect)
    disconnect_bt.config(command=do_disconnect)
    login_bt.config(command=do_login)
    logout_bt.config(command=do_logout)
    send_bt.config(command=do_send)
    set_topic_bt.config(command=do_set_topic)
    rooms_list.bind("<<ListboxSelect>>", on_room_select)

    # Initial UI state
    set_connected(False)
    set_chat_enabled(False)
    logout_bt.config(state=tk.DISABLED)

    root.mainloop()


if __name__ == "__main__":
    main()
