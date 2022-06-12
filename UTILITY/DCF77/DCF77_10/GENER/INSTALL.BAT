@echo off
cls
echo ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
echo ³  Nainstaluji program DCF77 z diskety (A: nebo B:) ³
echo ³  do adresare C:\DCF77. Chcete-li instalaci nyni   ³
echo ³  prerusit, stisknete klavesu Ctrl-BREAK. Stiskem  ³
echo ³  libovolne jine klavesy zahajite instalaci.       ³
echo ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
echo.
pause
echo.
echo Instaluji...
echo.
if not exist DCF77.COM goto NENI
md c:\dcf77
if not exist C:\DCF77\NUL goto NELZE
cd c:\dcf77
copy *.* c: > nul
c:
echo.
echo Instalace uspesne ukoncena.
echo ---------------------------
echo Doplnte, prosim, na zacatek souboru C:\AUTOEXEC.BAT radek:
echo        C:\DCF77\DCF77 n
echo kde n je cislo portu COM, ke kteremu je prijimac pripojen.
echo.
echo Pro WINDOWS uvolnete pouzity port podle pokynu v textu DCF.TXT.
echo.
echo Dalsi informace obdrzite zadanim prikazu CTI.
echo.
goto KONEC

:NELZE
echo Nelze vytvorit cilovy adresar C:\DCF77 !
echo 
goto KONEC

:NENI
echo.
echo Vlozte do mechaniky A: (resp. B:) instalacni
echo      disketu DCF-77 a zadejte prikazy:
echo               A: (resp. B:)
echo               INSTALL
echo 

:KONEC
pause

