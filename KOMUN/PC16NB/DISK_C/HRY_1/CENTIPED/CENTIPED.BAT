@echo off
cls
echo Centiped
echo --------
echo —kolem hry je rozst©elovat housenku.
echo Hra se spou¨t¡ stiskem kl vesy "1" (tj. 1 hr ‡)
echo a stiskem kl vesy "A" (tj. nejni‘¨¡ obt¡‘nost).
echo.
echo Ovl d n¡:  mezera ..... start hry, st©¡len¡
echo            ‡¡slice .... pohyb v¨emi 8 smˆry, p©i
echo                         opakovan‚m stisku se rychlost
echo                         zvy¨uje nebo naopak sni‘uje
echo                         (je-li opa‡n˜m smˆrem). 
echo            [5] ........ zastaven¡ pohybu
echo            F2 ......... pauza
echo            F5 ......... zvuk zap/vyp
echo            End ........ konec jedn‚ hry
echo            Ctrl-Break . £pln˜ konec hry (nebo Ctrl-End)
echo.
echo.
if "%1" == "" c:\system\klavesn\wait

c:\system\displej\detcard > NUL
if errorlevel 2 goto NHerc

c:\system\displej\emucga a > NUL
c:\system\displej\vmod 3
centip
c:\system\displej\vmod 7
c:\system\displej\emucga d > NUL
goto Konec

:NHerc
centip

:Konec
