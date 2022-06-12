@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo BUNKY EXTRA  -  celul rn¡ automat
echo -----------
echo Po startu stisknout MEZERU a zvolit
echo velikost pole A a‘ L (nap©. L).
echo.
echo Program je matematick˜m modelem
echo mno‘en¡ bunˆk. P©e‘¡v  pouze bu¤ka,
echo kter  m  2 nebo 3 sousedy. Na m¡stˆ,
echo kter‚ho se dot˜kaj¡ 3 bu¤ky, vznikne
echo nov  bu¤ka. Bu¤ka soused¡c¡ s m‚nˆ
echo ne‘ 2 bu¤kami zanik  na osamocen¡.
echo Bu¤ka soused¡c¡ se 4 bu¤kami zanik 
echo na p©emno‘en¡. Takto lze vytv ©et
echo r–zn‚ zaj¡mav‚ obrazce.
echo.
echo Ovl d n¡:  kyrzory (¨ipky) - pohyb
echo            Z - kreslen¡ bunˆk
echo            X - maz n¡ bunˆk
echo            C - p©esun beze zmˆny
echo            E - zah jen¡ generac¡
..\sharpexe bunky.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
