:start
c:\assemb\kontext ANIMI.asm
masm ANIMI /z;
if errorlevel == 1 goto chyba
link ANIMI,ANIMI,ANIMI/m;
if errorlevel == 1 goto chyba
del ANIMI.obj
rem tdmap ANIMI.map animi.tds
rem copy animi.tds pf1992\pf1992_.tds
del ANIMI.MAP
copy /b animc.exe + animi.exe anim.exe
animx
goto konec
:chyba
wait
goto start
:konec
