
; modul DOSMCOM.ASM - komunikace mezi po��ta�i
;                   ����ͻ                   ����ͻ
;  Konektor Canon:  �  7 �������������������Ķ  7 �  GND   zem 0 V
;                   �  3 ���������\ /�������Ķ  3 �  RxD   p�ij�man� data
;                   �  2 ���������/ \�������Ķ  2 �  TxD   vys�lan� data
;                   �  4 ��Ŀ             ��Ķ  4 �  RTS   vys�la� p�ipraven
;                   �  5 �<��             ��>�  5 �  CTS   uvoln�n� p�ij�ma�e
;                   �  6 �<Ŀ             ��>�  6 �  DSR   uvoln�n� vys�la�e
;                   � 20 ����             ��Ķ 20 �  DTR   p�ij�ma� p�ipraven
;                   � 22 �                   � 22 �  RI    v�zva
;                   �  1 �                   �  1 �  DCD   �rove� sign�lu
;                   ����ͼ                   ����ͼ
;
;   Nastaven� MODE:
;
;   mode COMm[:]b,[,p[,d[,s[,r]]]]
;        m = 1,2,3,4
;        b = rychlost 110,150,300,600,1200,2400,4800,9600,19200
;        p = parita N (��dn�), O (lich�), E (sud�), M (zna�ka), S (mezera)
;        d = datov�ch bit� 5,6,7,8
;        s = stop-bit� 1, 1.5, 2
;        r = opakov�n� E (chyba), B (zanepr�zdn�n), R (p�ipraven), NONE (neop.)
;
;  mode COM1:110,E,7,1,NONE

; *****************************************************************************
;
;                          Komunikace, p�en��en� soubor�
;
; *****************************************************************************

code     segment   public
         assume    cs:code,ds:code

upver    label     near                     ; p��znak vy��� verze

TIMEOUT  equ       9                        ; doba pro TIME-OUT 1/2 sekundy

SOH      equ       1                        ; za��tek z�hlav�
STX      equ       2                        ; za��tek textu
ETX      equ       3                        ; konec textu
EOT      equ       4                        ; konec p�enosu
ENQ      equ       5                        ; ��dost o spojen�
ACK      equ       6                        ; potvrzen� operace OK

SHO      equ       0eh                      ; vypnut� p�ep�na�e
SHI      equ       0fh                      ; zapnut� p�ep�na�e
;DLE      equ       10h

NAK      equ       15h                      ; p��znak chybn� operace
SYN      equ       16h                      ; synchronizace
ETB      equ       17h                      ; konec p�en��en�ho bloku
CAN      equ       18h                      ; p�eru�en� spojen� u�ivatelem

SUB      equ       1ah                      ; n�hrada znaku


ifdef    upver
extrn    testaktw:near,txtcom3:byte,txtcom5:byte,port:word,volbyh:near
extrn    windretx:near,setwsel:near,outch1:near,podklad:near,wram1:near
extrn    wram2:near,wnadpis:near,stinw:near,txtcom4:byte,testbreak:near
extrn    outbuf:byte,transtxt:near,txtcom6:byte,kurzout:near,msgcek:near
extrn    txtcom1:byte,inpkey:near,getkurz:near,test1file:near,soucins:near
extrn    flagsc:byte,nadpf1:near,nadpfm:near,bufnadp:byte,txtcom2:byte
extrn    storekall:near,storsel:near,aktdir:near,aktuald:near,setfirst:near
extrn    setkurzn:near,setnext:near,rerdir:near,storekur:near
extrn    getakt:near,getnakt:near,deledis:near,iniedis:near
extrn    txtcom7:byte,txtcom8:byte,txtcom9:byte,txtcoma:byte
extrn    mouseon:near,mouseoff:near,initukaz:near,informz:near,editmax:word
extrn    nulsel:near,outtxt:near,citacexp:byte,testkey:near,parbreak:word

endif


; -----------------------------------------------------------------------------
;                              P��jem
; -----------------------------------------------------------------------------
public   prijem

