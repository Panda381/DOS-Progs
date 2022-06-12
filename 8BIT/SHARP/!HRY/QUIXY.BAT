@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo BBG'S QUIXY  -  ohrani‡ov n¡ plochy
echo -----------
echo.
echo Nov  hra se za‡¡n  stiskem Y.
echo —kolem je ohrani‡it maxim ln¡ plochu.
echo Pomoc¡ kurzorov˜ch kl ves se pohybuje
echo po obrysech. V ur‡it‚m m¡stˆ se stiskne
echo MEZERA a p©ejede se p©es plochu.
echo.
..\sharpexe quixy.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
