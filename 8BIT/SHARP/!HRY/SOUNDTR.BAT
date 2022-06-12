@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo SOUND TRACK 1  -  10 melodi¡
echo -------------
echo.
echo Stiskem kl ves A a‘ J lze zvolit
echo jednu z 10 melodi¡.
echo.
..\sharpexe soundtr.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
