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
 echo 浜様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様融
 echo � V��en� u�ivatel� DOSMANA,                                          �
 echo �                                                                    �
 echo � pro  v��n�  z�jemce je p�ipraven OBR�ZKOV� KATALOG - celkem 655 PC �
 echo � her.  Ka�d� hra m� v katalogu jeden celoobrazovkov� v�jev. Katalog �
 echo � umo��uje  listovat  v seznamu her, zobrazovat obr�zky jednotliv�ch �
 echo � her a vybran� hry spou�t�t. Ve zkompresovan� podob� katalog zab�r� �
 echo � 4 ks DSHD 5.25" diskety a m��ete ho obdr�et za cenu disket + mani- �
 echo � pula�n� poplatek a po�tovn�, celkem cca 150 K�. Snadno lze katalog �
 echo � modifikovat, obohacovat o dal─ hry.                               �
 echo �                                                                    �
 echo � S pozdravem a p��n�m dobr� z�bavy u Va�eho po��ta�e                �
 echo �                                                          Va�e GEMA �
 echo 藩様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様夕
 echo.
 %3utility\wait "Stiskn�te libovolnou kl�vesu: "
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
