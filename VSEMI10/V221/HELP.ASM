
INCLUDE  DEF.ASM

; ------ p�ep�na�e v textu (definov�ny v DEF.ASM !)

;LF       EQU       10                       ; nov� ��dek textu
;FF       EQU       12                       ; nov� str�nka
;CR       EQU       13                       ; n�vrat na za��tek ��dku
;TSWCBOLD EQU       4                        ; zv�razn�n� p�smo      (SHIFT-F1)
;TSWCKEYS EQU       3                        ; kl�vesy na kl�vesnici (SHIFT-F2)
;TSWCNADP EQU       2                        ; nadpisy               (SHIFT-F3)
;TSWCNAD2 EQU       1                        ; nadpisy 2             (SHIFT-F4)
;TSWCFONT EQU       5                        ; zm�na fontu 16/8 linek (SHIFT-F5)
;TSWCPODK EQU       0                        ; podklad               (SHIFT-F6)

XF       EQU       TSWCFONT                 ; zm�na fontu
XP       EQU       TSWCPODK                 ; barva podkladu (�lut�)
X        EQU       db

HelpSeg  SEGMENT   BYTE PUBLIC

HelpDat  LABEL     BYTE

; ------ 1
;�
x LF,XF
x'                 ',XP,   '������������������������������������������ܸ',XP,CR
x'                 ',      '������������������������������������������ѿ',LF
x'                 ',      '                                           ܸ',CR
x'                 ',XP,   '��������������������������������������������',XP,CR
x'                 ',      '� o                                      o �',LF
x'                 ',      '                                           ��',CR
x'                 ',XP,   '��������������������������������������������',XP,CR
x'                 ',      '�                                          �',LF
x'                 ',   XF,'                                           ��',XF,CR
x'                 ',XP,XF,'��������������������������������������������',XF,XP,CR
x'                 ',      '�                 VSEMI10                  �',LF
x'                 ',      '�                                          �',LF
x'                 ',      '                                           ��',CR
x'                 ',XP,   '��������������������������������������������',XP,CR

IFDEF    DEMO
x'                 ',      '�             verze 2.21 DEMO              �',LF
ELSE
x'                 ',      '�               verze  2.21                �',LF
ENDIF

x'                 ',   XF,'                                           ��',XF,CR
x'                 ',XP,XF,'��������������������������������������������',XF,XP,CR
x'                 ',      '�    V�uka psan� na kl�vesnici po��ta�e    �',LF
x'                 ',      '�                                          �',LF
x'                 ',      '                                           ��',CR
x'                 ',XP,XF,'��������������������������������������������',XF,XP,CR
x'                 ',      '�     GEMA Soft,  Ro�nov pod Radho�t�m     �',LF
x'                 ',   XF,'                                           ��',XF,CR
x'                 ',XP,XF,'��������������������������������������������',XF,XP,CR
x'                 ',      '�        (c) Miroslav N�me�ek, 1997        �',LF
x'                 ',      '�                                          �',LF
x'                 ',   XF,'                                           ��',XF,CR
x'                 ',XP,XF,'��������������������������������������������',XF,XP,CR

IFNDEF    DEMO
x'                 ',      '�           licence: '
LicCis2  db        '00000-00000           �',LF
ELSE
x'                 ',      '�                                          �',LF
ENDIF

x'                 ',      '� o                                      o �',LF
x'                 ',      ' ��������������������������������������������',CR
x'                 ',XP,   '������������������������������������������߾',XP,CR
x'                 ',      '���������������������������������������������',LF
x'                 ',      ' ������������������������������������������߾',LF
x LF
x'                                                  ����������ѿ',LF
x'    Textem  t�to  n�pov�dy  m��ete kl�vesami      �  PageUp  �   ',30,' str�nka',LF
x'                                                  �          ��� ',  '� zp�t',LF
x'    PageUp a PageDown listovat po str�nk�ch.      ��������������',LF
x'                                                    ������������',LF
x'    Kl�vesami  Home  a  End  se p�esunete na      ����������ѿ',LF
x'                                                  � PageDown �   ',  '� str�nka',LF
x'    prvn�  nebo  posledn�  str�nku n�pov�dy.      �          ��� ',31,' vp�ed',LF
x'                                                  ��������������',LF
x'    Kl�vesou ESC n�pov�du opust�te.                 ������������',LF
x LF
x LF                                                
x'                                                  ����������ѿ',LF
x'                                                  �   Home   �   ',30,' prvn�',LF
x'              ����������ѿ                        �          ��� ',  '� str�nka',LF
x'              �   ESC    �    opu�t�n�            ��������������',LF
x'              �          ���  n�pov�dy              ������������',LF
x'              ��������������                      ����������ѿ',LF
x'                ������������                      �   End    �   ',  '� posledn�',LF
x'                                                  �          ��� ',31,' str�nka',LF
x'                                                  ��������������',LF
x'                                                    ������������',LF
IFDEF    DEMO
x LF
x'DEMO verze je omezena na 5 lekc� a do protokolu se neukl�daj� v�sledky testu !',LF
ENDIF
x FF

