cmake_minimum_required(VERSION 3.20)
project(SimpleChatGUI LANGUAGES C CXX)
set(CMAKE_CXX_STANDARD 17)

# SFS3_API.lib is always built with /MT (static release CRT).
# Every target — including Debug — must use /MT to avoid LNK2038.
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded" CACHE STRING "" FORCE)

# ── SFS3 pre-built static library ────────────────────────────────────
set(SFS3_DIST "${CMAKE_CURRENT_SOURCE_DIR}/../../../out/SFS3_API_CPP/dist"
    CACHE PATH "Path to SFS3_API.h + SFS3_API.lib")

if(NOT EXISTS "${SFS3_DIST}/SFS3_API.h")
    message(FATAL_ERROR
        "SFS3_API.h not found in ${SFS3_DIST}.\n"
        "Build steps:\n"
        "  1. haxe build.hxml\n"
        "  2. cpp\\build_lib.bat  (Developer Command Prompt)")
endif()

add_library(SFS3 STATIC IMPORTED GLOBAL)
if(WIN32)
    set_target_properties(SFS3 PROPERTIES IMPORTED_LOCATION "${SFS3_DIST}/SFS3_API.lib")
else()
    set_target_properties(SFS3 PROPERTIES IMPORTED_LOCATION "${SFS3_DIST}/libSFS3_API.a")
endif()
set_target_properties(SFS3 PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${SFS3_DIST}")

# ── Dear ImGui (fetched automatically) ───────────────────────────────
include(FetchContent)

FetchContent_Declare(imgui
    GIT_REPOSITORY https://github.com/ocornut/imgui.git
    GIT_TAG        v1.91.8
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(imgui)

add_library(dear_imgui STATIC
    ${imgui_SOURCE_DIR}/imgui.cpp
    ${imgui_SOURCE_DIR}/imgui_draw.cpp
    ${imgui_SOURCE_DIR}/imgui_tables.cpp
    ${imgui_SOURCE_DIR}/imgui_widgets.cpp
    ${imgui_SOURCE_DIR}/backends/imgui_impl_glfw.cpp
    ${imgui_SOURCE_DIR}/backends/imgui_impl_opengl3.cpp)
target_include_directories(dear_imgui PUBLIC
    ${imgui_SOURCE_DIR}
    ${imgui_SOURCE_DIR}/backends)

# ── GLFW (fetched automatically) ─────────────────────────────────────
set(GLFW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_TESTS    OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_DOCS     OFF CACHE BOOL "" FORCE)
set(GLFW_INSTALL        OFF CACHE BOOL "" FORCE)

FetchContent_Declare(glfw
    GIT_REPOSITORY https://github.com/glfw/glfw.git
    GIT_TAG        3.4
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(glfw)

target_link_libraries(dear_imgui PUBLIC glfw)
if(WIN32)
    target_link_libraries(dear_imgui PUBLIC opengl32)
else()
    find_package(OpenGL REQUIRED)
    target_link_libraries(dear_imgui PUBLIC OpenGL::GL)
endif()

# ── SimpleChatGUI executable ─────────────────────────────────────────
add_executable(SimpleChatGUI SimpleChatGUI.cpp)
target_link_libraries(SimpleChatGUI PRIVATE dear_imgui SFS3)

if(WIN32)
    target_link_libraries(SimpleChatGUI PRIVATE ws2_32 advapi32 crypt32 user32)
    # Debug: keep console window open for stdout/stderr; Release: hide it
    set_target_properties(SimpleChatGUI PROPERTIES
        WIN32_EXECUTABLE $<NOT:$<CONFIG:Debug>>)
    target_link_options(SimpleChatGUI PRIVATE
        $<$<NOT:$<CONFIG:Debug>>:/ENTRY:mainCRTStartup>)
elseif(APPLE)
    target_link_libraries(SimpleChatGUI PRIVATE pthread "-framework Security")
else()
    target_link_libraries(SimpleChatGUI PRIVATE pthread ssl crypto z)
endif()
