@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo EXPLODING FIST  -  karate
echo --------------
echo.
echo Po startu stisknout 1 (1 hr ‡)
echo nebo 2 (2 hr ‡i).
echo.
echo Ovl d n¡: Shift-BREAK - konec,
echo              n sleduje 1 (1 hr ‡)
echo              nebo 2 (2 hr ‡i)
echo.
echo  hr ‡ 1: Q W E   hr ‡ 2: O P @
echo          A   D           L   :
echo          Z X C           . / ?
echo.
..\sharpexe explodf.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
