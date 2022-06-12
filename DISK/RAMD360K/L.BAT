:start
kontext ramd360k.asm #2 vd.lst #1
masm ramd360k /z;
if errorlevel == 1 goto chyba
link ramd360k,ramd360k,ramd360k/m;
if errorlevel == 1 goto chyba
del ramd360k.obj
exe2bin ramd360k.exe ramd360k.sys
copy ramd360k.sys ramd360k.com
del ramd360k.exe
tdmap ramd360k.map ramd360k.tds
goto konec
:chyba
wait
goto start
:konec
