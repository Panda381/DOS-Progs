@echo off
echo Zvolte:   1   = rozdàlen° souboru %1 na 32 KB kusy
echo           2   = spojen° souboru %4.0?? do souboru se jmÇnem %4
%3utility\ask "          Esc = p©eru®en°: "12
echo.
if errorlevel 3 goto K
if errorlevel 2 goto S

echo.
%3utility\cutter %1
goto K

:S
echo.
echo Spoj°m soubory %4.0?? do souboru se jmÇnem %4
%3utility\get.com Zadejte jeho p©°ponu: 
if not exist %4.%get% goto N1
echo.
echo VAROVèNã: soubor %4.%get% jië existuje a bude p©eps†n !
%3utility\wait "Stisknàte libovolnou kl†vesu, Esc = p©eru®en°: "
if errorlevel 1 goto K

:N1

if not exist %4.000 goto N2
copy /b %4.000 %4.%get%

for %%3 in (1 2 3 4 5 6 7 8 9) do if exist %4.00%%3 copy /b %4.%get% + %4.00%%3
for %%3 in (0 1 2 3 4 5 6 7 8 9) do if exist %4.01%%3 copy /b %4.%get% + %4.01%%3
for %%3 in (0 1 2 3 4 5 6 7 8 9) do if exist %4.02%%3 copy /b %4.%get% + %4.02%%3
for %%3 in (0 1 2 3 4 5 6 7 8 9) do if exist %4.03%%3 copy /b %4.%get% + %4.03%%3
for %%3 in (0 1 2 3 4 5 6 7 8 9) do if exist %4.04%%3 copy /b %4.%get% + %4.04%%3
for %%3 in (0 1 2 3 4 5 6 7 8 9) do if exist %4.05%%3 copy /b %4.%get% + %4.05%%3
for %%3 in (0 1 2 3 4 5 6 7 8 9) do if exist %4.06%%3 copy /b %4.%get% + %4.06%%3
for %%3 in (0 1 2 3 4 5 6 7 8 9) do if exist %4.07%%3 copy /b %4.%get% + %4.07%%3
for %%3 in (0 1 2 3 4 5 6 7 8 9) do if exist %4.08%%3 copy /b %4.%get% + %4.08%%3
for %%3 in (0 1 2 3 4 5 6 7 8 9) do if exist %4.09%%3 copy /b %4.%get% + %4.09%%3
goto K

:N2
echo Nenalezen soubor %4.000 ke spojen° !

:K