prijem:                                   ;* p��jem soubor� z komunik. portu
ifdef    upver

         call      testaktw                 ; je okno aktivn� ?
         jc        prijem9                  ; okno nen� aktivn�
         lea       di,[txtcom3]             ; nadpis pro p��jem
         call      commport                 ; volba portu
         jc        prijem9                  ; p�eru�en� operace

                                          ;* informace o navazov�n� spojen�
         call      iniedis                  ; vytvo�en� p�enosov�ho bufferu
         jc        prijem9                  ; chyba vytvo�en� bufferu

         call      spojhlas                 ; hl��en� o navazov�n� spojen�
         call      inpkey                   ; vstup znaku z kl�vesnice


prijem4: call      deledis                  ; zru�en� bufferu
         call      windretx

prijem5: cmp       word ptr cs:[parbreak],0 ; bylo p�eru�en� ?
         je        prijem6                  ; nebylo p�eru�en�
;         mov       al,CAN
;         call      vysch                    ; vysl�n� znaku p�eru�en�
prijem6: ret


;prijem:                                   ;* p��jem soubor�

                                          ;* p��jem z�hlav� souboru
         clc                                ; p��znak - p�ipravenost OK
prijem1: call      potvrdp                  ; �ek�n� na identifik�tor
prijem2: call      cekprij                  ; �ek�n� na p��jem znaku
         cmp       al,EOT                   ; konec p�enosu ?
         je        prijem9                  ; je konec p�enosu
         cmp       al,SOH                   ; je za��tek hlavi�ky ?
         jne       prijem2                  ; nen� identifik�tor z�hlav�
         call      prijtxt                  ; p��jem textu z�hlav�
         jc        prijem1                  ; chyba p��jmu z�hlav� - znovu
                                          ;* z�hlav� p�ijato OK - vytvo�. soub.
;         mov       dx,offset transbuf       ; jm�no p�en��en�ho souboru
         mov       ah,3ch
         xor       cx,cx
         int       21h                      ; vytvo�en� souboru
         jc        prijem1                  ; chyba vytvo�en� souboru
         mov       bx,ax                    ; identifik�tor souboru
prijem32:call      potvrdp                  ; potvrzen� p��jmu
                                          ;* p��jem datov�ho bloku
prijem3: call      cekprij                  ; �ek�n� na p��jem znaku
         cmp       al,EOT                   ; konec p�enosu ?
         je        prijem8                  ; je konec p�enosu
         cmp       al,STX                   ; je za��tek bloku ?
         jne       prijem3                  ; nen� identifik�tor bloku
         call      prijtxt                  ; p��jem textu z�hlav�
         jc        prijem32                 ; chyba p��jmu z�hlav� - znovu
                                          ;* z�hlav� p�ijato OK - vytvo�. soub.



                                          ;* p��jem datov�ch blok�



prijem8:                                  ;* uzav�en� souboru
         mov       ah,3eh
         int       21h                      ; uzav�en� souboru

endif

prijem9:
         ret

ifdef    upver

; -----------------------------------------------------------------------------
public   potvrdp
potvrdp:                                  ;* potvrzen� p��jmu
                                            ; VSTUP: CY=chyba operace

         push      ax
         mov       al,ACK                   ; potvrzen� OK
         jnc       potvrdp3                 ; operace OK
         mov       al,NAK                   ; z�porn� potvrzen�
potvrdp3:call      vysch                    ; vysl�n� znaku potvrzen�
         pop       ax
         ret

public   cekprij
cekprij:                                  ;* �ek�n� na p��jem z�hlav�

                                          ;* �ek�n� na dal�� znak
potvrdp1:call      prijch                   ; p��jem znaku
         cmp       al,EOT                   ; konec p�enosu ?
         je        potvrdp2                 ; konec p�enosu
         cmp       al,SOH
         je        potvrdp2                 ; je identifik�tor z�hlav�
         cmp       al,STX
         je        potvrdp2                 ; je identifik�tor textu
         cmp       al,ENQ
         jne       potvrdp1                 ; nen� dotaz - ignorovat znak
         mov       al,ACK                   ; potvrzen� OK
         call      vysch                    ; vysl�n� znaku potvrzen�
         jmp       short potvrdp1           ; dal�� znak
