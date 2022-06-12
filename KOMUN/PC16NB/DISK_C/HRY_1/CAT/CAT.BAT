@echo off
cls
echo CAT
echo ---
echo —kolem hry je chytat my¨i, rybi‡ky atd. (jednotliv‚ sc‚ny jsou okna,
echo do kter˜ch mus¡ sk kat). Ko¨tˆ m–‘e zamˆstnat na¨lap n¡m stop.
echo.
echo Ovl d n¡:    vlevo/vpravo .... chozen¡+sk k n¡ vlevo/vpravo
echo              nahoru .......... sk k n¡
echo              ALT ............. speci ln¡ funkce
echo              Ctrl-S .......... zvuk zap/vyp
echo              Ctrl-R .......... reset hry
echo.
echo.
if "%1" == "" c:\system\klavesn\wait

c:\system\displej\detcard > NUL
if errorlevel 2 goto NHerc

c:\system\displej\emucga a > NUL
c:\system\displej\vmod 3
cat\cat
c:\system\displej\vmod 7
c:\system\displej\emucga d > NUL
goto Konec

:NHerc
cat\cat

:Konec
