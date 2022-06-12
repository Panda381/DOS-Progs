@echo off
cls

echo.
echo * Instalace programu VSEMI10 na pevny disk s celkovou kapacitou vetsi jak 5 MB *
echo.

if not "%2"=="" goto H
if "%1"=="A:" goto T
if "%1"=="a:" goto T
if "%1"=="B:" goto T
if "%1"=="b:" goto T

:H
echo Zadejte, prosim, jako parametr jmeno mechaniky A: nebo B:, z ktere je
echo program VSEMI10 instalovan (zadejte "A:INSTAL A:" nebo "B:INSTAL B:")
echo.
goto k

:T
if not exist %1\VSEMI10.EXE goto N
if not exist %1\GET.COM goto N
if not exist %1\ASK.COM goto N
if not exist %1\READ0.COM goto N
if not exist %1\CTI.COM goto N
if not exist %1\CTI_MNE.TXT goto N
if exist %1\HDINST.EXE goto OK

:N
echo V mechanice %1 neni vlozena spravna licencni disketa s programem VSEMI10 
echo.
goto k

:OK
echo Instalace programu VSEMI10 probehne do adresare:
echo C:\VSEMI10
echo.

%1\get.com Potvrdte stiskem Enter nebo zadejte novy disk:\adresar 
if not "%get%"=="" goto s
%1\setdir.com c:\vsemi10
if errorlevel==5 goto p
if errorlevel==4 goto z
if errorlevel==3 goto a
if errorlevel==2 goto d
if errorlevel==1 goto b
goto p

:v
echo.
echo Instalace programu VSEMI10 probehne do adresare:
cd
echo.

%1\get.com Potvrdte stiskem Enter nebo zadejte novy disk:\adresar 
if "%get%"=="" goto p

:s
%1\setdir.com %get%
if errorlevel==5 goto p
if errorlevel==4 goto z
if errorlevel==3 goto a
if errorlevel==2 goto d
if errorlevel==1 goto b
goto v

:z
echo Chyba !  Zadejte napriklad C:\POKUS\00 
goto v

:a
echo Chybne zadani adresare ! 
goto v

:d
echo Chybne zadani disku ! 
goto v

:b
echo ** Instalace prerusena **
goto k

:p
echo.
echo Cekejte, probiha instalace VSEMI10 na pevny disk...

%1\setdir.com testy
copy %1\testy\*.*>nul
cd ..

%1\setdir.com demo
copy %1\demo\*.*>nul
cd ..

copy %1\cti*.*>nul
%1\copyh %1\cti.com vsemi10.exe>nul
copy %1\*.*>nul
%1\copyh %1\cti.com vsemi10.exe>nul

hdinst %1vsemi10.exe

del copyh*.*>nul
del hdins*.*>nul
del insta*.*>nul
del setdi*.*>nul
del testd*.*>nul

dopis

:k
