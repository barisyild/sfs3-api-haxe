/*
 * SFS3 API — C++ bridge implementation
 *
 * Bridges the public C API (SFS3_API.h) to the hxcpp-generated Haxe classes.
 * Compiled together with the hxcpp output and merged into SFS3_API.lib.
 *
 * BUILD NOTE: The compiler must force-include the generated HxcppConfig
 * header (e.g. /FI"HxcppConfig-19.h") so that platform macros like
 * HX_WINDOWS are defined before hxcpp.h is pulled in. The build_lib
 * script handles this automatically.
 */

#if defined(_M_ARM64) && !defined(HXCPP_ARM64)
#define HXCPP_ARM64
#endif

#include <hxcpp.h>
#include <hx/GC.h>
#include <hx/Boot.h>

#include <com/smartfoxserver/v3/SmartFox.h>
#include <com/smartfoxserver/v3/ConfigData.h>
#include <com/smartfoxserver/v3/BlueBoxCfg.h>
#include <com/smartfoxserver/v3/core/ApiEvent.h>
#include <com/smartfoxserver/v3/core/EventDispatcher.h>
#include <com/smartfoxserver/v3/core/Logger.h>
#include <com/smartfoxserver/v3/entities/data/SFSObject.h>
#include <com/smartfoxserver/v3/entities/data/SFSArray.h>
#include <com/smartfoxserver/v3/requests/LoginRequest.h>
#include <com/smartfoxserver/v3/requests/LogoutRequest.h>
#include <com/smartfoxserver/v3/requests/JoinRoomRequest.h>
#include <com/smartfoxserver/v3/requests/LeaveRoomRequest.h>
#include <com/smartfoxserver/v3/requests/PublicMessageRequest.h>
#include <com/smartfoxserver/v3/requests/PrivateMessageRequest.h>
#include <com/smartfoxserver/v3/requests/ObjectMessageRequest.h>
#include <com/smartfoxserver/v3/bitswarm/TransportType.h>
#include <com/smartfoxserver/v3/requests/ExtensionRequest.h>
#include <com/smartfoxserver/v3/requests/SubscribeRoomGroupRequest.h>
#include <com/smartfoxserver/v3/requests/UnsubscribeRoomGroupRequest.h>
#include <com/smartfoxserver/v3/requests/SetRoomVariablesRequest.h>
#include <com/smartfoxserver/v3/requests/SetUserVariablesRequest.h>
#include <com/smartfoxserver/v3/entities/variables/SFSRoomVariable.h>
#include <com/smartfoxserver/v3/entities/variables/SFSUserVariable.h>
#include <com/smartfoxserver/v3/entities/SFSRoom.h>

#include "SFS3_API.h"

#include <algorithm>
#include <cstring>
#include <cstdlib>
#include <vector>
#include <mutex>

/* ── hxcpp runtime entry points ──────────────────────────────────────── */

extern void __boot_all();

extern "C" {
    void __hxcpp_main() {}
    void __hxcpp_lib_main() {
        HX_TOP_OF_STACK
        hx::Boot();
        __boot_all();
        __hxcpp_main();
    }
}

/*
 * hxcpp only exports hxRunLibrary / hxcpp_set_top_of_stack when compiled
 * in library mode (HXCPP_DLL_IMPORT).  Our static lib is built in exe
 * mode, so we provide equivalent helpers ourselves.
 */
static void sfs3_set_top_of_stack() {
    int i;
    hx::SetTopOfStack(&i, false);
}

static void sfs3_run_library() {
    __hxcpp_lib_main();
}

/*
 * Stack-boundary macros — nesting-safe.
 *
 * Every API function that touches hxcpp objects must bracket the hxcpp
 * calls with SFS3_HX_BEGIN / SFS3_HX_END so the GC can walk the stack.
 *
 * Problem: if a user callback (dispatched from SFS3_update, which already
 * holds HX_BEGIN) calls another SFS3 function (e.g. sendLogin), the inner
 * SFS3_HX_END would call SetTopOfStack(nullptr) and deregister the thread
 * from the GC while the outer block still accesses hxcpp objects.
 *
 * Fix: thread-local depth counter. Only the outermost pair actually
 * calls SetTopOfStack; nested pairs are no-ops.
 *
 * The NOINLINE attribute prevents the compiler from inlining the caller
 * and optimising away the stack variable whose address we hand to
 * SetTopOfStack (pattern borrowed from the Loreline C++ bridge).
 */
#if defined(_MSC_VER)
    #define SFS3_NOINLINE __declspec(noinline)
#else
    #define SFS3_NOINLINE __attribute__((noinline))
#endif

static thread_local int g_hxDepth = 0;

#define SFS3_HX_BEGIN                                       \
    int _sfs3_stack_ = 99;                                  \
    if (g_hxDepth++ == 0)                                   \
        hx::SetTopOfStack(&_sfs3_stack_, true);

#define SFS3_HX_END                                         \
    if (--g_hxDepth == 0)                                   \
        hx::SetTopOfStack((int*)0, true);

/* ── SFS3_String ────────────────────────────────────────────────────────── */

struct SFS3_StringData {
    ::String hxStr;
    int refCount;
};

static SFS3_String wrap_string(::String s) {
    SFS3_String r;
    if (s == null()) {
        r.ptr = nullptr;
    } else {
        r.ptr = new SFS3_StringData();
        r.ptr->hxStr = s;
        r.ptr->refCount = 1;
    }
    return r;
}

static ::String unwrap_string(SFS3_String s) {
    if (s.ptr == nullptr) return null();
    return s.ptr->hxStr;
}

SFS3_String SFS3_String_create(const char* s) {
    if (!s) { SFS3_String r; r.ptr = nullptr; return r; }
    return wrap_string(::String(s));
}

SFS3_String SFS3_String_createLen(const char* s, size_t len) {
    if (!s) { SFS3_String r; r.ptr = nullptr; return r; }
    return wrap_string(::String(s, (int)len));
}

SFS3_String SFS3_String_copy(SFS3_String other) {
    if (other.ptr) {
        other.ptr->refCount++;
    }
    return other;
}

void SFS3_String_release(SFS3_String* s) {
    if (s && s->ptr) {
        s->ptr->refCount--;
        if (s->ptr->refCount <= 0) {
            delete s->ptr;
        }
        s->ptr = nullptr;
    }
}

const char* SFS3_String_cstr(SFS3_String s) {
    if (!s.ptr) return nullptr;
    return s.ptr->hxStr.utf8_str();
}

size_t SFS3_String_length(SFS3_String s) {
    if (!s.ptr) return 0;
    return (size_t)s.ptr->hxStr.length;
}

bool SFS3_String_isNull(SFS3_String s) {
    return s.ptr == nullptr;
}

/* ── SFS3_Value ─────────────────────────────────────────────────────────── */

SFS3_Value SFS3_Value_null(void) {
    SFS3_Value v;
    memset(&v, 0, sizeof(v));
    v.type = SFS3_Null;
    v.stringValue.ptr = nullptr;
    v.userValue = nullptr;
    v.roomValue = nullptr;
    v.objectValue = nullptr;
    return v;
}

SFS3_Value SFS3_Value_fromInt(int val) {
    SFS3_Value v = SFS3_Value_null();
    v.type = SFS3_Int;
    v.intValue = val;
    return v;
}

SFS3_Value SFS3_Value_fromFloat(double val) {
    SFS3_Value v = SFS3_Value_null();
    v.type = SFS3_Float;
    v.floatValue = val;
    return v;
}

SFS3_Value SFS3_Value_fromBool(bool val) {
    SFS3_Value v = SFS3_Value_null();
    v.type = SFS3_Bool;
    v.boolValue = val;
    return v;
}

SFS3_Value SFS3_Value_fromString(SFS3_String val) {
    SFS3_Value v = SFS3_Value_null();
    v.type = SFS3_StringVal;
    v.stringValue = SFS3_String_copy(val);
    return v;
}

/* ── Lifecycle ──────────────────────────────────────────────────────────── */

static bool g_sfs3_initialized = false;

/*
 * GC strategy: inline in SFS3_update(), no dedicated thread.
 *
 * A background GC thread calling InternalCollect triggers a stop-the-world
 * pause that blocks ALL registered threads — including the main thread —
 * until every Haxe Executor thread reaches a GC safe point.  If any
 * Executor thread is stuck in blocking I/O (WebSocket processLoop /
 * Socket read), the main thread freezes for seconds.
 *
 * Instead we accumulate wall-clock time and run a minor collection inside
 * SFS3_update(), where the main thread is already in a safe state.
 * The Executor threads may still trigger GC via allocation pressure,
 * but those collections happen on threads that are already at safe points
 * and do not artificially stall the main thread.
 */
static double g_gcAccum = 0.0;
static constexpr double GC_INTERVAL_SEC = 15.0;

void SFS3_init(void) {
    if (g_sfs3_initialized) return;
    g_sfs3_initialized = true;
    sfs3_set_top_of_stack();
    sfs3_run_library();
}

void SFS3_dispose(void) {
    if (!g_sfs3_initialized) return;
    g_sfs3_initialized = false;
}

