@echo off
title ActivityTrack Agent Setup
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
if errorlevel 1 (
  echo.
  echo Setup failed. Read the error above.
  pause
)
