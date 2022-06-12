@echo off
if "%1"=="" goto K
:Z
echo Vol m ‡¡slo %1 %2 %3 %4 %5 %6
if "%3"=="" goto A
echo at q0 e1 l1 m1 s6=2 s7=30 s8=1 x1 dp %1,%2,%3 %4 %5 %6 > com3
goto C
:A
if "%2"=="" goto B
echo at q0 e1 l1 m1 s6=2 s7=30 s8=1 x1 dp %1,%2 %3 %4 %5 %6 > com3
goto C
:B
echo at q0 e1 l1 m1 s6=2 s7=30 s8=1 x1 dp %1 %2 %3 %4 %5 %6 > com3
:C
wait Po spojen¡ zvedni sluch tko a stiskni kl vesu 
echo ath0>com3
ask "ZNOVU ??? - stiskni MEZERU "
echo.
if errorlevel == 32 goto Z
echo Kon‡¡m
:K