; ------ 2
;�
x LF,XF
x'                         ���������������������ѿ         ///',LF
x'                         �                     �        ',39,'   /',LF
x'                         �                     ���     < o  )',LF
x'                         �     Hlavn� menu     ���           - .',LF
x'                         �                     ���       \',LF
x'                         �                     ���          (  \ \',LF
x'                         �                     ���         \',LF
x'                         �������������������������     \\    -     \',LF
x'                           �����������������������      \\    \\- \',LF
x'                                                         \====((======',LF
x'                                                                   \\\',LF
x'                                                                     \\',LF,XF
x LF
x'Po spu�t�n� programu VSEMI10 se zobraz� hlavn� menu programu.  Funkce hlavn�ho',LF
x'menu  lze volit bu� nastaven�m ukazatele na po�adovan� ��dek a stiskem kl�vesy',LF
x'ENTER  nebo  stiskem zv�razn�n�ho p�smene voleb menu. Ze v�ech funkc� programu',LF
x'se lze navr�tit zp�t do hlavn�ho menu stiskem kl�vesy ESC.',LF
x LF
x'   V�uka     - v�ukov� lekce pro v�uku psan�',LF
x'   Cvi�en�   - procvi�ov�n� znalost� psan�m podle vlastn� ti�t�n� p�edlohy',LF
x'   Test      - test znalost� opisov�n�m p�ipraven�ho textu s vyhodnocen�m chyb',LF
x'   Nastaven� - volba kl�vesnice a nastaven� parametr� programu',LF
x'   Pomoc     - tato n�pov�da k programu (z�stane naposledy zobrazen� str�nka)',LF
x'   Konec     - ukon�en� programu VSEMI10, n�vrat do opera�n�ho syst�mu',LF
x FF

; ------ 3
;�
x LF,XF
x'                           �����������������ѿ                  ��',LF
x'                           �                 �           ����������������',LF
x'                           �                 ���         ',XF,'����������������',XF,CR
x'                                                            A  B�  C�  D� ',LF
x'                           �      V�uka      ���',LF
x'                           �                 ���         ����������������',CR
x'                                                           ������������',LF
x'                           �                 ���         ����������������',LF
x'                           �                 ���           / /      \ \',LF
x'                           ���������������������          / /        \ \',LF
x'                             �������������������          ��          ��',LF,XF
x LF
x'Po proveden� volby V�uka z hlavn�ho menu se zobraz� nab�dka lekc� v�uky. Obsah',LF
x'i uspo��d�n� lekc� z�vis� na zvolen� kl�vesnici, proto je pot�eba p�ed vlastn�',LF
x'v�ukou zvolit nejvhodn�j�� typ kl�vesnice (viz volba Nastaven�).',LF
x LF
x'Po volb� lekce kl�vesou ENTER se zobraz� text lekce k prob�ran�m kl�ves�m. Pod',LF
x't�mto  textem  je cvi�ebn� ��dek. �kolem je text na tomto ��dku opisovat podle',LF
x'instrukc�  v  textu lekce. Kl�vesou F2 lze zapnout/vypnout metronom. P�i tomto',LF
x'cvi�en�  nen�  d�le�it�  rychlost,  ale  p�esnost. Mus� b�t naps�no bez jedin�',LF
x'chyby. Jednotliv�mi cvi�en�mi lze listovat pomoc� kl�ves PageUp a PageDown.',LF
x LF
x'Po  spr�vn�m  ops�n�  cvi�ebn�ch ��dk� je p�edlo�en v�ce��dkov� cvi�ebn� text.',LF
x'V tomto testu je ji� d�le�it� rychlost. Pokra�ov�n� ve v�uce je povoleno pouze',LF
x'je-li  chybovost men�� ne� 0.80 % a v�kon minim�ln� 100 �hoz�/minutu (v�kon se',LF
x'sni�uje o chyby). V�ukov� test je mo�n� opustit kl�vesou ESC.',LF
x FF

