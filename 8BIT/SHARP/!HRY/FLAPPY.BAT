@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo FLAPPY  -  p�esouv�n� koul�
echo ------
echo.
echo C�lem: modrou kouli na modrou cihlu.
echo �erven� koule lze rozm��knout. Houby
echo slou�� k usp�v�n� (st��l� se mezerou).
echo Sc�nu lze p�eru�it stiskem BREAK.
echo Po p�eru�en�: MEZERA=znovu, CR=menu.
echo.
echo ��������������� Hesla ���������������Ŀ
echo � 5:shiba�55:ayAko�105:Sappr�155:Engla�
echo �10:MegmI�60:Uf,f,�110:OhaYo�160:Rome!�
echo �15:PenTA�65:Chie?�115:Gohan�165:PaRie�
echo �20:miki!�70:sAKE!�120:Ramen�170:Letgo�
echo �25:sakra�75:Syogn�125:Nemui�175:FrEnc�
echo �30:1,2,0�80:bUSHi�130:Natsu�180:AFewe�
echo �35:??OkU�85:BakA!�135:Yuki!�185:GerMa�
echo �40:OmoRI�90:STONE�140:HeIwa�190:Tokyo�
echo �45:U-CaN�95:Japan�145:Pice!�195:Prend�
echo �50:QuoTe�00:HArfE�150:MZ801�200:OKU-H�
echo ���������������������������������������
..\sharpexe flappy.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
