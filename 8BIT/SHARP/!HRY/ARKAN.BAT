@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo ARKANOIDS  -  arkanoidy, rozb¡jen¡ zdi
echo ---------
echo.
echo Po startu se stiskne 2 x MEZERA.
echo.
echo Kl vesami ¨ipka vlevo a ¨ipka vpravo se
echo posouv  voz¡k vlevo a vpravo. Mezerou
echo se vyp l¡ m¡‡ek. —kolem je rozb¡t zeƒ
echo odr ‘en¡m m¡‡ku do zdi. Sb¡raj¡ se
echo padaj¡c¡ ok‚nka:    "N" nov  sc‚na
echo                     "C" lepidlo
echo                     "L" dal¨¡ ‘ivot
echo                     "P" dlouh˜ voz¡k
echo                     "R" st©¡len¡
echo.
..\sharpexe arkan.mzf > nul
..\delay 6 > nul
..\sharpexe arkan_.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
