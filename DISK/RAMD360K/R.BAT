:start
kontext ramd360y.asm #2 vd.lst #1
masm ramd360y /z;
if errorlevel == 1 goto chyba
link ramd360y,ramd360y,ramd360y/m;
if errorlevel == 1 goto chyba
del ramd360y.obj
exe2bin ramd360y.exe ramd360y.sys
copy ramd360y.sys ramd360y.com
del ramd360y.exe
tdmap ramd360y.map ramd360y.tds
goto konec
:chyba
wait
goto start
:konec
