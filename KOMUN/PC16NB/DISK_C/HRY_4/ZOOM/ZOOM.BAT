@echo off
cls
echo Ovl dac¡ kl vesy:
echo ----------------
echo         [4] ......... vlevo
echo         [5] ......... rovnˆ
echo         [6] ......... vpravo
echo         [8] ......... nahoru (je-li ji‘ naho©e, tak zrychlit)
echo         [2] ......... dol– (je-li ji‘ dole, tak zpomalit)
echo         mezera ...... st©¡len¡
echo         Enter ....... pauza
echo.
echo —kolem je prol‚tat mezi br nami (sektor 1 a 2) a st©¡let UFO (sektor 3).
echo.
echo.
if "%1" == "" c:\system\klavesn\wait

c:\system\displej\detcard > NUL
if errorlevel 2 goto NHerc

c:\system\displej\emucga a > NUL
c:\system\displej\vmod 3
zoom\zoom
c:\system\displej\vmod 7
c:\system\displej\emucga d > NUL
goto Konec

:NHerc
zoom\zoom

:Konec
