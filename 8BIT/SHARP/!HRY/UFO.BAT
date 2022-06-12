@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo UFO  -  odst©elov n¡ UFO
echo ---
echo.
echo Po startu se stiskne N.
echo.
echo Pomoc¡ kl ves VLEVO a VPRAVO se
echo pohybuje, mezerou se st©¡l¡. Mus¡
echo se zabr nit tomu, aby UFO zaplnily
echo d¡ru.
echo.
echo Po skon‡en¡ hry se stiskne S = znovu.
..\sharpexe ufo.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
