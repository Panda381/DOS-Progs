@echo off
rem                    Modifika‡n¡ parametry p©i startu programu
rem ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
rem º /DM monochromatick˜ displej           º /A  zapnut¡/vypnut¡ atribut–     º
rem º /DC barevn˜ displej                   º /B  zapnut¡/vypnut¡ n povˆdy     º
rem º /FC ‡e¨tina bez diakritiky            º /L  zapnut¡/vypnut¡ neakt. okna  º
rem º /FK ‡e¨tina v k¢du brat©¡ Kamenick˜ch º /O  zapnut¡/vypnut¡ obou oken    º
rem º /FL ‡e¨tina v k¢du Latin 2            º /T  p©epnut¡ aktu ln¡ho okna     º
rem º /SN t©¡dˆn¡ adres ©e podle jm‚na      º /U  z mˆna oken                  º
rem º /SE t©¡dˆn¡ adres ©e podle p©¡pony    º /Q  zkr cen‚ zobrazen¡ soubor–   º
rem º /SD t©¡dˆn¡ adres ©e podle data       º /C  proveden¡ p©¡kazu po startu  º
rem º /SS t©¡dˆn¡ adres ©e podle velikosti  º /H  vypnut¡ funkce SHIFT         º
rem º /SX net©¡dˆn˜ adres ©                 º /J  automatick˜ kalend ©         º
rem º /43 nastaven¡ m¢du zobrazen¡ EGA/VGA  º /K  standardn¡ kl vesnice 83/84  º
rem º /M0 vypnut¡ ovlada‡e my¨i             º /N  automatick‚ u‘ivatelsk‚ menu º
rem º /Rn stm¡v n¡ obrazovky n min., 0=vyp. º /P  program permanentnˆ v pamˆti º
rem º /Wn v˜¨ka oken n © dk– (minim lnˆ 3)  º /V  zobrazov n¡ soubor– HID, SYS º
rem º /Gn signalizace v˜zvy z portu COMn    º /Y  zobrazov n¡ jm‚na disku      º
rem º  soubor  funkce editace souboru       º /Z  zmˆna domovsk‚ho adres ©e    º
rem ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
echo on
%0\..\utility\egacs k
%0\..\utility\cskey k 3
%0\..\dosman.exe /dc/fk/l/v/y
%0\..\utility\cskey !
%0\..\utility\egacs !
