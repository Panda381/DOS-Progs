�:�<�� �\�� �8�{�s� <!u%�r)<Cu�&����<Mu�&����<*uH�� s�s�<Cu� �	<Du�@� rR<0r�<4w�� ,0����� r5<0r�<4w���<Cu�&���<Mu�&���<Wu����u�} � � �| �|t�=�t�� �t�=�t�;�t�k�t�� t�&�@t����� ��<	t�< t�</t�<ar<zw, < sN�P�	�!X�P�r;�r��i�X�P� =�!�s�������
�S�X�PQRR�� ��!Z�7 �N�!r��uR������
� Z3ɴ<�!�ZYX�PR��u(���h����!
�u��!����w�<t<u���ZXÿ�� �9 �����u��/ ��Y
�l
�|�s�������� �@�!r�;�u�>�!r亠�)���P���p� � X�qúY
�l
�*���� �?�!s�1��;�u��>�!r��
�R��L ���������- ������ ���������>@��t��w����������P���p� � X�q�R��$ s�����P� r�����
 r� Z�PSQ���E�����?��������* r���# r��� r�^*� r�|�� ���� �Y[X�Ê��������x������:�u	�����:�t��� s�U���b
�x
�-�s���v���� �@�!r�;�u�>�!r㺄�����J �b
�x
������ �?�!s�{�9�;�u��>�!r�
��� �% r�- s	Mu�
��������QR� � �) ZY�QR� � � ZY�QR� � � ZY�P��
P��P�SR����� Z[X�PSQRVWU�]_^ZY[X�PSQ����0�&��ȱ���=��r)�Y[Xà�$C��������t�� sA�t�X�s���[��t4��r/���DDt�| t�L��t�[�r��r�[������s��t� ��9�r�s޹ � �*�r�s��t
��r�s��t�u�� � �[s�����(3ҡ���;�����O�����c���������ؿ'��� r;�r�'���
 ��w��������3Ɋ����r%�Ŋ�����%��t@@����?���ƴ @�����3ɻ@ �� s�+�������u�A���QR�� �r�6��Ά�����
��4�ZY���  � � �#�rH����u� �< ��� �ŀ�w�, ;�u�Ku�<�u� �S ��� �ŀ�w�C ;�u�Ku��SQR��  ����3�� r"u
�tSQA:�w	C� rt��Y[s@��u�HZY[�SQR��  ������  � � ��r(��A��@r� � ��� �ŀ�w�
 ;�u�Ku��SQR�3�� ���* r$u��
vSQA��@s	C� rt��Y[s@A��@r�HZY[�PSQRVW��r(�6���� ��ˊ���s���6���� ���_^ZY[X�R���9�ZPSQRV�
 3ɓ3���������0RA���u�X� ��^ZY[X�PQR���!ZYX�QVW�6��ƾ�  ����<U�u���u�����r���_^Y�PSQRVW�6����U�u�<�u�|r�| r�<�u�|s� �D=  r�� r��D� �~ r�| t��| tڋD
�u�
�tϣ��D
�u�
�t����&���D3��u�|&)u8�D �T"�L3ۀ|&)u�\�u���Oǃ� rG;�s��@t��� s�_^ZY[X�P�t��s��t�X�PSR���&����&��u��&��r�����u�Z[X�PRV���D�t6=@ s1���D�t'
�u#���D�t= r�D�t= s����s�^ZXú����< r9���������� B���� �N r����� ���������� &���t��PSQR����3��ع �l�쨀t	;lt����ZY[X�PSQR����3��ع �l��u	;lt����ZY[X�CMOS.BIN MBOOT.BIN Soubor CMOS$Soubor MBOOT$.BIN jiz existuje a bude prepsan novym obsahem !$.BIN nenalezen !
$VAROVANI - obsah pameti CMOS bude navracen ze souboru CMOS.BIN !$VAROVANI - obsah sektoru MBOOT pevneho disku
           bude navracen ze souboru MBOOT.BIN !$
   Esc=preruseni operace, jina klavesa=pokracovani: $Chyba zapisu do souboru CMOS.BIN !
$Chyba zapisu do souboru MBOOT.BIN !
$Chyba zapisu do pameti CMOS !
$Chyba zapisu sektoru MBOOT na disk !
$Chyba cteni ze souboru CMOS.BIN !
$Chyba cteni MBOOT sektoru z disku !
$Chyba cteni ze souboru MBOOT.BIN !
$Obsah pameti CMOS ulozen do souboru CMOS.BIN.
$Obsah pameti CMOS ($64$128$256$ bajtu) byl navracen ze souboru CMOS.BIN.
   K aktualizaci nastaveni CMOS je nyni treba provest
   tvrdy RESET pocitace pomoci tlacitka RESET...
$Obsah MBOOT sektoru pevneho disku ulozen do souboru MBOOT.BIN.
$Obsah MBOOT sektoru pevneho disku byl navracen ze souboru MBOOT.BIN.
$ @ Nedostatek pameti k provedeni operace !
$PCBACK V1.03 - zalohovani konfigurace PC; (c) Miroslav Nemecek
$Zadejte:   C ..... uschova obsahu CMOS do souboru CMOS.BIN
           !C .... navrat obsahu CMOS ze souboru CMOS.BIN
           M ..... uschova sektoru MBOOT do souboru MBOOT.BIN
           !M .... navrat sektoru MBOOT ze souboru MBOOT.BIN
           *C .... detekce parametru pevneho disku C:
           *D .... detekce parametru pevneho disku D:
                   - uvedenim cislic 0 az 4 za parametrem lze
                     urcit pouzite testy (implicitne "*C1234"):
                              0 = aktualni informace BIOS
                              1 = pouzit MASTER BOOT
                              2 = pouzit DOS BOOT
                              3 = pouzity informace AT-BUS
                              4 = pouzit test citelnosti
           W ..... provest operaci bez dalsiho varovani
$�
Parametry pevneho disku C:
--------------------------
testuji... $disk nenainstalovan
$parametry nelze urcit
$ pocet sektoru : $
    pocet hlav : $
   pocet valcu : $
sektoru celkem : $
 kapacita [MB] : $           ��