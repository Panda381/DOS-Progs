
; Makra KONTEXTu: SHIFT-F1 zv�razn�n� text
;                 SHIFT-F2 kl�vesy s p�ek�dov�n�m
;                 SHIFT-F3 nadpis
;                 SHIFT-F4 nadpis 2
;                 ALT-A  db ' ',LF

INCLUDE  DEF.ASM

LekSeg3  SEGMENT   BYTE PUBLIC

IFNDEF   DEMO

; ------ lekce 25 - �
;�
LekcC25  label     byte
Lekc125  label     byte
Lekc225  label     byte
db '�)',LF
db LF
db 'P�smeno � p��eme ukazov��kem prav� ruky. Ukazov��ek vychylujeme m�rn�',LF
db 'vpravo vzh�ru.',LF
db LF
db 'ukazov��kem prav� ruky  - �',LF
db LF
db 'Pozor na spojen� n�, m�, h� a z�, doch�z� p�i nich �asto k p�eklep�m.',LF
db LF
db LF
db EOT

LekcI25  label     byte
db '�)',LF
db LF
db LF
db 'P�smeno  �  p��eme  pomoc� tzv. mrtv� (prefixov�) kl�vesy. Mal��kem lev�',LF
db 'ruky  stiskneme kl�vesu ��rky `, potom stiskneme op�t mal��kem lev� ruky',LF
db 'p�smeno a.',LF
db LF
db LF
db LF
db LF
db EOT

LDatC25  label     byte
LDatI25  label     byte
LDat125  label     byte
LDat225  label     byte
db '������� j�j�j�j�j�j�j�j j�m�j�m� j�n�j�n� j�h�j�h� j�z�j�z�',LF
db 'm�j v�j n�j b�j m�j v�j n�j b�j m�j v�j n�j b�j m�j v�j n�j',LF
db 'h�j z�j n�j h�j z�j n�j h�j z�j n�j h�j z�j n�j h�j z�j n�j',LF
db 'ju�j �lk�j ju�j �lk�j ju�j �lk�j ju�j �lk�j ju�j �lk�j ju�j',LF
db 'mal� jak� mal� jak� mal� jak� mal� jak� mal� jak� mal� jak�',LF
db '��ry m�ry ��ry m�ry ��ry m�ry ��ry m�ry ��ry m�ry ��ry m�ry',LF
db 'd�le m�me m�te d�le m�me m�te d�le m�me m�te d�le m�me m�te',LF
db 'r�na slab� r�na slab� r�na slab� r�na slab� r�na slab� r�na',LF
db 'z�jem z�vod n�vrh st�le st�ty pr�ce kter� velk� jasn� dobr�',LF
db 'pl�nov�n� prohlubov�n� prosazov�n� projedn�v�n� poskytov�n�',LF
db 'vl�dn� komise, z�kladn� ukazatel, zdokonalov�n�m pl�nov�n�,',LF
db 'technick� dokumentace, dobr� spolupr�ce, z�vazn� objedn�vka',LF
db 'st�l� kontrola, st�tn� podniky, zas�l�me V�m, St�tn� banka.',LF
db FF
db 'zhodnocov�n� pl�n m�me st�tn� m�te pl�nov�n� �esk� skute�n�',LF
db 'V�s d�le z�vody mezin�rodn�ho kter� pr�ce org�ny objedn�vka',LF
db 'V�m n�s n�rodn� mezin�rodn�ho st�le n�vrhy zas�l�me dod�vky',LF
db 'm� dobr� z�pis zpr�va n�klady z�jem z�silka z�klady n�ro�n�',LF
db FF
db 'Pros�me V�s, abyste n�m zaslal nab�dku s ud�n�m podrobnost�',LF
db 'o balen� a dodac�ch podm�nk�ch. Z�silka nebyla v�as dod�na.',LF
db 'Odvol�v�me se na jedn�n� z listopadu. Pros�me o zpr�vu, zda',LF
db 'm�me d�le po��tat s objedn�vkou. Z�sady pro uzav�r�n� smluv',LF
db 'V�m zas�l�me. Banka posoudila finan�n� pl�n a odeslala sv�j',LF
db 'pl�n. N�vrh pl�nu pr�ce je zpracov�n a nyn� je projedn�v�n.',LF
db EOT

; ------ lekce 26 - �
;�
LekcC26  label     byte
Lekc126  label     byte
Lekc226  label     byte
db '�)',LF
db LF
db 'P�smeno � p��eme ukazov��kem lev� ruky. Ukazov��ek vychylujeme kolmo',LF
db 'vzh�ru.',LF
db LF
db 'ukazov��kem lev� ruky  - �',LF
db LF
db 'D�vejte si pozor na �ast� hmatov� spojen� v�, b� a t�.',LF
db LF
db LF
db EOT

LekcI26  label     byte
db '�)',LF
db LF
db LF
db 'P�smeno  �  p��eme  pomoc� tzv. mrtv� (prefixov�) kl�vesy. Mal��kem lev�',LF
db 'ruky  stiskneme  kl�vesu  ��rky `, potom stiskneme ukazov��kem lev� ruky',LF
db 'p�smeno r.',LF
db LF
db LF
db LF
db LF
db EOT

