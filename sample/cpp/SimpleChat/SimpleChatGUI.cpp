/*
 * SimpleChatGUI — SmartFoxServer 3 C++ GUI chat client
 *
 * Multiplatform Dear ImGui interface matching the Python/Tkinter example.
 * Uses the C++ OOP wrapper (SFS3.hpp) for all server communication.
 *
 * All SFS3 event callbacks are dispatched on the main thread inside
 * sfs3::update(), so no manual mutex / dispatch queue is needed.
 */

#include "imgui.h"
#include "imgui_impl_glfw.h"
#include "imgui_impl_opengl3.h"

#if defined(__APPLE__)
#define GL_SILENCE_DEPRECATION
#endif
#include <GLFW/glfw3.h>

#include "SFS3.hpp"

#include <string>
#include <vector>

// ── Application state ────────────────────────────────────────────────

struct ChatLine { std::string sender; std::string text; bool system; };

struct RoomInfo { int id; std::string name; int userCount, maxUsers; };
struct UserInfo { std::string name; bool isMe; };

static struct App {
    sfs3::SmartFox sfs;
    bool created     = false;
    bool connected   = false;
    bool loggedIn    = false;
    bool inRoom      = false;

    char host[128]       = "127.0.0.1";
    int  port            = 9977;
    int  wsPort          = 8088;
    char zone[128]       = "Playground";
    bool useWS           = false;
    char username[64]    = "Bax";
    char msgBuf[512]     = "";
    char topicBuf[128]   = "Movies";
    std::string currentTopic = "(not set)";

    std::vector<ChatLine> chat;
    std::vector<RoomInfo> rooms;
    std::vector<UserInfo> users;
    int selRoom          = -1;
    bool scrollChat      = false;

    void log(const std::string& t) { chat.push_back({"", t, true}); scrollChat = true; }
    void msg(const std::string& who, const std::string& t) { chat.push_back({who, t, false}); scrollChat = true; }

    void populateRooms() {
        rooms.clear();
        if (!created) return;
        auto roomList = sfs.getRooms();
        for (auto& r : roomList) {
            rooms.push_back({r.getId(), r.getName(), r.getUserCount(), r.getMaxUsers()});
        }
    }

    void populateUsers() {
        users.clear();
        if (!created) return;
        auto room = sfs.getLastJoinedRoom();
        if (!room) return;
        auto userList = room.getUsers();
        for (auto& u : userList) {
            users.push_back({u.getName(), u.isItMe()});
        }
    }
} g;

// ── SFS3 event handlers ─────────────────────────────────────────────
// All callbacks fire on the main thread (inside sfs3::update), so we
// can directly mutate application state without synchronization.

