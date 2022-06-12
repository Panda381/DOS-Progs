TexGen v1.19 - gener�tor textur
(c) 2015 Miroslav N�me�ek

projekt: www.breatharian.eu/TexiGen
www: panda38.sweb.cz
email: Panda38@seznam.cz
portfolio: www.shutterstock.com/g/PandaWild


Licen�n� podm�nky pou�it� aplikace TexiGen
-----------------------------------------

Aplikace TexiGen je voln� k dispozici jako FREEWARE a lze ji voln� ���it a pou��vat pro soukrom� i komer�n� ��ely. Textury vytvo�en� pomoc� aplikace TexiGen a gener�tor� v aplikaci obsa�en�ch je mo�n� bez omezen� prod�vat, s jednou v�jimkou - nesm� b�t prod�v�ny textury vygenerovan� z ciz�ch variant a z implicitn�ch variant nastaven� gener�tor�, proto�e varianty jsou du�evn�m vlastnictv�m jejich autor�. Pro ��ely prodeje textur je nutn� vygenerovat vlastn� varianty nastaven� gener�tor�. Uveden� nemus� platit automaticky pro gener�tory od jin�ch autor�, kte�� si stanovuj� sv� licen�n� podm�nky.

K programu TexiGen jsou voln� k dispozici jeho zdrojov� k�dy a mohou b�t vyu��v�ny v jin�ch soukrom�ch i komer�n�ch projektech. V p��pad� vytvo�en� modifikace programu je nutn� viditeln� odli�it modifikovanou verzi od p�vodn� verze, aby bylo z�ejm�, �e se jedn� o modifikovanou verzi, a tak� uv�st ze kter�ho projektu modifikace vych�zela.

Aplikace TexiGen je poskytov�na v takov� form� v jak� je, se zn�m�mi i nezn�m�mi chybami. Autor nenese ��dnou zodpov�dnost za p��padn� n�sledky vznikl� pou�it�m aplikace, ani za n�sledky vznikl� chybnou funkc� aplikace.


Zn�m� chyby a nedostatky
------------------------

- chyb� undo/redo
- chyb� podpora clipboard
- po n�jak� dob� editace se p�estanou zobrazovat t�hla (a i prvky v okn� v�b�ru barev), program se mus� spustit znovu
- nedostate�n� o�et�en� chyby p�i na��t�n� gener�toru
- v Blur je obraz �patn� posunut� (proti Image jakoby uskakoval doleva dol�)
- nedostate�n� funk�n� Emboss filtr, odlesky a st�ny nevypadaj� realisticky
- mo�n� nem� Image p�esn� sou�adnice, v�stup se li�� od origin�lu
- obsluha scrolov�n� my�i
- prav�m tla��tkem lok�ln� menu
- mo�nost minimalizovat program b�hem renderov�n� (=dialog sou��st� okna)
- zobrazen� ��sla varianty (vedle titulku Variace)
- relativn� cesty RelToAbsPath, AbsToRelPath, aby cesty nebyly sou��st� gener�toru (gener�tor se pak ned� p�en�st jinam)
- Includes filtry - ve slo�ce _Includes (zobraz� se v nab�dce tak� jako filtry - m�ly by m�t v n�zvu verzi)
- smy�ka - opravit havarov�n� (te� je o�et�eno s Level < 100) p�i polo�en� v�stupu LoopEnd na Source LoobBeg.
- bloky - filtr bloku m� v sob� graf filtr�, v _Blocks jsou knihovny blok� (jsou to norm�ln� filtry), v bloku m��e b�t vno�en� dal�� blok
- integrovan� obr�zek se zachov�n�m komprimovan�ch form�t�
- cache filtr (p�edrenderuje obr�zek v nastaven�m rozli�en� - absolutn� rozli�en� nebo relativn� k v�stupn�mu rozli�en�)


V�voj verz�
-----------

14.10.2014 v1.0 - Lite verze omezen� na textury 1024x1024

16.10.2014 v1.01 - Mutov�n� variant, pr�ce s renderovac� frontou (ru�en�, priorita, odhad �asu).

17.10.2014 v1.02 - Priorita n�hled�.

18.10.2014 v1.03 - Oprava filtru Particle (posun obrazu), filtry sou�adnice a n�hody Particle, filtr n�hody.

20.10.2014 v1.10 - Uvoln�n� pln� verze programu do Freeware.

22.10.2014 v1.11 - Filtr sn�hov� vlo�ky.

28.10.2014 v1.12 - Filtry Percentile a Lookup.

 4.11.2014 v1.13 - Generov�n� videa, oprava hranic Bevel Profile.

 9.11.2014 v1.14 - Vylep�en� funkce filtr� Blur, HighPass a Percentile.

14. 1.2015 v1.15 - Zrychlena obsluha vstupn�ch obr�zk� (na�tou se do pam�ti - vy��� n�roky na pam�). Sd�len� obr�zk� mezi renderovac�mi vl�kny (sn�en� n�rok� na pam�). O�et�en� nena�ten�ho obr�zku (obr�zek lze i vypnout). Podpora vstupu z obr�zk� TGA, BMP, PNG a JPG, pouze 24bitov� RGB form�ty, u TGA a PNG nav�c 32bitov� RGBA, TGA i komprimovan� form�t. Mo�nost automatick� konverze renderovan�ho obr�zku na JPG. Inverze z�mk� vlastnost� gener�toru. F9 vyb�r� n�hodn� i vstupn� obr�zky v zadan� slo�ce. 

 5. 2.2015 v1.16 - Filtr Tussock, filtr Cut, p�ep�na� AlphaMod u Blend.

12. 2.2015 v1.17 - �esk� n�pov�da a tutori�ly.

 3. 3.2015 v1.18 - Filtry Deform a Enform. Mo�nost na��tat a zpracov�vat video filtrem Video.

 8. 3.2015 v1.19 - Filtr Fractal.