potvrdp2:ret

endif
; -----------------------------------------------------------------------------
;                             Vys�l�n�
; -----------------------------------------------------------------------------
public   vysil
vysil:                                    ;* vys�l�n� soubor�

ifdef    upver
                                          ;* test opr�vn�nosti po�adavku
         mov       byte ptr ds:[flagsc],3   ; nastaven� typu operace
         call      testaktw                 ; test zapnut� okna
         jc        vysil33                  ; okno je vypnut�
         call      getkurz                  ; test, zda je kurzor platn�
         jc        vysil33                  ; kurzor nen� platn�
         call      test1file                ; je operace s kurzorem ?
         jnz       vysil2                   ; je pr�ce s kurzorem
         call      soucins                  ; se�ten� ozna�en�ch soubor�
         jnz       vysil3                   ; je ozna�en alespo� 1 soubor - OK
         or        byte ptr cs:[flagsc],4   ; p��znak - operace s 1 souborem
vysil2:  test      byte ptr ds:[si],10h     ; je adres�� ?
         jz        vysil3                   ; nen� adres�� - OK
vysil33: ret

vysil3:
         push      cs
         pop       ds
         call      vysvolb                  ; volba portu pro vys�l�n�
         jc        vysil33                  ; p�eru�en� operace

         call      iniedis                  ; vytvo�en� p�enosov�ho bufferu
         jc        vysil33                  ; chyba vytvo�en� bufferu

         call      storekall                ; �schova pozice kurzor� obou oken
         call      storsel                  ; uschov�n� v�b�r� soubor�
         mov       si,cs:[bp+4]             ; adres�� okna
         call      aktdir                   ; nastaven� aktivn�ho adres��e okna
         call      testbreak                ; je p�eru�en� operace ?
         jc        vysil9                   ; je p�eru�en� operace
         call      aktuald                  ; aktualizace adres��e disku
         jc        vysil9                   ; p�eru�en� operace
         call      setfirst                 ; nastaven� prvn�ho souboru
         jc        vysil9                   ; nen� prvn� soubor
         jmp       short vysil72            ; zpracov�n� prvn�ho souboru

vysil7:  call      setkurzn                 ; nastaven� na dal�� polo�ku
         jc        vysil71                  ; je ji� konec seznamu
vysil70: call      setnext                  ; nastaven� dal��ho souboru
vysil72: jc        vysil71                  ; nen� ji� dal�� soubor
         call      storekur                 ; �schova pozice kurzoru
         call      vys1f                    ; vysl�n� 1 souboru
         jnc       vysil70                  ; operace OK - dal�� soubor
vysil71:                                  ;* n�vrat parametr� oken
         call      windretx
         call      getnakt
         call      rerdir                   ; nastaven� nov�ho na�ten� adres��e
         call      getakt
         call      rerdir                   ; nastaven� nov�ho na�ten� adres��e
vysil9:  call      deledis                  ; zru�en� bufferu
         call      windretx
endif
         ret



ifdef    upver

public   vys1f
vys1f:                                    ;* vysl�n� jednoho souboru
                                            ; V�STUP: CY=chyba operace

         xor       dx,dx                    ; DH: bit 7 - zobrazeno hl��en�
         jmp       short vys1f1             ; v�zva k spojen�

vys1f0:  call      spojhlas                 ; hl��en� o navazov�n� spojen�
         or        dh,80h                   ; p��znak zobrazen� hl��en�
vys1f1:  ;mov       byte ptr ds:[citacexp],TIMEOUT ; �ekac� doba
         mov       al,ENQ                   ; po�adavek na spojen�
         call      vysch                    ; vysl�n� po�adavku spojen�
vys1f2:  call      testbreak                ; test p�eru�en� operace
         jc        vys1f9                   ; je p�eru�en�
         call      prijch                   ; p��jem znaku
         jc        vys1f3                   ; nen� p�ijat znak OK
         cmp       al,ACK                   ; je potvrzen� p�ipravenosti ?
         je        vys1f4                   ; je potvrzena p�ipravenost
