@echo off
cls
echo.
echo.
echo      °±±²²²ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ²²²±±°
echo      °±±²²²ÛÛÛÛ                                                  ÛÛÛÛ²²²±±°
echo      °±±²²²ÛÛÛÛ  DEMO ukazky softwarove nabidky firmy GEMA Soft  ÛÛÛÛ²²²±±°
echo      °±±²²²ÛÛÛÛ                                                  ÛÛÛÛ²²²±±°
echo      °±±²²²ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ²²²±±°
echo.                                                                   INVEX 96
echo.

echo      Vazeny  uzivateli  PC,  dovolujeme si Vam nabidnout demonstracni verze
echo      nejzajimavejsich  programu  z  nasi produkce. V pripade blizsiho zajmu
echo      o programy naleznete jejich dodaci podminky v souboru CTI_MNE.TXT.

echo.
echo      1) DOS Manazer V2.00 .... Souborovy a diskovy manazer pro DOS, WINDOWS
echo                                a WINDOWS 95.  Usnadni Vam obsluhu pocitace.
echo      2) VSEMI10 V2.20 ........ Vyuka  psani  na  klavesnici pocitace. Mnoho
echo                                typu klavesnic, testy, protokoly,  47 lekci.
echo      3) ANTI_MOR VA.00 ....... Antivirovy  system proti modernim supervirum
echo                                typu ONE HALF. Odstraneni, detekce i mutaci.
echo.
echo.

if not exist UTILITY\WAIT.COM goto Varov

echo.     Instalace probehne do adresare C:\GEMASOFT
echo.
utility\wait "     Potvrdte instalaci stiskem klavesy (Esc = preruseni instalace) "
if errorlevel 1 goto Konec

echo      Probiha instalace ...
echo.

if not exist C:\GEMASOFT\NUL md C:\GEMASOFT > NUL
if not exist C:\GEMASOFT\ANTI_MOR\NUL md C:\GEMASOFT\ANTI_MOR > NUL
if not exist C:\GEMASOFT\DOSMDEMO\NUL md C:\GEMASOFT\DOSMDEMO > NUL
if not exist C:\GEMASOFT\DOSMDEMO\DBF\NUL md C:\GEMASOFT\DOSMDEMO\DBF > NUL
if not exist C:\GEMASOFT\DOSMDEMO\NOT\NUL md C:\GEMASOFT\DOSMDEMO\NOT > NUL
if not exist C:\GEMASOFT\DOSMDEMO\TAB\NUL md C:\GEMASOFT\DOSMDEMO\TAB > NUL
if not exist C:\GEMASOFT\DOSMDEMO\UTILITY\NUL md C:\GEMASOFT\DOSMDEMO\UTILITY > NUL
if not exist C:\GEMASOFT\UTILITY\NUL md C:\GEMASOFT\UTILITY > NUL
if not exist C:\GEMASOFT\VSEMI10\NUL md C:\GEMASOFT\VSEMI10 > NUL
if not exist C:\GEMASOFT\VSEMI10\TESTY\NUL md C:\GEMASOFT\VSEMI10\TESTY > NUL

copy *.* C:\GEMASOFT > NUL
if exist C:\GEMASOFT\TESTDISK.COM del C:\GEMASOFT\TESTDISK.COM > NUL
copy ANTI_MOR\*.* C:\GEMASOFT\ANTI_MOR > NUL
copy DOSMDEMO\*.* C:\GEMASOFT\DOSMDEMO > NUL
copy DOSMDEMO\DBF\*.* C:\GEMASOFT\DOSMDEMO\DBF > NUL
copy DOSMDEMO\NOT\*.* C:\GEMASOFT\DOSMDEMO\NOT > NUL
copy DOSMDEMO\TAB\*.* C:\GEMASOFT\DOSMDEMO\TAB > NUL
copy DOSMDEMO\UTILITY\*.* C:\GEMASOFT\DOSMDEMO\UTILITY > NUL
copy UTILITY\*.* C:\GEMASOFT\UTILITY > NUL
copy VSEMI10\*.* C:\GEMASOFT\VSEMI10 > NUL
copy VSEMI10\TESTY\*.* C:\GEMASOFT\VSEMI10\TESTY > NUL

if not exist C:\WINDOWS\PLOCHA\NUL goto NeniWin95
if exist C:\WINDOWS\PLOCHA\DOSMWIN.PIF goto JeDosmWin
copy C:\GEMASOFT\DOSMDEMO\UTILITY\DOSMWIN.PIF C:\WINDOWS\PLOCHA > NUL

:JeDosmWin
if exist C:\WINDOWS\PLOCHA\DOSMDOS.PIF goto NeniWin95
copy C:\GEMASOFT\DOSMDEMO\UTILITY\DOSMDOS.PIF C:\WINDOWS\PLOCHA > NUL

:NeniWin95

C:
cd \GEMASOFT

echo      Instalace ukoncena OK
echo.

goto Konec

:Varov
echo      Instalaci, prosim, provedte z diskety "DOS Manazer - DEMO",
echo      (pred spustenim instalace nejprve zadejte A: nebo B:).
echo.

:Konec
