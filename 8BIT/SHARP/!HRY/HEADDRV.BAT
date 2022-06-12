@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo HEAD DRIVER  -  proj¡‘dˆn¡ trat¡
echo -----------
echo.
echo Po startu stisknout 2 x MEZERU.
echo.
echo C¡lem je projet ka‘d˜m m¡stem trati.
echo P©itom se mus¡ vyh˜bat lovc–m.
echo MEZERA postav¡ p©ek ‘ku pro lovce.
echo.
echo Po skon‡en¡ hry zadat Y = znovu.
..\sharpexe headdrv.mzf > nul
..\delay 6 > nul
..\sharpexe headdrv_.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
