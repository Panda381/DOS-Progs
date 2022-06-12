echo off
echo.
echo ษอออออออออออออออออออออออออออออออออออป
echo บ Zadejte pozadovany format diskety บ
echo บ    ([Esc] = preruseni operace)    บ
echo ฬอออออออออออออออออออออออออออออออออออน
echo บ Diskety 5 1/4":  1 = 1.2 MB (AT)  บ
echo บ                  2 = 720 KB (XT)  บ
echo บ                  3 = 360 KB       บ
echo บ                  4 = 320 KB       บ
echo บ                  5 = 180 KB       บ
echo บ                  6 = 160 KB       บ
echo ฬอออออออออออออออออออออออออออออออออออน
echo บ Diskety 3 1/2":  1 = 1.44 MB      บ
echo บ                  2 = 720 KB       บ
echo ศอออออออออออออออออออออออออออออออออออผ
%2utility\ask 123456
if errorlevel == 7 goto konec
if errorlevel == 6 goto format6
if errorlevel == 5 goto format5
if errorlevel == 4 goto format4
if errorlevel == 3 goto format3
if errorlevel == 2 goto format2

:format1
format %1
goto konec

:format2
format %1 /t:80 /n:9
goto konec

:format3
format %1 /4
goto konec

:format4
format %1 /8
goto konec

:format5
format %1 /1/4
goto konec

:format6
format %1 /1/8

:konec