LDatC26  label     byte
LDatI26  label     byte
LDat126  label     byte
LDat226  label     byte
db '�������� f�f�f�f�ff�f�f v�f�v�f� b�f�b�f� g�f�g�f� t�f�t�f�',LF
db 'fr�f asd�f fr�f asd�f fr�f asd�f fr�f asd�f fr�f asd�f fr�f',LF
db '�fa �f� �fe �f� �fa �f� �fe �f� �fa �f� �fe �f� �fa �f� �fe',LF
db 'p�es b�eh p�es b�eh p�es b�eh p�es b�eh p�es b�eh p�es b�eh',LF
db 'po�ad ��dek po�ad ��dek po�ad ��dek po�ad ��dek po�ad ��dek',LF
db 'h�ib k�ik h�ib k�ik h�ib k�ik h�ib k�ik h�ib k�ik h�ib k�ik',LF
db 'sada� p�esad� ke� sada� p�esad� ke� sada� p�esad� ke� sada�',LF
db '��jen p��mo ��jen p��mo ��jen p��mo ��jen p��mo ��jen p��mo',LF
db 'dob�e t�eba st�ed ��jen p��mo d�evo t�et� p�ece ��dit ��dek',LF
db 'p�ikl�d�me p�edkl�d�me p�ikl�d�te p�edkl�d�te p�edpokl�d�me',LF
db FF
db 'p�i p�edem vnit�n� prost�edky opat�en� vytvo�it p�edpoklady',LF
db 'p��mo ��zen� p��lohy �st�edn� d��ve t�eba pot�eby mimo��dn�',LF
db '�editel za��zen� hospod��stv� dob�e p�itom ve�ejn� p�eprava',LF
db 'mimo��dn� pozornost, hospod��sk� spolupr�ce, vnit�n� pokyny',LF
db 'soubory opat�en�, proto je t�eba, vytv��eli p�itom prostor.',LF
db FF
db 'Potvrzen� objedn�vky jsme nemohli zaslat d��ve, nejd��ve je',LF
db 'pot�eba up�esnit platebn� podm�nky. Seznam opat�en� zas�l�m',LF
db 'p�esto v p��loze. R�di V�m p�iprav�me pot�ebnou dokumentaci',LF
db 'pro zahrani�n�ho z�kazn�ka. Dob�e regulujeme spot�ebu plynu',LF
db 'a elekt�iny. Zahrani�n� investi�n� prost�edky nen� pot�eba.',LF
db 'Jsme p�ipraveni rychle zajistit p�epravu z�silek p�es mo�e.',LF
db 'Program rozvoje vnit�n� struktury byl p�ebudov�n. Rozhodnu-',LF
db 't� je st�edem z�jmu spot�ebitel�. P�ijat� opat�en� p�edali.',LF
db EOT

; ------ lekce 27 - �
;�
LekcC27  label     byte
Lekc127  label     byte
Lekc227  label     byte
db '�)',LF
db LF
db 'P�smeno � p��eme prsten�kem prav� ruky.',LF
db LF
db 'prsten�kem prav� ruky  - �',LF
db LF
db 'Toto p�smeno je hmatov� velmi obt��n�. Ukazov��ek slou�� jako op�rn� bod',LF
db 'na kl�vesnici, proto mus� z�stat v z�kladn� poloze!',LF
db LF
db LF
db EOT

LekcI27  label     byte
db '�)',LF
db LF
db LF
db 'P�smeno  �  p��eme  pomoc� tzv. mrtv� (prefixov�) kl�vesy. Mal��kem lev�',LF
db 'ruky  stiskneme kl�vesu ��rky `, potom stiskneme prost�edn�kem lev� ruky',LF
db 'p�smeno e.',LF
db LF
db LF
db LF
db LF
db EOT

LDatC27  label     byte
LDatI27  label     byte
LDat127  label     byte
LDat227  label     byte
db '��������� l�l�l�l�l�l�l k�l�k�l� ��l���l� j�l�j�l� .l�l.l�l',LF
db 'lo�l jkl�� lo�l jkl�� lo�l jkl�� lo�l jkl�� lo�l jkl�� lo�l',LF
db 'm�l z�l n�l h�l m�l z�l n�l h�l m�l z�l n�l h�l m�l z�l n�l',LF
db 'l�ky l�pe l�ky l�pe l�ky l�pe l�ky l�pe l�ky l�pe l�ky l�pe',LF
db 'd�le rel� d�le rel� d�le rel� d�le rel� d�le rel� d�le rel�',LF
db 'tak� mal� tak� mal� tak� mal� tak� mal� tak� mal� tak� mal�',LF
db 'nov� star� nov� star� nov� star� nov� star� nov� star� nov�',LF
db 'velk� piln� siln� mlad� star� dobr� kter� modr� �esk� st�l�',LF
db 'kvalifikovan� �daje, pouh� �ty�i cel�, vysok� n�roky, jak�,',LF
db 'leskl� cetky, n�ro�n� �koly, Mozart byl g�nius, ploch� sklo',LF
db FF
db 'cel� pl�novit� �esk� americk� l�pe pr�myslov� hodnotn� mal�',LF
db 'tak� spr�vn� zejm�na stejn�ho odborov� podnikov� technick�m',LF
db 'p��e zna�n� pot�ebn� zbyte�n� mal� velk� kter� hospod��sk�m',LF
db 'jak� jednotn� probl�m �asov�m krajsk�m dlouhodob�m ��eln�ho',LF
db FF
db 'V p��loze V�m tak� zas�l�me vypracovan� a schv�len� pokyny.',LF
db 'Nov� ceny budou platit od z��� t. r., polotovary dod�me jen',LF
db 'v t�to cenov� kategorii. V p��loze zas�l�m upravovan� tech-',LF
db 'nick� dokumenty. Pl�n pravideln�ho z�sobov�n� prodejen jsme',LF
db 'p�epracovali podle V�mi udan�ho nov�ho p�epravn�ho syst�mu.',LF
db EOT

