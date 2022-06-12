@echo off
rem Zadejte jako parametr jmeno fontu (KAM, LAT, ...)
if "%1" == "" goto konec

getfont b
ren font14.asm %114BIN.ASM
getfont h
ren font14.asm %114HEX.ASM
getfont d
ren font14.asm %114DEC.ASM

:konec
