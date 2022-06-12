@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo TOMAHAWK  -  leteck˜ simul tor
echo --------
echo.
echo.
..\sharpexe tomahawk.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