vys1f3:  call      commtout                 ; je TIME-OUT ?
         jnc       vys1f2                   ; nen� je�t� TIME-OUT
         test      dh,80h                   ; je zobrazeno hl��en� ?
         jnz       vys1f1                   ; hl��en� je ji� zobrazeno
         jmp       short vys1f0             ; zobrazen� hl��en�
vys1f4:                                   ;* vysl�n� hlavi�ky souboru
         test      dh,80h                   ; je zobrazeno hl��en� ?
         jz        vys1f5                   ; hl��en� nen� zobrazeno
         call      windretx                 ; n�vrat zobrazen� okna
vys1f5:                                   ;* zobrazen� informa�n�ho textu
         lea       si,[txtcom7]             ; text "Vys�l�m"
         call      informz                  ; zobrazen� z�kladn�ho inform. ��dku
         call      mouseoff                 ; vypnut� my�i
         mov       si,offset txtcom9        ; text "na port ..."
         call      outtxt
         call      mouseon                  ; zapnut� my�i

         mov       al,77
         sub       al,dl                    ; po�et znak� do zbytku ��dku
         jnc       vys1f6
         xor       al,al                    ; nen� ��dn� voln� znak
vys1f6:  call      initukaz                 ; nastaven� ukazatele kop�rov�n�

         call      vysfk                    ; vys�l�n� 1 souboru
         jc        vys1f4                   ; chyba operace

         call      nulsel
vys1f9:
         call      windretx
         ret

vysfk:   clc

         mov       byte ptr ds:[citacexp],18
vysfk2:  call      commtout
         jnc       vysfk2

         ret

; -----------------------------------------------------------------------------
;                       Univerz�ln� podprogramy
; -----------------------------------------------------------------------------
public   spojhlas
spojhlas:                                 ;* hl��en� o navazov�n� spojen�
         lea       si,[txtcom4]             ; nadpis
         mov       bl,3                     ; po�et ��dk� okna

public   hlaseni
hlaseni:                                  ;* zobrazen� hl��en� SI

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es
         push      cs
         pop       es
         mov       di,si                    ; adresa textu

         call      setwsel                  ; nastaven� parametr� okna
         mov       al,7                     ; barva pro okno volby
         call      outch1                   ; nastaven� barvy ��slo 7
         call      podklad                  ; vykreslen� podkladu okna
         call      wram1                    ; zobrazen� vnit�n�ho r�me�ku
         call      wram2                    ; zobrazen� vn�j��ho r�me�ku
         call      wnadpis                  ; zobrazen� nadpisu okna
         call      stinw                    ; zobrazen� st�nu okna
         call      kurzout                  ; vypnut� kurzoru

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   vysvolb
vysvolb:                                  ;* volba portu pro vys�l�n�

         mov       di,offset bufnadp        ; nadpis pro vys�l�n�
         push      di
         mov       si,offset txtcom1
         call      transtxt                 ; p�enesen� za��tku textu
         call      test1file                ; je pr�ce s kurzorem ?
         jnz       vysvolb2                 ; je 1 soubor
         call      soucins                  ; se�ten� ozna�en�ch soubor�
         cmp       cx,1                     ; po�et ozna�en�ch soubor�
         ja        vysvolb3                 ; je ozna�en v�ce ne� 1 soubor
vysvolb2:call      nadpf1                   ; parametr nadpisu pro 1 soubor
         jmp       short vysvolb4
vysvolb3:call      nadpfm                   ; parametr nadpisu pro v�ce soubor�
vysvolb4:mov       si,offset txtcom2        ; zbytek nadpisu
         call      transtxt
         pop       di

public   commport
commport:                                 ;* volba portu (DI=nadpis)
         mov       si,offset txtcom5        ; volby pro nastaven� portu
         mov       al,byte ptr ds:[port]    ; p�ednastaven� port
         call      volbyh                   ; volba p��jmov�ho portu
         call      windretx
         jc        commport2                ; p�eru�en� operace
         mov       byte ptr ds:[port],al    ; nastaven� nov�ho portu
         add       al,"1"
         mov       ds:[txtcom6],al          ; nastaven� ozna�en� portu
         mov       ds:[txtcoma],al
