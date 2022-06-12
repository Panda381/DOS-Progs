@echo off
cls
echo BATMAN
echo ------
echo P©i startu hry stisknˆte 2x kl vesu "1"
echo (tj. displej CGA a ovl d n¡ kl vesnic¡).
echo.
echo Ovl d n¡:   "O" ............. pohyb vlevo
echo             "P" ............. pohyb vpravo
echo             "Q" ............. po ‘eb©¡ku nahoru
echo             "A"  ............ p©ikr‡en¡, po ‘eb©¡ku dol–
echo             mezera .......... st©¡len¡
echo             mezera + "Q" .... vy¨plh n¡ nahoru po lanˆ
echo             mezera + "A" .... sesko‡en¡ dol–
echo             F7 .............. konec hry
echo.
echo.
if "%1" == "" c:\system\klavesn\wait

cd batman
c:\system\displej\detcard > NUL
if errorlevel 2 goto NHerc

c:\system\displej\emucga a > NUL
c:\system\displej\vmod 3
batman
c:\system\displej\vmod 7
c:\system\displej\emucga d > NUL
goto Konec

:NHerc
batman

:Konec
cd ..
