@echo off
:start
tasm k8.asm /z/l 
kontext k8.asm #2 k8.lst #3 kont8.lst #2
goto start
