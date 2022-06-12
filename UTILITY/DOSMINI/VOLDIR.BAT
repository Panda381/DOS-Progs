@echo off
:ADRESAR
REM =================================
REM    Zobrazeni a zmena adresare
REM =================================
call %DMIP%\aktdir.bat
copy /b %DMIP%\voldir.dat + %DMIP%\adr.lst %DMIP%\voldir.lst >nul
%DMIP%\vyber %DMIP%\voldir.lst %DMIP%\voldir.tmp /E10/D28/C38/V19 %1
if errorlevel 255 goto KONEC
copy /b %DMIP%\cd.dat + %DMIP%\voldir.tmp %DMIP%\cddir.bat >nul
call %DMIP%\cddir.bat
del %DMIP%\cddir.bat
goto ADRESAR

:KONEC
del %DMIP%\voldir.lst >nul
call %DMIP%\delexist.bat %DMIP%\voldir.tmp