void SFS3_gc(void) {
    SFS3_HX_BEGIN
    hx::InternalCollect(false, false);
    SFS3_HX_END
}

/* SFS3_update is defined after the event infrastructure (PendingEvent, SFS3_Event) */

void SFS3_registerThread(void) {
    int stackVar = 0;
    hx::RegisterCurrentThread(&stackVar);
}

/* ── ConfigData ─────────────────────────────────────────────────────────── */

struct SFS3_ConfigData {
    hx::Object* obj;

    SFS3_ConfigData() : obj(nullptr) {}

    void set(hx::Object* o) {
        obj = o;
        if (obj) hx::GCAddRoot(&obj);
    }

    ~SFS3_ConfigData() {
        if (obj && g_sfs3_initialized) { hx::GCRemoveRoot(&obj); }
        obj = nullptr;
    }

private:
    SFS3_ConfigData(const SFS3_ConfigData&);
    SFS3_ConfigData& operator=(const SFS3_ConfigData&);
};

SFS3_ConfigData* SFS3_ConfigData_create(void) {
    SFS3_HX_BEGIN
    auto cfg = new SFS3_ConfigData();
    cfg->set(com::smartfoxserver::v3::ConfigData_obj::__new().GetPtr());
    SFS3_HX_END
    return cfg;
}

void SFS3_ConfigData_release(SFS3_ConfigData* cfg) {
    if (cfg) delete cfg;
}

/* Helper to cast the raw hx::Object* back to the concrete ConfigData type */
#define CFG_OBJ(c) (static_cast<com::smartfoxserver::v3::ConfigData_obj*>((c)->obj))

void SFS3_ConfigData_setHost(SFS3_ConfigData* cfg, const char* host) {
    if (cfg && host) CFG_OBJ(cfg)->host = ::String(host);
}

void SFS3_ConfigData_setPort(SFS3_ConfigData* cfg, int port) {
    if (cfg) CFG_OBJ(cfg)->port = port;
}

void SFS3_ConfigData_setUdpPort(SFS3_ConfigData* cfg, int port) {
    if (cfg) CFG_OBJ(cfg)->udpPort = port;
}

void SFS3_ConfigData_setHttpPort(SFS3_ConfigData* cfg, int port) {
    if (cfg) CFG_OBJ(cfg)->httpPort = port;
}

void SFS3_ConfigData_setHttpsPort(SFS3_ConfigData* cfg, int port) {
    if (cfg) CFG_OBJ(cfg)->httpsPort = port;
}

void SFS3_ConfigData_setZone(SFS3_ConfigData* cfg, const char* zone) {
    if (cfg && zone) CFG_OBJ(cfg)->zone = ::String(zone);
}

void SFS3_ConfigData_setUseSSL(SFS3_ConfigData* cfg, bool useSSL) {
    if (cfg) CFG_OBJ(cfg)->useSSL = useSSL;
}

void SFS3_ConfigData_setUseWebSocket(SFS3_ConfigData* cfg, bool useWS) {
    if (cfg) CFG_OBJ(cfg)->useWebSocket = useWS;
}

void SFS3_ConfigData_setUseTcpFallback(SFS3_ConfigData* cfg, bool fallback) {
    if (cfg) CFG_OBJ(cfg)->useTcpFallback = fallback;
}

void SFS3_ConfigData_setUseTcpNoDelay(SFS3_ConfigData* cfg, bool noDelay) {
    if (cfg) CFG_OBJ(cfg)->useTcpNoDelay = noDelay;
}

void SFS3_ConfigData_setTcpConnectionTimeout(SFS3_ConfigData* cfg, int ms) {
    if (cfg) CFG_OBJ(cfg)->tcpConnectionTimeout = ms;
}

void SFS3_ConfigData_setBlueBoxActive(SFS3_ConfigData* cfg, bool active) {
    if (cfg) CFG_OBJ(cfg)->blueBox->isActive = active;
}

const char* SFS3_ConfigData_getHost(SFS3_ConfigData* cfg) {
    if (!cfg) return nullptr;
    return CFG_OBJ(cfg)->host.utf8_str();
}

int SFS3_ConfigData_getPort(SFS3_ConfigData* cfg) {
    if (!cfg) return 0;
    return CFG_OBJ(cfg)->port;
}

const char* SFS3_ConfigData_getZone(SFS3_ConfigData* cfg) {
    if (!cfg) return nullptr;
    return CFG_OBJ(cfg)->zone.utf8_str();
}

/* ── SFS3_Event ─────────────────────────────────────────────────────────── */

struct SFS3_Event {
    ::hx::ObjectPtr<com::smartfoxserver::v3::core::ApiEvent_obj> hxEvt;
};

/* ── Event callback bridge ──────────────────────────────────────────────── */

struct EventListenerEntry {
    std::string eventType;
    SFS3_EventHandler handler;
    void* userData;
    SFS3_SmartFox* sfsHandle;
    ::Dynamic hxListener;
};

static std::mutex g_listenerMutex;
static std::vector<EventListenerEntry*> g_listeners;

/*
 * Pending event: holds a GC-rooted reference to the Haxe event object so it
 * stays alive until the main thread processes it during SFS3_update().
 */
struct PendingEvent {
    EventListenerEntry* entry;
    hx::Object* hxEvtRoot;

    PendingEvent() : entry(nullptr), hxEvtRoot(nullptr) {}
    PendingEvent(EventListenerEntry* e, hx::Object* evt) : entry(e), hxEvtRoot(evt) {
        if (hxEvtRoot) hx::GCAddRoot(&hxEvtRoot);
    }
    ~PendingEvent() {
        if (hxEvtRoot && g_sfs3_initialized) { hx::GCRemoveRoot(&hxEvtRoot); }
        hxEvtRoot = nullptr;
    }
    PendingEvent(PendingEvent&& o) noexcept : entry(o.entry), hxEvtRoot(o.hxEvtRoot) {
        o.entry = nullptr;
        o.hxEvtRoot = nullptr;
    }
    PendingEvent& operator=(PendingEvent&& o) noexcept {
        if (this != &o) {
            if (hxEvtRoot && g_sfs3_initialized) hx::GCRemoveRoot(&hxEvtRoot);
            entry = o.entry; hxEvtRoot = o.hxEvtRoot;
            o.entry = nullptr; o.hxEvtRoot = nullptr;
        }
        return *this;
    }
    PendingEvent(const PendingEvent&) = delete;
    PendingEvent& operator=(const PendingEvent&) = delete;
};

static std::mutex g_pendingMtx;
static std::vector<PendingEvent> g_pendingEvents;

/*
 * hxcpp-compatible closure using the HX_BEGIN_LOCAL_FUNC macro family.
 * Captures one pointer (EventListenerEntry*) and accepts one hxcpp arg.
 * Instead of calling the user handler directly (on a background thread),
 * it enqueues the event for deferred dispatch on the main thread.
 */
HX_BEGIN_LOCAL_FUNC_S1(::hx::LocalFunc, _hx_Closure_sfs3Event,
    EventListenerEntry*, entry) HXARGC(1)
void _hx_run(::Dynamic hxEvt) {
    std::lock_guard<std::mutex> lk(g_pendingMtx);
    g_pendingEvents.emplace_back(entry, hxEvt.GetPtr());
}
HX_END_LOCAL_FUNC1((void))

/* ── SFS3_update — flushes pending events on the caller's (main) thread ── */

SFS3_NOINLINE void SFS3_update(double deltaSec) {
    SFS3_HX_BEGIN
    std::vector<PendingEvent> batch;
    { std::lock_guard<std::mutex> lk(g_pendingMtx); batch.swap(g_pendingEvents); }
    for (auto& pe : batch) {
        SFS3_Event evt;
        evt.hxEvt = (com::smartfoxserver::v3::core::ApiEvent_obj*)pe.hxEvtRoot;
        pe.entry->handler(pe.entry->sfsHandle, &evt, pe.entry->userData);
    }

    g_gcAccum += deltaSec;
    if (g_gcAccum >= GC_INTERVAL_SEC) {
        g_gcAccum = 0.0;
        hx::InternalCollect(false, false);
    }
    SFS3_HX_END
}

SFS3_String SFS3_Event_getType(SFS3_Event* evt) {
    if (!evt) return SFS3_String_create(nullptr);
    return wrap_string(evt->hxEvt->getType());
}

bool SFS3_Event_getBool(SFS3_Event* evt, const char* key) {
    if (!evt || !key) return false;
    ::Dynamic val = evt->hxEvt->getParam(::String(key));
    if (val == null()) return false;
    return (bool)val;
}

int SFS3_Event_getInt(SFS3_Event* evt, const char* key) {
    if (!evt || !key) return 0;
    ::Dynamic val = evt->hxEvt->getParam(::String(key));
    if (val == null()) return 0;
    return (int)val;
}

SFS3_String SFS3_Event_getString(SFS3_Event* evt, const char* key) {
    if (!evt || !key) return SFS3_String_create(nullptr);
    ::Dynamic val = evt->hxEvt->getParam(::String(key));
    if (val == null()) return SFS3_String_create(nullptr);
    return wrap_string((::String)val);
}

