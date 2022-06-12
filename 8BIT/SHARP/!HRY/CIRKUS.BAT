@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo CIRKUS STAR  -  sest©elov n¡ balonk–
echo -----------
echo.
echo Po startu stisknout kl vesu S.
echo.
echo —kolem je chytat sk kaj¡c¡ho pan ‡ka
echo a sest©elovat j¡m balonky.
echo.
echo Ovl d n¡: VLEVO a VPRAVO - pohyb
echo           Z - st©¡len¡ vlevo
echo           C - st©¡len¡ vpravo
echo.
..\sharpexe cirkus.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
