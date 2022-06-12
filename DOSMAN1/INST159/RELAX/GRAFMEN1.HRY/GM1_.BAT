 @echo off
 if "%3" == "" goto DOSMAN

:Start
 @echo off
 %3klavesn\inkey !
 %3relax\grafmen1.hry\gmenu
 if errorlevel 26 goto Start
 if errorlevel 25 goto DOSMAN
 if errorlevel 24 goto SimEarth
 if errorlevel 23 goto Rockford
 if errorlevel 22 goto ZanyGolf
 if errorlevel 21 goto MGolf
 if errorlevel 20 goto Vegas
 if errorlevel 19 goto Maluj
 if errorlevel 18 goto Historik
 if errorlevel 17 goto Smycky
 if errorlevel 16 goto Krtek
 if errorlevel 15 goto Tom
 if errorlevel 14 goto Simpsoni
 if errorlevel 13 goto Motorky
 if errorlevel 12 goto Letadla
 if errorlevel 11 goto Bludiste
 if errorlevel 10 goto Vlak
 if errorlevel  9 goto Vejce
 if errorlevel  8 goto Tetrix
 if errorlevel  7 goto Abeceda
 if errorlevel  6 goto Varhany
 if errorlevel  5 goto Slova
 if errorlevel  4 goto Auta
 if errorlevel  3 goto Mesta
 if errorlevel  2 goto Potrubi
 if errorlevel  1 goto Zmena
 goto Start

:Zmena
 %3relax\grafmen2.hry\gm2_.bat %1 %2 %3

:Potrubi
 rem cd\relax\pipe
 rem c:\gmouse\gmouse u
 rem pipe0
 rem c:\gmouse\gmouse 2 *4
 goto Start

:Mesta
 rem cd\relax\simcity
 rem simcity0
 goto Start

:Auta
 rem cd\relax\stunts
 rem st
 goto Start

:Slova
 rem cd\relax\wr
 rem c:\sgnxpro\utility\sgpvol /vf:0,0
 rem wr1
 rem c:\sgnxpro\utility\sgpvol /vf:15,15
 rem c:\sgnxpro\demofm
 goto Start

:Varhany
 rem cd\relax\006
 rem 006
 goto Start

:Abeceda
 %3relax\abeceda
 goto Start

:Tetrix
 %3relax\tetrix
 goto Start

:Vejce
 %3relax\vejce
 goto Start

:Vlak
 cd > %3$dir$.lst
 %3utility\setdir %3relax
 call vlak.bat
 %3utility\setdir @%3$dir$.lst
 goto Start

:Bludiste
 %3relax\bludiste
 goto Start

:Letadla
 rem cd\relax\fs3
 rem fs3
 goto Start

:Motorky
 rem cd\relax\gpmoto
 rem gpega
 goto Start

:Simpsoni
 rem cd\relax\simpsons
 rem call simpsons
 goto Start

:Tom
 rem cd\relax\tomjerry
 rem tj
 goto Start

:Krtek
 %3relax\pf
 goto Start

:Smycky
 rem cd\relax\loopz
 rem call Start
 goto Start

:Historik
 rem cd\relax\historik
 rem histori0
 goto Start
	
:Maluj
 cd > %3$dir$.lst
 %3utility\setdir %3maluj
 maluj
 %3utility\setdir @%3$dir$.lst
 goto Start

:Vegas
 %3relax\vegas
 goto Start

:MGolf
 rem cd\relax\mgolf
 rem egagolf0
 goto Start

:ZanyGolf
 rem cd\relax\zanygolf
 rem zany0
 goto Start

:Rockford
 rem cd\relax\rockford
 rem c:\dosman\klavesn\inkey "n"
 rem rockford
 goto Start

:SimEarth
 rem cd\relax\simearth
 rem simeart0
 goto Start

:DOSMAN