/* ── SFS3_User (thin wrapper) ───────────────────────────────────────────── */

struct SFS3_User {
    ::Dynamic hxUser;
};

SFS3_User* SFS3_Event_getUser(SFS3_Event* evt, const char* key) {
    if (!evt || !key) return nullptr;
    ::Dynamic val = evt->hxEvt->getParam(::String(key));
    if (val == null()) return nullptr;
    auto u = new SFS3_User();
    u->hxUser = val;
    return u;
}

int SFS3_User_getId(SFS3_User* user) {
    if (!user) return -1;
    return (int)user->hxUser->__Field(HX_CSTRING("getId"), ::hx::paccDynamic)();
}

SFS3_String SFS3_User_getName(SFS3_User* user) {
    if (!user) return SFS3_String_create(nullptr);
    return wrap_string((::String)user->hxUser->__Field(HX_CSTRING("getName"), ::hx::paccDynamic)());
}

int SFS3_User_getPlayerId(SFS3_User* user) {
    if (!user) return -1;
    return (int)user->hxUser->__Field(HX_CSTRING("getPlayerId"), ::hx::paccDynamic)();
}

bool SFS3_User_isPlayer(SFS3_User* user) {
    if (!user) return false;
    return (bool)user->hxUser->__Field(HX_CSTRING("isPlayer"), ::hx::paccDynamic)();
}

bool SFS3_User_isSpectator(SFS3_User* user) {
    if (!user) return false;
    return (bool)user->hxUser->__Field(HX_CSTRING("isSpectator"), ::hx::paccDynamic)();
}

int SFS3_User_getPrivilegeId(SFS3_User* user) {
    if (!user) return 0;
    return (int)user->hxUser->__Field(HX_CSTRING("getPrivilegeId"), ::hx::paccDynamic)();
}

bool SFS3_User_isGuest(SFS3_User* user) {
    if (!user) return false;
    return (bool)user->hxUser->__Field(HX_CSTRING("isGuest"), ::hx::paccDynamic)();
}

bool SFS3_User_isStandardUser(SFS3_User* user) {
    if (!user) return false;
    return (bool)user->hxUser->__Field(HX_CSTRING("isStandardUser"), ::hx::paccDynamic)();
}

bool SFS3_User_isModerator(SFS3_User* user) {
    if (!user) return false;
    return (bool)user->hxUser->__Field(HX_CSTRING("isModerator"), ::hx::paccDynamic)();
}

bool SFS3_User_isAdmin(SFS3_User* user) {
    if (!user) return false;
    return (bool)user->hxUser->__Field(HX_CSTRING("isAdmin"), ::hx::paccDynamic)();
}

bool SFS3_User_isItMe(SFS3_User* user) {
    if (!user) return false;
    return (bool)user->hxUser->__Field(HX_CSTRING("getIsItMe"), ::hx::paccDynamic)();
}

static ::Dynamic user_getVar(SFS3_User* user, const char* name) {
    if (!user || !name) return null();
    ::Dynamic v = user->hxUser->__Field(HX_CSTRING("getVariable"), ::hx::paccDynamic)(::String(name));
    return v;
}

bool SFS3_User_containsVariable(SFS3_User* user, const char* name) {
    if (!user || !name) return false;
    return (bool)user->hxUser->__Field(HX_CSTRING("containsVariable"), ::hx::paccDynamic)(::String(name));
}

int SFS3_User_getVariable_int(SFS3_User* user, const char* name) {
    ::Dynamic v = user_getVar(user, name);
    if (v == null()) return 0;
    return (int)v->__Field(HX_CSTRING("getIntValue"), ::hx::paccDynamic)();
}

double SFS3_User_getVariable_double(SFS3_User* user, const char* name) {
    ::Dynamic v = user_getVar(user, name);
    if (v == null()) return 0.0;
    return (double)(Float)v->__Field(HX_CSTRING("getDoubleValue"), ::hx::paccDynamic)();
}

bool SFS3_User_getVariable_bool(SFS3_User* user, const char* name) {
    ::Dynamic v = user_getVar(user, name);
    if (v == null()) return false;
    return (bool)v->__Field(HX_CSTRING("getBoolValue"), ::hx::paccDynamic)();
}

SFS3_String SFS3_User_getVariable_string(SFS3_User* user, const char* name) {
    ::Dynamic v = user_getVar(user, name);
    if (v == null()) return SFS3_String_create(nullptr);
    ::String s = (::String)v->__Field(HX_CSTRING("getStringValue"), ::hx::paccDynamic)();
    return wrap_string(s);
}

/* ── SFS3_MMOItem (thin wrapper) ────────────────────────────────────────── */

struct SFS3_MMOItem {
    ::Dynamic hxItem;
};

static ::Dynamic mmoitem_getVar(SFS3_MMOItem* item, const char* name) {
    if (!item || !name) return null();
    ::Dynamic v = item->hxItem->__Field(HX_CSTRING("getVariable"), ::hx::paccDynamic)(::String(name));
    return v;
}

int SFS3_MMOItem_getId(SFS3_MMOItem* item) {
    if (!item) return -1;
    return (int)item->hxItem->__Field(HX_CSTRING("getId"), ::hx::paccDynamic)();
}

bool SFS3_MMOItem_containsVariable(SFS3_MMOItem* item, const char* name) {
    if (!item || !name) return false;
    return (bool)item->hxItem->__Field(HX_CSTRING("containsVariable"), ::hx::paccDynamic)(::String(name));
}

int SFS3_MMOItem_getVariable_int(SFS3_MMOItem* item, const char* name) {
    ::Dynamic v = mmoitem_getVar(item, name);
    if (v == null()) return 0;
    return (int)v->__Field(HX_CSTRING("getIntValue"), ::hx::paccDynamic)();
}

double SFS3_MMOItem_getVariable_double(SFS3_MMOItem* item, const char* name) {
    ::Dynamic v = mmoitem_getVar(item, name);
    if (v == null()) return 0.0;
    return (double)(Float)v->__Field(HX_CSTRING("getDoubleValue"), ::hx::paccDynamic)();
}

bool SFS3_MMOItem_getVariable_bool(SFS3_MMOItem* item, const char* name) {
    ::Dynamic v = mmoitem_getVar(item, name);
    if (v == null()) return false;
    return (bool)v->__Field(HX_CSTRING("getBoolValue"), ::hx::paccDynamic)();
}

SFS3_String SFS3_MMOItem_getVariable_string(SFS3_MMOItem* item, const char* name) {
    ::Dynamic v = mmoitem_getVar(item, name);
    if (v == null()) return SFS3_String_create(nullptr);
    ::String s = (::String)v->__Field(HX_CSTRING("getStringValue"), ::hx::paccDynamic)();
    return wrap_string(s);
}

/* ── Event list accessors ───────────────────────────────────────────────── */

static ::Dynamic evt_getArray(SFS3_Event* evt, const char* key) {
    if (!evt || !key) return null();
    ::Dynamic val = evt->hxEvt->getParam(::String(key));
    return val;
}

double SFS3_Event_getDouble(SFS3_Event* evt, const char* key) {
    if (!evt || !key) return 0.0;
    ::Dynamic val = evt->hxEvt->getParam(::String(key));
    if (val == null()) return 0.0;
    return (double)(Float)val;
}

int SFS3_Event_getLagValue(SFS3_Event* evt) {
    if (!evt) return 0;
    ::Dynamic val = evt->hxEvt->getParam(::String("lagValue"));
    if (val == null()) return 0;
    Float avg = (Float)val->__Field(HX_CSTRING("average"), ::hx::paccDynamic);
    return (int)avg;
}

int SFS3_Event_getUserListCount(SFS3_Event* evt, const char* key) {
    ::Dynamic arr = evt_getArray(evt, key);
    if (arr == null()) return 0;
    return (int)arr->__Field(HX_CSTRING("length"), ::hx::paccDynamic);
}

SFS3_User* SFS3_Event_getUserAt(SFS3_Event* evt, const char* key, int index) {
    ::Dynamic arr = evt_getArray(evt, key);
    if (arr == null()) return nullptr;
    int len = (int)arr->__Field(HX_CSTRING("length"), ::hx::paccDynamic);
    if (index < 0 || index >= len) return nullptr;
    ::Dynamic elem = arr->__GetItem(index);
    if (elem == null()) return nullptr;
    auto u = new SFS3_User();
    u->hxUser = elem;
    return u;
}

int SFS3_Event_getMMOItemCount(SFS3_Event* evt, const char* key) {
    ::Dynamic arr = evt_getArray(evt, key);
    if (arr == null()) return 0;
    return (int)arr->__Field(HX_CSTRING("length"), ::hx::paccDynamic);
}

SFS3_MMOItem* SFS3_Event_getMMOItemAt(SFS3_Event* evt, const char* key, int index) {
    ::Dynamic arr = evt_getArray(evt, key);
    if (arr == null()) return nullptr;
    int len = (int)arr->__Field(HX_CSTRING("length"), ::hx::paccDynamic);
    if (index < 0 || index >= len) return nullptr;
    ::Dynamic elem = arr->__GetItem(index);
    if (elem == null()) return nullptr;
    auto item = new SFS3_MMOItem();
    item->hxItem = elem;
    return item;
}

