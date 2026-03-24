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

## Protocol Support

| Target | TCP | UDP | WebSocket |
|--------|-----|-----|-----------|
| Python | YES | NO | YES |
| AS3 (Flash/AIR) | YES | YES | YES |
| Browser JS | NO | NO | YES |
| Node.js | YES | YES | YES |

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