; ------ 4
;�
x LF,XF
x'                           �����������������ѿ                                 ',LF
x'                           �                 �                                 ',LF
x'                           �                 ���                   -^          ',LF
x'                           �     Cvi�en�     ���        ^u^     o-',39,'o �         ',LF
x'                           �                 ���       (( o ))    \    �         ',LF
x'                           �                 ���        \u/      ',39,'-   \ ^      ',LF
x'                           �                 ���       o(          \   \))     ',LF
x'                           ���������������������         )o        � ^(        ',LF
x'                             �������������������     WwWwWwWwWw   (_/(__/      ',LF,XF
x LF
x'Po  proveden�  volby  Cvi�en�  z  hlavn�ho menu si program vy��d� zad�n� jm�na',LF
x'zkou�en�  osoby.  Doporu�uje  se zadat p��jmen�, jm�no a p��padn� dal�� �daje,',LF
x'je v�ak mo�n� jen stisknout ENTER bez zad�n�. P�i zad�v�n� lze kl�vesami Home,',LF
x'End, vlevo a vpravo text editovat a t�� obnovit ji� d��ve zadan� text.',LF
x LF
x'Po  zad�n�  jm�na  osoby lze za��t ps�t text. Program pr�b��n� ukazuje na lev�',LF
x'stran�  m���tka dosa�en� v�kon (v �hozech/minutu) a na prav� stran� ub�hl� �as',LF
x'(od okam�iku stisku prvn� kl�vesy). Na konci psan�ho ��dku se zobrazuj� �hozy.',LF
x'Kl�vesou F2 lze zapnout/vypnout metronom, kl�vesou F3 indikaci stisku kl�vesy.',LF
x LF
x'Cvi�en� lze ukon�it stiskem kl�vesy ESC (�as se po��t� po naposledy stisknutou',LF
x'kl�vesu) nebo je ukon�eno dosa�en�m zadan�ho �asov�ho omezen� (viz Nastaven�).',LF
x'Na  obrazovce se zobraz� po�et �hoz� a dosa�en� v�kon a sou�asn� se do souboru',LF
x'ulo�� protokol o proveden� testu (viz V�stupn� protokol).',LF
x FF

; ------ 5
;�
x LF,XF
x'                           �����������������ѿ                                 ',LF
x'                           �                 �                                 ',LF
x'                           �                 ���                  �����        ',LF
x'                           �      Test       ���         /       ��������      ',LF
x'                           �                 ���       /  \     ����������     ',LF
x'                           �                 ���                /o��������     ',LF
x'                           �                 ���      �    �   /   ��������    ',LF
x'                           ���������������������              o_,_ _�������\   ',LF
x'                             �������������������       \__/      (/     \)     ',LF,XF
x LF
x'Po  proveden�  volby Test z hlavn�ho menu se zad� jm�no jako ve volb� Cvi�en�.',LF
x'Po  zad�n� jm�na se zobraz� seznam test� (testy jsou ulo�eny v adres��i TESTY,',LF
x'vnit�n�  n�rodn� k�d Kamenick�ch - KEYBCS2). Seznamem je mo�n� listovat pomoc�',LF
x'kl�ves PageUp a PageDown, test se zvol� kl�vesou ENTER.',LF
x LF
x'Po  volb� testu se zobraz� v doln� ��sti obrazovky text testu. B�hem opisov�n�',LF
x'textu  se  zobrazuje v�kon, �as a �hozy jako ve volb� Cvi�en�. Nad zapisovan�m',LF
x'��dkem se zobrazuj� chyby, p�i povolen� editaci a� po odesl�n� kl�vesou ENTER.',LF
x'Kl�vesou F2 lze zapnout/vypnout metronom, kl�vesou F3 indikaci stisku kl�vesy.',LF
x LF
x'Test  lze  p�eru�it stiskem kl�vesy ESC (�as se po��t� po naposledy stisknutou',LF
x'kl�vesu) nebo je p�eru�en dosa�en�m zadan�ho �asov�ho omezen� (viz Nastaven�).',LF
x'Na  obrazovce se zobraz� po�et �hoz�, dosa�en� v�kon a chybovost a sou�asn� se',LF
x'do souboru ulo�� protokol o proveden� testu (viz V�stupn� protokol).',LF
x FF

