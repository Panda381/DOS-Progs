@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo SHACH  -  ¨achy
echo -----
echo.
echo Po startu se stiskne J a zvol¡ se
echo barva S (‡ern ) nebo W (b¡l ) a
echo obt¡‘nost 1 a‘ 6 (1 nejsnadnˆj¨¡).
echo.
echo Tah se zad  z pisem v˜choz¡ a
echo c¡lov‚ sou©adnice.
echo.
..\sharpexe shach.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