; ------ lekce 28 - �
;�
LekcC28  label     byte
Lekc128  label     byte
Lekc228  label     byte
db '�)',LF
db LF
db 'P�smeno � p��eme prsten�kem lev� ruky.',LF
db LF
db 'prsten�kem lev� ruky  - �',LF
db LF
db 'Toto p�smeno je hmatov� velmi obt��n�. Ukazov��ek slou�� jako op�rn� bod',LF
db 'na kl�vesnici, proto mus� z�stat v z�kladn� poloze!',LF
db LF
db LF
db EOT

LekcI28  label     byte
db '�)',LF
db LF
db LF
db 'P�smeno  �  p��eme  pomoc� tzv. mrtv� (prefixov�) kl�vesy. Mal��kem lev�',LF
db 'ruky  stiskneme  kl�vesu  ��rky  `, potom stiskneme prsten�kem lev� ruky',LF
db 'p�smeno s.',LF
db LF
db LF
db LF
db LF
db EOT

LDatC28  label     byte
LDatI28  label     byte
LDat128  label     byte
LDat228  label     byte
db '�������� s�s�s�s�s�s�s a�s�a�s� d�s�d�s� f�s�f�s� sxs�sxs�s',LF
db 'sw� dw� sw� dw� sw� dw� sw� dw� sw� dw� sw� dw� sw� dw� sw�',LF
db 'sw�s fd�sa sw�s fd�sa sw�s fd�sa sw�s fd�sa sw�s fd�sa sw�s',LF
db 'su�e su�� su�e su�� su�e su�� su�e su�� su�e su�� su�e su��',LF
db '�sa �si �se �s� �sa �si �se �s� �sa �si �se �s� �sa �si �se',LF
db 'v�� va� v�� va� v�� va� v�� va� v�� va� v�� va� v�� va� v��',LF
db '�at �epot �at �epot �at �epot �at �epot �at �epot �at �epot',LF
db '��p �ik ��p �ik ��p �ik ��p �ik ��p �ik ��p �ik ��p �ik ��p',LF
db 'lep�� dal�� hor�� lep�� dal�� hor�� lep�� dal�� hor�� lep��',LF
db '�l�pota ka�tan �paleta �nek �molka �otek �koda v�echno �peh',LF
db 'V�eobecn� podm�nky, Va�e zpr�va, v p���t�m roce, dal�� rok,',LF
db 'na�e hospod��stv�, zlep�en�m situace, V�� dopis, p�edev��m,',LF
db '�e�en� probl�m�, zvl��tn� proveden�, reklamovan� po�kozen�.',LF
db FF
db 'n�� na�� na�emu na�eho na�ich av�ak dal�� do�la �kola po�ta',LF
db 'V�� Va�� Va�emu Va�eho Va�ich p�edev��m p��slu�n� zvy�ov�n�',LF
db 'v�ak p���t� v�ichni v�eobecn� ov�em dne�n� za�leme nejvy���',LF
db FF
db 'Mus�me p�ipravit dal�� formy �e�en�. Nov� pokyny V�m za�le-',LF
db 'me po�tou. Reklamaci vy�et��me a zpr�vu V�m po�leme co nej-',LF
db 'd��ve. Podle na�ich informac� dod�v� konkurence srovnateln�',LF
db 'stanice za mnohem vy��� ceny. M�me z�jem o roz���en� spolu-',LF
db 'pr�ce s Va��m podnikem. P���t� zpr�vu o�ek�v�m koncem roku.',LF
db 'Pro p���t� rok p�ipravujeme zlep�en� na�ich za��zen�. Podle',LF
db 'n�kladn�ho listu byla sice cel� z�silka odesl�na v term�nu,',LF
db 'av�ak do�la po�kozena. P���t� p�edn��ku pl�nujeme v �ervnu.',LF
db 'Chceme pokra�ovat ve zvy�ov�n� kvality a rychlosti dopravy.',LF
db FF
db 'Investice jsou hmotn� a finan�n� zdroje vynakl�dan� na z��-',LF
db 'zen� z�kladn�ch prost�edk� a na rekonstrukce, modernizace a',LF
db 'p��stavby a n�stavby p�vodn�ch z�kladn�ch prost�edk�. Inve-',LF
db 'stic� jsou tak� zdroje vynakl�dan� na n�kup z�kladn�ch pro-',LF
db 'st�edk� ze zahrani�n�ch zdroj�. Rekonstrukce jsou z�sahy do',LF
db 'technologick� a konstruk�n� ��sti p�vodn�ch z�kladn�ch pro-',LF
db 'st�edk�. Opravou stroj� se obnovuje jejich ��ste�n� fyzick�',LF
db 'opot�eben� nebo po�kozen� za ��elem uveden� znovu do provo-',LF
db 'zu. P�itom se zpravidla modernizuj� jejich technick� vlast-',LF
db 'nosti, provozn� kvalita i bezpe�nost a provozn� vlastnosti.',LF
db EOT

; ------ lekce 29 - �
;�
LekcC29  label     byte
Lekc129  label     byte
Lekc229  label     byte
db '�)',LF
db LF
db 'P�smeno � p��eme lev�m mal��kem, kter� vychylujeme p��mo nahoru.',LF
db LF
db 'mal��kem lev� ruky  - �',LF
db LF
db 'V �ast�ch spojen� v�, b� a t� je tento pohyb velmi n�ro�n�.',LF
db LF
db LF
db LF
db EOT

LekcI29  label     byte
db '�)',LF
db LF
db LF
db 'P�smeno  �  p��eme  pomoc� tzv. mrtv� (prefixov�) kl�vesy. Mal��kem lev�',LF
db 'ruky  stiskneme  kl�vesu  ��rky  `, potom stiskneme prsten�kem lev� ruky',LF
db 'p�smeno w (pozor - ne tedy p�smeno e, ale sousedn� p�smeno w !).',LF
db LF
db LF
db LF
db LF
db EOT

