@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo ANDROMEDA  -  odst©elov n¡ UFO
echo ---------
echo.
echo Po startu se stiskne kl vesa N.
echo.
echo Ovl d n¡: X - vlevo
echo           C - vpravo
echo           M - st©¡len¡
echo.
echo Po skon‡en¡ hry zadat J a N.
echo (tj. nov  hra).
echo.
..\sharpexe andromed.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
