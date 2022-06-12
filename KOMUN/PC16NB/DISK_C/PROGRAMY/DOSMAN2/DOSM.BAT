@echo off
if not exist g:\dosman2\nul md g:\dosman2
if not exist g:\dosman2\menu\nul md g:\dosman2\menu
if not exist g:\dosman2\dosman.ini copy c:\programy\dosman2\dosman.ini g:\dosman2\dosman.ini > NUL
if not exist g:\dosman2\dosman.mnu copy c:\programy\dosman2\dosman.mnu g:\dosman2\dosman.mnu > NUL
if not exist g:\dosman2\menu\archiv.mnu copy c:\programy\dosman2\menu\archiv.mnu g:\dosman2\menu\archiv.mnu > NUL
if not exist g:\dosman2\menu\format.mnu copy c:\programy\dosman2\menu\format.mnu g:\dosman2\menu\format.mnu > NUL
if not exist g:\dosman2\menu\safedisk.mnu copy c:\programy\dosman2\menu\safedisk.mnu g:\dosman2\menu\safedisk.mnu > NUL
if not exist g:\dosman2\menu\system.mnu copy c:\programy\dosman2\menu\system.mnu g:\dosman2\menu\system.mnu > NUL
if not exist g:\dosman2\dbf\nul md g:\dosman2\dbf
if not exist g:\dosman2\dbf\*.dbf copy c:\programy\dosman2\dbf\*.* g:\dosman2\dbf\*.* > NUL
if not exist g:\dosman2\tab\nul md g:\dosman2\tab
if not exist g:\dosman2\tab\*.tab copy c:\programy\dosman2\tab\*.* g:\dosman2\tab\*.* > NUL

if exist C:\PROGRAMY\DOSMAN2\$DOSMAN$.CFG del C:\PROGRAMY\DOSMAN2\$DOSMAN$.CFG
:Loop
if exist C:\PROGRAMY\DOSMAN2\$DOSMAN$.BAT del C:\PROGRAMY\DOSMAN2\$DOSMAN$.BAT
C:\PROGRAMY\DOSMAN2\DOSMAN.EXE /kam /x C:\PROGRAMY\DOSMAN2 /z G:\DOSMAN2
if errorlevel 1 goto End
if not exist C:\PROGRAMY\DOSMAN2\$DOSMAN$.BAT goto End
call C:\PROGRAMY\DOSMAN2\$DOSMAN$.BAT
goto Loop
:End