commport2:ret
; -----------------------------------------------------------------------------
;                      Obsluha komunika�n�ho portu
; -----------------------------------------------------------------------------
public   vystxt
vystxt:                                   ;* vysl�n� textu na port
                                            ; VSTUP: AH=koncov� znak
                                            ;        ES:DI=adresa dat k vysl�n�
                                            ;        CX=po�et znak� k vysl�n�
                                            ;        CY=chyba nebo p�eru�en�
                                            ;        ES:DI=nov� adresa dat
         push      cx
         push      dx
         xor       dx,dx                    ; DL:st�ada� kontroln�ho sou�tu
                                            ; DH:p��znak p�esmyka�e
                                          ;* vysl�n� jednoho znaku
vystxt1: jcxz      vystxt7                  ; konec vys�l�n�
         mov       al,es:[di]               ; znak z bufferu
         inc       di                       ; zv��en� adresy v bufferu
         dec       cx                       ; sn��en� ��ta�e znak�
         call      vyschk                   ; vysl�n� k�dovan�ho znaku
         jc        vystxt9                  ; chyba nebo p�eru�en�
         jmp       short vystxt1            ; vysl�n� dal��ho znaku

vystxt7:                                  ;* vysl�n� konce textu
         mov       al,dl                    ; kontroln� sou�et
         call      vyschk                   ; vysl�n� kontroln�ho sou�tu
         jc        vystxt9                  ; chyba nebo p�eru�en�
         mov       al,ah                    ; koncov� znak
         call      vysch                    ; vysl�n� koncov�ho znaku
vystxt9: pop       dx
         pop       cx
         ret
; -----------------------------------------------------------------------------
public   vyschk
vyschk:                                   ;* vysl�n� k�dovan�ho znaku
                                            ; VSTUP: DH=p��znak p�esmyka�e
                                            ;        AL=vys�lan� znak
                                            ;        CY=p�eru�en�

         push      ax
         mov       ah,al                    ; znak k vysl�n�
         test      dh,1                     ; je trval� p�esmyka� ?
         jnz       vyschk4                  ; je nastaven p�esmyka�
                                          ;* nen� trval� p�esmyka�
         call      testctr0                 ; je ��dic� znak ?
         jnc       vyschk8                  ; nen� ��dic� znak - vysl�n�
         call      vystest                  ; m� b�t m�n�n p�esmyka� ?
         jnc       vyschk2                  ; je pouze p�echodn� zm�na
         and       dh,not 1                 ; vypnut� p��znaku p�esmyka�e
         mov       al,SHI                   ; zapnut� trval�ho p�esmyka�e
         call      vysch                    ; vysl�n� p�esmyka�e
         jc        vyschk9                  ; p�eru�en�
         jmp       short vyschk7            ; vysl�n� k�dovan�ho znaku
vyschk2:                                  ;* p�echodn� zapnut� p�esmyka�e
         mov       al,SUB                   ; znak n�hrady
         call      vysch                    ; vysl�n� identifik�toru n�hrady
         jc        vyschk9                  ; p�eru�en�
         jmp       short vyschk7            ; n�hrada znaku
vyschk4:                                  ;* je trval� p�esmyka�
         call      testctr                  ; je ��dic� znak ?
         jc        vyschk7                  ; je ��dic� znak - vysl�n�
         call      vystest                  ; m� b�t m�n�n p�esmyka� ?
         jnc       vyschk5                  ; je pouze p�echodn� zm�na
         or        dh,1                     ; zapnut� p��znaku p�esmyka�e
         mov       al,SHO                   ; vypnut� trval�ho p�esmyka�e
         call      vysch                    ; vysl�n� p�esmyka�e
         jc        vyschk9                  ; p�eru�en�
         jmp       short vyschk8            ; vysl�n� norm�ln�ho znaku
