/*
 * SFS3 API — Native C++ API
 *
 * Public header for the SmartFoxServer 3 client library.
 * Link against SFS3_API.lib (or .a) — built via cpp/build_lib.bat.
 *
 * All SFS3_String values are ref-counted and auto-managed.
 * Opaque handle types (SmartFox, ConfigData, SFSObject, etc.) require
 * explicit release via the corresponding SFS3_release* function.
 *
 * Thread safety: call SFS3_init() and SFS3_dispose() from the main thread.
 * Use SFS3_update() from the main loop to flush pending event callbacks.
 * Register additional threads with SFS3_registerThread() before calling
 * any SFS3 function from them.
 */

#ifndef SFS3_API_H
#define SFS3_API_H

#include <stddef.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/* ── Visibility ─────────────────────────────────────────────────────────── */
/*
 * Static linking is the default. Define SFS3_SHARED when building or
 * consuming a shared library (.dll / .so / .dylib).
 */

#if defined(SFS3_SHARED)
  #if defined(_WIN32) || defined(__CYGWIN__)
    #ifdef BUILDING_SFS3_API
      #define SFS3_PUBLIC __declspec(dllexport)
    #else
      #define SFS3_PUBLIC __declspec(dllimport)
    #endif
  #elif defined(__GNUC__) && __GNUC__ >= 4
    #define SFS3_PUBLIC __attribute__((visibility("default")))
  #else
    #define SFS3_PUBLIC
  #endif
#else
  #define SFS3_PUBLIC
#endif
#define SFS3_HIDDEN

/* ── SFS3_String (ref-counted) ──────────────────────────────────────────── */

typedef struct SFS3_StringData SFS3_StringData;

typedef struct SFS3_String {
    SFS3_StringData* ptr;
} SFS3_String;

SFS3_PUBLIC SFS3_String  SFS3_String_create(const char* s);
SFS3_PUBLIC SFS3_String  SFS3_String_createLen(const char* s, size_t len);
SFS3_PUBLIC SFS3_String  SFS3_String_copy(SFS3_String other);
SFS3_PUBLIC void         SFS3_String_release(SFS3_String* s);
SFS3_PUBLIC const char*  SFS3_String_cstr(SFS3_String s);
SFS3_PUBLIC size_t       SFS3_String_length(SFS3_String s);
SFS3_PUBLIC bool         SFS3_String_isNull(SFS3_String s);

/* ── Opaque handle types ────────────────────────────────────────────────── */

typedef struct SFS3_SmartFox     SFS3_SmartFox;
typedef struct SFS3_ConfigData   SFS3_ConfigData;
typedef struct SFS3_Event        SFS3_Event;
typedef struct SFS3_User         SFS3_User;
typedef struct SFS3_Room         SFS3_Room;
typedef struct SFS3_Buddy        SFS3_Buddy;
typedef struct SFS3_SFSObject    SFS3_SFSObject;
typedef struct SFS3_SFSArray     SFS3_SFSArray;

/* ── Value type (tagged union for event params / variables) ─────────────── */

typedef enum SFS3_ValueType {
    SFS3_Null = 0,
    SFS3_Int,
    SFS3_Float,
    SFS3_Bool,
    SFS3_StringVal,
    SFS3_UserVal,
    SFS3_RoomVal,
    SFS3_ObjectVal
} SFS3_ValueType;

typedef struct SFS3_Value {
    SFS3_ValueType type;
    union {
        int         intValue;
        double      floatValue;
        bool        boolValue;
    };
    SFS3_String     stringValue;
    SFS3_User*      userValue;
    SFS3_Room*      roomValue;
    SFS3_SFSObject* objectValue;
} SFS3_Value;

SFS3_PUBLIC SFS3_Value SFS3_Value_null(void);
SFS3_PUBLIC SFS3_Value SFS3_Value_fromInt(int v);
SFS3_PUBLIC SFS3_Value SFS3_Value_fromFloat(double v);
SFS3_PUBLIC SFS3_Value SFS3_Value_fromBool(bool v);
SFS3_PUBLIC SFS3_Value SFS3_Value_fromString(SFS3_String v);