int SFS3_Event_getStringListCount(SFS3_Event* evt, const char* key) {
    ::Dynamic arr = evt_getArray(evt, key);
    if (arr == null()) return 0;
    return (int)arr->__Field(HX_CSTRING("length"), ::hx::paccDynamic);
}

SFS3_String SFS3_Event_getStringListAt(SFS3_Event* evt, const char* key, int index) {
    ::Dynamic arr = evt_getArray(evt, key);
    if (arr == null()) return SFS3_String_create(nullptr);
    int len = (int)arr->__Field(HX_CSTRING("length"), ::hx::paccDynamic);
    if (index < 0 || index >= len) return SFS3_String_create(nullptr);
    ::Dynamic elem = arr->__GetItem(index);
    if (elem == null()) return SFS3_String_create(nullptr);
    return wrap_string((::String)elem);
}

/* ── SFS3_Room (thin wrapper) ───────────────────────────────────────────── */

struct SFS3_Room {
    ::Dynamic hxRoom;
};

SFS3_Room* SFS3_Event_getRoom(SFS3_Event* evt, const char* key) {
    if (!evt || !key) return nullptr;
    ::Dynamic val = evt->hxEvt->getParam(::String(key));
    if (val == null()) return nullptr;
    auto r = new SFS3_Room();
    r->hxRoom = val;
    return r;
}

int SFS3_Room_getId(SFS3_Room* room) {
    if (!room) return -1;
    return (int)room->hxRoom->__Field(HX_CSTRING("getId"), ::hx::paccDynamic)();
}

SFS3_String SFS3_Room_getName(SFS3_Room* room) {
    if (!room) return SFS3_String_create(nullptr);
    return wrap_string((::String)room->hxRoom->__Field(HX_CSTRING("getName"), ::hx::paccDynamic)());
}

SFS3_String SFS3_Room_getGroupId(SFS3_Room* room) {
    if (!room) return SFS3_String_create(nullptr);
    return wrap_string((::String)room->hxRoom->__Field(HX_CSTRING("getGroupId"), ::hx::paccDynamic)());
}

bool SFS3_Room_isJoined(SFS3_Room* room) {
    if (!room) return false;
    return (bool)room->hxRoom->__Field(HX_CSTRING("getJoined"), ::hx::paccDynamic)();
}

bool SFS3_Room_isGame(SFS3_Room* room) {
    if (!room) return false;
    return (bool)room->hxRoom->__Field(HX_CSTRING("getGame"), ::hx::paccDynamic)();
}

bool SFS3_Room_isHidden(SFS3_Room* room) {
    if (!room) return false;
    return (bool)room->hxRoom->__Field(HX_CSTRING("getHidden"), ::hx::paccDynamic)();
}

bool SFS3_Room_isPasswordProtected(SFS3_Room* room) {
    if (!room) return false;
    return (bool)room->hxRoom->__Field(HX_CSTRING("getPasswordProtected"), ::hx::paccDynamic)();
}

int SFS3_Room_getUserCount(SFS3_Room* room) {
    if (!room) return 0;
    return (int)room->hxRoom->__Field(HX_CSTRING("getUserCount"), ::hx::paccDynamic)();
}

int SFS3_Room_getMaxUsers(SFS3_Room* room) {
    if (!room) return 0;
    return (int)room->hxRoom->__Field(HX_CSTRING("getMaxUsers"), ::hx::paccDynamic)();
}

int SFS3_Room_getSpectatorCount(SFS3_Room* room) {
    if (!room) return 0;
    return (int)room->hxRoom->__Field(HX_CSTRING("getSpectatorCount"), ::hx::paccDynamic)();
}

int SFS3_Room_getMaxSpectators(SFS3_Room* room) {
    if (!room) return 0;
    return (int)room->hxRoom->__Field(HX_CSTRING("getMaxSpectators"), ::hx::paccDynamic)();
}

int SFS3_Room_getCapacity(SFS3_Room* room) {
    if (!room) return 0;
    return (int)room->hxRoom->__Field(HX_CSTRING("getCapacity"), ::hx::paccDynamic)();
}

int SFS3_Room_getUserListCount(SFS3_Room* room) {
    if (!room) return 0;
    SFS3_HX_BEGIN
    ::Dynamic arr = room->hxRoom->__Field(HX_CSTRING("getUserList"), ::hx::paccDynamic)();
    int n = (arr == null()) ? 0 : (int)arr->__Field(HX_CSTRING("length"), ::hx::paccDynamic);
    SFS3_HX_END
    return n;
}

SFS3_User* SFS3_Room_getUserAt(SFS3_Room* room, int index) {
    if (!room) return nullptr;
    SFS3_HX_BEGIN
    ::Dynamic arr = room->hxRoom->__Field(HX_CSTRING("getUserList"), ::hx::paccDynamic)();
    SFS3_HX_END
    if (arr == null()) return nullptr;
    int len = (int)arr->__Field(HX_CSTRING("length"), ::hx::paccDynamic);
    if (index < 0 || index >= len) return nullptr;
    auto u = new SFS3_User();
    u->hxUser = arr->__GetItem(index);
    return u;
}

/* ── SFS3_SFSObject wrapper ─────────────────────────────────────────────── */

struct SFS3_SFSObject {
    ::Dynamic hxObj;
};

SFS3_SFSObject* SFS3_Event_getSFSObject(SFS3_Event* evt, const char* key) {
    if (!evt || !key) return nullptr;
    ::Dynamic val = evt->hxEvt->getParam(::String(key));
    if (val == null()) return nullptr;
    auto o = new SFS3_SFSObject();
    o->hxObj = val;
    return o;
}

SFS3_SFSObject* SFS3_SFSObject_create(void) {
    auto o = new SFS3_SFSObject();
    o->hxObj = com::smartfoxserver::v3::entities::data::SFSObject_obj::newInstance();
    return o;
}

void SFS3_SFSObject_release(SFS3_SFSObject* obj) {
    if (obj) {
        obj->hxObj = null();
        delete obj;
    }
}

bool SFS3_SFSObject_containsKey(SFS3_SFSObject* obj, const char* key) {
    if (!obj || !key) return false;
    return (bool)obj->hxObj->__Field(HX_CSTRING("containsKey"), ::hx::paccDynamic)(::String(key));
}

int SFS3_SFSObject_size(SFS3_SFSObject* obj) {
    if (!obj) return 0;
    return (int)obj->hxObj->__Field(HX_CSTRING("size"), ::hx::paccDynamic)();
}

bool SFS3_SFSObject_isNull(SFS3_SFSObject* obj, const char* key) {
    if (!obj || !key) return true;
    return (bool)obj->hxObj->__Field(HX_CSTRING("isNull"), ::hx::paccDynamic)(::String(key));
}

void SFS3_SFSObject_putBool(SFS3_SFSObject* obj, const char* key, bool value) {
    if (!obj || !key) return;
    obj->hxObj->__Field(HX_CSTRING("putBool"), ::hx::paccDynamic)(::String(key), value);
}

void SFS3_SFSObject_putByte(SFS3_SFSObject* obj, const char* key, int value) {
    if (!obj || !key) return;
    obj->hxObj->__Field(HX_CSTRING("putByte"), ::hx::paccDynamic)(::String(key), value);
}

void SFS3_SFSObject_putShort(SFS3_SFSObject* obj, const char* key, int value) {
    if (!obj || !key) return;
    obj->hxObj->__Field(HX_CSTRING("putShort"), ::hx::paccDynamic)(::String(key), value);
}

void SFS3_SFSObject_putInt(SFS3_SFSObject* obj, const char* key, int value) {
    if (!obj || !key) return;
    obj->hxObj->__Field(HX_CSTRING("putInt"), ::hx::paccDynamic)(::String(key), value);
}

void SFS3_SFSObject_putLong(SFS3_SFSObject* obj, const char* key, long long value) {
    if (!obj || !key) return;
    obj->hxObj->__Field(HX_CSTRING("putLong"), ::hx::paccDynamic)(::String(key), (int)value);
}

void SFS3_SFSObject_putFloat(SFS3_SFSObject* obj, const char* key, float value) {
    if (!obj || !key) return;
    obj->hxObj->__Field(HX_CSTRING("putFloat"), ::hx::paccDynamic)(::String(key), (double)value);
}

void SFS3_SFSObject_putDouble(SFS3_SFSObject* obj, const char* key, double value) {
    if (!obj || !key) return;
    obj->hxObj->__Field(HX_CSTRING("putDouble"), ::hx::paccDynamic)(::String(key), value);
}

void SFS3_SFSObject_putString(SFS3_SFSObject* obj, const char* key, const char* value) {
    if (!obj || !key || !value) return;
    obj->hxObj->__Field(HX_CSTRING("putString"), ::hx::paccDynamic)(::String(key), ::String(value));
}

