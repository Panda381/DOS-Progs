@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo SCHACH 700  -  �achy
echo ----------
echo.
echo Po startu stisknout kl�vesu J (nov�
echo partie) a CR, zvolit barvu S (�ern�)
echo nebo W (b�l�) a CR, zvolit stupe�
echo 0 a� 6 (0 nejsna���) a CR.
echo.
echo Sou�adnice se zad�vaj� jako P�SMENO a
echo ��SLICE nejd��ve pro v�choz� pozici
echo a potom pro c�lovou pozici, c�lov� a
echo v�choz� pozice se mus� vz�jemn� odd�lit
echo poml�kou. Po zad�n� se stiskne CR.
echo Jinak lze tah zadat stiskem INST,
echo nastaven�m na v�choz� pozici, stiskem
echo INST, nastaven�m na koncovou pozici a
echo op�t stiskem INST.
echo.
..\sharpexe schach.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