/* ── Lifecycle (hxcpp runtime) ──────────────────────────────────────────── */

/*
 * Initialize the hxcpp garbage collector and boot all generated types.
 * Must be called once from the main thread before any other SFS3 call.
 */
SFS3_PUBLIC void SFS3_init(void);

/*
 * Shut down the hxcpp runtime and release all resources.
 * After this call no SFS3 function may be used.
 */
SFS3_PUBLIC void SFS3_dispose(void);

/*
 * Trigger a GC collection cycle. Optional — hxcpp manages this internally,
 * but can be called to reduce memory between heavy operations.
 */
SFS3_PUBLIC void SFS3_gc(void);

/*
 * Flush pending event callbacks. Call from the host's main loop at a
 * regular interval (e.g. 30-60 Hz). Events registered via
 * SFS3_addEventListener are dispatched on this call.
 */
SFS3_PUBLIC void SFS3_update(double deltaSec);

/*
 * Register the calling thread with the hxcpp GC so it can safely
 * interact with SFS3 handles. Must be called once per non-main thread.
 */
SFS3_PUBLIC void SFS3_registerThread(void);

/* ── ConfigData ─────────────────────────────────────────────────────────── */

SFS3_PUBLIC SFS3_ConfigData* SFS3_ConfigData_create(void);
SFS3_PUBLIC void SFS3_ConfigData_release(SFS3_ConfigData* cfg);

SFS3_PUBLIC void SFS3_ConfigData_setHost(SFS3_ConfigData* cfg, const char* host);
SFS3_PUBLIC void SFS3_ConfigData_setPort(SFS3_ConfigData* cfg, int port);
SFS3_PUBLIC void SFS3_ConfigData_setUdpPort(SFS3_ConfigData* cfg, int port);
SFS3_PUBLIC void SFS3_ConfigData_setHttpPort(SFS3_ConfigData* cfg, int port);
SFS3_PUBLIC void SFS3_ConfigData_setHttpsPort(SFS3_ConfigData* cfg, int port);
SFS3_PUBLIC void SFS3_ConfigData_setZone(SFS3_ConfigData* cfg, const char* zone);
SFS3_PUBLIC void SFS3_ConfigData_setUseSSL(SFS3_ConfigData* cfg, bool useSSL);
SFS3_PUBLIC void SFS3_ConfigData_setUseWebSocket(SFS3_ConfigData* cfg, bool useWS);
SFS3_PUBLIC void SFS3_ConfigData_setUseTcpFallback(SFS3_ConfigData* cfg, bool fallback);
SFS3_PUBLIC void SFS3_ConfigData_setUseTcpNoDelay(SFS3_ConfigData* cfg, bool noDelay);
SFS3_PUBLIC void SFS3_ConfigData_setTcpConnectionTimeout(SFS3_ConfigData* cfg, int ms);
SFS3_PUBLIC void SFS3_ConfigData_setBlueBoxActive(SFS3_ConfigData* cfg, bool active);

SFS3_PUBLIC const char* SFS3_ConfigData_getHost(SFS3_ConfigData* cfg);
SFS3_PUBLIC int         SFS3_ConfigData_getPort(SFS3_ConfigData* cfg);
SFS3_PUBLIC const char* SFS3_ConfigData_getZone(SFS3_ConfigData* cfg);

/* ── SmartFox (main client) ─────────────────────────────────────────────── */

SFS3_PUBLIC SFS3_SmartFox* SFS3_SmartFox_create(void);
SFS3_PUBLIC void           SFS3_SmartFox_release(SFS3_SmartFox* sfs);

/* Connection */
SFS3_PUBLIC void SFS3_connect(SFS3_SmartFox* sfs, SFS3_ConfigData* cfg);
SFS3_PUBLIC void SFS3_disconnect(SFS3_SmartFox* sfs);
SFS3_PUBLIC bool SFS3_isConnected(SFS3_SmartFox* sfs);
SFS3_PUBLIC void SFS3_killConnection(SFS3_SmartFox* sfs);

