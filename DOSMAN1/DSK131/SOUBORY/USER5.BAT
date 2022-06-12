@echo off
%3ask "Zkopiruji cely adresar %1 do %2%1 (A/N/Esc) ! "an
echo.
if errorlevel == 2 goto konec
xcopy %1 %2%1\ /s/e
:konec
