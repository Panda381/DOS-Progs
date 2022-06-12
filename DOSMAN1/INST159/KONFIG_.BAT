@echo off
if "%2"=="" goto K
call %2dosm %2user%1.bat
echo.
echo N†sleduje modifikace n†povàdy pro Ctrl-F%1.
%2utility\wait "Stisknàte libovolnou kl†vesu, Esc = p©eru®en°: "
if errorlevel 1 goto K
call %2dosm %2dosman.use
echo.
echo ========== V A R O V è N ã =========
echo Pokud byla provedena zmàna n†povàdy,
echo je nutno spustit  DOS Manaëer znovu,
echo aby se zmàna projevila.
echo.
%2utility\wait "Stisknàte libovolnou kl†vesu: "

:K
