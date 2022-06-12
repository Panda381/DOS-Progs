@echo off
set DISK=A
rem set DISK=B

echo. >> PROTOKOL
:START
cls
echo            Generovani licencni diskety programu DCF-77
echo            ===========================================
echo              (vystupni protokol do souboru PROTOKOL)
echo.
type _licence.txt
type licence.num
echo.

echo.
echo Vlozte do mechaniky %DISK%: prazdnou naformatovanou disketu....
wait "(stisknete libovolnou klavesu, ESC=preruseni)"
if errorlevel 1 goto KONEC

echo Generuji disketu...
datetime >> PROTOKOL
type _licence.txt >> PROTOKOL
type licence.num >> PROTOKOL

poj dcf77_.com /X > nul
lic_set
if not errorlevel 1 goto SET_OK
echo   Chyba zapisu licencniho cisla do DCF77.COM >> PROTOKOL
goto CHYBA

:SET_OK
poj dcf77.com > nul

copy clock.com %DISK%:\clock.com > nul
if not exist %DISK%:\clock.com goto KOPIE

copy clock.txt %DISK%:\clock.txt > nul
if not exist %DISK%:\clock.txt goto KOPIE

copy cti.bat %DISK%:\cti.bat > nul
if not exist %DISK%:\cti.bat goto KOPIE

copy dcf77.com %DISK%:\dcf77.com > nul
if not exist %DISK%:\dcf77.com goto KOPIE

copy dcf77.txt %DISK%:\dcf77.txt > nul
if not exist %DISK%:\dcf77.txt goto KOPIE

copy hlp.com %DISK%:\hlp.com > nul
if not exist %DISK%:\hlp.com goto KOPIE

copy hodiny.com %DISK%:\hodiny.com > nul
if not exist %DISK%:\hodiny.com goto KOPIE

copy hodiny.txt %DISK%:\hodiny.txt > nul
if not exist %DISK%:\hodiny.txt goto KOPIE

copy install.bat %DISK%:\install.bat > nul
if not exist %DISK%:\install.bat goto KOPIE

copy kalend.com %DISK%:\kalend.com > nul
if not exist %DISK%:\kalend.com goto KOPIE

copy kalend.txt %DISK%:\kalend.txt > nul
if not exist %DISK%:\kalend.txt goto KOPIE

goto VSE_OK

:KOPIE
echo   Chyba kopirovani souboru na disketu >> PROTOKOL
echo   Chyba kopirovani souboru na disketu !
goto CHYBA

:VSE_OK
echo   ......  generovani OK >> PROTOKOL
echo Generovani OK, vyjmete disketu a zapiste na ni licencni cislo:
type _licence.txt
type licence.num
echo.
wait
lic_inc
if not errorlevel 1 goto START
echo Chyba inkrementace licencniho cisla ! >> PROTOKOL

:CHYBA
wait
:KONEC
