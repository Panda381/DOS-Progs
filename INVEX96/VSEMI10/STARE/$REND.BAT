exe\inkey ?
if errorlevel 1 goto Dale
if not exist gema_%1.pov goto Dale
echo %1
if exist gema_%1.tga goto Dale1
exe\povray +Igema_%1.pov +Ogema_%1.tga +W320 +H200 -X -J +D +Q9 +A0 +MB1 %2 %3 %4 %5

:Dale1
if not "%1"=="0" goto Dale2
for %%X in (1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 21 22 23) do call $copy %1 %%X

:Dale2

if not "%1"=="20" goto Dale3
for %%X in (24 25 26 27 28 29 30 31 32 33 34 35 36 37) do call $copy %1 %%X

:Dale3
if not "%1"=="045" goto Dale4
for %%X in (46 47 48 49 50 51 52 53) do call $copy %1 %%X

:Dale4
if not "%1"=="110" goto Dale5
for %%X in (11 12 13 14 15 16 17 18 19) do call $copy %1 1%%X

:Dale5
if not "%1"=="140" goto Dale6
for %%X in (41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59) do call $copy %1 1%%X

:Dale6
if not "%1"=="160" goto Dale
for %%X in (61 62 63 64 65 66 67 68 69) do call $copy %1 1%%X

:Dale