LDatC29  label     byte
LDatI29  label     byte
LDat129  label     byte
LDat229  label     byte
db '��������� a�a�a�a�a�a�a s�a�s�a� d�a�d�a� f�a�f�a� x�a�x�a�',LF
db 'aq�fa fds�a aq�fa fds�a aq�fa fds�a aq�fa fds�a aq�fa fds�a',LF
db 'v�da v�ta v�da v�ta v�da v�ta v�da v�ta v�da v�ta v�da v�ta',LF
db 'sed� v�d� sed� v�d� sed� v�d� sed� v�d� sed� v�d� sed� v�d�',LF
db 'd�d b�h d�d b�h d�d b�h d�d b�h d�d b�h d�d b�h d�d b�h d�d',LF
db 'st�na �t�n� st�na �t�n� st�na �t�n� st�na �t�n� st�na �t�n�',LF
db 'kot� rob� kot� rob� kot� rob� kot� rob� kot� rob� kot� rob�',LF
db 'kvalitn� maxim�ln� d�sledn� odpov�dn� soustavn� organiza�n�',LF
db 'odpov�dn�j�� kvalitn�j�� �sporn�j�� aktivn�j�� d�sledn�j��m',LF
db 'p��sn� zam�stnance, je�t� lep��, �asn� z�tra, v tomto sm�ru',LF
db 'odb�ratelsk� vztahy, d�lbou pr�ce, v zem�d�lstv�, t���me se',LF
db 'n�kterou zpr�vu, v�c� na�ich zam�stnanc�, �sp��n� zvl�dneme',LF
db FF
db 'jist� je�t� sv�t� krom� m�s�c d�lba d�ln�ci d�ln�k� doprav�',LF
db 'dob� pln� m�st aktivn� zna�n� �sporn� zem�d�lci zem�d�lstv�',LF
db 'odpov�dn� v�c v�da v�dy t���me v�nujeme odpov�dnost d�ln�ci',LF
db 'm�li v�t�� spole�n� pl�novit� zem� krom� d�sledn� maxim�ln�',LF
db FF
db 'D�kujeme V�m za informaci. V posledn� dob� je�t� stoupl po-',LF
db '�et objedn�vek. Ve druh� vln� p�jde o zm�ny cen materi�l� a',LF
db 'surovin. Prov��ili jsme pe�liv� celou situaci v doprav�. Na',LF
db 'z�klad� t�chto podklad� zajist�me p�epravu z�silky. Pom�rn�',LF
db 'lep�� je nab�dka u kvalitn�j��ch v�c�. K uskute�n�n� t�chto',LF
db 'c�l� bude pot�eba ode v�ech vyvinout mimo��dn� velk� �sil�.',LF
db FF
db 'D�len�m vyr�b�n�ho sortimentu do d�l��ch skupin, kter� jsou',LF
db 'pl�nov�ny a sledov�ny ve v�ech ��stech kalkula�n�ho vzorce,',LF
db 'jsme velmi zdokonalili n�� syst�m pl�nov�n� a vyhodnocov�n�',LF
db 'd�l��ch ukazatel�. Uplatnili jsme zde hmotnou zainteresova-',LF
db 'nost vedouc�ch pracovn�k� na pln�n� sortimentu elektrom�r�.',LF
db 'T�m stoupla discipl�na p�i pln�n� prov�d�c�ho pl�nu a je�t�',LF
db 'v�ce se prohloubila vz�jemn� spolupr�ce mezi �seky provozu.',LF
db 'Dnes r�no se uskute�nila porada vedouc�ch pracovn�k� na�eho',LF
db 'podniku k pln�n� ro�n�ho pl�nu. Zpr�vu o hospoda�en� a tak�',LF
db 'zpr�vu o pln�n� pl�nu za pololet� p�ednesl �editel podniku.',LF
db 'Zpr�vu �editele doplnil hlavn� technik. Ve sv� ro�n� zpr�v�',LF
db 'upozornil na probl�my se zav�d�n�m nov�ho zp�sobu obr�b�n�.',LF
db FF
db 'Obrac�me se na V�s s prosbou, abyste ihned zlep�ili kvalitu',LF
db 'balen� p��stroj� zejm�na do zahrani��. P�i kontrole, kterou',LF
db 'jsme v minul�m roce prov�d�li ve Va�ich skladech, jsme tak�',LF
db 'na tuto skute�nost upozornili. Va�i pracovn�ci nedostate�n�',LF
db 'plnili bedny d�evitou vlnou. Doch�z� tak k po�kozov�n� p��-',LF
db 'stroj�. Ani dal�� ochrana materi�lu neodpov�dala n�ro�nosti',LF
db 'p�epravy p��stroj�. Bedny nemaj� p�edepsanou s�lu prken ani',LF
db 'nejsou zaji�t�ny proti po�kozen� p�i nakl�d�n� a vykl�d�n�.',LF
db EOT

; ------ lekce 30 - �
;�
LekcC30  label     byte
Lekc130  label     byte
Lekc230  label     byte
db '�)',LF
db LF
db 'P�smeno � p��eme prav�m ukazov��kem, kter� vychylujeme vlevo nahoru.',LF
db LF
db 'ukazov��kem prav� ruky  - �',LF
db LF
db 'Uv�domte si rozd�l mezi � a � a dbejte, aby prav� mal��ek, kter� tvo��',LF
db 'op�rn� bod, z�stal na sv� kl�vese.',LF
db LF
db LF
db EOT

LekcI30  label     byte
db '�)',LF
db LF
db LF
db 'P�smeno  �  p��eme  pomoc� tzv. mrtv� (prefixov�) kl�vesy. Mal��kem lev�',LF
db 'ruky  stiskneme  kl�vesu ��rky `, potom stiskneme ukazov��kem prav� ruky',LF
db 'p�smeno y.',LF
db LF
db LF
db LF
db LF
db EOT

