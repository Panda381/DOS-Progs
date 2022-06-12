@echo off
cls
type c:\system\system\starinst.mnu
ask "Zadejte va¨i volbu (A a‘ E)",dvmepx
if errorlevel == 6 goto EMULOFF
if errorlevel == 5 goto PRINTEX
if errorlevel == 4 goto EMUL
if errorlevel == 3 goto MIKRO
if errorlevel == 2 goto FDRAFT
if errorlevel == 1 goto DRAFT
goto end

:DRAFT
c:\system\system\fr-15.exe 0
copy /b c:\system\system\init.prn prn:
copy /b c:\system\system\fr-15.fnt prn:
copy c:\edit\kontext\draft.prt c:\edit\kontext\printer.prt
goto end

:FDRAFT
c:\system\system\fr-15.exe 0
copy /b c:\system\system\init.prn prn:
copy /b c:\system\system\fr-15.fnt prn:
copy /b c:\system\system\fdraft.prn prn:
copy c:\edit\kontext\fdraft.prt c:\edit\kontext\printer.prt
goto end

:MIKRO
c:\system\system\fr-15.exe 0
copy /b c:\system\system\init.prn prn:
copy /b c:\system\system\fr-15.fnt prn:
copy /b c:\system\system\mikro.prn prn:
copy c:\edit\kontext\mikro.prt c:\edit\kontext\printer.prt
goto end

:EMUL
copy /b c:\system\system\init.prn prn:
copy c:\edit\kontext\nlq.prt c:\edit\kontext\printer.prt
c:\system\system\fr-15.exe
goto end

:EMULOFF
c:\system\system\fr-15.exe 0
goto end

:PRINTEX
c:\system\system\fr-15.exe 0
copy /b c:\system\system\init.prn prn:
call c:\system\printex\pxinst.bat
copy c:\edit\kontext\printex.prt c:\edit\kontext\printer.prt
goto end

:end
