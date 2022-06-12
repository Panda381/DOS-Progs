@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo SOUND TRACK 2  -  15 melodi¡
echo -------------
echo.
echo Stiskem kl ves A a‘ O lze zvolit
echo jednu z 15 melodi¡.
echo.
..\sharpexe soundtr2.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
