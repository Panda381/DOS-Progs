@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo BUNKY EXTRA  -  celul�rn� automat
echo -----------
echo Po startu stisknout MEZERU a zvolit
echo velikost pole A a� L (nap�. L).
echo.
echo Program je matematick�m modelem
echo mno�en� bun�k. P�e��v� pouze bu�ka,
echo kter� m� 2 nebo 3 sousedy. Na m�st�,
echo kter�ho se dot�kaj� 3 bu�ky, vznikne
echo nov� bu�ka. Bu�ka soused�c� s m�n�
echo ne� 2 bu�kami zanik� na osamocen�.
echo Bu�ka soused�c� se 4 bu�kami zanik�
echo na p�emno�en�. Takto lze vytv��et
echo r�zn� zaj�mav� obrazce.
echo.
echo Ovl�d�n�:  kyrzory (�ipky) - pohyb
echo            Z - kreslen� bun�k
echo            X - maz�n� bun�k
echo            C - p�esun beze zm�ny
echo            E - zah�jen� generac�
..\sharpexe bunky.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
