@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo UNDERWURLDE  -  sk©¡tek
echo -----------
echo.
echo Po startu stisknout kl vesu 0.
echo Mus¡ se prov‚st sk©¡tek podzemn¡m
echo labyrintem.
echo.
echo Ovl d n¡: VLEVO a VPRAVO - pohyb
echo           NAHORU - sk k n¡
echo.
..\sharpexe underwur.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