/* UDP */
SFS3_PUBLIC void SFS3_connectUdp(SFS3_SmartFox* sfs);
SFS3_PUBLIC void SFS3_disconnectUdp(SFS3_SmartFox* sfs);
SFS3_PUBLIC bool SFS3_isUdpConnected(SFS3_SmartFox* sfs);

/* Info */
SFS3_PUBLIC SFS3_String SFS3_getVersion(SFS3_SmartFox* sfs);
SFS3_PUBLIC SFS3_String SFS3_getSessionToken(SFS3_SmartFox* sfs);
SFS3_PUBLIC SFS3_String SFS3_getConnectionMode(SFS3_SmartFox* sfs);
SFS3_PUBLIC SFS3_String SFS3_getHttpUploadURI(SFS3_SmartFox* sfs);
SFS3_PUBLIC void        SFS3_setClientDetails(SFS3_SmartFox* sfs, const char* platformId, const char* version);

/* Current user */
SFS3_PUBLIC SFS3_User* SFS3_getMySelf(SFS3_SmartFox* sfs);

/* Lag monitor */
SFS3_PUBLIC void SFS3_enableLagMonitor(SFS3_SmartFox* sfs, bool enabled, int intervalSec, int queueSize);

/* Stop all internal executors (advanced cleanup) */
SFS3_PUBLIC void SFS3_stopExecutors(SFS3_SmartFox* sfs);

/* ── Event callback ─────────────────────────────────────────────────────── */

/*
 * Generic event handler. The SFS3_Event handle is valid only for the
 * duration of the callback; do NOT store it. Extract needed values
 * via SFS3_Event_get* within the callback body.
 */
typedef void (*SFS3_EventHandler)(
    SFS3_SmartFox* sfs,
    SFS3_Event*    event,
    void*          userData
);

SFS3_PUBLIC void SFS3_addEventListener(
    SFS3_SmartFox*   sfs,
    const char*      eventType,
    SFS3_EventHandler handler,
    void*            userData
);

SFS3_PUBLIC void SFS3_removeEventListener(
    SFS3_SmartFox*   sfs,
    const char*      eventType,
    SFS3_EventHandler handler
);

SFS3_PUBLIC void SFS3_removeAllEventListeners(SFS3_SmartFox* sfs);

/* ── Event param access ─────────────────────────────────────────────────── */

SFS3_PUBLIC SFS3_String     SFS3_Event_getType(SFS3_Event* evt);

SFS3_PUBLIC bool            SFS3_Event_getBool(SFS3_Event* evt, const char* key);
SFS3_PUBLIC int             SFS3_Event_getInt(SFS3_Event* evt, const char* key);
SFS3_PUBLIC SFS3_String     SFS3_Event_getString(SFS3_Event* evt, const char* key);
SFS3_PUBLIC SFS3_User*      SFS3_Event_getUser(SFS3_Event* evt, const char* key);
SFS3_PUBLIC SFS3_Room*      SFS3_Event_getRoom(SFS3_Event* evt, const char* key);
SFS3_PUBLIC SFS3_SFSObject* SFS3_Event_getSFSObject(SFS3_Event* evt, const char* key);

/* ── Event type constants ───────────────────────────────────────────────── */

