@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo SHOGUN  -  ¨achovnice (kameny)
echo ------
echo.
echo Po startu stisknout MEZERU.
echo.
echo Kameny se p©emisŸuj¡ nastaven¡m
echo ukazatelem na k men, stiskem INST,
echo p©em¡stˆn¡m a opˆt stiskem INST.
..\sharpexe shogun.mzf > nul
..\delay 6 > nul
..\sharpexe shogun_.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
