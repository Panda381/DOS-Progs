@echo off
preview.exe

rem --------- Test korektnosti prostredi --------
if not exist WAIT.COM goto Konec
if not exist LOGO.SYS goto Konec
if not exist LOGOW.SYS goto Konec
if not exist LOGOS.SYS goto Konec
if not exist LOCK0.COM goto Konec
if not exist LOCK1.COM goto Konec
if "%WINDIR%" == "" goto Konec
if not exist %WINDIR%\LOGO?.SY? goto Konec

rem ---------- Provedeni instalace --------------
if exist %WINDIR%\LOGOW.SY$ goto JeInst
cls
echo Chcete nainstalovat LOGO pro WINDOWS 95 ?
echo.
echo Stiskem libovolne klavesy LOGO nainstalujete,
echo stiskem klavesy ESC operaci prerusite:
wait.com " "
if errorlevel 1 goto Konec

if exist C:\LOGO.SYS LOCK0.COM C:\LOGO.SYS
if exist C:\LOGO.SYS ren C:\LOGO.SYS LOGO.SY$
if exist C:\LOGO.SY$ LOCK1.COM C:\LOGO.SY$
if not exist %WINDIR%\LOGOW.SY$ ren %WINDIR%\LOGOW.SYS LOGOW.SY$
if not exist %WINDIR%\LOGOS.SY$ ren %WINDIR%\LOGOS.SYS LOGOS.SY$
copy LOGO.SYS C:\LOGO.SYS > NUL
LOCK1.COM C:\LOGO.SYS
copy LOGOW.SYS %WINDIR%\LOGOW.SYS > NUL
copy LOGOS.SYS %WINDIR%\LOGOS.SYS > NUL
cls
echo LOGO pro WINDOWS 95 bylo nainstalovano.
echo Muzete je vyzkouset ukoncenim WINDOWS.
echo.
pause
goto Konec

:JeInst
rem -------- Provedeni odinstalovani ------------
cls
echo Chcete navratit puvodni LOGO WINDOWS 95 ?
echo.
echo Stiskem libovolne klavesy navratite puvodni LOGO,
echo stiskem klavesy ESC operaci prerusite:
wait.com " "
if errorlevel 1 goto Konec

if exist C:\LOGO.SYS LOCK0.COM C:\LOGO.SYS
if exist C:\LOGO.SYS del C:\LOGO.SYS
if exist C:\LOGO.SY$ LOCK0.COM C:\LOGO.SY$
if exist C:\LOGO.SY$ ren C:\LOGO.SY$ LOGO.SYS
if exist C:\LOGO.SYS LOCK1.COM C:\LOGO.SYS
if exist %WINDIR%\LOGOW.SYS del %WINDIR%\LOGOW.SYS
ren %WINDIR%\LOGOW.SY$ LOGOW.SYS
if not exist %WINDIR%\LOGOS.SY$ goto Konec1
if exist %WINDIR%\LOGOS.SYS del %WINDIR%\LOGOS.SYS
ren %WINDIR%\LOGOS.SY$ LOGOS.SYS
:Konec1
cls
echo Puvodni LOGO WINDOWS 95 bylo navraceno.
echo.
pause

:Konec
