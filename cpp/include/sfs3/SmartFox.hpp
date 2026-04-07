#ifndef SFS3_SMARTFOX_HPP
#define SFS3_SMARTFOX_HPP

#include "SFS3_API.h"
#include "sfs3/User.hpp"
#include "sfs3/Room.hpp"
#include "sfs3/Event.hpp"
#include "sfs3/SFSObject.hpp"
#include "sfs3/ConfigData.hpp"

#include <string>
#include <vector>
#include <functional>
#include <utility>

namespace sfs3 {

class SmartFox {
    SFS3_SmartFox* h_;

    void ensure() { if (!h_) h_ = SFS3_SmartFox_create(); }

    using Callback = std::function<void(SmartFox&, Event&)>;

    struct ListenerSlot {
        Callback fn;
        SmartFox* self;
    };

    static void trampoline(SFS3_SmartFox*, SFS3_Event* raw, void* ud) {
        auto* slot = static_cast<ListenerSlot*>(ud);
        Event e(raw);
        slot->fn(*slot->self, e);
    }

    struct ListenerRecord {
        std::string eventType;
        SFS3_EventHandler cHandler;
        ListenerSlot* slot;
    };
    std::vector<ListenerRecord> listeners_;

public:
    SmartFox() : h_(nullptr) {}
    ~SmartFox() {
        if (h_) {
            removeAllEventListeners();
            SFS3_SmartFox_release(h_);
        }
    }

    SmartFox(SmartFox&& o) noexcept : h_(o.h_), listeners_(std::move(o.listeners_)) {
        o.h_ = nullptr;
        for (auto& lr : listeners_) lr.slot->self = this;
    }
    SmartFox& operator=(SmartFox&& o) noexcept {
        if (this != &o) {
            if (h_) { removeAllEventListeners(); SFS3_SmartFox_release(h_); }
            h_ = o.h_; listeners_ = std::move(o.listeners_); o.h_ = nullptr;
            for (auto& lr : listeners_) lr.slot->self = this;
        }
        return *this;
    }
    SmartFox(const SmartFox&) = delete;
    SmartFox& operator=(const SmartFox&) = delete;

    SFS3_SmartFox* handle() const { return h_; }

    // -- Connection -------------------------------------------------------

    void connect(const ConfigData& cfg)     { ensure(); SFS3_connect(h_, cfg.handle()); }
    void disconnect()                       { if (h_) SFS3_disconnect(h_); }
    bool isConnected() const                { return h_ && SFS3_isConnected(h_); }
    void killConnection()                   { if (h_) SFS3_killConnection(h_); }

    void connectUdp()                       { ensure(); SFS3_connectUdp(h_); }
    void disconnectUdp()                    { if (h_) SFS3_disconnectUdp(h_); }
    bool isUdpConnected() const             { return h_ && SFS3_isUdpConnected(h_); }

    // -- Info -------------------------------------------------------------

    std::string getVersion()        const { return h_ ? detail::toStr(SFS3_getVersion(h_)) : ""; }
    std::string getSessionToken()   const { return h_ ? detail::toStr(SFS3_getSessionToken(h_)) : ""; }
    std::string getConnectionMode() const { return h_ ? detail::toStr(SFS3_getConnectionMode(h_)) : ""; }
    std::string getHttpUploadURI()  const { return h_ ? detail::toStr(SFS3_getHttpUploadURI(h_)) : ""; }
    void setClientDetails(const char* plat, const char* ver) { ensure(); SFS3_setClientDetails(h_, plat, ver); }

    User getMySelf() const { return h_ ? User(SFS3_getMySelf(h_)) : User(); }

    void enableLagMonitor(bool on, int sec = 4, int q = 10) { ensure(); SFS3_enableLagMonitor(h_, on, sec, q); }
    void stopExecutors() { if (h_) SFS3_stopExecutors(h_); }

    // -- Events -----------------------------------------------------------

    void addEventListener(const char* type, Callback cb) {
        ensure();
        auto* slot = new ListenerSlot{std::move(cb), this};
        SFS3_addEventListener(h_, type, trampoline, slot);
        listeners_.push_back({type, trampoline, slot});
    }

