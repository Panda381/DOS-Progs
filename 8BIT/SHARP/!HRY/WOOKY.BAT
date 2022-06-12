@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo WOOKY  -  p©em¡sŸov n¡ koul¡
echo -----
echo.
echo Po startu stisknout 2 x CR.
echo —kolem je dostat ‡erven‚ koule
echo na ‡erven  p‚ra.
echo.
echo Ovl d n¡: VLEVO a VPRAVO = chozen¡
echo           NAHORU = ‘eb©¡k
echo           MEZERA = skok
echo           CR = st©¡len¡
echo.
echo P©i ztr tˆ ‘ivota lze kurzory zvolit
echo buƒ START (=znovu) nebo CONTINUE
echo (=pokra‡ov n¡ ve stejn‚m m¡stˆ), potom
echo se stiskne CR.
echo.
..\sharpexe wooky.mzf > nul
..\delay 20 > nul
..\sharpexe wooky_.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