LDatC30  label     byte
LDatI30  label     byte
LDat130  label     byte
LDat230  label     byte
db '��������� j�j�j�j�j�j j�j�j�j� n�j�n�j� h�j�h�j� y�j�jy�j�j',LF
db 'ju�j �lk�j ju�j �lk�j ju�j �lk�j ju�j �lk�j ju�j �lk�j ju�j',LF
db 'n�ch k�ch p�ch h�ch n�ch k�ch p�ch h�ch n�ch k�ch p�ch h�ch',LF
db 'r�ch d�ch t�ch v�ch r�ch d�ch t�ch v�ch r�ch d�ch t�ch v�ch',LF
db 's��ek d�mka s��ek d�mka s��ek d�mka s��ek d�mka s��ek d�mka',LF
db 'jak� jin� jak� jin� jak� jin� jak� jin� jak� jin� jak� jin�',LF
db 'st�l� jasn� pevn� nutn� m�rn� dobr� kaln� vadn� velk� �esk�',LF
db 'v�robn� celkov� piln� v�deck� p�semn� zem�d�lsk� st�l� mil�',LF
db 'slab� st� pouh� dlouh� tuh� v�znamn� v�hradn� vyz�vav� v�ti',LF
db 'v�znamn� jubileum, s�rov� chleb��ek, sud� t�den, chor� d�d,',LF
db FF
db 'jin�m pevn� celkov� podnikov� kter� kter�ch krajsk� n�ro�n�',LF
db 'v�born� v�roba v�robn� v�stava v��e stejn� v�sledky v�konn�',LF
db 'cel� nov� jak� �esk� v�znamn� hospod��sk� pl�novan� n�ro�n�',LF
db FF
db 'Rozhoduj�c� pro posouzen� jakosti v�robku bude anal�za pro-',LF
db 'veden� na z�klad� vzorku. Realizovali jsme v�sledky v�zkumu',LF
db 'a v�voje. Jde o velmi n�ro�n�, nal�hav� ale tak� neodkladn�',LF
db '�kol. Nezbytn� bude vz�jemn� spolupr�ce mezi dodavatelsk�mi',LF
db 'a odb�ratelsk�mi organizacemi. Po��tek z�ru�n� doby v�robku',LF
db 'je ur�en datem v�roby vyzna�en�m na n�m, d�lka je p�l roku.',LF
db EOT

; ------ lekce 31 - �
;�
LekcC31  label     byte
Lekc131  label     byte
Lekc231  label     byte
db '�)',LF
db LF
db 'P�smeno � p��eme lev�m ukazov��kem, kter� vychylujeme vpravo nahoru.',LF
db LF
db 'ukazov��kem lev� ruky  - �',LF
db LF
db 'Uv�domte si rozd�l mezi � a � a dbejte, aby lev� mal��ek, kter� tvo��',LF
db 'op�rn� bod, z�stal na sv� kl�vese.',LF
db LF
db LF
db EOT

LekcI31  label     byte
db '�)',LF
db LF
db LF
db 'P�smeno  �  p��eme  pomoc� tzv. mrtv� (prefixov�) kl�vesy. Mal��kem lev�',LF
db 'ruky  stiskneme kl�vesu ��rky `, potom stiskneme op�t mal��kem lev� ruky',LF
db 'p�smeno z.',LF
db LF
db LF
db LF
db LF
db EOT

LDatC31  label     byte
LDatI31  label     byte
LDat131  label     byte
LDat231  label     byte
db '�������� f�f�f�f�f�f f�f�f�f�f�f� d�f�d�f� s�f�s�f� c�f�c�f',LF
db 'ft�f asd�f ft�f asd�f ft�f asd�f ft�f asd�f ft�f asd�f ft�f',LF
db '�f� �fn �f� �f� �f� �fn �f� �f� �f� �fn �f� �f� �f� �fn �f�',LF
db '�fe �fd �fs �fd �fe �fd �fs �fd �fe �fd �fs �fd �fe �fd �fs',LF
db '�al �el �al �el �al �el �al �el �al �el �al �el �al �el �al',LF
db '��n� ��d� ��n� ��d� ��n� ��d� ��n� ��d� ��n� ��d� ��n� ��d�',LF
db 'jeho� ka�d� jeho� ka�d� jeho� ka�d� jeho� ka�d� jeho� ka�d�',LF
db '��dan� mno�stv� zbo��, �ivo�i�nou v�robu, po�adovan� slu�by',LF
db 'v�robn�m dru�stvu, t��k� pr�mysl, mo�nostem v�roby, proto�e',LF
db 'ka�d� ��dosti, �elezni�n� dopravou, s p��telsk�m pozdravem.',LF
db FF
db '�e v�dy zbo�� ka�dou pova�uj� ji� m��e mo�nosti n�le�itosti',LF
db '��dn� ��d�me �adatel mno�stv� mu�i �eny ml�de� sout�� t��ba',LF
db 'jako� n�br� �ivotn� po�adavky dru�stevn� slu�by poka�d� t��',LF
db 'kdy jeho� vyu��v�me nem��eme mo�n� ko�ich po��vat k��e jen�',LF
db FF
db 'Va�i zpr�vu jsme obdr�eli p��li� opo�d�n�, tak ji� nem��eme',LF
db 'vyhov�t Va�emu po�adavku. Zjistili jsme, �e k ��dn�mu omylu',LF
db 'nedo�lo. K z�le�itostem se vr�t�me, jakmile obdr��me od V�s',LF
db 'bli��� �daje. Litujeme, �e V�m nem��eme d�t okam�itou zpr�-',LF
db 'vu o mo�nostech v�roby. Po�adovan� zbo�� V�m nem��eme ihned',LF
db 'odeslat. Povolen� k poskytov�n� slu�eb ji� nen� vy�adov�no.',LF
db FF
db 'Pro dosa�en� stanoven�ch c�l� m�me ji� v�echny p�edpoklady.',LF
db 'Rozhoduj�c� bude, jak dok��eme vyu��t v�ech mo�nost�. Plat�',LF
db 'toti�, �e chceme-li obst�t v sout��i se sv�tem, mus�me v�ce',LF
db 'zn�t a l�pe pracovat. S obt��nost� a mno�stv�m �kol� rostou',LF
db 'i po�adavky na vedouc� pracovn�ky. Placen� slu�by p�izp�so-',LF
db 'bujeme po�adavk�m z�kazn�k� pro uspokojen� v�ech po�adavk�.',LF
db EOT

