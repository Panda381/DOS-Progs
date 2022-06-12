@echo off
licence\cskey k
licence\egacs k
:start
kontext help.asm

tasm help,help /z/t/zi/dDEBUG;
if errorlevel == 1 goto chyba
tasm lekce1,lekce1 /z/t/zi/dDEBUG;
if errorlevel == 1 goto chyba
tasm lekce2,lekce2 /z/t/zi/dDEBUG;
if errorlevel == 1 goto chyba
tasm lekce3,lekce3 /z/t/zi/dDEBUG;
if errorlevel == 1 goto chyba
tasm lekce4,lekce4 /z/t/zi/dDEBUG;
if errorlevel == 1 goto chyba
tasm vsemi10,vsemi10 /z/t/zi/dDEBUG;
if errorlevel == 1 goto chyba

tlink vsemi10+lekce1+lekce2+lekce3+lekce4+help,vsemi10/l/v;
if errorlevel == 1 goto chyba
goto konec
:chyba
pause
goto start
:konec
del vsemi10.map
del vsemi10.obj
del lekce1.obj
del lekce2.obj
del lekce3.obj
del lekce4.obj
del help.obj

