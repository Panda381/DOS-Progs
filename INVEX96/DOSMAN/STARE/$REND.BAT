exe\inkey ?
if errorlevel 1 goto Dale
if not exist gema_%1.pov goto Dale
echo %1
if exist gema_%1.tga goto Dale
exe\povray +Igema_%1.pov +Ogema_%1.tga +W320 +H200 -X -J +D +Q9 +A0 %2 %3 %4 %5
:Dale
