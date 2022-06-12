@echo off
cls

echo.
echo Hledam offset se slovem "Aktivni":
..\!crack /f getmode.com /s 6b 74 69 76 6e 69
echo ...Nalezeno na offsetu 0000:0049

echo Priprava programu CRACK.COM
copy ..\!crack.com CRACK.COM > nul
crack /f getmode.com /v 49 6b 74 69 76 6e 69 /w 49 4b 54 49 56 4e 49 /t vyzva1.txt

echo Priprava programu UNCRACK.COM
copy ..\!crack.com UNCRACK.COM > nul
uncrack /f getmode.com /v 49 4b 54 49 56 4e 49 /w 49 6b 74 69 76 6e 69 /t vyzva2.txt

echo.
echo Testuji. Pri prvnim spusteni zde bude slovo "Aktivni":
getmode

echo.
echo Provadim CRACK souboru:
crack.com
echo Testuji cracknuty program. Melo by zde byt slovo "AKTIVNI":
getmode

echo.
echo Provadim UNCRACK souboru:
uncrack.com
echo Testuji odcracknuty program. Melo by zde byt slovo "Aktivni":
getmode

echo.
pause