#define SFS3_EVT_CONNECTION               "connection"
#define SFS3_EVT_CONNECTION_LOST          "connectionLost"
#define SFS3_EVT_CONNECTION_RETRY         "connectionRetry"
#define SFS3_EVT_CONNECTION_RESUME        "connectionResume"
#define SFS3_EVT_UDP_CONNECTION           "udpConnection"
#define SFS3_EVT_UDP_CONNECTION_LOST      "udpConnectionLost"
#define SFS3_EVT_LOGIN                    "login"
#define SFS3_EVT_LOGIN_ERROR              "loginError"
#define SFS3_EVT_LOGOUT                   "logout"
#define SFS3_EVT_PING_PONG                "pingPong"
#define SFS3_EVT_ROOM_ADD                 "roomAdd"
#define SFS3_EVT_ROOM_REMOVE              "roomRemove"
#define SFS3_EVT_ROOM_CREATION_ERROR      "roomCreationError"
#define SFS3_EVT_ROOM_JOIN                "roomJoin"
#define SFS3_EVT_ROOM_JOIN_ERROR          "roomJoinError"
#define SFS3_EVT_USER_ENTER_ROOM          "userEnterRoom"
#define SFS3_EVT_USER_EXIT_ROOM           "userExitRoom"
#define SFS3_EVT_USER_COUNT_CHANGE        "userCountChange"
#define SFS3_EVT_PUBLIC_MESSAGE           "publicMessage"
#define SFS3_EVT_PRIVATE_MESSAGE          "privateMessage"
#define SFS3_EVT_OBJECT_MESSAGE           "objectMessage"
#define SFS3_EVT_MODERATOR_MESSAGE        "moderatorMessage"
#define SFS3_EVT_ADMIN_MESSAGE            "adminMessage"
#define SFS3_EVT_EXTENSION_RESPONSE       "extensionResponse"
#define SFS3_EVT_ROOM_VARIABLES_UPDATE    "roomVariablesUpdate"
#define SFS3_EVT_USER_VARIABLES_UPDATE    "userVariablesUpdate"
#define SFS3_EVT_ROOM_GROUP_SUBSCRIBE     "roomGroupSubscribe"
#define SFS3_EVT_ROOM_GROUP_UNSUBSCRIBE   "roomGroupUnsubscribe"
#define SFS3_EVT_INVITATION               "invitation"
#define SFS3_EVT_INVITATION_REPLY         "invitationReply"
#define SFS3_EVT_PROXIMITY_LIST_UPDATE    "proximityListUpdate"

/* ── Event param key constants ──────────────────────────────────────────── */

#define SFS3_PARAM_SUCCESS            "success"
#define SFS3_PARAM_ERROR_MESSAGE      "errorMessage"
#define SFS3_PARAM_ERROR_CODE         "errorCode"
#define SFS3_PARAM_USER               "user"
#define SFS3_PARAM_ROOM               "room"
#define SFS3_PARAM_SENDER             "sender"
#define SFS3_PARAM_MESSAGE            "message"
#define SFS3_PARAM_DATA               "data"
#define SFS3_PARAM_CMD                "cmd"
#define SFS3_PARAM_EXT_PARAMS         "extParams"
#define SFS3_PARAM_DISCONNECTION_REASON "disconnectionReason"
#define SFS3_PARAM_BUDDY              "buddy"
#define SFS3_PARAM_CHANGED_VARS       "changedVars"
#define SFS3_PARAM_GROUP_ID           "groupId"
#define SFS3_PARAM_NEW_ROOMS          "newRooms"

/* ── Requests ───────────────────────────────────────────────────────────── */

