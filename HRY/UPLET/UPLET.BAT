@echo off
:START
gmenu
if errorlevel 26 goto KONEC

if errorlevel 12 goto ZAJICI
if errorlevel 11 goto ZAJIC2
if errorlevel 10 goto ZAJIC1
if errorlevel  9 goto SOKAN
if errorlevel  8 goto SNEHULAK
if errorlevel  7 goto SKRITEK2
if errorlevel  6 goto SKRITEK1
if errorlevel  5 goto PTACI
if errorlevel  4 goto MISA2
if errorlevel  3 goto MISA1
if errorlevel  2 goto KENGAI
if errorlevel  1 goto HOUBA
goto START

:HOUBA
uplet houba.upl
goto START

:KENGAI
uplet kengai.upl
goto START

:MISA1
uplet misa1.upl
goto START

:MISA2
uplet misa2.upl
goto START

:PTACI
uplet ptaci.upl
goto START

:SKRITEK1
uplet skritek1.upl
goto START

:SKRITEK2
uplet skritek2.upl
goto START

:SNEHULAK
uplet snehulak.upl
goto START

:SOKAN
uplet sokan.upl
goto START

:ZAJIC1
uplet zajic1.upl
goto START

:ZAJIC2
uplet zajic2.upl
goto START

:ZAJICI
uplet zajici.upl
goto START

:KONEC