void SFS3_SFSObject_putSFSObject(SFS3_SFSObject* obj, const char* key, SFS3_SFSObject* value) {
    if (!obj || !key || !value) return;
    obj->hxObj->__Field(HX_CSTRING("putSFSObject"), ::hx::paccDynamic)(::String(key), value->hxObj);
}

void SFS3_SFSObject_putSFSArray(SFS3_SFSObject* obj, const char* key, SFS3_SFSArray* value) {
    /* forward-declared; implemented after SFS3_SFSArray struct */
}

bool SFS3_SFSObject_getBool(SFS3_SFSObject* obj, const char* key) {
    if (!obj || !key) return false;
    return (bool)obj->hxObj->__Field(HX_CSTRING("getBool"), ::hx::paccDynamic)(::String(key));
}

int SFS3_SFSObject_getByte(SFS3_SFSObject* obj, const char* key) {
    if (!obj || !key) return 0;
    return (int)obj->hxObj->__Field(HX_CSTRING("getByte"), ::hx::paccDynamic)(::String(key));
}

int SFS3_SFSObject_getShort(SFS3_SFSObject* obj, const char* key) {
    if (!obj || !key) return 0;
    return (int)obj->hxObj->__Field(HX_CSTRING("getShort"), ::hx::paccDynamic)(::String(key));
}

int SFS3_SFSObject_getInt(SFS3_SFSObject* obj, const char* key) {
    if (!obj || !key) return 0;
    return (int)obj->hxObj->__Field(HX_CSTRING("getInt"), ::hx::paccDynamic)(::String(key));
}

long long SFS3_SFSObject_getLong(SFS3_SFSObject* obj, const char* key) {
    if (!obj || !key) return 0;
    return (long long)(int)obj->hxObj->__Field(HX_CSTRING("getLong"), ::hx::paccDynamic)(::String(key));
}

float SFS3_SFSObject_getFloat(SFS3_SFSObject* obj, const char* key) {
    if (!obj || !key) return 0.0f;
    return (float)(double)obj->hxObj->__Field(HX_CSTRING("getFloat"), ::hx::paccDynamic)(::String(key));
}

double SFS3_SFSObject_getDouble(SFS3_SFSObject* obj, const char* key) {
    if (!obj || !key) return 0.0;
    return (double)obj->hxObj->__Field(HX_CSTRING("getDouble"), ::hx::paccDynamic)(::String(key));
}

SFS3_String SFS3_SFSObject_getString(SFS3_SFSObject* obj, const char* key) {
    if (!obj || !key) return SFS3_String_create(nullptr);
    ::Dynamic val = obj->hxObj->__Field(HX_CSTRING("getString"), ::hx::paccDynamic)(::String(key));
    if (val == null()) return SFS3_String_create(nullptr);
    return wrap_string((::String)val);
}

SFS3_SFSObject* SFS3_SFSObject_getSFSObject(SFS3_SFSObject* obj, const char* key) {
    if (!obj || !key) return nullptr;
    ::Dynamic val = obj->hxObj->__Field(HX_CSTRING("getSFSObject"), ::hx::paccDynamic)(::String(key));
    if (val == null()) return nullptr;
    auto o = new SFS3_SFSObject();
    o->hxObj = val;
    return o;
}

SFS3_SFSArray* SFS3_SFSObject_getSFSArray(SFS3_SFSObject* obj, const char* key);

SFS3_String SFS3_SFSObject_toJson(SFS3_SFSObject* obj) {
    if (!obj) return SFS3_String_create(nullptr);
    ::Dynamic val = obj->hxObj->__Field(HX_CSTRING("toJson"), ::hx::paccDynamic)();
    if (val == null()) return SFS3_String_create(nullptr);
    return wrap_string((::String)val);
}

SFS3_String SFS3_SFSObject_getDump(SFS3_SFSObject* obj) {
    if (!obj) return SFS3_String_create(nullptr);
    ::Dynamic val = obj->hxObj->__Field(HX_CSTRING("getDump"), ::hx::paccDynamic)();
    if (val == null()) return SFS3_String_create(nullptr);
    return wrap_string((::String)val);
}

/* ── SFS3_SFSArray wrapper ──────────────────────────────────────────────── */

struct SFS3_SFSArray {
    ::Dynamic hxArr;
};

SFS3_SFSArray* SFS3_SFSArray_create(void) {
    auto a = new SFS3_SFSArray();
    a->hxArr = com::smartfoxserver::v3::entities::data::SFSArray_obj::newInstance();
    return a;
}

void SFS3_SFSArray_release(SFS3_SFSArray* arr) {
    if (arr) {
        arr->hxArr = null();
        delete arr;
    }
}

int SFS3_SFSArray_size(SFS3_SFSArray* arr) {
    if (!arr) return 0;
    return (int)arr->hxArr->__Field(HX_CSTRING("size"), ::hx::paccDynamic)();
}

void SFS3_SFSArray_addBool(SFS3_SFSArray* arr, bool value) {
    if (!arr) return;
    arr->hxArr->__Field(HX_CSTRING("addBool"), ::hx::paccDynamic)(value);
}

void SFS3_SFSArray_addByte(SFS3_SFSArray* arr, int value) {
    if (!arr) return;
    arr->hxArr->__Field(HX_CSTRING("addByte"), ::hx::paccDynamic)(value);
}

void SFS3_SFSArray_addShort(SFS3_SFSArray* arr, int value) {
    if (!arr) return;
    arr->hxArr->__Field(HX_CSTRING("addShort"), ::hx::paccDynamic)(value);
}

void SFS3_SFSArray_addInt(SFS3_SFSArray* arr, int value) {
    if (!arr) return;
    arr->hxArr->__Field(HX_CSTRING("addInt"), ::hx::paccDynamic)(value);
}

void SFS3_SFSArray_addLong(SFS3_SFSArray* arr, long long value) {
    if (!arr) return;
    arr->hxArr->__Field(HX_CSTRING("addLong"), ::hx::paccDynamic)((int)value);
}

void SFS3_SFSArray_addFloat(SFS3_SFSArray* arr, float value) {
    if (!arr) return;
    arr->hxArr->__Field(HX_CSTRING("addFloat"), ::hx::paccDynamic)((double)value);
}

void SFS3_SFSArray_addDouble(SFS3_SFSArray* arr, double value) {
    if (!arr) return;
    arr->hxArr->__Field(HX_CSTRING("addDouble"), ::hx::paccDynamic)(value);
}

void SFS3_SFSArray_addString(SFS3_SFSArray* arr, const char* value) {
    if (!arr || !value) return;
    arr->hxArr->__Field(HX_CSTRING("addString"), ::hx::paccDynamic)(::String(value));
}

void SFS3_SFSArray_addSFSObject(SFS3_SFSArray* arr, SFS3_SFSObject* value) {
    if (!arr || !value) return;
    arr->hxArr->__Field(HX_CSTRING("addSFSObject"), ::hx::paccDynamic)(value->hxObj);
}

void SFS3_SFSArray_addSFSArray(SFS3_SFSArray* arr, SFS3_SFSArray* value) {
    if (!arr || !value) return;
    arr->hxArr->__Field(HX_CSTRING("addSFSArray"), ::hx::paccDynamic)(value->hxArr);
}

bool SFS3_SFSArray_getBool(SFS3_SFSArray* arr, int index) {
    if (!arr) return false;
    return (bool)arr->hxArr->__Field(HX_CSTRING("getBool"), ::hx::paccDynamic)(index);
}

int SFS3_SFSArray_getByte(SFS3_SFSArray* arr, int index) {
    if (!arr) return 0;
    return (int)arr->hxArr->__Field(HX_CSTRING("getByte"), ::hx::paccDynamic)(index);
}

int SFS3_SFSArray_getShort(SFS3_SFSArray* arr, int index) {
    if (!arr) return 0;
    return (int)arr->hxArr->__Field(HX_CSTRING("getShort"), ::hx::paccDynamic)(index);
}

int SFS3_SFSArray_getInt(SFS3_SFSArray* arr, int index) {
    if (!arr) return 0;
    return (int)arr->hxArr->__Field(HX_CSTRING("getInt"), ::hx::paccDynamic)(index);
}

long long SFS3_SFSArray_getLong(SFS3_SFSArray* arr, int index) {
    if (!arr) return 0;
    return (long long)(int)arr->hxArr->__Field(HX_CSTRING("getLong"), ::hx::paccDynamic)(index);
}

float SFS3_SFSArray_getFloat(SFS3_SFSArray* arr, int index) {
    if (!arr) return 0.0f;
    return (float)(double)arr->hxArr->__Field(HX_CSTRING("getFloat"), ::hx::paccDynamic)(index);
}

double SFS3_SFSArray_getDouble(SFS3_SFSArray* arr, int index) {
    if (!arr) return 0.0;
    return (double)arr->hxArr->__Field(HX_CSTRING("getDouble"), ::hx::paccDynamic)(index);
}

SFS3_String SFS3_SFSArray_getString(SFS3_SFSArray* arr, int index) {
    if (!arr) return SFS3_String_create(nullptr);
    ::Dynamic val = arr->hxArr->__Field(HX_CSTRING("getString"), ::hx::paccDynamic)(index);
    if (val == null()) return SFS3_String_create(nullptr);
    return wrap_string((::String)val);
}

