@echo off
%3utility\ask "Zkopiruji vsechny soubory a podadresare do %2*.* (A/N/Esc) ! "an
echo.
if errorlevel == 2 goto konec
xcopy *.* %2*.* /s/e
:konec
