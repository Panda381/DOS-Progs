@echo off
%3utility\ask "Varovani: Zrusim cely adresar %1 (A/N/Esc) ! "an
echo.
if errorlevel == 2 goto konec
xdel %1 /s/e
:konec