SFS3_PUBLIC void SFS3_sendLogin(SFS3_SmartFox* sfs, const char* userName, const char* password, const char* zoneName, SFS3_SFSObject* params);
SFS3_PUBLIC void SFS3_sendLogout(SFS3_SmartFox* sfs);
SFS3_PUBLIC void SFS3_sendJoinRoom(SFS3_SmartFox* sfs, const char* roomName, const char* password, int roomIdToLeave, bool asSpectator);
SFS3_PUBLIC void SFS3_sendJoinRoomById(SFS3_SmartFox* sfs, int roomId, const char* password, int roomIdToLeave, bool asSpectator);
SFS3_PUBLIC void SFS3_sendLeaveRoom(SFS3_SmartFox* sfs, int roomId);
SFS3_PUBLIC void SFS3_sendPublicMessage(SFS3_SmartFox* sfs, const char* message, SFS3_SFSObject* params, int targetRoomId);
SFS3_PUBLIC void SFS3_sendPrivateMessage(SFS3_SmartFox* sfs, const char* message, int recipientId, SFS3_SFSObject* params);
SFS3_PUBLIC void SFS3_sendObjectMessage(SFS3_SmartFox* sfs, SFS3_SFSObject* obj, int targetRoomId, const int* recipientIds, int recipientCount);
SFS3_PUBLIC void SFS3_sendExtensionRequest(SFS3_SmartFox* sfs, const char* extCmd, SFS3_SFSObject* params, int roomId, int txType);
SFS3_PUBLIC void SFS3_sendSubscribeRoomGroup(SFS3_SmartFox* sfs, const char* groupId);
SFS3_PUBLIC void SFS3_sendUnsubscribeRoomGroup(SFS3_SmartFox* sfs, const char* groupId);

/* ── User ───────────────────────────────────────────────────────────────── */

SFS3_PUBLIC int         SFS3_User_getId(SFS3_User* user);
SFS3_PUBLIC SFS3_String SFS3_User_getName(SFS3_User* user);
SFS3_PUBLIC int         SFS3_User_getPlayerId(SFS3_User* user);
SFS3_PUBLIC bool        SFS3_User_isPlayer(SFS3_User* user);
SFS3_PUBLIC bool        SFS3_User_isSpectator(SFS3_User* user);
SFS3_PUBLIC int         SFS3_User_getPrivilegeId(SFS3_User* user);
SFS3_PUBLIC bool        SFS3_User_isGuest(SFS3_User* user);
SFS3_PUBLIC bool        SFS3_User_isStandardUser(SFS3_User* user);
SFS3_PUBLIC bool        SFS3_User_isModerator(SFS3_User* user);
SFS3_PUBLIC bool        SFS3_User_isAdmin(SFS3_User* user);
SFS3_PUBLIC bool        SFS3_User_isItMe(SFS3_User* user);

/* ── Room ───────────────────────────────────────────────────────────────── */

SFS3_PUBLIC int         SFS3_Room_getId(SFS3_Room* room);
SFS3_PUBLIC SFS3_String SFS3_Room_getName(SFS3_Room* room);
SFS3_PUBLIC SFS3_String SFS3_Room_getGroupId(SFS3_Room* room);
SFS3_PUBLIC bool        SFS3_Room_isJoined(SFS3_Room* room);
SFS3_PUBLIC bool        SFS3_Room_isGame(SFS3_Room* room);
SFS3_PUBLIC bool        SFS3_Room_isHidden(SFS3_Room* room);
SFS3_PUBLIC bool        SFS3_Room_isPasswordProtected(SFS3_Room* room);
SFS3_PUBLIC int         SFS3_Room_getUserCount(SFS3_Room* room);
SFS3_PUBLIC int         SFS3_Room_getMaxUsers(SFS3_Room* room);
SFS3_PUBLIC int         SFS3_Room_getSpectatorCount(SFS3_Room* room);
SFS3_PUBLIC int         SFS3_Room_getMaxSpectators(SFS3_Room* room);
SFS3_PUBLIC int         SFS3_Room_getCapacity(SFS3_Room* room);

/*
 * Returns the list of users in a room.
 * Caller must SFS3_User_release() each returned SFS3_User*.
 */
SFS3_PUBLIC int         SFS3_Room_getUserListCount(SFS3_Room* room);
SFS3_PUBLIC SFS3_User*  SFS3_Room_getUserAt(SFS3_Room* room, int index);

/* ── Room lists from SmartFox ──────────────────────────────────────────── */

/*
 * Full room list (all rooms in the zone). Use with SFS3_getRoomAt().
 */
SFS3_PUBLIC int         SFS3_getRoomCount(SFS3_SmartFox* sfs);
SFS3_PUBLIC SFS3_Room*  SFS3_getRoomAt(SFS3_SmartFox* sfs, int index);
SFS3_PUBLIC SFS3_Room*  SFS3_getRoomById(SFS3_SmartFox* sfs, int roomId);
SFS3_PUBLIC SFS3_Room*  SFS3_getRoomByName(SFS3_SmartFox* sfs, const char* name);

