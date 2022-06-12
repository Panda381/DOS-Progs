@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo ADVOKA  -  zachra¤ov n¡ ho©¡c¡ho mˆsta
echo ------
echo.
echo Po startu stisknout 2 x mezeru.
echo.
echo Ovl d  se kurzorov˜mi kl vesami.
echo Mus¡ posb¡rat v¨echny dome‡ky. M–‘e
echo l‚zt po ‘eb©¡c¡ch a pomoc¡ mezery
echo p©eskakovat ohnˆ a mezery. Po ztr tˆ
echo v¨ech ‘ivot– se zept  "AGAIN ?",
echo zad  se kl vesa Y (tj. nov  hra).
echo.
..\sharpexe advoka.mzf > nul
..\delay 6 > nul
..\sharpexe advoka_.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