vyschk5:                                  ;* p�echodn� vypnut� p�esmyka�e
         mov       al,SUB                   ; znak n�hrady
         call      vysch                    ; vysl�n� identifik�toru n�hrady
         jc        vyschk9                  ; p�eru�en�
         jmp       short vyschk8            ; nen� n�hrada znaku

vyschk7: add       ah," "                   ; korekce na upraven� znak
vyschk8: mov       al,ah                    ; znak k vysl�n�
         call      vysch                    ; vysl�n� znaku
vyschk9: pop       ax
         ret
; -----------------------------------------------------------------------------
public   vystest
vystest:                                  ;* test obsahu pam�ti pro vys�la�
                                            ; VSTUP: AH=prvn� znak (testovan�)
                                            ;         ES:DI=vys�lac� buffer
                                            ; V�STUP: CY=zm�nit trval� p�esmyk.
         push      di
         push      cx
         push      dx
         mov       cx,4                     ; test pokus� = 4
         call      testctr0                 ; je ��dic� znak ?
         jc        vystest3                 ; je ��dic� znak
                                          ;* spo��t�n� ne��dic�ch znak�
vystest1:inc       di                       ; zv��en� adresy
         call      testctr                  ; je ��dic� znak ?
         jc        vystest6                 ; konec kontroly
         loop      vystest1                 ; dal�� znak
         jmp       short vystest6
                                          ;* spo��t�n� ��dic�ch znak�
vystest3:inc       di                       ; zv��en� adresy
         call      testctr                  ; je ��dic� znak ?
         jnc       vystest6                 ; nen� konec kontroly
         loop      vystest3                 ; dal�� znak
vystest6:                                 ;* je po�adovan� po�et znak� ?
         cmp       cx,2                     ; jsou alespo� 3 stejn� znaky ?
         pop       dx
         pop       cx
         pop       di
         ret
; -----------------------------------------------------------------------------
public   testctr
testctr: push      ax
         mov       ah,es:[di]
         call      testctr0
         pop       ax
         ret

public   testctr0
testctr0:                                 ;* test ��dic�ho znaku
                                            ; VSTUP: AH=testovan� znak
                                            ; V�STUP: CY=je ��dic� znak

         cmp       ah,7                     ; je speci�ln� ��dic� znak ?
         jb        testctr2                 ; je speci�ln� ��dic� znak
         cmp       ah,SHO                   ; je znak SHO (0eh) ?
         cmc
         ja        testctr2                 ; je platn� znak
         cmp       ah,1bh                   ; je platn� znak ?
testctr2:ret
; -----------------------------------------------------------------------------
public   prijtxt
prijtxt:                                  ;* p��jem textu z portu
                                            ; VSTUP: ES:DI=ukl�dac� adresa
                                            ; V�STUP: CX=po�et znak�
                                            ;         CY=chyba nebo p�eru�en�
                                            ;         AL=ukon�ovac� bajt
                                            ;         ES:DI=nov� ukl�dac� adresa

         push      cx
         push      dx
         xor       cx,cx                    ; ��ta� bajt�
         xor       dx,dx                    ; DL:st�ada� kontroln�ho sou�tu
                                            ; DH:p��znak p�esmyka�e
                                          ;* p��jem jednoho znaku
prijtxt1:cmp       di,cs:[editmax]          ; je ji� konec bufferu ?
         cmc
         jb        prijtxt9                 ; je p�ete�en� bufferu
         call      prijchk                  ; p��jem k�dovan�ho znaku
         jc        prijtxt9                 ; p�eru�en� nebo TIME-OUT
         je        prijtxt8                 ; konec bloku
         stosb                              ; ulo�en� znaku do bufferu
         xor       dl,al                    ; nastaven� kontroln�ho sou�tu
         inc       cx                       ; zv��en� ��ta�e znak�
         jmp       short prijtxt1           ; p��jem dal��ho znaku
prijtxt8:                                 ;* konec v�ty - test spr�vnosti
         or        dl,dl                    ; je kontroln� sou�et = 0 ?
         stc
         jnz       prijtxt9                 ; kontroln� sou�et nen� 0 - chyba
         jcxz      prijtxt9                 ; nen� ��dn� znak - chyba
         dec       cx                       ; zru�en� kontr. sou�tu v bufferu
         dec       di                       ; sn��en� ukl�dac� adresy
         clc                                ; p��znak - operace OK
