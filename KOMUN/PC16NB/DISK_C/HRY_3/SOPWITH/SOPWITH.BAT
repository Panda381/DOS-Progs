@echo off
cls
echo SOPWITH
echo -------
echo Ovl d n¡:    "," .......... nahoru
echo              "." .......... obr cenˆ
echo              "/" .......... dol–
echo              mezera ....... st©¡len¡
echo              "B" .......... bomba
echo              "X" .......... start, zv˜¨en¡ rychlosti
echo              "S" .......... zvuk zap/vyp
echo              Ctrl-Break ... konec hry
echo.
echo.
if "%1" == "" c:\system\klavesn\wait

cd sopwith
c:\system\displej\detcard > NUL
if errorlevel 2 goto NHerc
c:\system\displej\emucga a > NUL
c:\system\displej\vmod 3
sopwith
c:\system\displej\vmod 7
c:\system\displej\emucga d > NUL
goto Konec

:NHerc
sopwith

:Konec
cd ..
