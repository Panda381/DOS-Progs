@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo NIBBLER  -  housenka po‘¡raj¡c¡ body
echo -------
echo.
echo Po startu se zvol¡ rychlost 0 a‘ 5
echo (5 je nejpomalej¨¡) a stiskne se CR.
echo.
echo —kolem je posb¡rat v dan‚m ‡ase v¨echny
echo p©edmˆty v bludi¨ti.
..\sharpexe nibbler.mzf > nul
..\delay 500 > nul
..\sharpexe nibbler_.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
