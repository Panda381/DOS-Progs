:start
kontext TATRA.ANI
anim.exe TATRA.ANI
if not errorlevel==1 goto konec
pause
goto start
:konec
lzexe TATRA.EXE
del TATRA.OLD
