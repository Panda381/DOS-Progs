�ss#�&��R�|�	�!Z�@� �!� L�!���; ����	r��	�J�� �!rϻ��H�!s�H�!r���������� r��z�x�~�� �Z �,tP;Xu�?��!���X�,tP;Xu�-+-v3����X;-� s��< u�,tP�� X�L�!�x3�3�3��;>vs2W&�:/u��G�0�uX�X��&�+�s63��2_��r�s����Ǌ/�r� r�;zs����0�X��>v��0�!<r3�, =p r+��3�3�G9E�u�G9tGG��G8u��}�.u�E�DA�E�T��j.�f.�h� =�!r!��z�x3Ҵ?�!r
;�r���v�>�!��f�=�!s�f3ɴ<�!s	���, �F���v3��x�@�!r�;�u�>�!ô*�!�ڋ�3���;�s�9 �A��� ���u�K�6X�S� ��.u��
t��2���Y��u� �[øc��.t�l� ����u��rPQ�d���
�u$u�YX�3ɻ
 3���RA�u�Z��0��!��þ� �\�� �8� ru</�tp�0� rt</t�>/(s����/���_ rK�c </t�<Au�,��<Pu�,��<Ru�,��N�! r�-  P�
 �&-Z� £-� s����� r
<9w,0sN��� rt�N���<	u� <ar<zw, < sN�                                                 TIMERUN.DAT       TIMERUN V1.0 - casovane spousteni programu; (c) Miroslav Nemecek
$Chyba - nedostatek pameti ke spusteni programu TIMERUN !
Chyba pri zapisu do souboru TIMERUN.DAT !
Zadejte:    TIMERUN  jmeno  [dnu]  [/A]  [/?]
               jmeno ........... jmeno testovane podminky (napr. jmeno
                                 programu) - lze pouzit bezne znaky DOS krome
                                 mezer a "/"; podminka se eviduje v TIMERUN.DAT
               dnu ............. pocet dnu od posledniho spusteni programu
                                 (implicitne 1 den)
               /A .............. aktualizace data podminky (program spusten)
                                 - provede se jen pri splneni podminky
               /P .............. zobrazeni ubehleho poctu dnu podminky
               /R .............. zobrazeni zbyleho poctu dnu podminky

Navratovy kod: 0 ............... dosazeno pozadovaneho poctu dnu
               1 ............... program jeste neni potreba spoustet

Priklad:       TIMERUN chkdsk 7 /A
               IF ERRORLEVEL 1 GOTO dale
               chkdsk
               :dale
