@echo off
rem Zadejte jako parametr jmeno fontu (KAM, LAT, ...)
if "%1" == "" goto konec

getfont b
ren font08.asm %108BIN.ASM
getfont h
ren font08.asm %108HEX.ASM
getfont d
ren font08.asm %108DEC.ASM

:konec
