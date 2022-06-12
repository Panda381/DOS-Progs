@echo off
rem
rem P©¡klad p©¡pravy makra pro zobrazen¡ aktu ln¡ho dne
rem
rem   Tyto © dky je vhodn‚ doplnit do AUTOEXEC.BAT !
rem
copy getdat_.mac getdat.mac > nul
getdat >> getdat.mac
echo ">> getdat.mac
makro ! > nul
makro b 1000 > nul
makro r getdat.mac > nul
echo.
echo Aktu ln¡ den nyn¡ z¡sk te stiskem kl ves Ctrl-Shift-D !
echo.
