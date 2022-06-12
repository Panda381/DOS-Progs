@echo off
if not exist obj\*.* md OBJ

exec\make dm.mak /d
if errorlevel == 1 goto konec

cd obj
..\exec\tlink @..\link.fil, ..\dosman.exe /m;
cd ..

:konec

