:start
c:\assemb\kontext ANIMC.asm
masm ANIMC /z;
if errorlevel == 1 goto chyba
link ANIMC,ANIMC,ANIMC/m;
if errorlevel == 1 goto chyba
del ANIMC.OBJ
copy /b ANIMC.EXE+ANIMI.EXE ANIM.EXE
animx
tdmap ANIMC.MAP ANIM.TDS
del ANIMC.MAP
goto konec
:chyba
wait
goto start
:konec
