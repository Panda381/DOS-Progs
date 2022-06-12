@echo off
if exist vsemi10.exe del vsemi10.exe

:start
kontext vsemi10.asm

tasm help,help /z/t/ddemo;
if errorlevel == 1 goto chyba
tasm lekce1,lekce1 /z/t/ddemo;
if errorlevel == 1 goto chyba
tasm lekce2,lekce2 /z/t/ddemo;
if errorlevel == 1 goto chyba
tasm lekce3,lekce3 /z/t/ddemo;
if errorlevel == 1 goto chyba
tasm lekce4,lekce4 /z/t/ddemo;
if errorlevel == 1 goto chyba
tasm vsemi10,vsemi10 /z/t/ddemo;
if errorlevel == 1 goto chyba

tlink vsemi10+lekce1+lekce2+lekce3+lekce4+help,demo\vsemi10;
if errorlevel == 1 goto chyba
goto konec
:chyba
pause
goto start

:konec
del demo\vsemi10.map
del vsemi10.obj
del lekce1.obj
del lekce2.obj
del lekce3.obj
del lekce4.obj
del help.obj
rem cd demo
rem lzexe vsemi10.exe
rem del vsemi10.old
rem cd..