; ------ 6
;�
x LF,XF
x'                         ���������������������ѿ        (,)',LF
x'                         �                     �      ((,o))',LF
x'                         �  V�stupn� protokol  ���   ( ,o),)        ����',LF
x'                         �                     ���   ((o, o )   ___//__\\',LF
x'                         �                     ���     (o�)    /) o        \',LF
x'                         �������������������������      ��     \__________�',LF
x'                           �����������������������      ��       \_/   \_/',LF,XF
x LF
x'Ve  funkc�ch Cvi�en� a Test se vytv��� soubor v�stupn�ho protokolu o proveden�',LF
x'testu.  Tento  soubor  je  ulo�en do adres��e PROTOKOL programu VSEMI10. Jm�no',LF
x'souboru je odvozeno od jm�na testovan� osoby (p��jmen� bez h��k� a ��rek) nebo',LF
x'se pou�ije jako implicitn� jm�no znak $ (nen�-li jm�no zad�no).',LF
x LF,XF
x'P��pona  jm�na  souboru je zvolena tak, aby p�i abecedn�m t��d�n� souhlasilo i',LF
x'�asov� t��d�n� soubor�. Prvn� znak p��pony ud�v� ��slo m�s�ce (pro 10 a� 12 se',LF
x'pou�ij�  p�smena  A a� C). Druh� znak ud�v� ��slo dne (pro 10 a� 31 se pou�ij�',LF
x'p�smena A a� V). T�et� znak ud�v� po�adov� ��slo, pokud soubor ji� existuje.',LF
x LF,XF
x'������������ V z�hlav� protokolu jsou uvedeny n�sleduj�c� polo�ky: ���������Ŀ',LF,XF
x'� Jm�no: jm�no testovan� osoby         � V�kon: �ist� v�kon (�hoz�/minutu)   �',LF
x'� Datum: datum prov�d�n� testu         � Oprav: po�et proveden�ch oprav      �',LF
x'�   �as: �as prov�d�n� testu           � Kl�v.: nastaven� kl�vesnice         �',LF
x'� D�lka: d�lka testu v min. a sek.     �  Test: jm�no souboru testu          �',LF
x'� �hoz�: po�et hrub�ch �hoz� celkem    �  Chyb: po�et chyb a chybovost v %   �',LF,XF
x'������������������������������������������������������������������������������',LF,XF
x'Za  z�hlav�m  protokolu  je mezi dv�ma �arami ulo�en zapisovan� text. Na konci',LF
x'ka�d�ho ��dku je uveden po�et �hoz� na ��dku a za lom�tkem po�et chyb. V textu',LF
x'je  p�ed ka�dou chybou uveden znak _ (pro zv�razn�n� chyby). Za jednu chybu je',LF
x'pova�ov�no: z�m�na 2 znak�, chyb�j�c� znak, znak nav�c,  chybn�  znak.  Nejsou',LF
x'detekov�ny  rozs�hlej��  chyby (z�m�na slov, ��dk�) ani nen� prov�d�na korekce',LF
x'p�i chyb� v posledn�ch 10 �hozech - tyto chyby je nutno o�et�it ru�n�.',LF
x FF

