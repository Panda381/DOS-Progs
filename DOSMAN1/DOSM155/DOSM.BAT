@echo off
rem                    Modifikacni parametry pri startu programu
rem ษอออออออออออออออออออออออออออออออออออออออหออออออออออออออออออออออออออออออออออป
rem บ /DM monochromaticky displej           บ /A  zapnuti/vypnuti atributu     บ
rem บ /DC barevny displej                   บ /B  zapnuti/vypnuti napovedy     บ
rem บ /FC cestina bez diakritiky            บ /L  zapnuti/vypnuti neakt. okna  บ
rem บ /FK cestina v kodu bratri Kamenickych บ /O  zapnuti/vypnuti obou oken    บ
rem บ /FL cestina v kodu Latin 2            บ /T  prepnuti aktualniho okna     บ
rem บ /SN trideni adresare podle jmena      บ /U  zamena oken                  บ
rem บ /SE trideni adresare podle pripony    บ /Q  zkracene zobrazeni souboru   บ
rem บ /SD trideni adresare podle data       บ /C  provedeni prikazu po startu  บ
rem บ /SS trideni adresare podle velikosti  บ /H  vypnuti funkce SHIFT         บ
rem บ /SX netrideny adresar                 บ /I  uchovani historie pri F10    บ
rem บ /43, /28 nastaveni modu EGA/VGA       บ /J  automaticky kalendar         บ
rem บ /M0 vypnuti ovladace mysi             บ /K  standardni klavesnice 83/84  บ
rem บ /Rn stmivani obrazovky n min., 0=vyp. บ /N  automaticke uzivatelske menu บ
rem บ /Wn vyska oken n radku (minimalne 3)  บ /P  program permanentne v pameti บ
rem บ /Gn signalizace vyzvy z portu COMn    บ /V  zobrazovani souboru HID, SYS บ
rem บ                                       บ /Y  zobrazovani jmena disku      บ
rem บ  soubor  funkce editace souboru       บ /Z  zmena domovskeho adresare    บ
rem ศอออออออออออออออออออออออออออออออออออออออสออออออออออออออออออออออออออออออออออผ
%0\..\utility\egacs k
%0\..\utility\cskey k 3
%0\..\dosman.exe /dc/fk/l/v/y/i
if errorlevel == 1 goto konec
%0\..\$dosman$.bat
:konec
%0\..\utility\cskey !
%0\..\utility\egacs !
