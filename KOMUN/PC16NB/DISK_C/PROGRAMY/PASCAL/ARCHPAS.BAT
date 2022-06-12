@echo off
rem Povelov˜ soubor pro uchov n¡ d¡la v Pascalu na a:
rem P©edpokl d  se pr zdn  disketa v a:, kter  se nej-
rem prve form tuje.
echo Vlo‘te prvn¡ archiva‡n¡ disketu (adr. INC, EXE, ENG, MSC, WM) do A:
cd c:\atp
format a: /4/v:SOURCEPAS1
md a:\inc
md a:\exe
md a:\eng
md a:\msc
md a:\wm
xcopy inc a:\inc
xcopy exe a:\exe
xcopy eng a:\eng
xcopy msc a:\msc
xcopy wm a:\wm
echo Vlo‘te druhou archiva‡n¡ disketu (pro adres © ASD) do A:
format a: /4/v:SOURCEPAS2
md a:\asd
xcopy asd a:\asd
echo Vlo‘te t©et¡ archiva‡n¡ disketu(adr. SRT, PRG, XMP1) do A:
format a: /4/v:SOURCEPAS3
md a:\srt
md a:\prg
md a:\xmp1
xcopy srt a:\srt
xcopy prg a:\prg
xcopy xmp1 a:\xmp1
echo Vlo‘te ‡tvrtou archiva‡n¡ disketu (adr. MRG) do A:
format a: /4/v:SOURCEPAS4
md a:\mrg
xcopy mrg a:\mrg
echo Uchov n¡ adres ©– pro Pascal ukon‡eno
pause
cd c:\