; ------ 7
;�
x LF,XF
x'                           �����������������ѿ       ______�_',LF
x'                           �                 �      /��������\',LF
x'                           �                 ���   /����������\',LF
x'                           �    Nastaven�    ���  /������������\  (__)',LF
x'                           �                 ���   �          �   (oo)',LF
x'                           �                 ���   ����ͻ ��ͻ�  *(__)���',LF
x'                           �                 ���   ����͹ �, ��    \ ___ )\',LF
x'                           ���������������������   ����ͼ �  ��     �   �  *',LF
x'                             �������������������   ������������     �   �',LF,XF
x LF
x'Po  proveden� volby Nastaven� z hlavn�ho menu se zobraz� menu volby kl�vesnice',LF
x'a nastaven� parametr� programu. Zm�na p�ep�na�� se prov�d� kl�vesou ENTER nebo',LF
x'kl�vesou MEZERA. Ka�d� zm�na se ihned ulo�� do souboru konfigurace programu.',LF
x LF
x' P�sa�sk� kl�vesnice          - zvol� se p�sa�sk� kl�vesnice (typ psac� stroj)',LF
x' 1. program�torsk� kl�vesnice - zvol� se program�torsk� kl�vesnice (typ CSKEY)',LF
x' 2. program�torsk� kl�vesnice - zvol� se program�torsk� kl�vesnice (typ T602)',LF
x' Anglick� kl�vesnice          - zvol� se p�vodn� IBM kl�vesnice',LF
x' Metronom                     - p�i psan� textu lupe metronom (t�� kl�vesa F2)',LF
x' Rychlost metronomu           - nastaven� rychlosti metronomu (tik� za minutu)',LF
x' Zvukov� indikace             - p�i stisku kl�vesy se ozve lupnut� (t�� F3)',LF
x' Omezen� d�lky testu          - maxim�ln� d�lka testu a cvi�en� (v minut�ch)',LF
x' Editace chyb                 - ',XF,'p�i  testu a cvi�en� povolena editace (oprava)',LF
x'                                chyb kl�vesou BS (t�� DELETE nebo �ipka VLEVO)',LF
x LF,LF
x'Nastaven�m atributu R/O souboru VSEMI10.CNF lze zablokovat zm�nu konfigurace.',LF
x FF

; ------ 8
;�
x LF,XF
x'                        �����������������������ѿ                   )',LF
x'                        �                       �                  ( ___',LF
x'                        �  P�sa�sk� kl�vesnice  ���                �_���',LF
x'                        �                       ���       �.B      |   �',LF
x'                        �                       ���      E.C�.A  )==���=.',LF
x'                        ���������������������������     F��.��.D   (ooo)',LF
x'                          �������������������������   cXaQf�R.y�Y abcdefghijkl',LF,XF
x LF
x'P�sa�sk�  kl�vesnice  m�  rozlo�en� kl�ves shodn� s kl�vesnic� �esk�ho psac�ho',LF
x'stroje.  Je  proto ur�ena pro p�sa�e p�ivykl� psac�mu stroji a pro b��n� psan�',LF
x'text� s �esk�mi znaky s diakritikou.',LF,XF
x LF
x'        �����������������������������������������������������������ͻ',LF
x'        � ; � 1 � 2 � 3 � 4 � 5 � 6 � 7 � 8 � 9 � 0 � % � ~ �<-BkSpc�',LF
x'        � ` � + � � � � � � � � � � � � � � � � � � � = � ',39,' �       �',LF
x'        �����������������������������������������������������������͹',LF
x'        �Tab<-� Q � W � E � R � T � Z � U � I � O � P � / � ( �     �',LF
x'        �   ->�   �   �   �   �   �   �   �   �   �   � � � ) �     �',LF
x'        �����������������������������������������������������ͼ     �',LF
x'        �CpsLck� A � S � D � F � G � H � J � K � L � " � ! �  <-',39,'   �',LF
x'        �      �   �   �   � _ �   �   � _ �   �   � � � � � Enter  �',LF
x'        �����������������������������������������������������������͹',LF
x'        � Shift  � Y � X � C � V � B � N � M � ? � : � _ �  Shift   �',LF
x'        �        �   �   �   �   �   �   �   � , � . � - �          �',LF
x'        �����������������������������������������������������������͹',LF
x'        �Ctrl �       � Alt �        mezern�k       � Alt �   �Ctrl �',LF
x'        �     �       �     �                       �     �   �     �',LF
x'        �����ͼ       �����������������������������������ͼ   �����ͼ',LF
x LF
x LF
x'Kl�vesa  ',39,'~  je  tzv.  mrtv�  (nebo t�� prefixov�) kl�vesa. Po jej�m stisku se',LF
x'kurzor  neposune,  ale  nad  n�sleduj�c�m p�smenem se vytvo�� ��rka nebo h��ek',LF
x'(v  z�vislosti  na  kl�vese  SHIFT). Tuto kl�vesu lze vyu��t t�� ke generov�n�',LF
x'nestandardn�ch  znak� - stiskem jin� kl�vesy ne� p�smene se vygeneruje p�vodn�',LF
x'znak podle IBM kl�vesnice (dvoj�m stiskem ',39,39,' se vygeneruje znak ',39,').',LF
x FF