; ------ lekce 32 - ���
;�
LekcC32  label     byte
Lekc232  label     byte
db '���)',LF
db 'Na  ��seln�  �ad�  je  um�st�na  kl�vesa  ��rky  a  h��ku,  kter�  m� tu',LF
db 'vlastnost,  �e  po  jej�m  stisku  se kurzor neposune. Proto je naz�v�na',LF
db 'mrtvou  kl�vesou.  Tato  kl�vesa se pou��v� k psan� p�smen s ��rkou nebo',LF
db 'h��kem, kter� nejsou k dispozici na kl�vesnici p��mo (jako nap�. p�smena',LF
db '� � � a v�echna velk� p�smena s h��ky a ��rkami).',LF
db 'P�i  psan�  mal�ch p�smen s h��kem stiskneme a dr��me mal��kem lev� ruky',LF
db 'levou kl�vesu SHIFT a potom mal��kem prav� ruky stiskneme h��ek. Pust�me',LF
db 'kl�vesu SHIFT a stiskneme kl�vesu s po�adovan�m mal�m p�smenem.',LF
db LF
db EOT

LekcI32  label     byte
Lekc132  label     byte
db '���)',LF
db LF
db 'Tzv.  mrtv�  kl�vesa  (jinak t�� prefixov� kl�vesa) ` se pou��v� k psan�',LF
db 'p�smen  s  ��rkou  nebo  h��kem,  kter� nejsou k dispozici na kl�vesnici',LF
db 'p��mo (jako jsou p�smena ��� a v�echna velk� p�smena s h��ky a ��rkami).',LF
db LF
db 'P�i  psan� mal�ch p�smen ��� stiskneme mal��kem lev� ruky kl�vesu zp�tn�',LF
db '��rky ` a potom stiskneme kl�vesu s po�adovan�m p�smenem DTN.',LF
db LF
db LF
db EOT

LDatC32  label     byte
LDatI32  label     byte
LDat132  label     byte
LDat232  label     byte
db '��� ��� ��� �u �u �u �u �u �u �uj ��t ��m �uk ��p �uf �u��a',LF
db 'ze� m�� ze� m�� ze� m�� ze� m�� ze� m�� ze� m�� ze� m�� ze�',LF
db 'dr� su� dr� su� dr� su� dr� su� dr� su� dr� su� dr� su� dr�',LF
db 'stupe� z�rove� stupe� z�rove� stupe� z�rove� stupe� z�rove�',LF
db 's�� hu� tra� uhra�te u�ili�� l�ze�sk� poji��ovna zji��ujeme',LF
db 'up�es�ov�n� pl�n�, neust�le zd�raz�ujeme, upev�ov�n� svazku',LF
db 'v lo�sk�m roce, �ivotn� �rove�, nebo� chce�, pracovn� k�ze�',LF
db 'tak� pracovi��, nebo� odpov�� poji��ovny, odborn�ch u�ili��',LF
db 'zkvalit�ov�n� pr�ce, odm��ov�n� pracovn�k�, zvl��� d�le�it�',LF
db 'telefonn� s��, sklize� brambor, ihned prove�te, nebo� nech�',LF
db FF
db 'zvl��� �rove� alespo� sklize� s�� nebo� v�dy� bu�te odpov��',LF
db 'da� tra� lo�sk� zkvalit�ov�n� k�ze� stupe� kampa� spl�ujeme',LF
db FF
db 'Odpov�� V�m za�lu do t�dne. Upozor�ujeme na st�le velk� po-',LF
db '�et rizikov�ch pracovi��. Na dokonal�m ��zen� z�vis� �rove�',LF
db 'pr�ce. Vy�aduje to v�novat se zkvalit�ov�n� a zefektiv�ov�-',LF
db 'n� pr�ce. Nep�ipus�me, aby se p�i up�es�ov�n� pl�nu objevil',LF
db 'nedostatek z lo�sk�ho roku. Uji��ujeme, �e z�soba je n�zk�.',LF
db EOT

; ------ lekce 33 - ��������
;�
LekcC33  label     byte
db '���������)',LF
db 'P�i  psan�  velk�ch  p�smen  s  h��kem v prav� polovin� kl�vesnice (���)',LF
db 'stiskneme  a  dr��me lev�m mal��kem levou kl�vesu SHIFT, prav�m mal��kem',LF
db 'stiskneme  h��ek,  p��slu�n�m  prstem  prav�  ruky  stiskneme po�adovan�',LF
db 'p�smeno,  a teprve pot� uvoln�me kl�vesu SHIFT a navr�t�me mal��ek zp�t.',LF
db 'P�smeno  � p��eme tak� t�mto zp�sobem - jako bychom psali nad n�m h��ek.',LF
db 'P�i  psan�  velk�ch  p�smen s h��kem v lev� polovin� kl�vesnice (������)',LF
db 'postupujeme  obdobn�, av�ak po stisku h��ku uvoln�me levou kl�vesu SHIFT',LF
db 'a stiskneme a dr��me prav�m mal��kem pravou kl�vesu SHIFT.',LF
db LF
db EOT

