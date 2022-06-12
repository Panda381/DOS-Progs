@echo off
rem Zadejte jako parametr jmeno fontu (KAM, LAT, ...)
if "%1" == "" goto konec

getfont b
ren font16.asm %116BIN.ASM
getfont h
ren font16.asm %116HEX.ASM
getfont d
ren font16.asm %116DEC.ASM

:konec
