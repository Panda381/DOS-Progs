@echo off

if "%1" == "" goto KONEC
if not exist %1 goto KONEC

rem ARCHIV

if "%5" == "ARC" goto _ARC
for %%c in (ARJ A01 A02 A03 A04 A05 A06 A07 A08 A09) do if "%%c" == "%5" goto _ARJ
for %%c in (A10 A11 A12 A13 A14 A15 A16 A17 A18 A19) do if "%%c" == "%5" goto _ARJ
if "%5" == "ICE" goto _ICE
if "%5" == "LZH" goto _LZH
if "%5" == "ZIP" goto _ZIP

rem TEXT

if "%5" == "602" goto _602
if "%5" == "CSE" goto _CSE
if "%5" == "DAT" goto _DAT
if "%5" == "DBF" goto _DBF
if "%5" == "HLP" goto _HLP
if "%5" == "MAT" goto _MAT
for %%c in (BAT DOC DOK INI LST MNU TXT) do if "%%c" == "%5" goto _TXT

rem GRAFIKA

if "%5" == "SCR" goto _SCR
if "%5" == "UPL" goto _UPL
for %%c in (BMP CUT GIF LBM PCX PIC TGA) do if "%%c" == "%5" goto _VPIC

rem HUDBA

if "%5" == "MOD" goto _MOD
for %%c in (FRQ NTI SAM SND SPK VOC WAV) do if "%%c" == "%5" goto _SOU

rem OSTATNã - NEURÄENO

%3view\hlp.com %1
goto KONEC

-------------------------------------------------------------------- ARCHIV ---

:_ARC
pkunpak -v %1 > %3$view$.lst
%3view\hlp.com %3$view$.lst
goto KONEC
:_ARJ
arj v -v -y %1 > %3$view$.lst
%3view\hlp.com %3$view$.lst
goto KONEC
:_ICE
ice l %1 > %3$view$.lst
%3view\hlp.com %3$view$.lst
goto KONEC
:_LZH
lha l %1 > %3$view$.lst
%3view\hlp.com %3$view$.lst
goto KONEC
:_ZIP
pkunzip -v %1 > %3$view$.lst
%3view\hlp.com %3$view$.lst
goto KONEC

---------------------------------------------------------------------- TEXT ---

:_602
%3view\qview602.com %1
goto KONEC
:_CSE
%3view\qviewcse.com %1
goto KONEC
:_DAT
%3seznam\seznam.exe %1
goto KONEC
:_DBF
%3view\dbview.com %1
goto KONEC
:_HLP
%3view\hlp.com %1 /k
goto KONEC
:_MAT
%3view\qviewmat.com %1
goto KONEC
:_TXT
%3view\hlp.com %1
goto KONEC

------------------------------------------------------------------- GRAFIKA ---

:_SCR
%3utility\gdemo.com %1
goto KONEC
:_UPL
%3uplet\uplet.com %1
goto KONEC
:_VPIC
%3sharewar\vpic\vpic
goto KONEC

--------------------------------------------------------------------- HUDBA ---

:_MOD
%3music\music.exe %1
goto KONEC
:_SOU
%3view\sound.com %1
goto KONEC

------------------------------------------------------------------ POZNèMKY ---

:KONEC
