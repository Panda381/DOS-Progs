@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo PSSST  -  huben¡ housenek sprejem
echo -----
echo.
echo Po startu stisknout kl vesu 5.
echo.
echo —kolem hry je ochr nit kvˆtinu p©ed
echo brouky a housenkami. Je nutno pou‘¡t
echo v‘dy sprej odpov¡daj¡c¡ barvy (zelen˜
echo na housenky a ‡erven˜ na brouky).
echo.
echo Ovl d n¡: kurzory (¨ipky) - pohyb
echo           ? - st©¡k n¡ sprejem
echo.
..\sharpexe pssst.mzf > nul
..\delay 6 > nul
..\sharpsa2 pssst_1.mzf > nul
..\delay 6 > nul
..\sharpsa2 pssst_2.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