    void removeEventListener(const char* type) {
        for (auto it = listeners_.begin(); it != listeners_.end(); ++it) {
            if (it->eventType == type) {
                SFS3_removeEventListener(h_, type, it->cHandler);
                delete it->slot;
                listeners_.erase(it);
                break;
            }
        }
    }

    void removeAllEventListeners() {
        if (h_) SFS3_removeAllEventListeners(h_);
        for (auto& lr : listeners_) delete lr.slot;
        listeners_.clear();
    }

    // -- Rooms ------------------------------------------------------------

    std::vector<Room> getRooms() const {
        std::vector<Room> v;
        if (!h_) return v;
        int n = SFS3_getRoomCount(h_);
        v.reserve(n);
        for (int i = 0; i < n; i++) v.emplace_back(SFS3_getRoomAt(h_, i));
        return v;
    }

    Room getRoomById(int id)             const { return h_ ? Room(SFS3_getRoomById(h_, id)) : Room(); }
    Room getRoomByName(const char* name) const { return h_ ? Room(SFS3_getRoomByName(h_, name)) : Room(); }

    std::vector<Room> getJoinedRooms() const {
        std::vector<Room> v;
        if (!h_) return v;
        int n = SFS3_getJoinedRoomCount(h_);
        v.reserve(n);
        for (int i = 0; i < n; i++) v.emplace_back(SFS3_getJoinedRoomAt(h_, i));
        return v;
    }

    Room getLastJoinedRoom() const { return h_ ? Room(SFS3_getLastJoinedRoom(h_)) : Room(); }

    // -- Requests ---------------------------------------------------------

    void sendLogin(const char* user, const char* pass = "", const char* zone = nullptr, SFSObject* params = nullptr) {
        ensure(); SFS3_sendLogin(h_, user, pass, zone, params ? params->handle() : nullptr);
    }
    void sendLogout() { if (h_) SFS3_sendLogout(h_); }

    void sendJoinRoom(const char* name, const char* pass = nullptr, int leaveId = -1, bool spectator = false) {
        ensure(); SFS3_sendJoinRoom(h_, name, pass, leaveId, spectator);
    }
    void sendJoinRoomById(int id, const char* pass = nullptr, int leaveId = -1, bool spectator = false) {
        ensure(); SFS3_sendJoinRoomById(h_, id, pass, leaveId, spectator);
    }
    void sendLeaveRoom(int roomId = -1) { if (h_) SFS3_sendLeaveRoom(h_, roomId); }

    void sendPublicMessage(const char* msg, SFSObject* params = nullptr, int roomId = -1) {
        ensure(); SFS3_sendPublicMessage(h_, msg, params ? params->handle() : nullptr, roomId);
    }
    void sendPrivateMessage(const char* msg, int recipientId, SFSObject* params = nullptr) {
        ensure(); SFS3_sendPrivateMessage(h_, msg, recipientId, params ? params->handle() : nullptr);
    }
    void sendExtensionRequest(const char* cmd, SFSObject* params = nullptr, int roomId = -1, int tx = -1) {
        ensure(); SFS3_sendExtensionRequest(h_, cmd, params ? params->handle() : nullptr, roomId, tx);
    }
    void sendSetUserVariables(SFSObject* vars) {
        ensure(); SFS3_sendSetUserVariables(h_, vars ? vars->handle() : nullptr);
    }
    void sendSubscribeRoomGroup(const char* gid)   { ensure(); SFS3_sendSubscribeRoomGroup(h_, gid); }
    void sendUnsubscribeRoomGroup(const char* gid) { ensure(); SFS3_sendUnsubscribeRoomGroup(h_, gid); }

    void sendSetRoomVariable(const char* name, const char* value, int roomId = -1) {
        ensure(); SFS3_sendSetRoomVariable_string(h_, name, value, roomId);
    }
};

} // namespace sfs3

#endif // SFS3_SMARTFOX_HPP
