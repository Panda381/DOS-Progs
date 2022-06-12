@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo HERI-FIRE GAME  -  vrtuln¡k has¡ po‘ r
echo --------------
echo.
echo Po startu stisknout kl vesu N.
echo.
echo C¡lem hry je hasit lesn¡ po‘ r.
echo.
echo Ovl d n¡: U - nahoru
echo           M - dol–
echo           H - vlevo
echo           K - vpravo
echo           MEZERA - vodn¡ bomba
echo.
echo Po skon‡en¡ hry stisknout S = znovu.
..\sharpexe herifire.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