static void addListeners() {
    g.sfs.addEventListener(SFS3_EVT_CONNECTION, [](sfs3::SmartFox&, sfs3::Event& e) {
        bool ok = e.getBool(SFS3_PARAM_SUCCESS);
        if (ok) {
            g.connected = true;
            g.log("Connected to SmartFoxServer 3.");
        } else {
            g.connected = false;
            g.log("Connection failed: " + e.getString(SFS3_PARAM_ERROR_MESSAGE));
        }
    });

    g.sfs.addEventListener(SFS3_EVT_CONNECTION_LOST, [](sfs3::SmartFox&, sfs3::Event& e) {
        std::string reason = e.getString(SFS3_PARAM_DISCONNECTION_REASON);
        g.connected = g.loggedIn = g.inRoom = g.created = false;
        g.rooms.clear(); g.users.clear();
        g.selRoom = -1;
        g.currentTopic = "(not set)";
        g.sfs = sfs3::SmartFox();
        g.log("Disconnected" + (reason.empty() ? std::string(".") : (": " + reason)));
    });

    g.sfs.addEventListener(SFS3_EVT_LOGIN, [](sfs3::SmartFox&, sfs3::Event&) {
        g.loggedIn = true;
        auto me = g.sfs.getMySelf();
        g.log("Logged in as '" + (me ? me.getName() : "?") + "'.");
        g.populateRooms();
    });

    g.sfs.addEventListener(SFS3_EVT_LOGIN_ERROR, [](sfs3::SmartFox&, sfs3::Event& e) {
        g.log("Login error: " + e.getString(SFS3_PARAM_ERROR_MESSAGE));
    });

    g.sfs.addEventListener(SFS3_EVT_LOGOUT, [](sfs3::SmartFox&, sfs3::Event&) {
        g.loggedIn = g.inRoom = false;
        g.rooms.clear(); g.users.clear();
        g.currentTopic = "(not set)";
        g.log("Logged out.");
    });

    g.sfs.addEventListener(SFS3_EVT_ROOM_JOIN, [](sfs3::SmartFox&, sfs3::Event& e) {
        auto r = e.getRoom(SFS3_PARAM_ROOM);
        std::string rname = r ? r.getName() : "?";
        int uc = r ? r.getUserCount() : 0;
        int mu = r ? r.getMaxUsers() : 0;

        g.inRoom = true;
        g.populateRooms();
        g.populateUsers();

        std::string topic = r ? r.getVariable("topic") : "";
        g.currentTopic = topic.empty() ? "(not set)" : topic;

        g.log("Joined room '" + rname + "' (" + std::to_string(uc) + "/" + std::to_string(mu) + ").");
    });

    g.sfs.addEventListener(SFS3_EVT_ROOM_JOIN_ERROR, [](sfs3::SmartFox&, sfs3::Event& e) {
        g.log("Room join error: " + e.getString(SFS3_PARAM_ERROR_MESSAGE));
    });

    g.sfs.addEventListener(SFS3_EVT_ROOM_ADD, [](sfs3::SmartFox&, sfs3::Event&) {
        g.populateRooms();
    });

    g.sfs.addEventListener(SFS3_EVT_ROOM_REMOVE, [](sfs3::SmartFox&, sfs3::Event&) {
        g.populateRooms();
    });

    g.sfs.addEventListener(SFS3_EVT_USER_ENTER_ROOM, [](sfs3::SmartFox&, sfs3::Event& e) {
        auto u = e.getUser(SFS3_PARAM_USER);
        std::string nm = u ? u.getName() : "?";
        bool me = u ? u.isItMe() : false;
        g.populateUsers();
        g.populateRooms();
        if (!me) g.log(nm + " entered the room.");
    });

    g.sfs.addEventListener(SFS3_EVT_USER_EXIT_ROOM, [](sfs3::SmartFox&, sfs3::Event& e) {
        auto u = e.getUser(SFS3_PARAM_USER);
        std::string nm = u ? u.getName() : "?";
        bool me = u ? u.isItMe() : false;
        g.populateUsers();
        g.populateRooms();
        if (!me) g.log(nm + " left the room.");
    });

    g.sfs.addEventListener(SFS3_EVT_USER_COUNT_CHANGE, [](sfs3::SmartFox&, sfs3::Event&) {
        g.populateRooms();
    });

    g.sfs.addEventListener(SFS3_EVT_PUBLIC_MESSAGE, [](sfs3::SmartFox&, sfs3::Event& e) {
        auto u = e.getUser(SFS3_PARAM_SENDER);
        if (!u) return;
        std::string who = u.isItMe() ? "You" : u.getName();
        g.msg(who, e.getString(SFS3_PARAM_MESSAGE));
    });

    g.sfs.addEventListener(SFS3_EVT_ROOM_VARIABLES_UPDATE, [](sfs3::SmartFox&, sfs3::Event&) {
        auto room = g.sfs.getLastJoinedRoom();
        if (room) {
            std::string topic = room.getVariable("topic");
            if (!topic.empty()) g.currentTopic = topic;
        }
    });
}

// ── Actions (called from main thread) ────────────────────────────────

static void doConnect() {
    if (g.created) {
        g.sfs = sfs3::SmartFox();
        g.created = false;
    }
    g.created = true;
    addListeners();

    sfs3::ConfigData cfg;
    cfg.setHost(g.host).setZone(g.zone);
    if (g.useWS) {
        cfg.setUseWebSocket(true).setHttpPort(g.wsPort).setPort(g.wsPort);
    } else {
        cfg.setPort(g.port).setTcpConnectionTimeout(5000);
    }

    int p = g.useWS ? g.wsPort : g.port;
    g.log(std::string("Connecting via ") + (g.useWS ? "WebSocket" : "TCP") +
          " to " + g.host + ":" + std::to_string(p) + " ...");
    g.sfs.connect(cfg);
}

static void doDisconnect() {
    if (g.created) g.sfs.disconnect();
}

static void doLogin() {
    if (!g.created) return;
    std::string user = g.username;
    if (user.empty()) user = "Guest";
    g.sfs.sendLogin(user.c_str(), "", g.zone);
}

static void doLogout() {
    if (g.created) g.sfs.sendLogout();
}

static void doSend() {
    std::string m = g.msgBuf;
    if (m.empty() || !g.created || !g.inRoom) return;
    g.sfs.sendPublicMessage(m.c_str());
    g.msgBuf[0] = '\0';
}

