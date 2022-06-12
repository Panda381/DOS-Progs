@echo off
:start
rem c:
rem c:\!\gmenu.com
gmenu.com
if errorlevel == 254 goto Start

if errorlevel == 25 goto Konec

if errorlevel == 23 goto SimEarth
if errorlevel == 22 goto Rockford
if errorlevel == 21 goto ZanyGolf
if errorlevel == 20 goto MGolf
if errorlevel == 19 goto Vegas
if errorlevel == 18 goto Malovani
if errorlevel == 17 goto Historik
if errorlevel == 16 goto Smycky
if errorlevel == 15 goto Krtek
if errorlevel == 14 goto Tom
if errorlevel == 13 goto Simpsoni
if errorlevel == 12 goto Motorky
if errorlevel == 11 goto Letadla
if errorlevel == 10 goto Bludiste
if errorlevel == 9 goto Vlak
if errorlevel == 8 goto Vejce
if errorlevel == 7 goto Tetrix
if errorlevel == 6 goto Abeceda
if errorlevel == 5 goto Varhany
if errorlevel == 4 goto Slova
if errorlevel == 3 goto Auta
if errorlevel == 2 goto Mesta
if errorlevel == 1 goto Potrubi
goto Start


:Potrubi
 cd\relax\pipe
 c:\gmouse\gmouse u
 pipe0
 c:\gmouse\gmouse 2 *4
 goto Start

:Mesta
 cd\relax\simcity
 simcity0
 goto Start

:Auta
 cd\relax\stunts
 st
 goto Start

:Slova
 cd\relax\wr
 wr1
 goto Start

:Varhany
 cd\relax\006
 006
 goto Start

:Abeceda
 cd\dosman\relax
 abeceda
 goto Start

:Tetrix
 c:\dosman\klavesn\cskey /1
 c:\dosman\utility\rychklav
 c:\dosman\utility\setlock Ncs
 c:\dosman\relax\tetrix
 goto Start

:Vejce
 c:\dosman\relax\vejce.com
 goto Start

:Vlak
 c:\dosman\relax\vlak.com
 goto Start

:Bludiste
 cd\relax\bludiste
 bludiste
 goto Start

:Letadla
 cd\relax\fs3
 fs3
 goto Start

:Motorky
 cd\relax\gpmoto
 gpega
 goto Start

:Simpsoni
 cd\relax\simpsons
 call simpsons
 goto Start

:Tom
 cd\relax\tomjerry
 tj
 goto Start

:Krtek
 c:\dosman\relax\pf1993
 goto Start

:Smycky
 cd\relax\loopz
 call start
 goto Start

:Historik
 cd\relax\historik
 histori0
 goto Start
	
:Malovani
 cd\dosman\maluj
 maluj
 goto Start

:Vegas
 c:\dosman\relax\vegas
 goto start

:MGolf
 cd\relax\mgolf
 egagolf0
 goto start

:ZanyGolf
 cd\relax\zanygolf
 zany0
 goto start

:Rockford
 cd\relax\rockford
 c:\dosman\klavesn\inkey "n"
 rockford
 goto start

:SimEarth
 cd\relax\simearth
 simeart0
 goto start

:Konec