Lekc233  label     byte
db '���������)',LF
db 'P�i  psan�  velk�ch  p�smen s h��kem v prav� polovin� kl�vesnice (� a �)',LF
db 'stiskneme  a  dr��me lev�m mal��kem levou kl�vesu SHIFT, prav�m mal��kem',LF
db 'stiskneme  h��ek,  p��slu�n�m  prstem  prav�  ruky  stiskneme po�adovan�',LF
db 'p�smeno,  a teprve pot� uvoln�me kl�vesu SHIFT a navr�t�me mal��ek zp�t.',LF
db 'P�smeno  � p��eme tak� t�mto zp�sobem - jako bychom psali nad n�m h��ek.',LF
db 'P�i  psan�  velk�ch p�smen s h��kem v lev� polovin� kl�vesnice (�������)',LF
db 'postupujeme  obdobn�, av�ak po stisku h��ku uvoln�me levou kl�vesu SHIFT',LF
db 'a stiskneme a dr��me prav�m mal��kem pravou kl�vesu SHIFT.',LF
db LF
db EOT

LekcI33  label     byte
Lekc133  label     byte
db '���������)',LF
db LF
db 'P�i  psan�  velk�ch  p�smen  s  h��kem  stiskneme lev�m mal��kem kl�vesu',LF
db 'zp�tn�  ��rky  `,  pot� p��slu�n�m prstem lev� nebo prav� ruky stiskneme',LF
db 'po�adovan� p�smeno spolu s kl�vesou SHIFT. Zvl��tn�m p��padem je p�smeno',LF
db '�, u kter�ho stiskneme W (nam�sto E), a p�smeno �, u kter�ho stiskneme J',LF
db '(nam�sto p�smene U).',LF
db LF
db LF
db LF
db EOT

LDatC33  label     byte
LDatI33  label     byte
LDat133  label     byte
LDat233  label     byte
db '��� ������ ��� ������ z� u� n� e� r� t� s� d� c� ���O.���O.',LF
db '�i�kov ��p �umava ��blice �ilina �koda ��slav �atec �umperk',LF
db FF
db '�Z, M�, �SAD, �SD, �R, PLZE�, HORA��OVICE, T�E��, A�, �EN�K',LF
db FF
db '�R, SB�S, �SAV, DOPORU�EN�, �SD, �KODA Plze�, V�KG Ostrava.',LF
db EOT

; ------ lekce 34 - ���
;�
LekcC34  label     byte
Lekc234  label     byte
db '�������)',LF
db LF
db 'Kl�vesa  s diakritickou ��rkou ',39,' je op�t tzv. mrtv� kl�vesa. Jej� pomoc�',LF
db 'p��eme  p�smeno � a velk� p�smena s ��rkou (������). P�i psan� p�smena �',LF
db 'stiskneme  prav�m  mal��kem  kl�vesu  s  ��rkou  a pot� stiskneme prav�m',LF
db 'prsten�kem  kl�vesu  s  p�smenem  o.  Obdobn�, s pou�it�m kl�vesy SHIFT,',LF
db 'p��eme velk� p�smena s ��rkou (������).',LF
db LF
db LF
db LF
db EOT

Lekc134  label     byte
LekcI34  label     byte
db '�������)',LF
db LF
db 'Kl�vesa  s diakritickou ��rkou ` je op�t tzv. mrtv� kl�vesa. Jej� pomoc�',LF
db 'p��eme  p�smeno � a velk� p�smena s ��rkou (������). P�i psan� p�smena �',LF
db 'stiskneme  lev�m  mal��kem  kl�vesu  s  ��rkou ` a pot� stiskneme prav�m',LF
db 'prsten�kem  kl�vesu  s  p�smenem  o.  Obdobn�, s pou�it�m kl�vesy SHIFT,',LF
db 'p��eme velk� p�smena s ��rkou (������).',LF
db LF
db LF
db LF
db EOT

LDatC34  label     byte
LDatI34  label     byte
LDat134  label     byte
LDat234  label     byte
db '������� ������� ������� ������� o�� E�� U�� I�� O�� A�� Y��',LF
db 's�ja m�da s�ja m�da s�ja m�da s�ja m�da s�ja m�da s�ja m�da',LF
db '�lehla, �r�n, �ra rocku, �mos, �st� na Labem, �da na radost',LF
db FF
db 'Je jist� velmi obt��n� posuzovat re�lnost uveden� progn�zy.',LF
db 'Vag�ny byly dnes nalo�eny. M�dnost n�mi nab�zen�ho zbo�� je',LF
db 'pln� srovnateln� s m�dou ve sv�t�. �sp��n� realizace pl�no-',LF
db 'van�ch �kol� z�vis� na �rovni ��dic� pr�ce. �ra m�dy jazzu.',LF
db EOT

; ------ lekce 35 - ?
;�
LekcC35  label     byte
db '?)',LF
db LF
db 'Otazn�k  je  um�st�n  na doln� �ad� a p��eme ho prost�edn�kem prav� ruky',LF
db 'za sou�asn�ho stisknut� lev� kl�vesy SHIFT lev�m mal��kem.',LF
db LF
db 'prost�edn�kem prav� ruky  - ?',LF
db LF
db 'V  textu  p��eme  otazn�k t�sn� za posledn� slovo bez odd�lovac� mezery,',LF
db 'mezeru d�l�me a� za otazn�kem.',LF
db LF
db EOT

