@echo off
if "%1" == "" goto UPLKO
rem       --- Prohl¡‘en¡ archivn¡ch soubor– ---
goto _%6
:_ARC
pkunpak		-v		%1
goto KONEC
:_ARJ
%3sharewar\arj	l	-v -jp	%1
goto KONEC
:_ICE
ice		l		%1
goto KONEC
:_LZH
lha		l		%1
goto KONEC
:_RAR
rar		l		%1
goto KONEC
:_UC2
uc		v		%1
goto KONEC
:_ZIP
%3sharewar\pkunzip	-vm	%1
echo.
goto KONEC
:_HLP
%3view\hlp			%1
goto UPLKO
:KONEC
%3utility\wait "Stisknˆte libovolnou kl vesu: "
:UPLKO
