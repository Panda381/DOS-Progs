 @echo off
 if "%3" == "" goto DOSMAN

:Start
 @echo off
 %3klavesn\inkey !
 %3relax\grafmen2.hry\gmenu
 if errorlevel 26 goto Start
 if errorlevel 25 goto DOSMAN
 if errorlevel 24 goto Baltaz
 if errorlevel 23 goto Privat
 if errorlevel 22 goto GPU
 if errorlevel 21 goto Vsemi10
 if errorlevel 20 goto Flek
 if errorlevel 19 goto Tim
 if errorlevel 18 goto Anatomie
 if errorlevel 17 goto Vette
 if errorlevel 16 goto Toppler
 if errorlevel 15 goto Pool
 if errorlevel 14 goto Dott
 if errorlevel 13 goto Arkanoi5
 if errorlevel 12 goto Golf2
 if errorlevel 11 goto Golf1
 if errorlevel 10 goto Comex
 if errorlevel  9 goto Arkanoi4
 if errorlevel  8 goto Angl
 if errorlevel  7 goto Indi500
 if errorlevel  6 goto Elf
 if errorlevel  5 goto Eb
 if errorlevel  4 goto Ducktale
 if errorlevel  3 goto Clovece
 if errorlevel  2 goto Cisco
 if errorlevel  1 goto Zmena
 goto Start

:Zmena
 %3relax\grafmen0.hry\gm0_.bat %1 %2 %3

:Cisco
 rem cd\relax\cisco
 rem c:\dosman\klavesn\inkey F1 F10
 rem cisco
 goto Start

:Clovece
 rem cd\relax\clovece
 rem c:\dosman\klavesn\inkey ESC "O"
 rem clovece
 goto Start

:Ducktale
 rem cd\relax\ducktale
 rem c:\dosman\klavesn\inkey " N " ENTER
 rem ducktale.com
 goto Start

:Eb
 rem cd\relax\eb
 rem call eb
 goto Start

:Elf
 rem cd\relax\elf
 rem c:\dosman\klavesn\inkey ENTER
 rem elf
 goto Start

:Indi500
 rem cd\relax\indi500
 rem indy
 goto Start

:Angl
 rem cd\relax\angl
 rem ts600a
 goto Start

:Arkanoi4
 rem cd\relax\arkanoi4
 rem call `.bat
 goto Start

:Arkanoi5
 rem cd\relax\arkanoi4
 rem call `2.bat
 goto Start

:Comex
 rem c:\dosman\egacss k
 rem c:\dosman\cskey 2
 rem c:\dosman\utility\setlock C
 rem cd\relax\comex
 rem comex
 rem c:\dosman\utility\setlock c
 rem c:\dosman\cskey 1
 goto Start

:Golf1
 rem cd\relax\golf1
 rem golf
 goto Start

:Golf2
 rem cd\relax\golf4
 rem golf
 goto Start

:Golf3
 rem cd\relax\golf3
 rem golf
 goto Start

:Dott
 rem cd\relax\Dott
 rem tentacle
 goto Start

:Pool
 rem cd\relax\pool
 rem c:\dosman\klavesn\inkey "12"
 rem pool
 goto Start

:Toppler
 rem cd\relax\toppler
 rem toppler
 goto Start

:Vette
 rem cd\relax\vette
 rem vette
 goto Start

:Anatomie
 rem cd\relax\anatomie
 rem bworks
 goto Start

:Tim
 rem cd\relax\tim
 rem tim
 goto Start

:Flek
 rem
 goto Start

:Vsemi10
 %3vsemi10\vsemi10
 goto Start

:GPU
 rem
 goto Start

:Privat
 %3relax\privat
 goto Start

:Baltaz
 rem
 goto Start

:DOSMAN
