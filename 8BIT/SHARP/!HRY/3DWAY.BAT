@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo 3-D WAY OUT  -  prostorov‚ bludi¨tˆ
echo -----------
echo.
echo Po startu se stiskne kl vesa MEZERA.
echo Zad  se v˜¨ka bludi¨tˆ (nap©. 10 + CR)
echo a ¨¡©ka bludi¨tˆ (nap©. 10 + CR).
echo Nyn¡ je pot©eba naj¡t v˜chod EXIT.
echo.
echo Ovl d n¡: ¨ipka vlevo/vpravo - ot ‡en¡
echo           ¨ipka nahoru - pohyb vp©ed
echo           E - konec hry
echo           B - n povˆda kl ves
echo           H - zobrazen¡ mapy (max. 4x)
echo               R - n vrat z mapy do hry
..\sharpexe 3dway.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!

