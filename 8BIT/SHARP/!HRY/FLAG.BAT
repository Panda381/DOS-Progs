@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo FLAG  -  z�vody formule F1
echo ----
echo.
echo Po startu se mezerou nastav� po�adovan�
echo z�vodn� dr�ha a stiskne se CR. Potom se
echo zad� po�et kol (nap�. 5) a stiskne se
echo CR. Mezerou se zvol� auto a stiskne se
echo op�t CR.
echo.
echo Ovl�d�n�: VLEVO a VPRAVO - ��zen� sm�ru
echo           NAHORU - plyn
echo           DOL� - brzda
echo           DEL - zv��en� rychl. stupn�
echo           INST - sn��en� rychl. stupn�
echo.
echo Po h�e zadat Y (nov� hra).
echo.
..\sharpexe flag.mzf > nul
..\delay 6 > nul
..\sharpsav flag_1.mzf > nul
..\delay 6 > nul
..\sharpsav flag_2.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
