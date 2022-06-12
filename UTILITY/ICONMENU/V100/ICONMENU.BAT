@echo off
rem -------------------------------------------------
rem    Vynulov n¡ pý¡padnìch neplatnìch parametr…
rem -------------------------------------------------
set XHOME=
set XDISK=
set XPATH=
set XFILE=

if not "%XEXEC%"=="" goto Znovu
%0\..\iconmenu.exe
goto Znovu2

rem -------------------------------------------------
rem       Volba operace pomoc¡ ikonov‚ho menu
rem -------------------------------------------------
:Znovu
if not "%XHOME%"=="" %XHOME%:
if not "%XPATH%"=="" cd%XPATH%.
%XEXEC%iconmenu.exe
:Znovu2
if errorlevel 254 goto Chyba
if errorlevel 250 goto Konec
if errorlevel 100 goto Mezera
if errorlevel 10 goto Setup
if errorlevel 2 goto Znovu
if errorlevel 1 goto Info

rem -------------------------------------------------
rem      Start zvolen‚ho programu nebo podmenu
rem -------------------------------------------------
:Start
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
call %XEXEC%iconmenu.bat %XHOME% %XDISK% %XPATH% %XFILE%
goto Znovu

rem -------------------------------------------------
rem Zobrazen¡ obr zku jako "n hled" (jen EGA a VGA !)
rem -------------------------------------------------
:Mezera
%XEXEC%detcard.com > NUL
if not errorlevel 3 goto Znovu

:Mezera1
if not exist _SCR\%XFILE%.SCR goto Mezera2
%XEXEC%gdemo.com _SCR\%XFILE%.SCR
goto Znovu

:Mezera2
if not exist %XEXEC%_SCR\%XFILE%.SCR goto Mezera3
%XEXEC%gdemo.com %XEXEC%_SCR\%XFILE%.SCR
goto Znovu

:Mezera3
if not exist %XEXEC%..\_SCR\%XFILE%.SCR goto Znovu
%XEXEC%gdemo.com %XEXEC..\_SCR\%XFILE%.SCR
goto Znovu

rem -------------------------------------------------
rem         Nastaven¡ konfigurace programu
rem -------------------------------------------------
:Setup
if not exist CONFIG.BAT goto NeniCBAT
call CONFIG.BAT
goto Znovu

:NeniCBAT
if not exist SETUP.BAT goto NeniSBAT
call SETUP.BAT
goto Znovu

:NeniSBAT
if not exist CONFIG.COM goto NeniCCOM
CONFIG.COM
goto Znovu

:NeniCCOM
if not exist CONFIG.EXE goto NeniCEXE
CONFIG.EXE
goto Znovu

:NeniCEXE
if not exist SETUP.COM goto NeniSCOM
SETUP.COM
goto Znovu

:NeniSCOM
if not exist SETUP.EXE goto NeniSEXE
SETUP.EXE
goto Znovu

:NeniSEXE
if not exist INSTALL.COM goto NeniICOM
INSTALL.COM
goto Znovu

:NeniICOM
if not exist INSTALL.EXE goto Znovu
INSTALL.EXE
goto Znovu

rem -------------------------------------------------
rem         Zobrazen¡ informac¡ k programu
rem -------------------------------------------------
:Info
if not exist FILE_ID.DIZ goto NeniDIZ
%XEXEC%hlp.com FILE_ID.DIZ /L

:NeniDIZ
if not exist !INFO.TXT goto NeniINFO
%XEXEC%hlp.com !INFO.TXT /L

:NeniINFO
if not exist README goto NeniREAD
%XEXEC%hlp.com README /L

:NeniREAD
if not exist README.TXT goto NeniREAT
%XEXEC%hlp.com README.TXT /L

:NeniREAT
if not exist README.DOC goto NeniREAC
%XEXEC%hlp.com README.DOC /L

:NeniREAC
if not exist READ.ME goto NeniREAM
%XEXEC%hlp.com READ.ME /L

:NeniREAM
if not exist %XFILE%.TXT goto NeniTXT
%XEXEC%hlp.com %XFILE%.TXT /L

:NeniTXT
if not exist %XFILE%.DOC goto Znovu
%XEXEC%hlp.com %XFILE%.DOC /L
goto Znovu

rem -------------------------------------------------
rem   Konec, navr cen¡ parametr… pýi extern¡m vol n¡
rem -------------------------------------------------
:Chyba
pause

:Konec
set XHOME=%1
set XDISK=%2
set XPATH=%3
set XFILE=%4
