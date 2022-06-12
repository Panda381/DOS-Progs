@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo BASKETBALL - basketbal
echo ----------
echo.
echo Po startu stisknout kl vesy P a
echo potom 1 (1 hr ‡) nebo 2 (2 hr ‡i).
echo.
..\sharpexe basket.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!


