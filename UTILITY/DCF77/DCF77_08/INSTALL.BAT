@echo off
cls
echo Nainstaluji program DCF77 z diskety v mechanice A:
echo do adresare C:\DCF77. Chcete-li instalaci nyni
echo prerusit, stisknete klavesy Ctrl-BREAK, jinak
echo stiskem libovolne jine klavesy zahajite instalaci.
echo.
pause
echo.
echo Instaluji...
if not exist A:\DCF77.COM goto NENI
md c:\dcf77
if not exist C:\DCF77\NUL goto NELZE
cd c:\dcf77
copy a:*.*
echo.
echo Instalace uspesne ukoncena.
echo Blizsi informace ziskate zadanim prikazu:
echo                CTI
echo.
goto KONEC

:NELZE
echo Nelze vytvorit cilovy adresar C:\DCF77 !
echo 
goto KONEC

:NENI
echo V disketove mechanice A: neni vlozena
echo instalacni disketa pro DCF77 !
echo 

:KONEC