SFS3_SFSObject* SFS3_SFSArray_getSFSObject(SFS3_SFSArray* arr, int index) {
    if (!arr) return nullptr;
    ::Dynamic val = arr->hxArr->__Field(HX_CSTRING("getSFSObject"), ::hx::paccDynamic)(index);
    if (val == null()) return nullptr;
    auto o = new SFS3_SFSObject();
    o->hxObj = val;
    return o;
}

SFS3_SFSArray* SFS3_SFSArray_getSFSArray(SFS3_SFSArray* arr, int index) {
    if (!arr) return nullptr;
    ::Dynamic val = arr->hxArr->__Field(HX_CSTRING("getSFSArray"), ::hx::paccDynamic)(index);
    if (val == null()) return nullptr;
    auto a = new SFS3_SFSArray();
    a->hxArr = val;
    return a;
}

SFS3_String SFS3_SFSArray_toJson(SFS3_SFSArray* arr) {
    if (!arr) return SFS3_String_create(nullptr);
    ::Dynamic val = arr->hxArr->__Field(HX_CSTRING("toJson"), ::hx::paccDynamic)();
    if (val == null()) return SFS3_String_create(nullptr);
    return wrap_string((::String)val);
}

SFS3_String SFS3_SFSArray_getDump(SFS3_SFSArray* arr) {
    if (!arr) return SFS3_String_create(nullptr);
    ::Dynamic val = arr->hxArr->__Field(HX_CSTRING("getDump"), ::hx::paccDynamic)();
    if (val == null()) return SFS3_String_create(nullptr);
    return wrap_string((::String)val);
}

/* Deferred implementations that needed SFS3_SFSArray struct */

SFS3_SFSArray* SFS3_SFSObject_getSFSArray(SFS3_SFSObject* obj, const char* key) {
    if (!obj || !key) return nullptr;
    ::Dynamic val = obj->hxObj->__Field(HX_CSTRING("getSFSArray"), ::hx::paccDynamic)(::String(key));
    if (val == null()) return nullptr;
    auto a = new SFS3_SFSArray();
    a->hxArr = val;
    return a;
}

/* ── SmartFox ───────────────────────────────────────────────────────────── */

struct SFS3_SmartFox {
    hx::Object* obj;

    SFS3_SmartFox() : obj(nullptr) {}

    void set(hx::Object* o) {
        obj = o;
        if (obj) hx::GCAddRoot(&obj);
    }

    ~SFS3_SmartFox() {
        if (obj && g_sfs3_initialized) { hx::GCRemoveRoot(&obj); }
        obj = nullptr;
    }

private:
    SFS3_SmartFox(const SFS3_SmartFox&);
    SFS3_SmartFox& operator=(const SFS3_SmartFox&);
};

#define SFS_OBJ(s) (static_cast<com::smartfoxserver::v3::SmartFox_obj*>((s)->obj))

SFS3_SmartFox* SFS3_SmartFox_create(void) {
    SFS3_HX_BEGIN
    auto sfs = new SFS3_SmartFox();
    sfs->set(com::smartfoxserver::v3::SmartFox_obj::__new().GetPtr());
    SFS3_HX_END
    return sfs;
}

void SFS3_SmartFox_release(SFS3_SmartFox* sfs) {
    if (sfs) {
        {
            std::lock_guard<std::mutex> lock(g_listenerMutex);
            for (auto it = g_listeners.begin(); it != g_listeners.end(); ) {
                if ((*it)->sfsHandle == sfs) {
                    delete *it;
                    it = g_listeners.erase(it);
                } else {
                    ++it;
                }
            }
        }
        delete sfs;
    }
}

SFS3_NOINLINE void SFS3_connect(SFS3_SmartFox* sfs, SFS3_ConfigData* cfg) {
    if (!sfs || !cfg) return;
    SFS3_HX_BEGIN
    SFS_OBJ(sfs)->connect(
        (com::smartfoxserver::v3::ConfigData)::Dynamic(cfg->obj));
    SFS3_HX_END
}

SFS3_NOINLINE void SFS3_disconnect(SFS3_SmartFox* sfs) {
    if (!sfs) return;
    SFS3_HX_BEGIN
    SFS_OBJ(sfs)->disconnect();
    SFS3_HX_END
}

SFS3_NOINLINE bool SFS3_isConnected(SFS3_SmartFox* sfs) {
    if (!sfs) return false;
    SFS3_HX_BEGIN
    bool r = SFS_OBJ(sfs)->isConnected();
    SFS3_HX_END
    return r;
}

void SFS3_killConnection(SFS3_SmartFox* sfs) {
    if (!sfs) return;
    SFS3_HX_BEGIN
    SFS_OBJ(sfs)->killConnection();
    SFS3_HX_END
}

void SFS3_connectUdp(SFS3_SmartFox* sfs) {
    if (!sfs) return;
    SFS3_HX_BEGIN
    SFS_OBJ(sfs)->connectUdp();
    SFS3_HX_END
}

void SFS3_disconnectUdp(SFS3_SmartFox* sfs) {
    if (!sfs) return;
    SFS3_HX_BEGIN
    SFS_OBJ(sfs)->disconnectUdp();
    SFS3_HX_END
}

bool SFS3_isUdpConnected(SFS3_SmartFox* sfs) {
    if (!sfs) return false;
    SFS3_HX_BEGIN
    bool r = SFS_OBJ(sfs)->isUdpConnected();
    SFS3_HX_END
    return r;
}

SFS3_String SFS3_getVersion(SFS3_SmartFox* sfs) {
    if (!sfs) return SFS3_String_create(nullptr);
    SFS3_HX_BEGIN
    SFS3_String r = wrap_string(SFS_OBJ(sfs)->getVersion());
    SFS3_HX_END
    return r;
}

SFS3_String SFS3_getSessionToken(SFS3_SmartFox* sfs) {
    if (!sfs) return SFS3_String_create(nullptr);
    SFS3_HX_BEGIN
    SFS3_String r = wrap_string(SFS_OBJ(sfs)->getSessionToken());
    SFS3_HX_END
    return r;
}

SFS3_String SFS3_getConnectionMode(SFS3_SmartFox* sfs) {
    if (!sfs) return SFS3_String_create(nullptr);
    SFS3_HX_BEGIN
    SFS3_String r = wrap_string(SFS_OBJ(sfs)->getConnectionMode());
    SFS3_HX_END
    return r;
}

SFS3_String SFS3_getHttpUploadURI(SFS3_SmartFox* sfs) {
    if (!sfs) return SFS3_String_create(nullptr);
    SFS3_HX_BEGIN
    SFS3_String r = wrap_string(SFS_OBJ(sfs)->getHttpUploadURI());
    SFS3_HX_END
    return r;
}

void SFS3_setClientDetails(SFS3_SmartFox* sfs, const char* platformId, const char* version) {
    if (!sfs) return;
    SFS3_HX_BEGIN
    SFS_OBJ(sfs)->setClientDetails(
        platformId ? ::String(platformId) : null(),
        version ? ::String(version) : null()
    );
    SFS3_HX_END
}

SFS3_User* SFS3_getMySelf(SFS3_SmartFox* sfs) {
    if (!sfs) return nullptr;
    SFS3_HX_BEGIN
    ::Dynamic user = SFS_OBJ(sfs)->getMySelf();
    SFS3_HX_END
    if (user == null()) return nullptr;
    auto u = new SFS3_User();
    u->hxUser = user;
    return u;
}

void SFS3_enableLagMonitor(SFS3_SmartFox* sfs, bool enabled, int intervalSec, int queueSize) {
    if (!sfs) return;
    SFS3_HX_BEGIN
    SFS_OBJ(sfs)->enableLagMonitor(enabled, intervalSec, queueSize);
    SFS3_HX_END
}

void SFS3_stopExecutors(SFS3_SmartFox* sfs) {
    if (!sfs) return;
    SFS3_HX_BEGIN
    SFS_OBJ(sfs)->stopExecutors();
    SFS3_HX_END
}

/* ── Event listeners ────────────────────────────────────────────────────── */

SFS3_NOINLINE void SFS3_addEventListener(SFS3_SmartFox* sfs, const char* eventType,
                           SFS3_EventHandler handler, void* userData) {
    if (!sfs || !eventType || !handler) return;

    auto entry = new EventListenerEntry();
    entry->eventType = eventType;
    entry->handler = handler;
    entry->userData = userData;
    entry->sfsHandle = sfs;

    SFS3_HX_BEGIN
    ::Dynamic hxCb = ::Dynamic(new _hx_Closure_sfs3Event(entry));
    entry->hxListener = hxCb;

    {
        std::lock_guard<std::mutex> lock(g_listenerMutex);
        g_listeners.push_back(entry);
    }

    SFS_OBJ(sfs)->addEventListener(::String(eventType), hxCb);
    SFS3_HX_END
}

