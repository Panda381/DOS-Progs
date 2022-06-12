@echo off
rem -------------------------------------------------
rem    Vynulov n¡ p©¡padn˜ch neplatn˜ch parametr–
rem -------------------------------------------------
set XHOME=
set XDISK=
set XPATH=
set XFILE=

if not "%XEXEC%"=="" goto Znovu
C:\AKTDAT.COM > NUL
C:\SYSTEM\KLAVESN\setlock cn > NUL
%0\..\iconmenu.exe -* +@
goto Znovu2

rem -------------------------------------------------
rem       Volba operace pomoc¡ ikonov‚ho menu
rem -------------------------------------------------
:Znovu
if not "%XHOME%"=="" %XHOME%:
if not "%XPATH%"=="" cd%XPATH%.
C:\AKTDAT.COM > NUL
C:\SYSTEM\KLAVESN\setlock cn > NUL
%XEXEC%iconmenu.exe -* +@
:Znovu2
if errorlevel 254 goto Chyba
if errorlevel 250 goto Konec
if errorlevel 1 goto Znovu

rem -------------------------------------------------
rem      Start zvolen‚ho programu nebo podmenu
rem -------------------------------------------------
:Start
C:\SYSTEM\KLAVESN\setlock cn > NUL
C:\AKTDAT.COM > NUL
if not exist %XFILE%.BAT goto NeniBAT
call %XFILE%.BAT
goto Znovu

:NeniBAT
if not exist %XFILE%.COM goto NeniCOM
%XFILE%.COM
goto Znovu

:NeniCOM
if not exist %XFILE%.EXE goto NeniEXE
%XFILE%.EXE
goto Znovu

:NeniEXE
call %XEXEC%menu.bat %XHOME% %XDISK% %XPATH% %XFILE%
goto Znovu

rem -------------------------------------------------
rem   Konec, navr cen¡ parametr– p©i extern¡m vol n¡
rem -------------------------------------------------
:Chyba
pause

:Konec
set XHOME=%1
set XDISK=%2
set XPATH=%3
set XFILE=%4
