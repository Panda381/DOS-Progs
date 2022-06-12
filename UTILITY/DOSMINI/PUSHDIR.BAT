@echo off
REM ==================================
REM Uschova aktivniho disku a adresare
REM ==================================

%DMIP%\aktdisk > %DMIP%\popdir.tmp
echo :>> %DMIP%\popdir.tmp
copy /b %DMIP%\popdir.tmp + %DMIP%\cd.dat %DMIP%\popdir.bat >nul
del %DMIP%\popdir.tmp
cd >> popdir.bat

copy %DMIP%\setsdir.dat %DMIP%\setsdir.bat >nul
cd >> %DMIP%\setsdir.bat
call %DMIP%\setsdir.bat
del %DMIP%\setsdir.bat