/*
 * Joined rooms only.
 */
SFS3_PUBLIC int         SFS3_getJoinedRoomCount(SFS3_SmartFox* sfs);
SFS3_PUBLIC SFS3_Room*  SFS3_getJoinedRoomAt(SFS3_SmartFox* sfs, int index);
SFS3_PUBLIC SFS3_Room*  SFS3_getLastJoinedRoom(SFS3_SmartFox* sfs);

/* ── SFSObject (key-value data) ─────────────────────────────────────────── */

SFS3_PUBLIC SFS3_SFSObject* SFS3_SFSObject_create(void);
SFS3_PUBLIC void            SFS3_SFSObject_release(SFS3_SFSObject* obj);

SFS3_PUBLIC bool        SFS3_SFSObject_containsKey(SFS3_SFSObject* obj, const char* key);
SFS3_PUBLIC int         SFS3_SFSObject_size(SFS3_SFSObject* obj);
SFS3_PUBLIC bool        SFS3_SFSObject_isNull(SFS3_SFSObject* obj, const char* key);

SFS3_PUBLIC void        SFS3_SFSObject_putBool(SFS3_SFSObject* obj, const char* key, bool value);
SFS3_PUBLIC void        SFS3_SFSObject_putByte(SFS3_SFSObject* obj, const char* key, int value);
SFS3_PUBLIC void        SFS3_SFSObject_putShort(SFS3_SFSObject* obj, const char* key, int value);
SFS3_PUBLIC void        SFS3_SFSObject_putInt(SFS3_SFSObject* obj, const char* key, int value);
SFS3_PUBLIC void        SFS3_SFSObject_putLong(SFS3_SFSObject* obj, const char* key, long long value);
SFS3_PUBLIC void        SFS3_SFSObject_putFloat(SFS3_SFSObject* obj, const char* key, float value);
SFS3_PUBLIC void        SFS3_SFSObject_putDouble(SFS3_SFSObject* obj, const char* key, double value);
SFS3_PUBLIC void        SFS3_SFSObject_putString(SFS3_SFSObject* obj, const char* key, const char* value);
SFS3_PUBLIC void        SFS3_SFSObject_putSFSObject(SFS3_SFSObject* obj, const char* key, SFS3_SFSObject* value);
SFS3_PUBLIC void        SFS3_SFSObject_putSFSArray(SFS3_SFSObject* obj, const char* key, SFS3_SFSArray* value);

SFS3_PUBLIC bool        SFS3_SFSObject_getBool(SFS3_SFSObject* obj, const char* key);
SFS3_PUBLIC int         SFS3_SFSObject_getByte(SFS3_SFSObject* obj, const char* key);
SFS3_PUBLIC int         SFS3_SFSObject_getShort(SFS3_SFSObject* obj, const char* key);
SFS3_PUBLIC int         SFS3_SFSObject_getInt(SFS3_SFSObject* obj, const char* key);
SFS3_PUBLIC long long   SFS3_SFSObject_getLong(SFS3_SFSObject* obj, const char* key);
SFS3_PUBLIC float       SFS3_SFSObject_getFloat(SFS3_SFSObject* obj, const char* key);
SFS3_PUBLIC double      SFS3_SFSObject_getDouble(SFS3_SFSObject* obj, const char* key);
SFS3_PUBLIC SFS3_String SFS3_SFSObject_getString(SFS3_SFSObject* obj, const char* key);
SFS3_PUBLIC SFS3_SFSObject* SFS3_SFSObject_getSFSObject(SFS3_SFSObject* obj, const char* key);
SFS3_PUBLIC SFS3_SFSArray*  SFS3_SFSObject_getSFSArray(SFS3_SFSObject* obj, const char* key);

