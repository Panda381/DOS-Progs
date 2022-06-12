@echo off

if "%1" == "" goto KONEC

set dsk=B
echo Vloëte disketu uráenou ke kop°rov†n° do mechaniky A: nebo B:
%3utility\ask "a stisknàte kl†vesu A nebo B podle pouëitÇ mechaniky (Esc = p©eru®en°): "ab
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
echo Vloëte do mechaniky %dsk%: áistou NAFORMèTOVANOU disketu
echo a stisknàte libovolnou kl†vesu.
if not exist %3utility\wait.com pause
%3utility\wait "VAROVèNã: pñvodn° obsah diskety bude ZNIÄEN ! (Esc = p©eru®en°) "
if errorlevel 1 goto KONEC
%3disk\diskfile %3$disk$.dsk %dsk%: /w
goto Z

:KONEC
if exist %3$disk$.dsk del %3$disk$.dsk