void SFS3_removeEventListener(SFS3_SmartFox* sfs, const char* eventType,
                              SFS3_EventHandler handler) {
    if (!sfs || !eventType || !handler) return;

    SFS3_HX_BEGIN
    EventListenerEntry* removed = nullptr;
    {
        std::lock_guard<std::mutex> lock(g_listenerMutex);
        for (auto it = g_listeners.begin(); it != g_listeners.end(); ++it) {
            if ((*it)->sfsHandle == sfs &&
                (*it)->eventType == eventType &&
                (*it)->handler == handler) {
                SFS_OBJ(sfs)->removeEventListener(::String(eventType), (*it)->hxListener);
                removed = *it;
                g_listeners.erase(it);
                break;
            }
        }
    }
    if (removed) {
        std::lock_guard<std::mutex> lk(g_pendingMtx);
        g_pendingEvents.erase(
            std::remove_if(g_pendingEvents.begin(), g_pendingEvents.end(),
                [removed](const PendingEvent& pe) { return pe.entry == removed; }),
            g_pendingEvents.end());
        delete removed;
    }
    SFS3_HX_END
}

void SFS3_removeAllEventListeners(SFS3_SmartFox* sfs) {
    if (!sfs) return;
    if (g_sfs3_initialized) {
        SFS3_HX_BEGIN
        SFS_OBJ(sfs)->removeAllEventListeners();
        SFS3_HX_END
    }

    std::vector<EventListenerEntry*> removed;
    {
        std::lock_guard<std::mutex> lock(g_listenerMutex);
        for (auto it = g_listeners.begin(); it != g_listeners.end(); ) {
            if ((*it)->sfsHandle == sfs) {
                removed.push_back(*it);
                it = g_listeners.erase(it);
            } else {
                ++it;
            }
        }
    }
    {
        std::lock_guard<std::mutex> lk(g_pendingMtx);
        g_pendingEvents.erase(
            std::remove_if(g_pendingEvents.begin(), g_pendingEvents.end(),
                [&removed](const PendingEvent& pe) {
                    for (auto* e : removed) if (pe.entry == e) return true;
                    return false;
                }),
            g_pendingEvents.end());
    }
    for (auto* e : removed) delete e;
}

/* ── Room list ──────────────────────────────────────────────────────────── */

int SFS3_getRoomCount(SFS3_SmartFox* sfs) {
    if (!sfs) return 0;
    SFS3_HX_BEGIN
    ::Dynamic mgr = SFS_OBJ(sfs)->getRoomManager();
    ::Dynamic list = mgr->__Field(HX_CSTRING("getRoomList"), ::hx::paccDynamic)();
    int n = (list == null()) ? 0 : (int)list->__Field(HX_CSTRING("length"), ::hx::paccDynamic);
    SFS3_HX_END
    return n;
}

SFS3_Room* SFS3_getRoomAt(SFS3_SmartFox* sfs, int index) {
    if (!sfs) return nullptr;
    SFS3_HX_BEGIN
    ::Dynamic mgr = SFS_OBJ(sfs)->getRoomManager();
    ::Dynamic list = mgr->__Field(HX_CSTRING("getRoomList"), ::hx::paccDynamic)();
    SFS3_HX_END
    if (list == null()) return nullptr;
    int len = (int)list->__Field(HX_CSTRING("length"), ::hx::paccDynamic);
    if (index < 0 || index >= len) return nullptr;
    auto r = new SFS3_Room();
    r->hxRoom = list->__GetItem(index);
    return r;
}

SFS3_Room* SFS3_getRoomById(SFS3_SmartFox* sfs, int roomId) {
    if (!sfs) return nullptr;
    SFS3_HX_BEGIN
    ::Dynamic mgr = SFS_OBJ(sfs)->getRoomManager();
    ::Dynamic room = mgr->__Field(HX_CSTRING("getRoomById"), ::hx::paccDynamic)(roomId);
    SFS3_HX_END
    if (room == null()) return nullptr;
    auto r = new SFS3_Room();
    r->hxRoom = room;
    return r;
}

SFS3_Room* SFS3_getRoomByName(SFS3_SmartFox* sfs, const char* name) {
    if (!sfs || !name) return nullptr;
    SFS3_HX_BEGIN
    ::Dynamic mgr = SFS_OBJ(sfs)->getRoomManager();
    ::Dynamic room = mgr->__Field(HX_CSTRING("getRoomByName"), ::hx::paccDynamic)(::String(name));
    SFS3_HX_END
    if (room == null()) return nullptr;
    auto r = new SFS3_Room();
    r->hxRoom = room;
    return r;
}

int SFS3_getJoinedRoomCount(SFS3_SmartFox* sfs) {
    if (!sfs) return 0;
    SFS3_HX_BEGIN
    ::Array< ::Dynamic> rooms = SFS_OBJ(sfs)->getJoinedRooms();
    int n = (rooms == null()) ? 0 : rooms->length;
    SFS3_HX_END
    return n;
}

SFS3_Room* SFS3_getJoinedRoomAt(SFS3_SmartFox* sfs, int index) {
    if (!sfs) return nullptr;
    SFS3_HX_BEGIN
    ::Array< ::Dynamic> rooms = SFS_OBJ(sfs)->getJoinedRooms();
    SFS3_HX_END
    if (rooms == null() || index < 0 || index >= rooms->length) return nullptr;
    auto r = new SFS3_Room();
    r->hxRoom = rooms->__get(index);
    return r;
}

SFS3_Room* SFS3_getLastJoinedRoom(SFS3_SmartFox* sfs) {
    if (!sfs) return nullptr;
    SFS3_HX_BEGIN
    ::Dynamic room = SFS_OBJ(sfs)->getLastJoinedRoom();
    SFS3_HX_END
    if (room == null()) return nullptr;
    auto r = new SFS3_Room();
    r->hxRoom = room;
    return r;
}

/* ── Requests ───────────────────────────────────────────────────────────── */

SFS3_NOINLINE void SFS3_sendLogin(SFS3_SmartFox* sfs, const char* userName, const char* password,
                    const char* zoneName, SFS3_SFSObject* params) {
    if (!sfs) return;
    SFS3_HX_BEGIN
    ::Dynamic req = com::smartfoxserver::v3::requests::LoginRequest_obj::__new(
        userName ? ::String(userName) : HX_CSTRING(""),
        password ? ::String(password) : HX_CSTRING(""),
        zoneName ? ::String(zoneName) : null(),
        params ? params->hxObj : null()
    );
    SFS_OBJ(sfs)->send(req);
    SFS3_HX_END
}

SFS3_NOINLINE void SFS3_sendLogout(SFS3_SmartFox* sfs) {
    if (!sfs) return;
    SFS3_HX_BEGIN
    ::Dynamic req = com::smartfoxserver::v3::requests::LogoutRequest_obj::__new();
    SFS_OBJ(sfs)->send(req);
    SFS3_HX_END
}

SFS3_NOINLINE void SFS3_sendJoinRoom(SFS3_SmartFox* sfs, const char* roomName, const char* password,
                       int roomIdToLeave, bool asSpectator) {
    if (!sfs || !roomName) return;
    SFS3_HX_BEGIN
    ::Dynamic req = com::smartfoxserver::v3::requests::JoinRoomRequest_obj::__new(
        ::String(roomName),
        password ? ::String(password) : null(),
        roomIdToLeave >= 0 ? ::Dynamic(roomIdToLeave) : null(),
        asSpectator
    );
    SFS_OBJ(sfs)->send(req);
    SFS3_HX_END
}

SFS3_NOINLINE void SFS3_sendJoinRoomById(SFS3_SmartFox* sfs, int roomId, const char* password,
                           int roomIdToLeave, bool asSpectator) {
    if (!sfs) return;
    SFS3_HX_BEGIN
    ::Dynamic req = com::smartfoxserver::v3::requests::JoinRoomRequest_obj::__new(
        roomId,
        password ? ::String(password) : null(),
        roomIdToLeave >= 0 ? ::Dynamic(roomIdToLeave) : null(),
        asSpectator
    );
    SFS_OBJ(sfs)->send(req);
    SFS3_HX_END
}

SFS3_NOINLINE void SFS3_sendLeaveRoom(SFS3_SmartFox* sfs, int roomId) {
    if (!sfs) return;
    SFS3_HX_BEGIN
    ::Dynamic req = com::smartfoxserver::v3::requests::LeaveRoomRequest_obj::__new(
        roomId >= 0 ? ::Dynamic(roomId) : null()
    );
    SFS_OBJ(sfs)->send(req);
    SFS3_HX_END
}

SFS3_NOINLINE void SFS3_sendPublicMessage(SFS3_SmartFox* sfs, const char* message,
                            SFS3_SFSObject* params, int targetRoomId) {
    if (!sfs || !message) return;
    SFS3_HX_BEGIN
    ::Dynamic req = com::smartfoxserver::v3::requests::PublicMessageRequest_obj::__new(
        ::String(message),
        params ? params->hxObj : null(),
        targetRoomId >= 0 ? ::Dynamic(targetRoomId) : null()
    );
    SFS_OBJ(sfs)->send(req);
    SFS3_HX_END
}

