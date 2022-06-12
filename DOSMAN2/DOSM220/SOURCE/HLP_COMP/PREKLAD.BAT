@echo off
..\exec\tasm HLP_COMP.ASM /z/zn/m5/t
..\exec\tlink HLP_COMP.OBJ /x/t
del HLP_COMP.OBJ
