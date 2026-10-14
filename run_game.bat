@echo off
title VECTOR//BREAK Launcher
echo Launching VECTOR//BREAK: The Last Trajectory...

set "GODOT_EXE="
if exist "C:\Users\Radhashree\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe" set "GODOT_EXE=C:\Users\Radhashree\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe"
if exist "C:\Users\dalia\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe" set "GODOT_EXE=C:\Users\dalia\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe"

if "%GODOT_EXE%"=="" (
    where godot >nul 2>&1
    if %errorlevel% equ 0 (
        start "" godot --path "%~dp0"
        exit /b 0
    )
    echo Godot 4.7.2 executable not found in default download paths or PATH.
    pause
    exit /b 1
)

start "" "%GODOT_EXE%" --path "%~dp0"
