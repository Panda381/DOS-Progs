@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo HOBRA SCHACH  -  ¨achy
echo ------------
echo.
echo Po startu stisknou J a CR, potom
echo zvolit barvu S (‡ern ) nebo W (b¡l )
echo a stisknout CR, nakonec zvolit
echo obt¡‘nost 1 a‘ 9 (1 nejsnadnˆj¨¡) a
echo stisknout CR.
echo.
echo Tah se provede stiskem INST a zad n¡m
echo v˜choz¡ a c¡lov‚ sou©adnice + CR nebo
echo se stiskne DEL, nastav¡ se kurzor na
echo figurku, stiskne se DEL, nastav¡ se na
echo novou pozici a opˆt se stiskne DEL.
echo.
..\sharpexe hobrasch.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!


