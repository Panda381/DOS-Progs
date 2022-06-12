@echo off
bin\egacs w
bin\cskey w

:Znovu
bin\kontext control.asm #2 mainform.asm #3 forms.asm #4 graphics.asm #5 def.inc #1

bin\brcc -fobaltik -ires baltik
if errorlevel 1 pause
if errorlevel 1 goto Znovu

bin\tasm /z /t /zn /m10 /mu stub,stub
if errorlevel 1 pause
if errorlevel 1 goto Znovu

bin\tlink /x stub,stub
if errorlevel 1 pause
if errorlevel 1 goto Znovu
if exist stub.obj del stub.obj

bin\tasm /z /t /zi /m10 /mu /iinclude winmain
if errorlevel 1 pause
if errorlevel 1 goto Znovu

bin\tasm /z /t /zi /m10 /mu /iinclude mainform
if errorlevel 1 pause
if errorlevel 1 goto Znovu

bin\tasm /z /t /zi /m10 /mu /iinclude forms
if errorlevel 1 pause
if errorlevel 1 goto Znovu

bin\tasm /z /t /zi /m10 /mu /iinclude graphics
if errorlevel 1 pause
if errorlevel 1 goto Znovu

bin\tasm /z /t /zi /m10 /mu /iinclude bitmap
if errorlevel 1 pause
if errorlevel 1 goto Znovu

bin\tasm /z /t /zi /m10 /mu /iinclude control
if errorlevel 1 pause
if errorlevel 1 goto Znovu

bin\tlink /3 /Twe /LLIB /v /x winmain+mainform+forms+graphics+bitmap+control,!baltik,,import.lib,baltik,baltik
if errorlevel 1 pause
if errorlevel 1 goto Znovu

bin\tlink /3 /Twe /LLIB /x winmain+mainform+forms+graphics+bitmap+control,baltik,,import.lib,baltik,baltik
if errorlevel 1 pause
if errorlevel 1 goto Znovu

if exist *.obj del *.obj
if exist *.res del *.res
if exist stub.exe del stub.exe
:Konec
