@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo MANIC MINER 800  -  horn¡k v jeskyn¡ch
echo ---------------
echo.
echo Po startu stisknout kl vesu CR.
echo.
echo —kolem je prov‚st horn¡ka Willyho
echo 20 jeskynˆmi.
echo.
echo Ovl d n¡: VLEVO a VPRAVO - pohyb
echo           MEZERA (NAHORU) - skok
echo           A - pauza (pokra‡ov n¡ CR)
echo           B - zvuk zap/vyp
echo           Shift-BREAK - p©eru¨en¡
..\sharpexe miner.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
