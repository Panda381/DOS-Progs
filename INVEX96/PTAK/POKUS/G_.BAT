if exist dosman.pov goto dale

if exist dosm00%2.tga goto dale

3ds2pov dosman.3ds dosman.pov -adosman.vue -lbirdmat.inc -f%1 -op2 -v
if not exist dosman.pov goto dale

if exist dosm00%1.tga goto pokracuj
povray -idosman.pov -odosm00%1.tga -w320 -h200 +D +A
if exist dosm00%1.tga goto OK
goto dale

:pokracuj
povray -idosman.pov -odosm00%1.tga -w320 -h200 +D +A +C
:OK
rem del dosman.pov

:dale