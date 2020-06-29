@ECHO OFF
SET BINDIR=%~dp0
CD /D "%BINDIR%"
:Start
cls
d:\Qt\Projects\build-CheckQRServer-Desktop_Qt_5_15_0_MinGW_32_bit-Release\release\CheckQRServer.exe -e
cls
goto Start