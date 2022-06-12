@echo off
if exist %0\..\HIEW.EXE goto Start
if exist %0\..\INSTALL\HIEW.DOS goto Inst
%0\..\HIEWCS\HIEWCS.EXE %1 %2 %3 %4 %5 %6 %7 %8 %9
goto Konec

:Inst
copy %0\..\INSTALL\HIEW.DOS %0\..\HIEW.EXE > NUL
copy %0\..\INSTALL\HIEW.HLP %0\..\HIEW.HLP > NUL

:Start
%0\..\HIEW.EXE %1 %2 %3 %4 %5 %6 %7 %8 %9
:Konec
