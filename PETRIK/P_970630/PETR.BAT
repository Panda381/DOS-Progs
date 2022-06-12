@echo off
:Start
dosman program.prg
petr
wait "Stiskni libovolnou kl vesu, ESC=prerusen¡...."
if not errorlevel 1 goto Start