SFS3_NOINLINE void SFS3_sendPrivateMessage(SFS3_SmartFox* sfs, const char* message,
                             int recipientId, SFS3_SFSObject* params) {
    if (!sfs || !message) return;
    SFS3_HX_BEGIN
    ::Dynamic req = com::smartfoxserver::v3::requests::PrivateMessageRequest_obj::__new(
        ::String(message), recipientId,
        params ? params->hxObj : null()
    );
    SFS_OBJ(sfs)->send(req);
    SFS3_HX_END
}

SFS3_NOINLINE void SFS3_sendExtensionRequest(SFS3_SmartFox* sfs, const char* extCmd,
                               SFS3_SFSObject* params, int roomId, int txType) {
    if (!sfs || !extCmd) return;
    SFS3_HX_BEGIN
    ::Dynamic req = com::smartfoxserver::v3::requests::ExtensionRequest_obj::__new(
        ::String(extCmd),
        params ? params->hxObj : null(),
        roomId >= 0 ? ::Dynamic(roomId) : null(),
        txType >= 0 ? ::Dynamic(txType) : null()
    );
    SFS_OBJ(sfs)->send(req);
    SFS3_HX_END
}

SFS3_NOINLINE void SFS3_sendSubscribeRoomGroup(SFS3_SmartFox* sfs, const char* groupId) {
    if (!sfs || !groupId) return;
    SFS3_HX_BEGIN
    ::Dynamic req = com::smartfoxserver::v3::requests::SubscribeRoomGroupRequest_obj::__new(
        ::String(groupId)
    );
    SFS_OBJ(sfs)->send(req);
    SFS3_HX_END
}

SFS3_NOINLINE void SFS3_sendUnsubscribeRoomGroup(SFS3_SmartFox* sfs, const char* groupId) {
    if (!sfs || !groupId) return;
    SFS3_HX_BEGIN
    ::Dynamic req = com::smartfoxserver::v3::requests::UnsubscribeRoomGroupRequest_obj::__new(
        ::String(groupId)
    );
    SFS_OBJ(sfs)->send(req);
    SFS3_HX_END
}

SFS3_NOINLINE void SFS3_sendObjectMessage(SFS3_SmartFox* sfs, SFS3_SFSObject* obj,
                            int targetRoomId, const int* recipientIds, int recipientCount) {
    if (!sfs || !obj) return;
    SFS3_HX_BEGIN
    ::Dynamic req = com::smartfoxserver::v3::requests::ObjectMessageRequest_obj::__new(
        obj->hxObj,
        targetRoomId >= 0 ? ::Dynamic(targetRoomId) : null(),
        null()
    );
    SFS_OBJ(sfs)->send(req);
    SFS3_HX_END
}

SFS3_NOINLINE void SFS3_sendSetUserVariables(SFS3_SmartFox* sfs, SFS3_SFSObject* vars) {
    if (!sfs || !vars) return;
    SFS3_HX_BEGIN
    ::Dynamic keys = vars->hxObj->__Field(HX_CSTRING("getKeys"), ::hx::paccDynamic)();
    int count = (int)keys->__Field(HX_CSTRING("length"), ::hx::paccDynamic);
    ::Array< ::Dynamic> varList = ::Array_obj< ::Dynamic>::__new(count);
    for (int i = 0; i < count; i++) {
        ::String key = (::String)keys->__GetItem(i);
        ::Dynamic wrapper = vars->hxObj->__Field(HX_CSTRING("get"), ::hx::paccDynamic)(key);
        ::Dynamic val = wrapper->__Field(HX_CSTRING("getObject"), ::hx::paccDynamic)();
        int sfsType = (int)wrapper->__Field(HX_CSTRING("getTypeId"), ::hx::paccDynamic)();
        int varType = 0;
        if (sfsType >= 0 && sfsType <= 8) varType = sfsType;
        auto uv = ::com::smartfoxserver::v3::entities::variables::SFSUserVariable_obj::__new(
            key, val, (::Dynamic)varType);
        varList[i] = uv;
    }
    auto req = ::com::smartfoxserver::v3::requests::SetUserVariablesRequest_obj::__new(varList);
    SFS_OBJ(sfs)->send(req);
    SFS3_HX_END
}
void SFS3_sendSetRoomVariables(SFS3_SmartFox* sfs, SFS3_SFSObject* vars, int roomId) { (void)sfs; (void)vars; (void)roomId; }

SFS3_NOINLINE void SFS3_sendSetRoomVariable_string(SFS3_SmartFox* sfs, const char* name, const char* value, int roomId) {
    if (!sfs || !name || !value) return;
    SFS3_HX_BEGIN
    auto rv = ::com::smartfoxserver::v3::entities::variables::SFSRoomVariable_obj::__new(
        ::String(name), ::String(value), null());
    ::Array< ::Dynamic> varList = ::Array_obj< ::Dynamic>::__new(1);
    varList[0] = rv;
    ::Dynamic room = null();
    if (roomId >= 0) {
        room = SFS_OBJ(sfs)->__Field(HX_CSTRING("getRoomById"), ::hx::paccDynamic)(roomId);
    }
    auto req = ::com::smartfoxserver::v3::requests::SetRoomVariablesRequest_obj::__new(varList, room);
    SFS_OBJ(sfs)->send(req);
    SFS3_HX_END
}

SFS3_String SFS3_Room_getVariable_string(SFS3_Room* room, const char* name) {
    if (!room || !name) return SFS3_String_create(nullptr);
    SFS3_String result = SFS3_String_create(nullptr);
    SFS3_HX_BEGIN
    ::Dynamic rv = room->hxRoom->__Field(HX_CSTRING("getVariable"), ::hx::paccDynamic)(::String(name));
    if (rv != null()) {
        ::String str = rv->__Field(HX_CSTRING("getStringValue"), ::hx::paccDynamic)();
        if (str != null()) result = wrap_string(str);
    }
    SFS3_HX_END
    return result;
}
void SFS3_sendInitBuddyList(SFS3_SmartFox* sfs) { (void)sfs; }
void SFS3_sendAddBuddy(SFS3_SmartFox* sfs, const char* buddyName) { (void)sfs; (void)buddyName; }
void SFS3_sendRemoveBuddy(SFS3_SmartFox* sfs, const char* buddyName) { (void)sfs; (void)buddyName; }
void SFS3_sendBlockBuddy(SFS3_SmartFox* sfs, const char* buddyName, bool blocked) { (void)sfs; (void)buddyName; (void)blocked; }
void SFS3_sendGoOnline(SFS3_SmartFox* sfs, bool online) { (void)sfs; (void)online; }
void SFS3_sendBuddyMessage(SFS3_SmartFox* sfs, const char* message, int buddyId, SFS3_SFSObject* params) { (void)sfs; (void)message; (void)buddyId; (void)params; }
void SFS3_sendInviteUsers(SFS3_SmartFox* sfs, const int* userIds, int count, int secondsForAnswer, SFS3_SFSObject* params) { (void)sfs; (void)userIds; (void)count; (void)secondsForAnswer; (void)params; }
void SFS3_sendInvitationReply(SFS3_SmartFox* sfs, int invitationId, SFS3_InvitationReply reply, SFS3_SFSObject* params) { (void)sfs; (void)invitationId; (void)reply; (void)params; }
void SFS3_sendKickUser(SFS3_SmartFox* sfs, int userId, const char* message, int delaySeconds) { (void)sfs; (void)userId; (void)message; (void)delaySeconds; }
void SFS3_sendBanUser(SFS3_SmartFox* sfs, int userId, const char* message, int banMode, int delaySeconds, int durationHours) { (void)sfs; (void)userId; (void)message; (void)banMode; (void)delaySeconds; (void)durationHours; }
void SFS3_sendSpectatorToPlayer(SFS3_SmartFox* sfs, int roomId) { (void)sfs; (void)roomId; }
void SFS3_sendPlayerToSpectator(SFS3_SmartFox* sfs, int roomId) { (void)sfs; (void)roomId; }

/* ── Buddy access stubs ─────────────────────────────────────────────────── */

int SFS3_Buddy_getId(SFS3_Buddy* buddy) { (void)buddy; return -1; }
SFS3_String SFS3_Buddy_getName(SFS3_Buddy* buddy) { (void)buddy; return SFS3_String_create(nullptr); }
bool SFS3_Buddy_isBlocked(SFS3_Buddy* buddy) { (void)buddy; return false; }
bool SFS3_Buddy_isOnline(SFS3_Buddy* buddy) { (void)buddy; return false; }
SFS3_String SFS3_Buddy_getNickName(SFS3_Buddy* buddy) { (void)buddy; return SFS3_String_create(nullptr); }
SFS3_String SFS3_Buddy_getState(SFS3_Buddy* buddy) { (void)buddy; return SFS3_String_create(nullptr); }

/* ── Logging ────────────────────────────────────────────────────────────── */

void SFS3_setLogLevel(SFS3_LogLevel level) {
    /* Map to Haxe Logger.setLevel — uses Dynamic field access */
    int hxLevel = level; /* same numeric mapping */
    com::smartfoxserver::v3::core::Logger_obj::setLevel(hxLevel);
}
