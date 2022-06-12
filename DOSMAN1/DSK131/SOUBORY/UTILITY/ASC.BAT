@echo off
cls
egacs /k > nul:
vmod 3
echo Tento p©¡kazov˜ soubor v m umo‘n¡ prohl¡‘et fonty instalovan‚ pomoc¡
echo programu EGACS.COM. Po zobrazen¡ font– na displeji m–‘ete obsah displeje
echo vytisknout na p©ipojen‚ tisk rnˆ stiskem kl vesy PrintScreen.
echo.
echo K tomu je zapot©eb¡ p©¡tomnost n sleduj¡c¡ch program–:
echo.
echo GRAPHICS.COM - syst‚mov˜ program pro tisk obrazovky v grafick‚m re‘imu
echo EGACS   .COM - instal tor n rodn¡ch font– displeje
echo VMOD    .COM - nastaven¡ videom¢du displeje
echo ASCII   .COM - zobrazen¡ tabulek font– displeje
echo WAIT    .COM - prodleva
echo.
echo Pokud v m nˆkter˜ z program– chyb¡, p©eru¨te dal¨¡ ‡innost stiskem
echo kl vesy Ctrl-Break.
echo.
echo.
wait
graphics graphics
vmod 16
egacs /0
echo.
echo Zobraz¡ se standardn¡ k¢d IBM.
echo.
echo.
wait
ascii
egacs /k
echo.
echo Zobraz¡ se k¢d brat©¡ Kamenick˜ch.
echo.
echo.
wait
ascii
egacs /l
echo.
echo Zobraz¡ se k¢d Latin 2.
echo.
echo.
wait
ascii
egacs /k > nul:
