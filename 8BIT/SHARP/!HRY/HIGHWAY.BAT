@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo HIGHWAY  -  automaty p©esunuj¡ n lo‘
echo -------
echo.
echo Po startu stisknout kl vesu 5.
echo.
echo —kolem je p©em¡stit n lo‘ pomoc¡
echo d lkovˆ ©¡zen˜ch robot– do t˜lu
echo nep©¡tele. Jeden robot uvol¤uje cestu,
echo ostatn¡ roboti tla‡¡ n lo‘ p©ed sebou.
echo.
echo Ovl d n¡:  VLEVO a VPRAVO - ot ‡en¡
echo            NAHORU - zrychlen¡
echo            DOL¦ - zpomalen¡
echo            MEZERA - st©¡len¡
..\sharpexe highway.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
