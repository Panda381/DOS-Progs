@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo BARBARIAN  -  souboj s me‡i (VRAM 32K)
echo ---------
echo.
echo.
..\sharpexe barbar.mzf > nul
..\delay 6 > nul
..\sharpsa3 barbar_1.mzf > nul
..\delay 6 > nul
..\sharpsa3 barbar_2.mzf > nul
..\delay 6 > nul
..\sharpsa3 barbar_3.mzf > nul
..\delay 6 > nul
..\sharpsa3 barbar_4.mzf > nul
..\delay 6 > nul
..\sharpsa3 barbar_5.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
