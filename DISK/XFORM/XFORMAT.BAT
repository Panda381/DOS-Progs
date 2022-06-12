@echo off

:Start
set DSK=
set POL=
set FRM=

rem ======================================================================
rem           Volba disku k formatovani, zobrazeni a preruseni
rem ======================================================================
cls
echo.
echo.
echo                        ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
echo                        ³    X F O R M    ³°°
echo                        ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ°°
echo.                         °°°°°°°°°°°°°°°°°°°
echo.
echo                    Rezidentni formatovani disket
echo.
echo.
echo.
echo             A ....... volba disku A: k formatovani 1 diskety
echo             B ....... volba disku B: k formatovani 1 diskety
echo             1 ....... volba disku A: k formatovani vice disket
echo             2 ....... volba disku B: k formatovani vice disket
echo.
echo             D ....... zobrazeni prubehu formatovani
echo             Q ....... preruseni probihajiciho formatovani
echo             X ....... odinstalovani programu XFORM z pameti
echo           [Esc] ..... preruseni volby
echo.
echo.
echo.
ask "Zvolte operaci (stisknete A, B, 1, 2, D, Q, X nebo [Esc]): "ab12dqx

if errorlevel 8 goto Konec
if errorlevel 7 goto Odinst
if errorlevel 6 goto Prerus
if errorlevel 5 goto Zobraz
if errorlevel 4 goto DiskBP
if errorlevel 3 goto DiskAP
if errorlevel 2 goto DiskB
if errorlevel 1 goto DiskA


:Zobraz
rem ======================================================================
rem                      Zobrazeni prubehu formatovani
rem ======================================================================
xform d
goto Start

:Prerus
rem ======================================================================
rem                   Preruseni probihajiciho formatovani
rem ======================================================================
xform q > nul
goto Start

:Odinst
rem ======================================================================
rem                   Odinstalovani programu z pameti
rem ======================================================================
cls
xform !
echo.
ask "Stisknete libovolnou klavesu..."
goto Start


:DiskBP
set POL=P
goto DiskB

:DiskAP
set POL=P

:DiskA
set DSK=A
goto DiskDale

:DiskB
set DSK=B

:DiskDale

rem ======================================================================
rem               Rozliseni typu mechaniky k formatovani
rem ======================================================================

cls
typflop %DSK% > nul

if errorlevel 5 goto Disk5
if errorlevel 4 goto Disk4
if errorlevel 3 goto Disk3
if errorlevel 2 goto Disk2
if errorlevel 1 goto Disk1

echo.
echo Disk %DSK%: neni nainstalovan !
echo.
ask "Stisknete libovolnou klavesu..."
goto Start

