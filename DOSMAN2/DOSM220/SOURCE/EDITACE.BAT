@echo off
if not exist obj\*.* md OBJ
goto start1

:start

echo.
exec\wait "CHYBA ..... Esc=preruseni: "
echo.
if errorlevel 1 goto konec

:start1

exec\egacs k > NUL
exec\cskey k > NUL
cd asm
..\exec\kontext dm.asm #2  #1
cd ..
exec\cskey ! > NUL
exec\egacs ! > NUL

exec\make dm.mak /d
if errorlevel == 1 goto start

cd obj
..\exec\tlink @..\link.fil, ..\dosman.exe /x/l/v;
cd ..
if errorlevel == 1 goto start

:konec