prijtxt9:pop       dx
         pop       cx
         ret
; -----------------------------------------------------------------------------
public   prijchk
prijchk:                                  ;* p��jem k�dovan�ho znaku
                                            ; VSTUP: DH=p��znak p�esmyka�e
                                            ; V�STUP: AL=p�ijat� znak
                                            ;         CY=p�eru�en�
                                            ;         NZ=je platn� znak
                                            ;            ZY=��dic� znak konce

prijchk1:call      prijch                   ; p��jem znaku
         jc        prijchk9                 ; p�eru�en� nebo TIME-OUT
                                          ;* test konce p�enosu
prijchk2:cmp       al,EOT                   ; konec p�enosu ?
         je        prijchk9                 ; je konec p�enosu
         cmp       al,ETX                   ; konec v�ty ?
         je        prijchk9                 ; konec v�ty
         cmp       al,ETB                   ; konec bloku ?
         je        prijchk9                 ; konec bloku
         cmp       al,7                     ; spodn� hranice - znak BEL
         jb        prijchk9                 ; zak�zan� znak
                                          ;* trval� p�esmyka�e
         cmp       al,SHI                   ; je zapnut� p�esmyka�e ?
         jne       prijchk3                 ; nen� zapnut� p�esmyka�e
         or        dh,1                     ; zapnut� trval�ho p�esmyka�e
         jmp       short prijchk1           ; p��jem dal��ho znaku
prijchk3:cmp       al,SHO                   ; je vypnut� p�esmyka�e ?
         jne       prijchk4                 ; nen� vypnut� p�esmyka�e
         and       dh,not 1                 ; vypnut� trval�ho p�esmyka�e
         jmp       short prijchk1           ; p��jem dal��ho znaku
prijchk4:                                 ;* p�echodn� n�hrada znaku
         cmp       al,SUB                   ; je p�echodn� n�hrada znaku ?
         jne       prijchk5                 ; nen� n�hrada znaku SUB
         or        dh,2                     ; p��znak p�echodn� n�hrady znaku
         jmp       short prijchk1           ; p��jem dal��ho znaku
prijchk5:                                 ;* test p�evodu znaku
         test      dh,1                     ; je trval� p�evod znaku ?
         jz        prijchk6                 ; nen� trval� p�evod znaku
         test      dh,2                     ; je p�echodn� vypnut� ?
         jnz       prijchk8                 ; je p�echodn� vypnut�
         jmp       short prijchk7           ; p�evod znaku
prijchk6:test      dh,2                     ; je p�echodn� zapnut� ?
         jz        prijchk8                 ; nen� p�echodn� zapnut�
prijchk7:                                 ;* p�evod znaku
         cmp       al," "                   ; je ��dic� znak ?
         jb        prijchk8                 ; je ��dic� znak
         sub       al," "                   ; korekce na bin�rn� znak
prijchk8:and       dh,not 2                 ; zru�en� p��znaku p�echodn� zm�ny
         cmp       dh,0ffh                  ; nastaven� p��znaku NZ
         clc                                ; p��znak znaku OK
prijchk9:
         ret
; -----------------------------------------------------------------------------
public   testprij
testprij:                                 ;* test p��jmu znaku
                                            ; V�STUP: CY=nen� p�ipraven znak

         push      ax
         push      dx
         mov       dx,cs:[port]             ; ��slo komunika�n�ho portu
         mov       ax,300h
         int       14h                      ; dotaz na stav s�riov�ho portu
         test      ah,1                     ; jsou data p�ipravena ?
testpri1:jnz       testpri2                 ; data jsou p�ipravena
         call      testbreak                ; test p�eru�en�
         stc                                ; p��znak - nen� p�ipraven znak