SFS3_PUBLIC SFS3_String SFS3_SFSObject_toJson(SFS3_SFSObject* obj);
SFS3_PUBLIC SFS3_String SFS3_SFSObject_getDump(SFS3_SFSObject* obj);

/* ── SFSArray (ordered data) ────────────────────────────────────────────── */

SFS3_PUBLIC SFS3_SFSArray* SFS3_SFSArray_create(void);
SFS3_PUBLIC void           SFS3_SFSArray_release(SFS3_SFSArray* arr);
SFS3_PUBLIC int            SFS3_SFSArray_size(SFS3_SFSArray* arr);

SFS3_PUBLIC void        SFS3_SFSArray_addBool(SFS3_SFSArray* arr, bool value);
SFS3_PUBLIC void        SFS3_SFSArray_addByte(SFS3_SFSArray* arr, int value);
SFS3_PUBLIC void        SFS3_SFSArray_addShort(SFS3_SFSArray* arr, int value);
SFS3_PUBLIC void        SFS3_SFSArray_addInt(SFS3_SFSArray* arr, int value);
SFS3_PUBLIC void        SFS3_SFSArray_addLong(SFS3_SFSArray* arr, long long value);
SFS3_PUBLIC void        SFS3_SFSArray_addFloat(SFS3_SFSArray* arr, float value);
SFS3_PUBLIC void        SFS3_SFSArray_addDouble(SFS3_SFSArray* arr, double value);
SFS3_PUBLIC void        SFS3_SFSArray_addString(SFS3_SFSArray* arr, const char* value);
SFS3_PUBLIC void        SFS3_SFSArray_addSFSObject(SFS3_SFSArray* arr, SFS3_SFSObject* value);
SFS3_PUBLIC void        SFS3_SFSArray_addSFSArray(SFS3_SFSArray* arr, SFS3_SFSArray* value);

SFS3_PUBLIC bool        SFS3_SFSArray_getBool(SFS3_SFSArray* arr, int index);
SFS3_PUBLIC int         SFS3_SFSArray_getByte(SFS3_SFSArray* arr, int index);
SFS3_PUBLIC int         SFS3_SFSArray_getShort(SFS3_SFSArray* arr, int index);
SFS3_PUBLIC int         SFS3_SFSArray_getInt(SFS3_SFSArray* arr, int index);
SFS3_PUBLIC long long   SFS3_SFSArray_getLong(SFS3_SFSArray* arr, int index);
SFS3_PUBLIC float       SFS3_SFSArray_getFloat(SFS3_SFSArray* arr, int index);
SFS3_PUBLIC double      SFS3_SFSArray_getDouble(SFS3_SFSArray* arr, int index);
SFS3_PUBLIC SFS3_String SFS3_SFSArray_getString(SFS3_SFSArray* arr, int index);
SFS3_PUBLIC SFS3_SFSObject* SFS3_SFSArray_getSFSObject(SFS3_SFSArray* arr, int index);
SFS3_PUBLIC SFS3_SFSArray*  SFS3_SFSArray_getSFSArray(SFS3_SFSArray* arr, int index);

SFS3_PUBLIC SFS3_String SFS3_SFSArray_toJson(SFS3_SFSArray* arr);
SFS3_PUBLIC SFS3_String SFS3_SFSArray_getDump(SFS3_SFSArray* arr);

/* ── User Variables ─────────────────────────────────────────────────────── */

/*
 * Set user variables. vars is an array of {name, value} pairs encoded as
 * an SFSObject where each key is the variable name and the value is typed.
 * For more complex variable types, use the hxcpp-generated classes directly.
 */
SFS3_PUBLIC void SFS3_sendSetUserVariables(SFS3_SmartFox* sfs, SFS3_SFSObject* vars);

/* ── Room Variables ─────────────────────────────────────────────────────── */