; ------ 9
;�
x LF,XF
x'                   ��������������������������������ѿ         )',LF
x'                   �                                �        ( ___  ��I   d�j',LF
x'                   �  1. program�torsk� kl�vesnice  ���      �_��� ya.Sg dAgh,',LF
x'                   �                                ���      |   � �����  ����� ',LF
x'                   �                                ���      ,���=.�����. ����� ',LF
x'                   ������������������������������������       oooo  o o   o o',LF
x'                     ����������������������������������  abcdefghijklmnopqrstu',LF,XF
x LF
x'1.  program�torsk�  kl�vesnice je nejvhodn�j��m typem kl�vesnice p�edev��m pro',LF
x'program�tory,  ale  i  pro ostatn� u�ivatele �asto pou��vaj�c� speci�ln� znaky',LF
x'po��ta�e  (jako  nap�.  # $ & @). Z �esk�ho psac�ho stroje jsou p�evzaty �esk�',LF
x'znaky  v  ��seln�  �ad�,  v�echny  ostatn�  znaky jsou zachov�ny podle p�vodn�',LF
x'anglick� kl�vesnice. ��slice se zad�vaj� v numerick�m poli kl�vesnice.',LF,XF
x'        �����������������������������������������������������������ͻ',LF
x'        � ~ � ! � @ � # � $ � % � ^ � & � * � ( � ) � _ � + �<-BkSpc�',LF
x'        � ` � � � � � � � � � � � � � � � � � � � � � - � = �       �',LF
x'        �����������������������������������������������������������͹',LF
x'        �Tab<-� Q � W � E � R � T � Y � U � I � O � P � { � } �     �',LF
x'        �   ->�   �   �   �   �   �   �   �   �   �   � [ � ] �     �',LF
x'        �����������������������������������������������������ͼ     �',LF
x'        �CpsLck� A � S � D � F � G � H � J � K � L � : � " �  <-',39,'   �',LF
x'        �      �   �   �   � _ �   �   � _ �   �   � ; � ',39,' � Enter  �',LF
x'        �����������������������������������������������������������͹',LF
x'        � Shift  � Z � X � C � V � B � N � M � < � > � ? �  Shift   �',LF
x'        �        �   �   �   �   �   �   �   � , � . � / �          �',LF
x'        �����������������������������������������������������������͹',LF
x'        �Ctrl �       � Alt �        mezern�k       � Alt �   �Ctrl �',LF
x'        �     �       �     �                       �     �   �     �',LF
x'        �����ͼ       �����������������������������������ͼ   �����ͼ',LF
x LF
x'Kl�vesa  ` je tzv. mrtv� (nebo t�� prefixov�) kl�vesa jako u p�ede�l� p�sa�sk�',LF
x'kl�vesnice.  Na  rozd�l  od  n� se v�ak pou��v� jak pro h��ek tak i pro ��rku,',LF
x'podle  stisknut�ho  p�smene.  Odchylkou  je  p�smeno  ��,  kter� se vygeneruje',LF
x'stiskem kl�vesy wW, a p�smeno �, kter� se vygeneruje stiskem J.',LF
x FF

