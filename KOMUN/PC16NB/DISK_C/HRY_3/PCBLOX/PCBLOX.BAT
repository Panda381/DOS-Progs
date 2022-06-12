@echo off
cls
echo PC-BLOX
echo -------
echo Ovl d n¡:    ¨ipky ......... posun kurzoru vlevo/vpravo/nahoru/dol–
echo              PgUp/PgDn ..... posun kurzoru dop©edu a dozadu
echo              mezera,Enter .. polo‘en¡ kostky
echo              ESC ........... vyvol n¡ hlavn¡ho menu
echo              DEL ........... zru¨en¡ kostky
echo              ESC ........... hlavn¡ menu
echo              F2 ............ menu volby kostek
echo              F4 ............ p©ekreslen¡ obrazovky
echo              F6 ............ ot ‡en¡ a p©evracen¡ modelu
echo              F7 ............ blokov‚ operace (Enter zah j¡ ozna‡ov n¡)
echo              F9 ............ (ulo‘en¡)/na‡ten¡ modelu
echo              F10 ........... konec programu 
echo                               (na dotaz "QUIT ?" zvolte "Y",
echo                                na dotaz "PRINT ?" zvolte "N")
echo.
echo  !!!!    VAROVN‹:   NEUKLDEJTE MODEL NA DISK (UKLDN‹ NEFUNGUJE)    !!!!
echo.
echo.
if "%1" == "" c:\system\klavesn\wait

c:\system\displej\detcard > NUL
if errorlevel 2 goto NHerc

c:\system\displej\emucga a > NUL
c:\system\displej\vmod 3
pc-blox
c:\system\displej\vmod 7
c:\system\displej\emucga d > NUL
goto Konec

:NHerc
pc-blox

:Konec
