if not exist gem_%1.pov goto Dale
echo %1
if exist gem_%1.tga goto Dale
pvengine64.exe +Igem_%1.pov +Ogem_%1.tga +W1920 +H1440 -display +V +X +J -D +Q9 +A +R2 %2 %3 %4 %5
:Dale
