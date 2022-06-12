@echo off
c:\system\append C:\HRY_3\PTOMB;
if not exist g:\ptomb\nul md g:\ptomb
g:
cd\ptomb
cls
echo Pharaon's Tomb
echo --------------
echo Ovl d n¡:   Ctrl ............. vlevo
echo             Alt .............. vpravo
echo             mezera ........... v˜skok (+ Ctrl nebo Alt = ¨ikm˜ skok)
echo             Q ................ konec hry (t‚‘ p©i £vodn¡ obrazovce)
echo             S ................ ulo‘en¡ hry
echo             R ................ navr cen¡ ulo‘en‚ hry
echo             B, C ............. st©¡len¡
echo.
echo.
if "%1" == "" c:\system\klavesn\wait

c:\system\displej\detcard > NUL
if errorlevel 2 goto NHerc

c:\system\displej\emucga a > NUL
c:\system\displej\vmod 3
c:ptomb1
c:\system\displej\vmod 7
c:\system\displej\emucga d > NUL
goto Konec

:NHerc
c:ptomb1

:Konec
cd\
c:
c:\system\append ;
