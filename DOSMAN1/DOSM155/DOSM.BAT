@echo off
rem                    Modifikacni parametry pri startu programu
rem 浜様様様様様様様様様様様様様様様様様様様僕様様様様様様様様様様様様様様様様融
rem � /DM monochromaticky displej           � /A  zapnuti/vypnuti atributu     �
rem � /DC barevny displej                   � /B  zapnuti/vypnuti napovedy     �
rem � /FC cestina bez diakritiky            � /L  zapnuti/vypnuti neakt. okna  �
rem � /FK cestina v kodu bratri Kamenickych � /O  zapnuti/vypnuti obou oken    �
rem � /FL cestina v kodu Latin 2            � /T  prepnuti aktualniho okna     �
rem � /SN trideni adresare podle jmena      � /U  zamena oken                  �
rem � /SE trideni adresare podle pripony    � /Q  zkracene zobrazeni souboru   �
rem � /SD trideni adresare podle data       � /C  provedeni prikazu po startu  �
rem � /SS trideni adresare podle velikosti  � /H  vypnuti funkce SHIFT         �
rem � /SX netrideny adresar                 � /I  uchovani historie pri F10    �
rem � /43, /28 nastaveni modu EGA/VGA       � /J  automaticky kalendar         �
rem � /M0 vypnuti ovladace mysi             � /K  standardni klavesnice 83/84  �
rem � /Rn stmivani obrazovky n min., 0=vyp. � /N  automaticke uzivatelske menu �
rem � /Wn vyska oken n radku (minimalne 3)  � /P  program permanentne v pameti �
rem � /Gn signalizace vyzvy z portu COMn    � /V  zobrazovani souboru HID, SYS �
rem �                                       � /Y  zobrazovani jmena disku      �
rem �  soubor  funkce editace souboru       � /Z  zmena domovskeho adresare    �
rem 藩様様様様様様様様様様様様様様様様様様様瞥様様様様様様様様様様様様様様様様夕
%0\..\utility\egacs k
%0\..\utility\cskey k 3
%0\..\dosman.exe /dc/fk/l/v/y/i
if errorlevel == 1 goto konec
%0\..\$dosman$.bat
:konec
%0\..\utility\cskey !
%0\..\utility\egacs !
