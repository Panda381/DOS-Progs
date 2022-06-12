@echo off
cls
echo Goody
echo -----
echo Ovl d n¡:   ¨ipka vlevo [4] ..... pohyb vlevo
echo             ¨ipka vpravo [6] .... pohyb vpravo
echo             ¨ipka nahoru [8] .... v˜skok nahoru
echo             ¨ipka dol– [2] ...... v˜tah zap/vyp
echo             mezera .............. st©¡len¡ (z vis¡ na d‚lce dr‘en¡)
echo             Enter ............... ‘eb©¡k vz¡t/postavit
echo             Esc ................. p©eru¨en¡ hry
echo             Ctrl-Break .......... p©eru¨en¡ programu
echo             vlevo/vpravo+nahoru . dalek˜ skok
echo.
echo N kup v obchodˆ (mus¡ m¡t pen¡ze) .... dr‘et mezeru, ukazatel na
echo                                        po‘adovan˜ p©edmˆt, mezeru pustit.
echo Heslo: 1354943169580
echo.
echo Pou‘it¡ p©edmˆt–: letlampa otev¡r  stˆnu p©ed trezorem, vrta‡ka z podzem¡
echo do banky, dynamit na banku vpravo, kladivo na banku v¡ce vpravo, kle¨tˆ
echo a ¨roubov k na banku vrchem. K £niku z vˆzen¡ lze pou‘¡t kl¡‡.
echo.
echo.
if "%1" == "" c:\system\klavesn\wait

c:\system\displej\detcard > NUL
if errorlevel 2 goto NHerc

c:\system\displej\emucga a > NUL
c:\system\displej\vmod 3
goody\goody
c:\system\displej\vmod 7
c:\system\displej\emucga d > NUL
goto Konec

:NHerc
goody\goody

:Konec