; ------ 10
;�
x LF,XF
x'                   ��������������������������������ѿ',LF
x'                   �                                �',LF
x'                   �  2. program�torsk� kl�vesnice  ���',LF
x'                   �                                ���      � �,dS      O',LF
x'                   �                                ���    ,!as�s�.F   �/O>',LF
x'                   ������������������������������������   dcsdsd,sWEs  m �',LF
x'                     ����������������������������������  afeRgFjjK�Dlmnopqrstu',LF,XF
x LF
x'Pro  2. program�torskou kl�vesnici plat� v�e jako u p�ede�l� 1. program�torsk�',LF
x'kl�vesnice  s  t�m rozd�lem, �e z psac�ho stroje p�eb�r� i mrtvou (prefixovou)',LF
x'kl�vesu.  Z  toho  vypl�v� nutnost rozli�ovat mezi h��kem a ��rkou a t�� hor��',LF
x'dosa�itelnost n�kter�ch znak� (jako nap�. =), je proto m�n� vhodn�m typem.',LF,XF
x LF
x'        �����������������������������������������������������������ͻ',LF
x'        � ~ � ! � @ � # � $ � % � ^ � & � * � ( � ) � _ � ~ �<-BkSpc�',LF
x'        � ` � + � � � � � � � � � � � � � � � � � � � - � ',39,' �       �',LF
x'        �����������������������������������������������������������͹',LF
x'        �Tab<-� Q � W � E � R � T � Y � U � I � O � P � { � } �     �',LF
x'        �   ->�   �   �   �   �   �   �   �   �   �   � [ � ] �     �',LF
x'        �����������������������������������������������������ͼ     �',LF
x'        �CpsLck� A � S � D � F � G � H � J � K � L � : � " �  <-',39,'   �',LF
x'        �      �   �   �   � _ �   �   � _ �   �   � ; � ',39,' � Enter  �',LF
x'        �����������������������������������������������������������͹',LF
x'        � Shift  � Z � X � C � V � B � N � M � < � > � ? �  Shift   �',LF
x'        �        �   �   �   �   �   �   �   � , � . � / �          �',LF
x'        �����������������������������������������������������������͹',LF
x'        �Ctrl �       � Alt �        mezern�k       � Alt �   �Ctrl �',LF
x'        �     �       �     �                       �     �   �     �',LF
x'        �����ͼ       �����������������������������������ͼ   �����ͼ',LF
x LF
x'Kl�vesa  ',39,'~  je  tzv.  mrtv�  (nebo t�� prefixov�) kl�vesa. Po jej�m stisku se',LF
x'kurzor  neposune,  ale  nad n�sleduj�c�m p�smenem se vytvo�� ��rka nebo h��ek.',LF
x'Lze  ji  pou��t  t�� ke generov�n� nestandardn�ch znak� - stiskem jin� kl�vesy',LF
x'ne� p�smene se vygeneruje p�vodn� znak podle IBM kl�vesnice.',LF
x FF

; ------ 11
;�
x LF,XF
x'                        �����������������������ѿ',LF
x'                        �                       �      *  ^.^',LF
x'                        �  Anglick� kl�vesnice  ���   ***       **          * ',LF
x'                        �                       ���   ***      **** \ /*** ***',LF
x'                        �                       ���    *     * *** * O  ******',LF
x'                        ���������������������������    �  *** ***** (o)***  � ',LF
x'                          �������������������������  abcdefghijklmnopqrstuvwxy',LF,XF
x LF
x'Anglick� kl�vesnice je p�vodn� kl�vesnice po��ta�e IBM. S minim�ln� nadstavbou',LF
x'pro  generov�n� �esk�ch znak� m��e b�t pln� vyhovuj�c� kl�vesnic� program�tor�',LF
x'a  v�ech  ostatn�ch  u�ivatel�  nevy�aduj�c�ch  psan�  dlouh�ch �esk�ch text�.',LF
x'V�echny kl�vesy z�st�vaj� zachov�ny, je pouze dopln�na tzv. mrtv� kl�vesa.',LF,XF
x LF
x'        �����������������������������������������������������������ͻ',LF
x'        � ~ � ! � @ � # � $ � % � ^ � & � * � ( � ) � _ � + �<-BkSpc�',LF
x'        � ` � 1 � 2 � 3 � 4 � 5 � 6 � 7 � 8 � 9 � 0 � - � = �       �',LF
x'        �����������������������������������������������������������͹',LF
x'        �Tab<-� Q � W � E � R � T � Y � U � I � O � P � { � } �     �',LF
x'        �   ->�   �   �   �   �   �   �   �   �   �   � [ � ] �     �',LF
x'        �����������������������������������������������������ͼ     �',LF
x'        �CpsLck� A � S � D � F � G � H � J � K � L � : � " �  <-',39,'   �',LF
x'        �      �   �   �   � _ �   �   � _ �   �   � ; � ',39,' � Enter  �',LF
x'        �����������������������������������������������������������͹',LF
x'        � Shift  � Z � X � C � V � B � N � M � < � > � ? �  Shift   �',LF
x'        �        �   �   �   �   �   �   �   � , � . � / �          �',LF
x'        �����������������������������������������������������������͹',LF
x'        �Ctrl �       � Alt �        mezern�k       � Alt �   �Ctrl �',LF
x'        �     �       �     �                       �     �   �     �',LF
x'        �����ͼ       �����������������������������������ͼ   �����ͼ',LF
x LF
x'Kl�vesa  `  je  tzv.  mrtv�  (nebo  t��  prefixov�)  kl�vesa  jako  u p�sa�sk�',LF
x'kl�vesnice.  Na  rozd�l  od  n� se v�ak pou��v� jak pro h��ek tak i pro ��rku,',LF
x'podle  stisknut�ho  p�smene.  Odchylkou  je  p�smeno  ��,  kter� se vygeneruje',LF
x'stiskem kl�vesy wW, a p�smeno �, kter� se vygeneruje stiskem J.',LF
x FF

