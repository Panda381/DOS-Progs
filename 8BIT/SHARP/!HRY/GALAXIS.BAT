@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo GALAXIS 700  -  odst©elov n¡ lod¡ raketou
echo -----------
echo.
echo Po startu je nutn‚ stisknout kl vesy:
echo        VLEVO
echo        VPRAVO
echo        MEZERA
echo a libovolnou kl vesu (nap©. MEZERA).
echo.
echo —kolem je zas hnout letadla v horn¡
echo ‡ sti obrazovky (s k©¡dly) a p©itom
echo se vyhybat bomb m a korun m. Stiskem
echo mezery se lze pohybovat nahoru.
echo.
echo Po skon‡en¡ hry stisknout J = znovu.
echo.
..\sharpexe galaxis.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
