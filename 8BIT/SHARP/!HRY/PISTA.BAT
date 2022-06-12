@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo PAVOUCEK PISTA  -  pi¨kvorky
echo --------------
echo.
echo Po startu se stiskne MEZERA a zad  se
echo po‡et hr ‡– 1 nebo 2 (nap©. 1) a zad 
echo se zna‡ka X (k©¡‘ky) nebo O (kole‡ka).
echo.
echo Pomoc¡ kurzorov˜ch kl ves (¨ipky) se
echo nastav¡ ukazatel a stiskne se MEZERA.
echo.
..\sharpexe pista.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
