@echo off
setlocal enabledelayedexpansion
REM ============================================================
REM  TransportValidator AS3 — Build & Run
REM
REM  Usage:
REM    build_validator.bat                   (uses PATH)
REM    build_validator.bat "C:\AIR_SDK"      (explicit SDK path)
REM ============================================================

set MXMLC=mxmlc
set ADL=adl

if not "%~1"=="" (
    set "MXMLC=%~1\bin\mxmlc"
    set "ADL=%~1\bin\adl"
)

echo Compiling TransportValidator.as ...
"!MXMLC!" TransportValidator.as -include-libraries+=SFS3_API_AS3.swc -output TransportValidator.swf -advanced-telemetry
if !errorlevel! neq 0 (
    echo.
    echo Compilation failed. Make sure AIR SDK is installed.
    pause
    exit /b !errorlevel!
)

echo Running with ADL ...
"!ADL!" TransportValidator-app.xml