; ------ 12
;�
x LF,XF
x'                        �����������������������ѿ                             ',LF
x'                                                        �                     ',CR
x'                        �                       �       *        ����',LF
x'                                                        �',CR
x'                        �   Spu�t�n� programu   ���      *     ___//__\\����',LF
x'                                                        �',CR
x'                        �                       ���     *   /) o    ___//__\\',LF
x'                        �                       ���     �   \____/) o        \',LF
x'                        ���������������������������     �     \_/\__________�',LF
x'                          �������������������������     �          \_/   \_/',LF,XF
x LF
x'Program VSEMI10 lze spou�t�t se zad�n�m n�sleduj�c�ch parametr�:',LF
x LF
x'  /? ................ zobrazen� n�pov�dy k zad�n� parametr�',LF
x'  /C soubor ......... jm�no konfigura�n�ho souboru (p��padn� i s cestou)',LF
x'                      - implicitn� soubor VSEMI10.CNF v domovsk�m adres��i',LF
x'  /T adres�� ........ adres�� obsahuj�c� soubory test�',LF
x'                      - implicitn� adres�� TESTY v domovsk�m adres��i',LF
x'  /P adres�� ........ adres�� pro ukl�d�n� protokol� test�',LF
x'                      - implicitn� adres�� PROTOKOL v domovsk�m adres��i',LF
x LF,XF
x'P��kaz "VSEMI10 /C VSEMI10.CNF /T TESTY /P PROTOKOL" pou�ije aktu�ln� adres��.',LF
x'Odd�lovac�  znak  parametr� "/" nen� nutn� uv�d�t. Jm�na soubor� a adres��� se',LF
x'uv�d�j�  podle  b��n�ch  konvenc� DOS relativn� k aktu�ln�mu adres��i a disku.',LF
x'Na  konci  adres��e  m��e, ale nemus� b�t uveden znak "\". Domovsk� adres�� je',LF
x'adres��,  ve  kter�m je program VSEMI10 nainstalov�n. P�i �innosti programu je',LF
x'automaticky zaji�t�no vypnut� ovlada�� kl�vesnic KEYB.COM a CSKEY.COM (KEYB je',LF
x'syst�mov� ovlada� kl�vesnice, CSKEY je ovlada� dod�van� spolu se VSEMI10). P�i',LF
x'pou�it�  jin�ch  ovlada��  kl�vesnic  je  nutno  zajistit  jejich vypnut� p�ed',LF
x'spu�t�n�m  programu  VSEMI10  (aby  rozm�st�n�  znak� na kl�vesnici odpov�dalo',LF
x'standardn�mu  rozm�st�n�  kl�vesnice  IBM),  jinak nebude rozm�st�n� kl�ves na',LF
x'kl�vesnici spr�vn�.',LF
x FF

HelpSeg  ENDS
         END
