@echo off
cls
..\exec\tasm DOSMFLOP.ASM /z/zn/m5/t
..\exec\tlink DOSMFLOP.OBJ /x/t
echo -------------------------------------
echo Ignorovat varovani "Open conditional"
echo -------------------------------------
del DOSMFLOP.OBJ
