�.������ )rH� )���J�!r<����H�!�H�!r/������@r"���� ���t�� �&� ��s�v�v�F�Z�L�!�#%��!�����CC��s���"�6� L�!������������/���<�D� ��s���+ r���þ�þ��þ���þ���þ�������PSQRVW�&���� �6#��3ێ�� � ��N�s%��s���:�� �#� �U#��O�D3 �' s���� �@��(�� _^ZY[X�PQR&� u@&�G=0 w7<r3��&�G= w&<r"� ��&�G��H3���=� w	<r����ZYX�P��u&�G � ��&�G��&�G��&�GX�PSQRVW��@u*�5�!�n$�p$��r$�׹ ���%�!��@�v$0�}$��u$_^ZY[XÜ��@tPR�n$�%�!ZX�&����PQW�� ����_YX�P��P�U� � s�rMu�]X�P� � X��U� PSQRVWU�����]_^ZY[s��uMu$��t	���t
�X]�V��#�V��#�� �% ^r	�� ��X��=�����tPV��� �^X�SRVW���� ���F�� ��5��ڀ� ڀ� K�4�G�� ��n sS�޷ ��ߊG�[<tL< tH= Gt<	t= Mu	B:�v���= Ot= t= Ku��u����WR���GG:E�t	B��u�Z_�__��:���5 � _^Z[ø�!� <ar<zw, < u��!�� <t�u�<�u�ÜV�$� ^��V�6�� ^É6�S� �S� PQR���BB�@�!ZYX[þ� �\����8� t�s�>��</t�<:t�<-t�<Ar<Bw������#,A���ϻ <GtI�<UtC�<Mt=�<Tt7�<Vt1� <It+�@<Rt%��<Wt� <Ct<Xu���$<Ou����Ç��u����t��$� r��e�� t�r</uN�ê� rt</u�N� �����<ar<zw, <	u� < sN�SU��^�? t	:tCCC��_�^][�PQR�
 3����0O&��u�ZYX����t�À&�À�������tø C�� <�u~���3����C� �����sd��=P r]� � �= rP�� �s 
�uE=( r@P� ��
�Z�	R�V Xr)��"���|�D����N���+�OO����.����tPSR�
�� Z[X�P���t���I�!X�QVWU���= ]_^YÜVW�/_^��    6#       (@(@                                          F SAFEDISK v1.00 - zabezpeceni archivnich disket; (c) Miroslav Nemecek
��������������������  SAFEDISK   disk:  povel  �������������������ͻ
� disk: ..... oznaceni pracovniho disku A: nebo B: (implicitne A:) �
� X ......... nepouzivat pamet XMS                                 �
� O ......... nezapisovat protokol o operaci (SAFEDISK.REP)        �
� �������������� POVELY PRO SKUPINU DISKET ARCHIVU ��������������� �
� G ......... vygenerovani zabezpecovaci paritni diskety archivu   �
� U ......... obnoveni poskozene diskety archivu                   �
� M ......... modifikace archivu (pridani/vypusteni diskety)       �
� T ......... test zabezpeceni skupiny disket archivu              �
� ������������������� POVELY PRO JEDNU DISKETU ������������������� �
� V ......... verifikace diskety (overeni citelnosti)              �
� I ......... identifikace diskety (zobrazeni jmena a ident. kodu) �
� R soubor .. nacteni diskety do souboru (soubor bude prepsan !)   �
� W soubor .. zapis souboru na disketu (obsah bude prepsan !)      �
� C ......... kopirovani obsahu diskety v mechanice                �
������������������������������������������������������������������ͼ
Program  SAFEDISK  zabezpecuje diskety archivu vygenerovanim paritni
zabezpecovaci  diskety.  Paritni  disketa je bitovou logickou funkci
XOR  vsech  disket  archivu.  Po vzniku chyby na kterekoliv z disket
(casto i vice disketach soucasne) lze poskozenou disketu opet zpetne
vygenerovat  pomoci  paritni  diskety  a  vsech  zbyvajicich disket.
Do  souboru  SAFEDISK.REP  se  zapisuje  protokol o vsech operacich.
  (Detekovana volna pamet XMS         KB)