LekcI35  label     byte
Lekc135  label     byte
Lekc235  label     byte
db '?)',LF
db LF
db 'Otazn�k  je  um�st�n  na  doln�  �ad� a p��eme ho mal��kem prav� ruky za',LF
db 'sou�asn�ho stisknut� lev� kl�vesy SHIFT lev�m mal��kem.',LF
db LF
db 'mal��kem prav� ruky  - ?',LF
db LF
db 'V  textu  p��eme  otazn�k t�sn� za posledn� slovo bez odd�lovac� mezery,',LF
db 'mezeru d�l�me a� za otazn�kem.',LF
db LF
db EOT

LDatC35  label     byte
LDatI35  label     byte
LDat135  label     byte
LDat235  label     byte
db '????? k?k?k?k ,?,?,?,?, ik? ik? ik? ik? j?l� j?l� j?l� j?l�',LF
db 'Kdy? Kde? Kdo? Kdy? Kde? Kdo? Kdy? Kde? Kdo? Kdy? Kde? Kdo?',LF
db 'Jak�? Jak�? Jak�? Jak�? Jak�? Jak�? Jak�? Jak�? Jak�? Jak�?',LF
db 'Jak? Jak�? Kter�? ��? Jak�? Kter�? Kam? Co? Kde? Kdy? Jak�?',LF
db 'Co d�l� v�zkum? V �em to je? Pro� k tomu doch�z�? Co je to?',LF
db FF
db 'Ch�pe pracovn�k v�znam sv�ch �kol� v podnikov� d�lb� pr�ce?',LF
db 'Co u�init proto, aby i v tomto sm�ru nastalo zlep�en�? Jak�',LF
db 'je vztah mezi kvalifikac� lid� a �koly, kter� jsou jim sv�-',LF
db '�ov�ny? Co je t�eba v t�to v�ci zm�nit? Hled�te dobrou pra-',LF
db 'covn� p��le�itost? S jakou perspektivou mohu u v�s po��tat?',LF
db FF
db 'Co my v�me o jejich pr�ci, o obt���ch, nesn�z�ch a rizik�ch',LF
db 'cesty nezn�m�m ter�nem za nov�mi poznatky a �e�en�mi, o vy-',LF
db 'sok� cen�, kter� se za n� plat�? Co tak� v�me o v�sledc�ch,',LF
db 'k nim� �asto pracn� dosp�li, kter� odevzd�vaj� spole�nosti?',LF
db 'Zaj�m�me se o n� vskutku tak, jak si zaslou��? Pom�h�me jim',LF
db '��inn� vytv��et spr�vn� podm�nky k jejich pr�ci, aby vz�cn�',LF
db 'potenci�l jejich v�dom� byl vyu�it opravdu nejhospod�rn�ji?',LF
db EOT

; ------ lekce 36 - !
;�
LekcC36  label     byte
db '!)',LF
db LF
db 'Vyk�i�n�k  p��eme prav�m mal��kem, kter� posuneme o jednu kl�vesu vpravo',LF
db 'za sou�asn�ho stisku lev� kl�vesy SHIFT lev�m mal��kem.',LF
db LF
db 'mal��kem prav� ruky  - !',LF
db LF
db 'V  textu p��eme vyk�i�n�k t�sn� za posledn� slovo bez odd�lovac� mezery,',LF
db 'mezeru d�l�me a� za vyk�i�n�kem.',LF
db LF
db EOT

LekcI36  label     byte
Lekc136  label     byte
Lekc236  label     byte
db '!)',LF
db LF
db 'Vyk�i�n�k p��eme lev�m mal��kem, kter� posuneme vlevo nahoru na ��selnou',LF
db '�adu kl�ves za sou�asn�ho stisku prav� kl�vesy SHIFT prav�m mal��kem.',LF
db LF
db 'mal��kem lev� ruky  - !',LF
db LF
db 'V  textu p��eme vyk�i�n�k t�sn� za posledn� slovo bez odd�lovac� mezery,',LF
db 'mezeru d�l�me a� za vyk�i�n�kem.',LF
db LF
db EOT

LDatC36  label     byte
db '!!!!!! �!�!�!�! j! j! j! j! j�! j�! j�! j�! j�! j�! j�! j�!',LF
db 'dej! ber! dej! ber! dej! ber! dej! ber! dej! ber! dej! ber!',LF
db 'Pozor! Vy�e�eno! U�te se! Nevypl�ovat! Zastav! Nep�ekl�dat!',LF
db 'Dodr�ujte bezpe�nostn� p�edpisy! Necho�te tam! Dejte pozor!',LF
db 'Pi�te pozorn�! Dbejte v�ech pokyn�! Zastavte se! Jd�te tam!',LF
db FF
db 'Proto se p�ij�te i Vy ur�it� pod�vat! Pracuj! Studuj! St�j!',LF
db EOT

LDatI36  label     byte
LDat136  label     byte
LDat236  label     byte
db '!!!!!! a!a!a!a! f! f! f! f! fa! fe! fr! fa! fe! fr! fa! fe!',LF
db 'dej! ber! dej! ber! dej! ber! dej! ber! dej! ber! dej! ber!',LF
db 'Pozor! Vy�e�eno! U�te se! Nevypl�ovat! Zastav! Nep�ekl�dat!',LF
db 'Dodr�ujte bezpe�nostn� p�edpisy! Necho�te tam! Dejte pozor!',LF
db 'Pi�te pozorn�! Dbejte v�ech pokyn�! Zastavte se! Jd�te tam!',LF
db FF
db 'Proto se p�ij�te i Vy ur�it� pod�vat! Pracuj! Studuj! St�j!',LF
db EOT

ENDIF

LekSeg3  ENDS
         END
