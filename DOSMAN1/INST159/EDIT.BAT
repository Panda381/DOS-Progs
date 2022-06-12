@echo off

if "%1" == "" goto KONEC
if not exist %1 goto KONEC

for %%c in (BMP CUT GIF IMG LBM PCX) do if "%%c" == "%5" goto OBRAZ
for %%c in (PIC RLE TGA TIF WPG)     do if "%%c" == "%5" goto OBRAZ

for %%c in (BAT DOC DOK INI LST MNU TXT) do if "%%c" == "%5" goto TEXT

:OSTATNI
%3view\hlp.com %1
goto KONEC

:OBRAZ
%3sharewar\gws\gws
goto KONEC

:TEXT
%3dosm.bat %1
goto KONEC

:KONEC
