��                           P  @ c @  `5(.yds �.�.��!�!�3���&�>Ivv.�.�6.�>.�� �����.�6����  .����� @r�  .�6.�6��.>*.�����  r�  .�6.�.�>.�6.���!$��!.�.�.�.QPW� @� ���3�����_XY�QPW� @� ���3�� ��_XY�QR������� �6,�Ȏش ����B����J�������ZY�����u�4π��u1R.����t�%�!3�.�.����t�%�!3�.�	Zπ� t.�.<u�C�<v>VP�.�6"�$� ��d��X�.�PS�3ۜ.��4���.�>&���[X^���RPV.�6"�0� ��� �.���^XZ�ϰd�e�Mt� ����	�	�!� ����ړ��P�1t�Ȏ؍6"���>���X� �t	���	�!� ���=4u�������3��ذn�t�� u�5�!.�.��Ȏ؍9�%�!�5�!.�.�	�Ȏ؍D�%�!.�6"�$� �� ��[�	�!�b�1.�� .��b�2.��} .�� ��B�'�W�h _����>,�h�1����h�2���2���.)*�h�3����h�4����v�1����v�2���v�3���v�4���i� ���n� ���s�1���s�2����� �� ����3ҁ�  ;�8�</t<-t<?u��?u�� u��� ;�� :�uՀ� t;��:�u����z���;���<$t,tl<0r�<9w�� ,0�;�[�,0|V<	R�R�
 ��Z�����C�3�;�<� <ar<fw1,a
�	�,0|&<	"�R� ��Z�������� �Ȋ�����Ī��Ò��8 	�%(���F���-���2��A��( �A�(����CGA-Emulator Ver. 1.0 (C) 1987 by Heimsoeth Software GmbH & Co KG
$CGA-Emulator usage: EMU [possible switches]
    -B1:nn (1024) = copy nn words from bank 2 to 3 per timer tick
    -B2:nn (   0) = copy nn words from bank 1 to 4 per timer tick
  6845 register parameters for graphics mode: 
  Horizontal: 
    -H1:nn (  53) = Num. chars per row minus 1
    -H2:nn (  34) = Num. visible chars per row
    -H3:nn (  30) = Pos. of first char during sync minus 1
    -H4:nn (   7) = Num. chars during sync per row minus 1
  Vertical: 
    -V1:nn ( 121) = Num. rows minus 1
    -V2:nn (   2) = Num. scans in addition to number of rows
    -V3:nn ( 100) = Num. visible rows
    -V4:nn ( 115) = Row number to begin retrace
  Other: 
    -I:nn  (   2) = 1=interlace, 2=normal
    -N:nn  (   2) = Num. scans per row minus 1
    -S1:nn (   0) = First scan where cursor will overlay a char
    -S2:nn (   2) = Last  scan where cursor will overlay a char
    -NT           = Do NOT use timer tick (default is used)
    -DE           = Deactivate installed EMU
  Note: Parameters preceded with a dollar sign are interpreted in hexadecimal
 $EMU deactivated$