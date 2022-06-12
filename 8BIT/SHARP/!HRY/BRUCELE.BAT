@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo BRUCE LEE  -  ‡¡nsk‚ karate
echo ---------
echo.
echo Po startu stisknou kl vesu D
echo (p©edefinov n¡ kl ves) a potom
echo postupnˆ stisknout kl vesy VLEVO,
echo VPRAVO, NAHORU, DOL¦ a MEZERA.
echo Potom stisknout kl vesu CR (start).
echo —kolem je pob¡t nep© tele.
echo.
echo Ovl d n¡: kurzory (¨ipky) - chozen¡
echo           MEZERA - akce (v kombinaci
echo                    s kurzory r–zn‚
echo                    £dery karate)
echo           BREAK - p©eru¨en¡
echo           GRAPH - zvuk
echo           TAB - pauza
echo.
..\sharpexx brucele.mzf > nul
..\delay 6 > nul
..\sharpsa3 brucele_.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
