@echo off
rem Spojen¡ soubor– rozdˆlen˜ch programem CUTTER
if "%1" == "" goto zad
if "%2" == "" goto zad
if exist %2 goto ex
if not exist %1.000 goto neni
copy /b %1.000 %2
for %%3 in   (1 2 3 4 5 6 7 8 9) do if exist %1.00%%3 copy /b %2 + %1.00%%3
for %%3 in (0 1 2 3 4 5 6 7 8 9) do if exist %1.01%%3 copy /b %2 + %1.01%%3
for %%3 in (0 1 2 3 4 5 6 7 8 9) do if exist %1.02%%3 copy /b %2 + %1.02%%3
for %%3 in (0 1 2 3 4 5 6 7 8 9) do if exist %1.03%%3 copy /b %2 + %1.03%%3
for %%3 in (0 1 2 3 4 5 6 7 8 9) do if exist %1.04%%3 copy /b %2 + %1.04%%3
for %%3 in (0 1 2 3 4 5 6 7 8 9) do if exist %1.05%%3 copy /b %2 + %1.05%%3
for %%3 in (0 1 2 3 4 5 6 7 8 9) do if exist %1.06%%3 copy /b %2 + %1.06%%3
for %%3 in (0 1 2 3 4 5 6 7 8 9) do if exist %1.07%%3 copy /b %2 + %1.07%%3
for %%3 in (0 1 2 3 4 5 6 7 8 9) do if exist %1.08%%3 copy /b %2 + %1.08%%3
for %%3 in (0 1 2 3 4 5 6 7 8 9) do if exist %1.09%%3 copy /b %2 + %1.09%%3
goto kon
:zad
echo Zadejte: SPOJ  jmeno_souboru  jmeno_souboru.pripona
goto kon
:ex
echo Cilovy soubor ji‘ existuje
goto kon
:neni
echo Nenalezen zdrojov˜ soubor
:kon
