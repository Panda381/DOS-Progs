@echo off
rem                    Modifika�n� parametry p�i startu programu
rem ��������������������������������������������������������������������������ͻ
rem � /DM monochromatick� displej           � /A  zapnut�/vypnut� atribut�     �
rem � /DC barevn� displej                   � /B  zapnut�/vypnut� n�pov�dy     �
rem � /FC �e�tina bez diakritiky            � /L  zapnut�/vypnut� neakt. okna  �
rem � /FK �e�tina v k�du brat�� Kamenick�ch � /O  zapnut�/vypnut� obou oken    �
rem � /FL �e�tina v k�du Latin 2            � /T  p�epnut� aktu�ln�ho okna     �
rem � /SN t��d�n� adres��e podle jm�na      � /U  z�m�na oken                  �
rem � /SE t��d�n� adres��e podle p��pony    � /Q  zkr�cen� zobrazen� soubor�   �
rem � /SD t��d�n� adres��e podle data       � /C  proveden� p��kazu po startu  �
rem � /SS t��d�n� adres��e podle velikosti  � /H  vypnut� funkce SHIFT         �
rem � /SX net��d�n� adres��                 � /J  automatick� kalend��         �
rem � /43 nastaven� m�du zobrazen� EGA/VGA  � /K  standardn� kl�vesnice 83/84  �
rem � /M0 vypnut� ovlada�e my�i             � /N  automatick� u�ivatelsk� menu �
rem � /Rn stm�v�n� obrazovky n min., 0=vyp. � /P  program permanentn� v pam�ti �
rem � /Wn v��ka oken n ��dk� (minim�ln� 3)  � /V  zobrazov�n� soubor� HID, SYS �
rem � /Gn signalizace v�zvy z portu COMn    � /Y  zobrazov�n� jm�na disku      �
rem �  soubor  funkce editace souboru       � /Z  zm�na domovsk�ho adres��e    �
rem ��������������������������������������������������������������������������ͼ
echo on
%0\..\utility\egacs k
%0\..\utility\cskey k 3
%0\..\dosman.exe /dc/fk/l/v/y
%0\..\utility\cskey !
%0\..\utility\egacs !
