@echo off
cls
:start
home
dcf77.com
echo.
echo ===== Preruseni zobrazeni stiskem libovolne klavesy =====
inkey ?
if not errorlevel 1 goto start
inkey !
