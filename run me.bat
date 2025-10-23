@echo off
title Get Device Info
echo Running PowerShell script...

pushd "%~dp0"
PowerShell -NoProfile -ExecutionPolicy Bypass -File "%~dp0get-device-info.ps1"
popd

echo.
echo Script complete. Closing in 3 seconds...
timeout /t 3

exit