static void doJoinRoom(int roomId) {
    if (!g.created) return;
    g.sfs.sendJoinRoomById(roomId);
}

static void doSetTopic() {
    if (!g.created || !g.inRoom) return;
    g.sfs.sendSetRoomVariable("topic", g.topicBuf);
    g.log("Topic set to '" + std::string(g.topicBuf) + "'.");
}

// ── ImGui rendering ──────────────────────────────────────────────────

static void renderUI() {
    ImGuiIO& io = ImGui::GetIO();
    ImGui::SetNextWindowPos(ImVec2(0, 0));
    ImGui::SetNextWindowSize(io.DisplaySize);
    ImGui::Begin("##main", nullptr,
        ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize |
        ImGuiWindowFlags_NoMove    | ImGuiWindowFlags_NoCollapse |
        ImGuiWindowFlags_NoBringToFrontOnFocus);

    // ── Header bar ──────────────────────────────────────────────
    ImGui::TextColored(ImVec4(0.2f, 0.4f, 0.8f, 1), "SmartFoxServer 3");
    ImGui::SameLine();
    ImGui::TextDisabled("|  Simple Chat");
    ImGui::SameLine(ImGui::GetWindowWidth() - 340);
    ImGui::TextDisabled("SmartFoxServer 3 Examples");

    ImGui::Separator();

    // ── Controls ────────────────────────────────────────────────
    ImGui::Checkbox("WS", &g.useWS); ImGui::SameLine();

    bool canConnect = !g.connected && !g.created;
    ImGui::BeginDisabled(!canConnect);
    if (ImGui::Button("Connect")) doConnect();
    ImGui::EndDisabled(); ImGui::SameLine();

    ImGui::SetNextItemWidth(100);
    ImGui::InputText("##user", g.username, sizeof(g.username)); ImGui::SameLine();

    ImGui::BeginDisabled(!g.connected || g.loggedIn);
    if (ImGui::Button("Login")) doLogin();
    ImGui::EndDisabled(); ImGui::SameLine();

    ImGui::BeginDisabled(!g.loggedIn);
    if (ImGui::Button("Logout")) doLogout();
    ImGui::EndDisabled(); ImGui::SameLine();

    ImGui::BeginDisabled(!g.connected);
    if (ImGui::Button("Disconnect")) doDisconnect();
    ImGui::EndDisabled();

    ImGui::Spacing();

    // ── Main area: Chat (left) + Sidebar (right) ────────────────
    float sideW = 220.0f;
    float chatW = ImGui::GetContentRegionAvail().x - sideW - ImGui::GetStyle().ItemSpacing.x;
    float mainH = ImGui::GetContentRegionAvail().y;

    // ─── Chat panel ─────────────────────────────────────────────
    ImGui::BeginChild("##chatpanel", ImVec2(chatW, mainH), ImGuiChildFlags_Borders);

    ImGui::Text("Topic: '%s'", g.currentTopic.c_str());
    ImGui::Separator();

    float inputH = ImGui::GetFrameHeightWithSpacing() * 2 + ImGui::GetStyle().ItemSpacing.y;
    ImGui::BeginChild("##chatlog", ImVec2(0, -inputH), ImGuiChildFlags_None);
    for (auto& line : g.chat) {
        if (line.system) {
            ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(0.5f, 0.5f, 0.5f, 1));
            ImGui::TextWrapped("%s", line.text.c_str());
            ImGui::PopStyleColor();
        } else {
            ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(0.1f, 0.1f, 0.6f, 1));
            ImGui::TextWrapped("%s said:", line.sender.c_str());
            ImGui::PopStyleColor();
            ImGui::SameLine();
            ImGui::TextWrapped("%s", line.text.c_str());
        }
    }
    if (g.scrollChat) { ImGui::SetScrollHereY(1.0f); g.scrollChat = false; }
    ImGui::EndChild();

    // Message input
    ImGui::BeginDisabled(!g.inRoom);
    ImGui::SetNextItemWidth(chatW - 80);
    bool enterSend = ImGui::InputText("##msg", g.msgBuf, sizeof(g.msgBuf),
                                       ImGuiInputTextFlags_EnterReturnsTrue);
    ImGui::SameLine();
    if (ImGui::Button("Send", ImVec2(60, 0)) || enterSend) doSend();

    // Topic row
    ImGui::Text("Chat topic:");
    ImGui::SameLine();
    ImGui::SetNextItemWidth(120);
    ImGui::InputText("##topic", g.topicBuf, sizeof(g.topicBuf));
    ImGui::SameLine();
    if (ImGui::Button("Set")) doSetTopic();
    ImGui::EndDisabled();

    ImGui::EndChild();

    // ─── Sidebar ────────────────────────────────────────────────
    ImGui::SameLine();
    ImGui::BeginChild("##sidebar", ImVec2(0, mainH), ImGuiChildFlags_None);

    // Rooms
    if (ImGui::CollapsingHeader("Rooms", ImGuiTreeNodeFlags_DefaultOpen)) {
        ImGui::BeginChild("##rooms", ImVec2(0, mainH * 0.45f), ImGuiChildFlags_Borders);
        if (g.rooms.empty()) {
            ImGui::TextDisabled("(connect and login)");
        }
        for (int i = 0; i < (int)g.rooms.size(); i++) {
            auto& rm = g.rooms[i];
            char label[256];
            snprintf(label, sizeof(label), "%s  (%d/%d)", rm.name.c_str(), rm.userCount, rm.maxUsers);
            if (ImGui::Selectable(label, g.selRoom == i)) {
                g.selRoom = i;
                doJoinRoom(rm.id);
            }
        }
        ImGui::EndChild();
    }

    // Users
    if (ImGui::CollapsingHeader("Users", ImGuiTreeNodeFlags_DefaultOpen)) {
        ImGui::BeginChild("##users", ImVec2(0, 0), ImGuiChildFlags_Borders);
        if (g.users.empty()) {
            ImGui::TextDisabled("(no users)");
        }
        for (auto& u : g.users) {
            if (u.isMe)
                ImGui::TextColored(ImVec4(0.2f, 0.6f, 0.2f, 1), "%s (you)", u.name.c_str());
            else
                ImGui::Text("%s", u.name.c_str());
        }
        ImGui::EndChild();
    }

    ImGui::EndChild();

    ImGui::End();
}

