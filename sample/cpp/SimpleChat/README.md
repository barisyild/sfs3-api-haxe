# SFS3 C++ SimpleChat GUI

Cross-platform GUI chat client using **Dear ImGui** + **GLFW** + **OpenGL 3**.
Mirrors the Python/Tkinter SimpleChat layout.

## Prerequisites

1. **CMake** 3.20+ installed and in PATH
2. **SFS3 static library** built:
   ```cmd
   haxe build.hxml
   cpp\build_lib.bat          REM  (Developer Command Prompt)
   ```
   This produces `out/SFS3_API_CPP/dist/SFS3_API.h` + `SFS3_API.lib`.

3. A C++ compiler (MSVC / clang++ / g++) with C++17 support.

Dear ImGui and GLFW are downloaded automatically by CMake — no manual install needed.

## Build (Windows / MSVC)

```cmd
cd sample\cpp\SimpleChatGUI
cmake -B build -G "Visual Studio 17 2022"
cmake --build build --config Release
```

Run: `build\Release\SimpleChatGUI.exe`

## Build (Linux)

```bash
sudo apt install libgl-dev libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev   # if needed
cd sample/cpp/SimpleChatGUI
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build
```

Run: `./build/SimpleChatGUI`

## Build (macOS)

```bash
cd sample/cpp/SimpleChatGUI
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build
```

Run: `./build/SimpleChatGUI`

## Features

- Connect / Disconnect (TCP or WebSocket)
- Login / Logout with username
- Room list with join-on-click
- User list for current room
- Public chat messages
- Chat topic (local, room variable support pending)
- Enter key sends message
- Orange accent matching the SFS3 example style
