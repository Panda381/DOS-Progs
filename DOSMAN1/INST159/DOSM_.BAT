@echo off
rem
rem P©¡klad p©¡kazov‚ho souboru, kter˜ vyu‘¡v  principu modifikace COMSPEC.
rem Modifikace COMSPEC zajist¡ spustitelnost program– pouze u vybran˜ch voleb.
rem D le viz DOSMAN_.MNU.
rem
rem                    Modifika‡n¡ parametry p©i startu programu
rem ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
rem º /DM monochromatick˜ displej           º /A  zapnut¡/vypnut¡ atribut–     º
rem º /DC barevn˜ displej                   º /B  zapnut¡/vypnut¡ n povˆdy     º
rem º /FC ‡e¨tina bez diakritiky            º /L  zapnut¡/vypnut¡ neakt. okna  º
rem º /FK ‡e¨tina v k¢du brat©¡ Kamenick˜ch º /O  zapnut¡/vypnut¡ obou oken    º
rem º /FL ‡e¨tina v k¢du Latin 2            º /T  p©epnut¡ aktu ln¡ho okna     º
rem º /SN t©¡dˆn¡ adres ©e podle jm‚na      º /U  z mˆna oken                  º
rem º /SE t©¡dˆn¡ adres ©e podle p©¡pony    º /Q, /QQ  r–zn‚ form ty okna      º
rem º /SD t©¡dˆn¡ adres ©e podle data       º /C  proveden¡ p©¡kazu po startu  º
rem º /SS t©¡dˆn¡ adres ©e podle velikosti  º /H  vypnut¡ funkce SHIFT        *º
rem º /SX net©¡dˆn˜ adres ©                 º /I  uchov n¡ historie p©i F10    º
rem º /43, /28  nastaven¡ m¢du EGA/VGA      º /J  automatick˜ kalend ©         º
rem º /M0 vypnut¡ ovlada‡e my¨i             º /K  standardn¡ kl vesnice 83/84 *º
rem º /Rn stm¡v n¡ obrazovky n min., 0=vyp. º /N  automatick‚ u‘ivatelsk‚ menu º
rem º /Wn v˜¨ka oken n © dk– (minim lnˆ 3)  º /P  program permanentnˆ v pamˆti º
rem º /Gn signalizace v˜zvy z portu COMn    º /V  zobrazov n¡ soubor– HID, SYS º
rem º /!M z kaz opu¨tˆn¡ u‘ivatelsk‚ho menu º /Y  zobrazov n¡ jm‚na disku      º
rem º  soubor      - funkce editace souboru º /Z  zmˆna domovsk‚ho adres ©e    º
rem ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

:start0
set CMS=%COMSPEC%
set COMSPEC=C:\DOSMAN\RELAX\PF.EXE

:start1
dosman /l/r5/fk/v/w17/y/i %1
if errorlevel 1 goto start1
call $dosman$.bat
goto start0