// ── Main ─────────────────────────────────────────────────────────────

int main() {
    if (!glfwInit()) return 1;

#ifdef __APPLE__
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 2);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GLFW_TRUE);
    const char* glslVer = "#version 150";
#else
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    const char* glslVer = "#version 330";
#endif

    GLFWwindow* win = glfwCreateWindow(900, 580,
        "SmartFoxServer 3 Examples - Simple Chat", nullptr, nullptr);
    if (!win) { glfwTerminate(); return 1; }
    glfwMakeContextCurrent(win);
    glfwSwapInterval(1);

    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGui::StyleColorsLight();

    ImGuiStyle& st = ImGui::GetStyle();
    st.FrameRounding  = 3.0f;
    st.GrabRounding   = 3.0f;
    st.WindowRounding = 0.0f;
    st.Colors[ImGuiCol_Header]        = ImVec4(1.0f, 0.6f, 0.2f, 0.65f);
    st.Colors[ImGuiCol_HeaderHovered] = ImVec4(1.0f, 0.6f, 0.2f, 0.85f);
    st.Colors[ImGuiCol_HeaderActive]  = ImVec4(1.0f, 0.6f, 0.2f, 1.00f);
    st.Colors[ImGuiCol_Button]        = ImVec4(0.26f, 0.59f, 0.98f, 0.40f);
    st.Colors[ImGuiCol_ButtonHovered] = ImVec4(0.26f, 0.59f, 0.98f, 0.70f);
    st.Colors[ImGuiCol_ButtonActive]  = ImVec4(0.06f, 0.53f, 0.98f, 1.00f);

    ImGui_ImplGlfw_InitForOpenGL(win, true);
    ImGui_ImplOpenGL3_Init(glslVer);

    sfs3::init();

    while (!glfwWindowShouldClose(win)) {
        glfwPollEvents();
        sfs3::update(1.0 / 60.0);

        ImGui_ImplOpenGL3_NewFrame();
        ImGui_ImplGlfw_NewFrame();
        ImGui::NewFrame();

        renderUI();

        ImGui::Render();
        int w, h;
        glfwGetFramebufferSize(win, &w, &h);
        glViewport(0, 0, w, h);
        glClearColor(0.94f, 0.94f, 0.94f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
        glfwSwapBuffers(win);
    }

    sfs3::dispose();
    g.sfs = sfs3::SmartFox();
    g.created = false;

    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplGlfw_Shutdown();
    ImGui::DestroyContext();
    glfwDestroyWindow(win);
    glfwTerminate();
    return 0;
}
