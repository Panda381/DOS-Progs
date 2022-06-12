@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo SUPERGORGON  -  st©¡len¡ UFO
echo -----------
echo.
echo Po startu stisknout MEZERU,
echo kl vesu N a kl vesu 1 (po‡et
echo hr ‡–).
echo.
echo Ovl d n¡: NAHORU a DOL¦ - ©¡zen¡
echo           VPRAVO - zv˜¨en¡ rychlosti
echo           VLEVO - oto‡en¡
echo           Z - st©¡len¡
echo           A - bomba
echo.
echo Po skon‡en¡ hry zadat J = znovu.
..\sharpexe supergor.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