AN # Prerusit operaci ? ... (A)no, (N)e CHYBA - nedostatek pameti !
�������������������������������������������������������������������Ŀ
�            GENEROVANI zabezpecovaci paritni diskety              �
������������������������������������������������������������������Ĵ
� Vkladejte postupne jednotlive diskety skupiny archivnich disket, �
� ktere chcete  zabezpecit  paritni  disketou.  Na  poradi a poctu �
� disket  nezalezi,  ale  dobre  si zaevidujte, ktere diskety tato �
� paritni disketa zabezpecuje (nejlepe na stitek paritni diskety), �
� jinak  nebude  obnoveni  disket  mozne. Je vhodne poznacit si na �
� diskety i jejich kontrolni soucty pro pozdejsi kontrolu  disket. �
� Pozor  -  vsechny  diskety  musi  mit stejny format (velikost) ! �
� Po vlozeni vsech disket skupiny  archivu zadejte povel "(Z)apis" �
� (kod za timto povelem je identifikacni kod paritni diskety).     �
��������������������������������������������������������������������
DS$P.8 Vlozte disketu do A: ... (D)alsi, (S)oubor, (P)reruseniDS$Z.PBL Vlozte disketu do A: ... (D)alsi, (S)oubor, (Z)apis (kod=FFFF), (P)reruseni���������������������������������������������������������������������Ŀ
�                    OBNOVENI poskozene diskety                      �
��������������������������������������������������������������������Ĵ
� K obnoveni poskozene diskety ze skupiny disket potrebujete paritni �
� disketu,  kterou  byla  tato skupina zabezpecena a vsechny ostatni �
� diskety  ze skupiny. Postupne vkladejte nejdrive paritni disketu a �
� potom  vsechny  ostatni  diskety. Na zaver zvolte povel "(Z)apis", �
� ktery  vygeneruje  novou  opravovanou  disketu  (kod za povelem je �
� identifikacni kod teto diskety).                                   �
�                                                                    �
� Pozn.: Pokud se behem operace objevila chyba na nektere z disket,  �
�        obnovi se chybejici cast dat z puvodni poskozene diskety !  �
����������������������������������������������������������������������
�����������������������������������������������������������������������Ŀ
�                     MODIFIKACE paritni diskety                       �
����������������������������������������������������������������������Ĵ
� Tuto  funkci  pouzijte  v pripade, ze chcete pridat dalsi disketu ke �
� skupine  archivnich  disket nebo ze chcete nekterou disketu vypustit �
� (popr. vice disket). V pripade modifikace diskety ze skupiny archivu �
� musite  tuto  disketu nejdrive vypustit a po modifikaci opet pridat. �
� Mezi  operacemi pridani nebo vypusteni neni rozdil, oboji se provadi �
� stejnym  zpusobem.  Nejdrive  vlozte  paritni disketu, potom vsechny �
� diskety,  ktere  chcete  pridat  ci  vypustit.  Nakonec zvolte povel �
� "(Z)apis",  ktery  vygeneruje  novou  paritni disketu (muzete pouzit �
� puvodni disketu). Kod za povelem je identifik. kod paritni diskety.  �
������������������������������������������������������������������������
H������������������������������������������������������������������Ŀ
�              TEST celistvosti skupiny disket archivu             �
������������������������������������������������������������������Ĵ
� Pri  testu celistvosti skupiny disket archivu vkladejte postupne �
� nejdrive  paritni disketu a potom vsechny ostatni diskety, ktere �
� jsou  zabezpeceny touto paritni disketou. Timto testem se overi, �
� zda  paritni  disketa  souhlasi  s  prirazenou skupinou archivu. �
� Pokud  vlozite  omylem  jinou  disketu  (nebo  dvakrat stejnou), �
� vyradite  ji  jejim  opetovnym vlozenim. Po vlozeni vsech disket �
� skupiny  archivu  i  s paritni disketou zadejte povel "(K)onec". �
� Udaj poctu procent za povelem udava zabezpecenou cast dat.       �
��������������������������������������������������������������������
��������������������������������������������������������������������Ŀ
�                       TEST citelnosti diskety                     �
�������������������������������������������������������������������Ĵ
� Vkladejte diskety, ktere chcete overit na citelnost. Pri nalezeni �
� chyby cteni se zobrazi chybove hlaseni. Na zaver testu se zobrazi �
� tez   kontrolni  soucet  diskety  a  identifikacni  kod  diskety. �
� Poznacte  si  tyto  udaje  na  stitek  diskety  pro jeji pozdejsi �
� kontrolu  a  identifikaci.  Timto zpusobem je mozne kontrolovat a �
� identifikovat tez paritni diskety.                                �
���������������������������������������������������������������������
��������������������������������������������������������������������Ŀ
�                      IDENTIFIKACNI kod diskety                    �
�������������������������������������������������������������������Ĵ
� Identifikacni  kod  diskety  slouzi k rychle identifikaci diskety �
� napr.  pri  vyhledavani diskety, pri kontrole celistvosti skupiny �
� disket  nebo  pri pouzivani katalogu disket. Identifikacni kod je �
� vytvoren  jako kontrolni soucet stopy 0 na strane 0 diskety. Neni �
� potreba  provadet kontrolni soucet cele diskety, pricemz vzajemne �
� rozpoznani  disket  je  v  praxi postacujici. Proto se doporucuje �
� poznacit si na disketu kontrolni soucet i identifikacni kod.      �
�                                                                   �
� Pozn.: pro zrychleni operace se mechanika mezi disketami nevypina �
���������������������������������������������������������������������
 - nacitam parametry disketyO%D1P9B CHYBA cteni BOOT sektoru diskety:  (O)pakovat, (D)ale, (P)rerusitO!P-6 V mechanice A: neni disketa !  (O)pakovat, (P)rerusitO#P/8 Disketa chranena proti zapisu !  (O)pakovat, (P)rerusitP                                                                               