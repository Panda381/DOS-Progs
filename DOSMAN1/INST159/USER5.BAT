@echo off

if "%1" == "" goto KONEC

set dsk=B
echo Vlo�te disketu ur�enou ke kop�rov�n� do mechaniky A: nebo B:
%3utility\ask "a stiskn�te kl�vesu A nebo B podle pou�it� mechaniky (Esc = p�eru�en�): "ab
echo.
if errorlevel 3 goto KONEC
if errorlevel 2 goto B 
set dsk=A

:B
if exist %3$disk$.dsk del %3$disk$.dsk
%3disk\diskfile %dsk%: %3$disk$.dsk
if not exist %3$disk$.dsk goto KONEC
if errorlevel 1 goto KONEC

:Z
echo.
echo Vlo�te do mechaniky %dsk%: �istou NAFORM�TOVANOU disketu
echo a stiskn�te libovolnou kl�vesu.
if not exist %3utility\wait.com pause
%3utility\wait "VAROV�N�: p�vodn� obsah diskety bude ZNI�EN ! (Esc = p�eru�en�) "
if errorlevel 1 goto KONEC
%3disk\diskfile %3$disk$.dsk %dsk%: /w
goto Z

:KONEC
if exist %3$disk$.dsk del %3$disk$.dsk
