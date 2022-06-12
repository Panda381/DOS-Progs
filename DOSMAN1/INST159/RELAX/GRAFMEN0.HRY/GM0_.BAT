 @echo off
 if "%3" == "" goto DOSMAN

:Start
 @echo off
 %3klavesn\inkey !
 %3relax\grafmen0.hry\gmenu
 if errorlevel 26 goto Start
 if errorlevel 25 goto DOSMAN
 if errorlevel 21 goto Vsemi10
 if errorlevel 19 goto Vlak
 if errorlevel 18 goto Vejce
 if errorlevel 17 goto Vegas
 if errorlevel 14 goto Tetrix
 if errorlevel 13 goto Privat
 if errorlevel 12 goto Maluj
 if errorlevel  9 goto Krtek
 if errorlevel  8 goto Bludiste
 if errorlevel  7 goto Abeceda
 if errorlevel  5 goto Katalog
 if errorlevel  3 goto Vybarvi
 if errorlevel  1 goto Zmena
 goto Start

:Zmena
 %3relax\grafmen1.hry\gm1_.bat %1 %2 %3

:Vybarvi
 cd > %3$dir$.lst
 %3utility\setdir %3vybarvi
 vybarvi
 %3utility\setdir @%3$dir$.lst
 goto Start

:Katalog
 cls
 echo.
 echo.
 echo ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
 echo º V ‘en¡ u‘ivatel‚ DOSMANA,                                          º
 echo º                                                                    º
 echo º pro  v ‘n‚  z jemce je p©ipraven OBRZKOV KATALOG - celkem 655 PC º
 echo º her.  Ka‘d  hra m  v katalogu jeden celoobrazovkov˜ v˜jev. Katalog º
 echo º umo‘¤uje  listovat  v seznamu her, zobrazovat obr zky jednotliv˜ch º
 echo º her a vybran‚ hry spou¨tˆt. Ve zkompresovan‚ podobˆ katalog zab¡r  º
 echo º 4 ks DSHD 5.25" diskety a m–‘ete ho obdr‘et za cenu disket + mani- º
 echo º pula‡n¡ poplatek a po¨tovn‚, celkem cca 150 K‡. Snadno lze katalog º
 echo º modifikovat, obohacovat o dal¨¡ hry.                               º
 echo º                                                                    º
 echo º S pozdravem a p© n¡m dobr‚ z bavy u Va¨eho po‡¡ta‡e                º
 echo º                                                          Va¨e GEMA º
 echo ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
 echo.
 %3utility\wait "Stisknˆte libovolnou kl vesu: "
 goto Start

:Abeceda
 %3relax\abeceda
 goto Start

:Bludiste
 %3relax\bludiste
 goto Start

:Krtek
 %3relax\pf
 goto Start

:Maluj
 cd > %3$dir$.lst
 %3utility\setdir %3maluj
 maluj
 %3utility\setdir @%3$dir$.lst
 goto Start

:Privat
 %3relax\privat
 goto Start

:Tetrix
 %3relax\tetrix
 goto Start

:Vegas
 %3relax\vegas
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

:Vsemi10
 %3vsemi10\vsemi10
 goto Start

:DOSMAN
