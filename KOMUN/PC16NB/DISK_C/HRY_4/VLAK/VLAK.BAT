@echo off
cls
echo Vlak
echo ----
echo —kolem hry je posb¡rat v¨echny p©edmˆty ve sc‚nˆ
echo a projet koncov˜mi vraty.
echo.
echo Ovl d n¡:     ¨ipka vlevo [4] ..... smˆr vlevo
echo               ¨ipka vpravo [6] .... smˆr vpravo
echo               ¨ipka nahoru [8] .... smˆr nahoru
echo               ¨ipka dol– [2] ...... smˆr dol–
echo               F1 .................. n povˆda k ©e¨en¡ sc‚ny
echo                                     (pouze p©ed zah jen¡m sc‚ny)
echo               F2 .................. zvuk zap/vyp (i bˆhem dema)
echo               F4 .................. zad n¡ hesla pro skok do jin‚ sc‚ny
echo               Esc ................. konec hry
echo.
echo.
if "%1" == "" c:\system\klavesn\wait

c:\system\klavesn\inkey F2
c:\system\displej\detcard > nul
if errorlevel 2 goto COLOR
vlak$ vlak_mon\vlak$.exe
goto KONEC

:COLOR
vlak$ vlak_col\vlak$.exe

:KONEC