SFS3_PUBLIC void SFS3_sendSetRoomVariables(SFS3_SmartFox* sfs, SFS3_SFSObject* vars, int roomId);
SFS3_PUBLIC void SFS3_sendSetRoomVariable_string(SFS3_SmartFox* sfs, const char* name, const char* value, int roomId);
SFS3_PUBLIC SFS3_String SFS3_Room_getVariable_string(SFS3_Room* room, const char* name);

/* ── Buddy requests ─────────────────────────────────────────────────────── */

SFS3_PUBLIC void SFS3_sendInitBuddyList(SFS3_SmartFox* sfs);
SFS3_PUBLIC void SFS3_sendAddBuddy(SFS3_SmartFox* sfs, const char* buddyName);
SFS3_PUBLIC void SFS3_sendRemoveBuddy(SFS3_SmartFox* sfs, const char* buddyName);
SFS3_PUBLIC void SFS3_sendBlockBuddy(SFS3_SmartFox* sfs, const char* buddyName, bool blocked);
SFS3_PUBLIC void SFS3_sendGoOnline(SFS3_SmartFox* sfs, bool online);
SFS3_PUBLIC void SFS3_sendBuddyMessage(SFS3_SmartFox* sfs, const char* message, int buddyId, SFS3_SFSObject* params);

/* ── Buddy access ───────────────────────────────────────────────────────── */

SFS3_PUBLIC int         SFS3_Buddy_getId(SFS3_Buddy* buddy);
SFS3_PUBLIC SFS3_String SFS3_Buddy_getName(SFS3_Buddy* buddy);
SFS3_PUBLIC bool        SFS3_Buddy_isBlocked(SFS3_Buddy* buddy);
SFS3_PUBLIC bool        SFS3_Buddy_isOnline(SFS3_Buddy* buddy);
SFS3_PUBLIC SFS3_String SFS3_Buddy_getNickName(SFS3_Buddy* buddy);
SFS3_PUBLIC SFS3_String SFS3_Buddy_getState(SFS3_Buddy* buddy);

/* ── Invitation requests ────────────────────────────────────────────────── */

typedef enum SFS3_InvitationReply {
    SFS3_INVITATION_ACCEPT  = 0,
    SFS3_INVITATION_REFUSE  = 1,
    SFS3_INVITATION_EXPIRED = 255
} SFS3_InvitationReply;

SFS3_PUBLIC void SFS3_sendInviteUsers(SFS3_SmartFox* sfs, const int* userIds, int count, int secondsForAnswer, SFS3_SFSObject* params);
SFS3_PUBLIC void SFS3_sendInvitationReply(SFS3_SmartFox* sfs, int invitationId, SFS3_InvitationReply reply, SFS3_SFSObject* params);

/* ── Game requests ──────────────────────────────────────────────────────── */

SFS3_PUBLIC void SFS3_sendKickUser(SFS3_SmartFox* sfs, int userId, const char* message, int delaySeconds);
SFS3_PUBLIC void SFS3_sendBanUser(SFS3_SmartFox* sfs, int userId, const char* message, int banMode, int delaySeconds, int durationHours);
SFS3_PUBLIC void SFS3_sendSpectatorToPlayer(SFS3_SmartFox* sfs, int roomId);
SFS3_PUBLIC void SFS3_sendPlayerToSpectator(SFS3_SmartFox* sfs, int roomId);

/* ── Transport type constants (for extension requests) ──────────────────── */

#define SFS3_TX_TCP             0
#define SFS3_TX_UDP_RELIABLE    1
#define SFS3_TX_UDP_UNRELIABLE  2

/* ── Logging ────────────────────────────────────────────────────────────── */

typedef enum SFS3_LogLevel {
    SFS3_LOG_DEBUG = 0,
    SFS3_LOG_INFO,
    SFS3_LOG_WARN,
    SFS3_LOG_ERROR,
    SFS3_LOG_OFF
} SFS3_LogLevel;

SFS3_PUBLIC void SFS3_setLogLevel(SFS3_LogLevel level);

#ifdef __cplusplus
}
#endif

#endif /* SFS3_API_H */