:Disk1
rem ======================================================================
rem           Volba formatu diskety pro mechaniku 360 KB 5 1/4"
rem ======================================================================
echo (Pozn.: "*" oznacuje nestandardni formaty - vyzaduji instalaci XFLOP.COM)
echo.
echo.
echo            ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
echo            ³   Formatovani v mechanice %DSK%: (360 KB  5 1/4")   ³°°
echo            ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ°°
echo              °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
echo.
echo.
echo.
echo             A ...... 360 KB (DD, 40 stop,  9 sektoru, 2 strany)
echo             B ...... 320 KB (DD, 40 stop,  8 sektoru, 2 strany)
echo             C ...... 180 KB (DD, 40 stop,  9 sektoru, 1 strana)
echo             D ...... 160 KB (DD, 40 stop,  8 sektoru, 1 strana)
echo           * E ...... 533 KB (DD, 41 stop, 13 sektoru, 2 strany)
echo           * F ...... 410 KB (DD, 41 stop, 10 sektoru, 2 strany)
echo           * G ...... 266 KB (DD, 41 stop, 13 sektoru, 1 strana)
echo           * H ...... 205 KB (DD, 41 stop, 10 sektoru, 1 strana)
echo           [Esc]..... preruseni operace
echo.
echo.
echo.
echo.
ask "Zvolte pozadovany format diskety A az H (popr. [Esc]=preruseni): "abcdefgh

if errorlevel 9 goto Start
if errorlevel 8 goto F205
if errorlevel 7 goto F266
if errorlevel 6 goto F410
if errorlevel 5 goto F533
if errorlevel 4 goto F160
if errorlevel 3 goto F180
if errorlevel 2 goto F320
if errorlevel 1 goto F360


:Disk2
rem ======================================================================
rem           Volba formatu diskety pro mechaniku 1.2 MB 5 1/4"
rem ======================================================================
echo (Pozn.: "*" oznacuje nestandardni formaty - vyzaduji instalaci XFLOP.COM)
echo.
echo.
echo            ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
echo            ³   Formatovani v mechanice %DSK%: (1.2 MB  5 1/4")   ³°°
echo            ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ°°
echo              °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
echo.
echo             A ...... 1.2 MB (HD, 80 stop, 15 sektoru, 2 strany)
echo             B ...... 360 KB (DD, 40 stop,  9 sektoru, 2 strany)
echo             C ...... 320 KB (DD, 40 stop,  8 sektoru, 2 strany)
echo             D ...... 180 KB (DD, 40 stop,  9 sektoru, 1 strana)
echo             E ...... 160 KB (DD, 40 stop,  8 sektoru, 1 strana)
echo           * F .... 1.476 MB (HD, 82 stop, 18 sektoru, 2 strany)
echo           * G ..... 1.44 MB (HD, 80 stop, 18 sektoru, 2 strany)
echo           * H ...... 820 KB (DD, 82 stop, 10 sektoru, 2 strany)
echo           * I ...... 720 KB (DD, 80 stop,  9 sektoru, 2 strany)
echo           * J ...... 410 KB (DD, 41 stop, 10 sektoru, 2 strany)
echo           * K ...... 280 KB (DD, 40 stop,  7 sektoru, 2 strany)
echo           * L ...... 205 KB (DD, 41 stop, 10 sektoru, 1 strana)
echo           * M ...... 140 KB (DD, 40 stop,  7 sektoru, 1 strana)
echo           [Esc]..... preruseni operace
echo.
ask "Zvolte pozadovany format diskety A az M (popr. [Esc]=preruseni): "abcdefghijklm

if errorlevel 14 goto Start
if errorlevel 13 goto F140
if errorlevel 12 goto F205
if errorlevel 11 goto F280
if errorlevel 10 goto F410
if errorlevel 9 goto F720
if errorlevel 8 goto F820
if errorlevel 7 goto F1440
if errorlevel 6 goto F1476
if errorlevel 5 goto F160
if errorlevel 4 goto F180
if errorlevel 3 goto F320
if errorlevel 2 goto F360
if errorlevel 1 goto F1200


:Disk3
rem ======================================================================
rem           Volba formatu diskety pro mechaniku 720 KB 3 1/2"
rem ======================================================================
echo (Pozn.: "*" oznacuje nestandardni formaty - vyzaduji instalaci XFLOP.COM)
echo.
echo.
echo            ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
echo            ³   Formatovani v mechanice %DSK%: (720 KB  3 1/2")   ³°°
echo            ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ°°
echo              °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
echo.
echo.
echo             A ...... 720 KB (DD, 80 stop,  9 sektoru, 2 strany)
echo           * B .... 1.066 MB (DD, 82 stop, 13 sektoru, 2 strany)
echo           * C ...... 820 KB (DD, 82 stop, 10 sektoru, 2 strany)
echo           * D ...... 533 KB (DD, 41 stop, 13 sektoru, 2 strany)
echo           * E ...... 410 KB (DD, 41 stop, 10 sektoru, 2 strany)
echo           * F ...... 360 KB (DD, 40 stop,  9 sektoru, 2 strany)
echo           * G ...... 320 KB (DD, 40 stop,  8 sektoru, 2 strany)
echo           * H ...... 266 KB (DD, 41 stop, 13 sektoru, 1 strana)
echo           * I ...... 205 KB (DD, 41 stop, 10 sektoru, 1 strana)
echo           * J ...... 180 KB (DD, 40 stop,  9 sektoru, 1 strana)
echo           * K ...... 160 KB (DD, 40 stop,  8 sektoru, 1 strana)
echo           [Esc]..... preruseni operace
echo.
echo.
ask "Zvolte pozadovany format diskety A az K (popr. [Esc]=preruseni): "abcdefghijk

if errorlevel 12 goto Start
if errorlevel 11 goto F160
if errorlevel 10 goto F180
if errorlevel 9 goto F205
if errorlevel 8 goto F266
if errorlevel 7 goto F320
if errorlevel 6 goto F360
if errorlevel 5 goto F410
if errorlevel 4 goto F533
if errorlevel 3 goto F820
if errorlevel 2 goto F1066
if errorlevel 1 goto F720


:Disk4
rem ======================================================================
rem           Volba formatu diskety pro mechaniku 1.44 MB 3 1/2"
rem ======================================================================
echo (Pozn.: "*" oznacuje nestandardni formaty - vyzaduji instalaci XFLOP.COM)
echo.
echo           ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
echo           ³   Formatovani v mechanice %DSK%: (1.44 MB  3 1/2")   ³°°
echo           ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ°°
echo             °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
echo.
echo             A ..... 1.44 MB (HD, 80 stop, 18 sektoru, 2 strany)
echo             B ...... 720 KB (DD, 80 stop,  9 sektoru, 2 strany)
echo           * C .... 1.722 MB (HD, 82 stop, 21 sektoru, 2 strany)
echo           * D ...... 1.2 MB (HD, 80 stop, 15 sektoru, 2 strany)
echo           * E .... 1.066 MB (DD, 82 stop, 13 sektoru, 2 strany)
echo           * F ...... 820 KB (DD, 82 stop, 10 sektoru, 2 strany)
echo           * G ...... 533 KB (DD, 41 stop, 13 sektoru, 2 strany)
echo           * H ...... 410 KB (DD, 41 stop, 10 sektoru, 2 strany)
echo           * I ...... 360 KB (DD, 40 stop,  9 sektoru, 2 strany)
echo           * J ...... 320 KB (DD, 40 stop,  8 sektoru, 2 strany)
echo           * K ...... 266 KB (DD, 41 stop, 13 sektoru, 1 strana)
echo           * L ...... 205 KB (DD, 41 stop, 10 sektoru, 1 strana)
echo           * M ...... 180 KB (DD, 40 stop,  9 sektoru, 1 strana)
echo           * N ...... 160 KB (DD, 40 stop,  8 sektoru, 1 strana)
echo           [Esc]..... preruseni operace
echo.
ask "Zvolte pozadovany format diskety A az N (popr. [Esc]=preruseni): "abcdefghijklmn

if errorlevel 15 goto Start
if errorlevel 14 goto F160
if errorlevel 13 goto F180
if errorlevel 12 goto F205
if errorlevel 11 goto F266
if errorlevel 10 goto F320
if errorlevel 9 goto F360
if errorlevel 8 goto F410
if errorlevel 7 goto F533
if errorlevel 6 goto F820
if errorlevel 5 goto F1066
if errorlevel 4 goto F1200
if errorlevel 3 goto F1722
if errorlevel 2 goto F720
if errorlevel 1 goto F1440

:Disk5
rem ======================================================================
rem           Volba formatu diskety pro mechaniku 2.88 MB 3 1/2"
rem ======================================================================
echo (Pozn.: "*" oznacuje nestandardni formaty - vyzaduji instalaci XFLOP.COM)
echo.
echo           ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
echo           ³   Formatovani v mechanice %DSK%: (2.88 MB  3 1/2")   ³°°
echo           ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ°°
echo             °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
echo             A ..... 2.88 MB (QD, 80 stop, 36 sektoru, 2 strany)
echo             B ..... 1.44 MB (HD, 80 stop, 18 sektoru, 2 strany)
echo             C ...... 720 KB (DD, 80 stop,  9 sektoru, 2 strany)
echo           * D .... 3.444 MB (QD, 82 stop, 42 sektoru, 2 strany)
echo           * E .... 1.722 MB (HD, 82 stop, 21 sektoru, 2 strany)
echo           * F ...... 1.2 MB (HD, 80 stop, 15 sektoru, 2 strany)
echo           * G .... 1.066 MB (DD, 82 stop, 13 sektoru, 2 strany)
echo           * H ...... 820 KB (DD, 82 stop, 10 sektoru, 2 strany)
echo           * I ...... 533 KB (DD, 41 stop, 13 sektoru, 2 strany)
echo           * J ...... 410 KB (DD, 41 stop, 10 sektoru, 2 strany)
echo           * K ...... 360 KB (DD, 40 stop,  9 sektoru, 2 strany)
echo           * L ...... 320 KB (DD, 40 stop,  8 sektoru, 2 strany)
echo           * M ...... 266 KB (DD, 41 stop, 13 sektoru, 1 strana)
echo           * N ...... 205 KB (DD, 41 stop, 10 sektoru, 1 strana)
echo           * O ...... 180 KB (DD, 40 stop,  9 sektoru, 1 strana)
echo           [Esc]..... preruseni operace
echo.
ask "Zvolte pozadovany format diskety A az O (popr. [Esc]=preruseni): "abcdefghijklmno

if errorlevel 16 goto Start
if errorlevel 15 goto F180
if errorlevel 14 goto F205
if errorlevel 13 goto F266
if errorlevel 12 goto F320
if errorlevel 11 goto F360
if errorlevel 10 goto F410
if errorlevel 9 goto F533
if errorlevel 8 goto F820
if errorlevel 7 goto F1066
if errorlevel 6 goto F1200
if errorlevel 5 goto F1722
if errorlevel 4 goto F3444
if errorlevel 3 goto F720
if errorlevel 2 goto F1440
if errorlevel 1 goto F2880

:F140
rem --------- 140K, 40 stop, 7 sektoru, 1 strana
set FRM=F140 R16
goto Format

:F160
rem --------- 160K, 40 stop, 8 sektoru, 1 strana
set FRM=F160
goto Format

:F180
rem --------- 180K, 40 stop, 9 sektoru, 1 strana
set FRM=F180
goto Format

:F205
rem --------- 205K, 41 stop, 10 sektoru, 1 strana
set FRM=F205 T41 R32
goto Format

:F266
rem --------- 266K, 41 stop, 13 sektoru, 1 strana
set FRM=F266 T41 R32
goto Format

:F280
rem --------- 280K, 40 stop, 7 sektoru, 2 strany
set FRM=F280 C1 R32
goto Format

:F320
rem --------- 320K, 40 stop, 8 sektoru, 2 strany
set FRM=F320
goto Format

:F360
rem --------- 360K, 40 stop, 9 sektoru, 2 strany
set FRM=F360
goto Format

:F410
rem --------- 410K, 41 stop, 10 sektoru, 2 strany
set FRM=F410 T41 C1 R48
goto Format

:F533
rem --------- 533K, 41 stop, 13 sektoru, 2 strany
set FRM=F533 T41 C1 R48
goto Format

:F720
rem --------- 720K, 80 stop, 9 sektoru, 2 strany
set FRM=F720
goto Format

:F820
rem --------- 820K, 82 stop, 10 sektoru, 2 strany
set FRM=F820 T82 C1 R48
goto Format

:F1066
rem --------- 1.066M, 82 stop, 13 sektoru, 2 strany
set FRM=F1.066 T82 C1 R48
goto Format

:F1200
rem --------- 1.2M, 80 stop, 15 sektoru, 2 strany
set FRM=F1.2
goto Format

:F1440
rem --------- 1.44M, 80 stop, 18 sektoru, 2 strany
set FRM=F1.44
goto Format

:F1476
rem --------- 1.476M, 82 stop, 18 sektoru, 2 strany
set FRM=F1.476 T82 C2 R48
goto Format

:F1722
rem --------- 1.722M, 82 stop, 21 sektoru, 2 strany
set FRM=F1.722 T82 C2 R48
goto Format

:F2880
rem --------- 2.88M, 80 stop, 36 sektoru, 2 strany
set FRM=F2.88
goto Format

:F3444
rem -------- 3.444M, 82 stop, 42 sektoru, 2 strany
set FRM=F3.444 T82 R80
goto Format


:Format
rem ======================================================================
rem               Form tov n¡ diskety zvolen˜m form tem
rem ======================================================================
cls
echo.
echo.
echo.
echo.
xform %DSK% %POL% %FRM% D E %1 %2 %3 %4 %5 %6 %7 %8 %9
goto Start

:konec
cls
set DSK=
set POL=
set FRM=

