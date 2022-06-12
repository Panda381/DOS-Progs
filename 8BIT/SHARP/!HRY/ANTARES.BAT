@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo COLOR ANTARES  -  st©¡len¡ UFO z lodi
echo -------------
echo.
echo Po startu se stiskne kl vesa N.
echo.
echo Ovl d n¡: O - nahoru
echo           . - dol–
echo           K - vlevo
echo           ; - vpravo
echo.
echo           L - laserov˜ kanon
echo          CR - fotonov  bomba
echo           H - zes¡len¡ ochran. ¨t¡tu
echo           G - zeslaben¡ ochran. ¨t¡tu
echo           1 - konec hry
echo.
echo Po skon‡en¡ hry stisknout J (znovu).
echo.
..\sharpexe antares.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
