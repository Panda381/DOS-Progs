@echo off
if "%2"=="" goto K
call %2dosm %2user%1.bat
echo.
echo N�sleduje modifikace n�pov�dy pro Ctrl-F%1.
%2utility\wait "Stiskn�te libovolnou kl�vesu, Esc = p�eru�en�: "
if errorlevel 1 goto K
call %2dosm %2dosman.use
echo.
echo ========== V A R O V � N � =========
echo Pokud byla provedena zm�na n�pov�dy,
echo je nutno spustit  DOS Mana�er znovu,
echo aby se zm�na projevila.
echo.
%2utility\wait "Stiskn�te libovolnou kl�vesu: "

:K
