@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo CANNON BALL  -  rozst©elov n¡ m¡‡k–
echo -----------
echo.
echo Po startu stisknout mezeru. —kolem je
echo rozst©¡let sk kaj¡c¡ m¡‡ky.
echo.
echo Ovl d n¡: VLEVO a VPRAVO - pohyb
echo           MEZERA - st©¡len¡
echo.
..\sharpexe cannon.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
