# C++ (hxcpp) integration

## Files

- **`include/SFS3_API.h`** — Public C header. Opaque handles, lifecycle, GC, type conversions, event callbacks, requests.
- **`src/SFS3_API.cpp`** — Implementation that bridges the C API to hxcpp-generated Haxe classes.
- **`build_lib.bat`** — Compiles the bridge and merges it with the hxcpp output into a single static library.

## Building the static library

```cmd
REM 1. Generate hxcpp output (from project root)
haxe build.hxml

REM 2. Build the combined static library (Developer Command Prompt)
cpp\build_lib.bat
```

This produces two files in `out/SFS3_API_CPP/dist/`:

| File | Description |
|------|-------------|
| `SFS3_API.h` | Public C header — the only header consumers need |
| `SFS3_API.lib` | Combined static library (hxcpp runtime + bridge) |

## Usage from a host C++ application

```cpp
#include "SFS3_API.h"
#include <cstdio>

void onConnection(SFS3_SmartFox* sfs, SFS3_Event* evt, void* userData) {
    bool success = SFS3_Event_getBool(evt, SFS3_PARAM_SUCCESS);
    if (success) {
        printf("Connected! Logging in...\n");
        SFS3_sendLogin(sfs, "", "", NULL, NULL);
    } else {
        SFS3_String msg = SFS3_Event_getString(evt, SFS3_PARAM_ERROR_MESSAGE);
        printf("Connection failed: %s\n", SFS3_String_cstr(msg));
        SFS3_String_release(&msg);
    }
}

void onLogin(SFS3_SmartFox* sfs, SFS3_Event* evt, void* userData) {
    SFS3_User* me = SFS3_getMySelf(sfs);
    SFS3_String name = SFS3_User_getName(me);
    printf("Logged in as: %s\n", SFS3_String_cstr(name));
    SFS3_String_release(&name);
}

int main() {
    SFS3_init();

    SFS3_SmartFox* sfs = SFS3_SmartFox_create();
    SFS3_ConfigData* cfg = SFS3_ConfigData_create();
    SFS3_ConfigData_setHost(cfg, "127.0.0.1");
    SFS3_ConfigData_setZone(cfg, "BasicExamples");

    SFS3_addEventListener(sfs, SFS3_EVT_CONNECTION, onConnection, NULL);
    SFS3_addEventListener(sfs, SFS3_EVT_LOGIN, onLogin, NULL);

    SFS3_connect(sfs, cfg);

    while (SFS3_isConnected(sfs)) {
        SFS3_update(1.0 / 60.0);
    }

    SFS3_SmartFox_release(sfs);
    SFS3_ConfigData_release(cfg);
    SFS3_dispose();
    return 0;
}
```

## Compile & Link

### MSVC (Windows)

```cmd
cl /EHsc /std:c++17 app.cpp ^
    /I"out\SFS3_API_CPP\dist" ^
    /link out\SFS3_API_CPP\dist\SFS3_API.lib ^
    ws2_32.lib advapi32.lib crypt32.lib
```

### clang++ / g++ (Linux / macOS)

```bash
# Build the static library first (on Linux/macOS you would use ar to merge)
clang++ -std=c++17 -O2 app.cpp \
    -Iout/SFS3_API_CPP/dist \
    -Lout/SFS3_API_CPP/dist -lSFS3_API \
    -lpthread -lssl -lcrypto -lz
```

## System library dependencies

When linking statically, the final executable needs these system libraries:

| Platform | Libraries |
|----------|-----------|
| Windows  | `ws2_32.lib` `advapi32.lib` `crypt32.lib` |
| Linux    | `-lpthread -lssl -lcrypto -lz` |
| macOS    | `-lpthread -lssl -lcrypto -lz -framework Security` |

## API Summary

| Category | Functions |
|----------|-----------|
| **Lifecycle** | `SFS3_init`, `SFS3_dispose`, `SFS3_gc`, `SFS3_update`, `SFS3_registerThread` |
| **String** | `SFS3_String_create/release/cstr/length/isNull` (ref-counted) |
| **Value** | `SFS3_Value_null/fromInt/fromFloat/fromBool/fromString` (tagged union) |
| **ConfigData** | `create/release`, setters for host/port/zone/SSL/WebSocket/etc. |
| **SmartFox** | `create/release`, `connect/disconnect/isConnected/killConnection` |
| **UDP** | `connectUdp/disconnectUdp/isUdpConnected` |
| **Events** | `addEventListener/removeEventListener/removeAllEventListeners` |
| **Event access** | `Event_getType/getBool/getInt/getString/getUser/getRoom/getSFSObject` |
| **Requests** | `sendLogin/Logout/JoinRoom/LeaveRoom/PublicMessage/PrivateMessage/ExtensionRequest/...` |
| **User** | `getId/getName/getPlayerId/isPlayer/isSpectator/isGuest/isAdmin/isItMe` |
| **Room** | `getId/getName/getGroupId/isJoined/isGame/getUserCount/getMaxUsers/...` |
| **SFSObject** | `create/release`, `put*/get*` for all SFS data types, `toJson/getDump` |
| **SFSArray** | `create/release`, `add*/get*` for all SFS data types, `toJson/getDump` |
| **Logging** | `SFS3_setLogLevel` |
