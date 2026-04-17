![GitHub stars](https://img.shields.io/github/stars/barisyild/sfs3-api-haxe)
![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)
![GitHub release](https://img.shields.io/github/v/release/barisyild/sfs3-api-haxe)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/barisyild/sfs3-api-haxe)

# SFS3 API Haxe

SmartFoxServer 3 client API written in Haxe, cross-compiled to multiple targets.

## Build

```bash
haxe build.hxml
```

## Output

| File | Target |
|------|--------|
| `out/SFS3_API_PY.py` | Python |
| `out/SFS3_API_AS3.swc` | ActionScript 3 (Flash/AIR) |
| `out/SFS3_API_JS.js` | Browser JavaScript |
| `out/SFS3_API_Node.js` | Node.js |
| `out/SFS3_API_CPP/` | C++ (hxcpp — native sources + `output.exe` stub) |

## C++ (hxcpp)

Requires **`hxcpp`** (`haxelib install hxcpp`) and a C++ toolchain (e.g. **Visual Studio** on Windows, **clang++/g++** on macOS/Linux).

**Public C API:** [`cpp/include/SFS3_API.h`](cpp/include/SFS3_API.h) + [`cpp/src/SFS3_API.cpp`](cpp/src/SFS3_API.cpp) — a [Loreline-style](https://github.com/jeremyfa/loreline/blob/main/cpp/include/Loreline.h) C wrapper with:
- **Lifecycle**: `SFS3_init/dispose/gc/update/registerThread` (hxcpp GC management)
- **Opaque handles**: `SFS3_SmartFox*`, `SFS3_ConfigData*`, `SFS3_SFSObject*`, `SFS3_User*`, `SFS3_Room*`
- **Type conversions**: `SFS3_String` (ref-counted), `SFS3_Value` (tagged union)
- **Event callbacks**: `SFS3_addEventListener` with C function pointers + userData
- **Requests**: `SFS3_sendLogin/Logout/JoinRoom/PublicMessage/ExtensionRequest/...`
- **Data access**: `SFS3_SFSObject_putInt/getString/...`, `SFS3_SFSArray_add*/get*`

See [`cpp/README.md`](cpp/README.md) for full usage example and compile/link instructions.

## Protocol Support

| Target | TCP | UDP | WebSocket |
|--------|-----|-----|-----------|
| Python | YES | NO | YES |
| AS3 (Flash/AIR) | YES | YES | YES |
| Browser JS | NO | NO | YES |
| Node.js | YES | YES | YES |
| C++ (hxcpp) | YES | YES | YES |

## Flash/AIR (SWC + mxmlc)

When linking `SFS3_API_AS3.swc` with **mxmlc**, use **`-include-libraries+=...`** (not `-library-path`).  
`-library-path` only pulls symbols reachable from your main class; the Haxe runtime and SFS3 API use indirect references, so many SWC types would be missing at runtime.

See `sample/as3/SimpleChat/build.bat`.

## Sample

`out/SimpleChat.py` — Tkinter chat client for testing against a SmartFoxServer 3 instance.

```bash
pip install -r sample/python/requirements.txt
python out/SimpleChat.py
```
