@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo GARD  -  p©ebarvov n¡ ‡tverc–
echo ----
echo.
echo Po startu stisknout MEZERU a zadat
echo obt¡‘nost P, N, A (nap©. A=snadn‚).
echo.
echo C¡lem hry je p©ebarvit celou plochu
echo na stejnou barvu. Pomoc¡ kurzor–
echo (¨ipky) se p©emisŸuje ukazatel,
echo stiskem MEZERY se zmˆn¡ barva ‡tverce.
echo.
..\sharpexe gard.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