testpri2:pop       dx
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   testvys
testvys:                                  ;* test vysl�n� znaku
                                            ; V�STUP: CY=vys�la� nen� p�ipraven

         push      ax
         push      dx
         mov       dx,cs:[port]             ; ��slo komunika�n�ho portu
         mov       ax,300h
         int       14h                      ; dotaz na stav s�riov�ho portu
         test      ah,20h                   ; je vys�lac� buffer pr�zdn� ?
         jmp       short testpri1
; -----------------------------------------------------------------------------
public   prijch
prijch:                                   ;* p��jem znaku
                                            ; V�STUP: AL=p�ijat� znak
                                            ;         CY=TIME-OUT nebo BREAK

         push      dx
         push      ax
         mov       byte ptr cs:[citacexp],TIMEOUT ; TIME-OUT 1/3 sekundy
         xor       ax,ax
prijch1: call      commbreak                ; test - je p�eru�en� BREAK ?
         jc        prijch3                  ; je p�eru�en�
         call      commtout                 ; test - je TIME-OUT ?
         jc        prijch3                  ; je TIME-OUT
         call      testprij                 ; test p��jmu znaku
         jc        prijch1                  ; nen� p�ipraven p�ijat� znak
         mov       dx,cs:[port]             ; ��slo komunika�n�ho portu
         mov       ah,2
         int       14h                      ; p��jem znaku z portu
         test      ah,80h                   ; je TIME-OUT ?
         jnz       prijch2                  ; je TIME-OUT
         cmp       al,CAN                   ; je p�eru�en� od protistanice ?
         clc                                ; p��znak p��jmu OK
         jne       prijch3                  ; nen� p�eru�en� od protistanice
         int       23h                      ; nastaven� p��znaku p�eru�en�
prijch2: stc                                ; p��znak p�eru�en�/TIME-OUT
prijch3: mov       dl,al                    ; �schova p�ijat�ho znaku
         pop       ax
         mov       al,dl                    ; p�ijat� znak
         pop       dx
         ret
; -----------------------------------------------------------------------------
public   vysch
vysch:                                    ;* vysl�n� znaku
                                            ; VSTUP: AL=znak k vysl�n�
                                            ; V�STUP: CY=BREAK nebo TIME-OUT

         push      dx
         push      ax
         mov       byte ptr cs:[citacexp],TIMEOUT ; TIME-OUT 1/3 sekundy
vysch1:  call      commbreak                ; test - je p�eru�en� BREAK ?
         jc        vysch3                   ; je p�eru�en�
         call      commtout                 ; test - je TIME-OUT ?
         jc        vysch3                   ; je TIME-OUT
         call      testvys                  ; test pr�zdn�ho vys�lac�ho bufferu
         jnc       vysch2                   ; vys�la� je p�ipraven
         call      testprij                 ; test p�ijat�ho znaku
         jc        vysch1                   ; nen� p�ipraven vys�lac� buffer
         push      ax
         call      prijch                   ; ignorov�n� p�ijat�ho znaku
         pop       ax
         jmp       short vysch1
                                          ;* vysl�n� znaku na port
vysch2:  mov       dx,cs:[port]             ; ��slo komunika�n�ho portu
         mov       ah,1
         int       14h                      ; vysl�n� znaku na port
         test      ah,80h                   ; je TIME-OUT ?
         jz        vysch3                   ; nen� TIME-OUT
         stc                                ; p��znak TIME-OUT
vysch3:  pop       ax
         pop       dx
         ret
; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------
public   commbreak
commbreak:                                ;* test BREAK
                                            ; V�STUP: CY=je BREAK

         cmp       word ptr cs:[parbreak],0 ; je p�eru�en� ?
         jne       commtou1                 ; je p�eru�en�
commbrk1:clc
         ret
; -----------------------------------------------------------------------------
public   commtout
commtout:                                 ;* test TIME-OUT
                                            ; V�STUP: CY=je TIME-OUT

         cmp       byte ptr cs:[citacexp],0 ; je TIME-OUT ?
         jne       commbrk1                 ; nen� TIME-OUT
commtou1:stc                                ; je TIME-OUT
         ret
; -----------------------------------------------------------------------------
endif

code     ends

         end
