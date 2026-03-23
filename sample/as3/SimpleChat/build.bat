@echo off
setlocal enabledelayedexpansion
REM ============================================================
REM  SimpleChat AS3 — Build & Run
REM
REM  Requires Adobe AIR SDK with mxmlc and adl.
REM  Download: https://airsdk.harman.com/download
REM
REM  Usage:
REM    build.bat                         (uses PATH)
REM    build.bat "C:\AIR_SDK"            (explicit SDK path)
REM ============================================================

set MXMLC=mxmlc
set ADL=adl

if not "%~1"=="" (
    set "MXMLC=%~1\bin\mxmlc"
    set "ADL=%~1\bin\adl"
)

echo Compiling SimpleChat.as ...
REM Use -include-libraries (not -library-path) so mxmlc merges the whole SWC.
REM -library-path only links reachable symbols; Haxe/SFS3 uses reflection and
REM indirect types, so many SWC classes would be stripped from SimpleChat.swf.
"!MXMLC!" SimpleChat.as -include-libraries+=SFS3_API_AS3.swc -output SimpleChat.swf
if !errorlevel! neq 0 (
    echo.
    echo Compilation failed. Make sure AIR SDK is installed.
    echo Download from: https://airsdk.harman.com/download
    echo Then run: build.bat "C:\path\to\AIR_SDK"
    pause
    exit /b !errorlevel!
)

echo Running with ADL ...
"!ADL!" SimpleChat-app.xml
