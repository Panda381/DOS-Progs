COMMENT %
              Pakov�n� souboru do form�tu KOMP (.PAK)
        %

;------------------------------------------------------------------------------
;                             Programov� segment
;------------------------------------------------------------------------------


buffersize equ     1000h                    ; velikost cyklick�ho bufferu
matchlimit equ     18                       ; maxim�ln� d�lka shody
threshold  equ     2                        ; max. d�lka shody pro k�dov�n�

textbuf  equ       offset konec
konec0   equ       textbuf+buffersize+matchlimit ; konec dat


code     SEGMENT   page
         ASSUME    cs:code,ds:code

         org       100h                     ; za��tek programu COM

komp:                                       ; hlavn� t�lo programu
                                          ;* inicializace vlastn�ho z�sobn�ku
         cld                                ; sm�r posunu ukazatele nahoru
         cli                                ; z�kaz p�eru�en�
         mov       word ptr [stack],sp      ; �schova ukazatele z�sobn�ku
         mov       word ptr [stack+2],ss    ; �schova segmentu ukazatele z�sob.
         mov       ax,cs                    ; segment programu
         mov       ss,ax                    ; segment programu
         mov       sp,offset stack          ; vlastn� z�sobn�k
         sti                                ; povolen� p�eru�en�
                                          ;* zde se uvoln� pam�� programu
         mov       bx,konec0                ; adresa konce p�id�len� pam�ti
         shr       bx,1                     ; BX / 2
         shr       bx,1                     ; BX / 4
         shr       bx,1                     ; BX / 8
         shr       bx,1                     ; BX / 16 - d�lka programu
         inc       bx                       ; zaokrouhlen� d�lky pam�ti
         mov       ah,4ah                   ; funkce modifikace pam�ti
         int       21h                      ; modifikace (uvoln�n�) pam�ti
         jc        dekomp7                  ; chyba uvoln�n� pam�ti
                                          ;* p�id�len� buffer� pro soubory
         mov       bx,0ffffh                ; po�adavek na p�id�len� maxima RAM
         mov       ah,48h                   ; po�adavek na p�id�len� pam�ti
         int       21h                      ; poskytnut� maxim. voln� RAM
         shr       bx,1                     ; polovina voln� pam�ti
         dec       bx
         mov       ah,48h                   ; funkce p�id�len� pam�ti
         int       21h                      ; p�id�len� pam�ti pro vstupn� buf.
         jc        dekomp7                  ; chyba p�id�len� pam�ti
         mov       ds:[segbuff1],ax         ; segment bufferu 1 (vstupn� soubor)
         mov       ah,48h                   ; funkce p�id�len� pam�ti
         int       21h                      ; p�id�len� pam�ti pro v�stupn� buf.
         jc        dekomp7                  ; chyba p�id�len� pam�ti
         mov       ds:[segbuff2],ax         ; segment buff. 2 (v�stupn� soubor)
         mov       word ptr ds:[writbyte+2],ax ; segment buff.2 (v�stupn� soubor)
         xor       dx,dx
         shl       bx,1                     ; BX * 2
         rcl       dx,1
         shl       bx,1                     ; BX * 4
         rcl       dx,1
         shl       bx,1                     ; BX * 8
         rcl       dx,1
         shl       bx,1                     ; BX * 16
         rcl       dx,1
         mov       word ptr ds:[delbuff1],bx ; d�lka bufferu 1 (vstupn� soubor)
         mov       word ptr ds:[delbuff1+2],dx
         mov       word ptr ds:[delbuff2],bx ; d�lka bufferu 2 (v�stupn� soubor)
         mov       word ptr ds:[delbuff2+2],dx
         or        bx,dx                    ; je alespo� n�jak� buffer ?
         jnz       dekomp6                  ; buffer OK

                                          ;* chyba p�id�len� pam�ti
dekomp7: mov       dx,offset err2           ; chybov� hl��en�
         mov       ah,9
         int       21h                      ; tisk chybov�ho hl��en�
         mov       al,3                     ; n�vratov� k�d - chyba RAM
         jmp       navrat                   ; n�vrat z programu

                                          ;* rozk�dov�n� p��kazov�ho ��dku
dekomp6: mov       si,81h                   ; p��kazov� ��dek
         xor       cx,cx                    ; cx <- 0000
         mov       cl,ds:[80h]              ; po�et zadan�ch znak�
         jcxz      dekomp8                  ; nen� zad�n ��dn� parametr - chyba
                                          ;* rozk�dov�n� jm�na vstupn�ho souboru
         mov       di,offset jmeno1         ; jm�no vstupn�ho souboru
dekomp1: lodsb                              ; znak zad�n�
         cmp       al,20h                   ; je mezera nebo ��dic� znak ?
         ja        dekomp3                  ; je platn� znak - p�enos
dekomp2: loop      dekomp1                  ; vypust�n� dal��ho znaku
                                          ;* chyba zad�n� soubor�
dekomp8: mov       dx,offset uvtxt          ; �vodn� text
         mov       ah,9                     ; funkce tisku textu
         int       21h                      ; tisk �vodn�ho textu
         mov       al,1                     ; ukon�en� programu s chybou
         jmp       short navrat             ; n�vrat z programu

dekomp3: stosb                              ; ulo�en� platn�ho znaku
         lodsb                              ; na�ten� dal��ho znaku
         cmp       al,20h                   ; je platn� znak ?
         jna       dekomp4                  ; nen� platn� znak - konec jm�na
         loop      dekomp3                  ; p�enos dal��ho platn�ho znaku
dekomp4: xor       al,al                    ; koncov� znak '0'
         stosb                              ; ulo�en� koncov�ho znaku jm�na
         dec       si                       ; n�vrat ukazatele p��kaz. ��dku
         jcxz      dekomp8                  ; nen� zad�n dal�� parametr - chyba
                                          ;* rozk�dov�n� jm�na v�stupn�ho soub.
         mov       di,offset jmeno2         ; jm�no v�stupn�ho souboru
dekom10: lodsb                              ; znak zad�n�
         cmp       al,20h                   ; je mezera nebo ��dic� znak ?
         ja        dekom30                  ; je platn� znak - p�enos
dekom20: loop      dekom10                  ; vypust�n� dal��ho znaku
         jmp       short dekomp8            ; nen� zad�n ��dn� v�stupn� soubor
dekom30: stosb                              ; ulo�en� platn�ho znaku
         lodsb                              ; na�ten� dal��ho znaku
         cmp       al,20h                   ; je platn� znak ?
         jna       dekom40                  ; nen� platn� znak - konec jm�na
         loop      dekom30                  ; p�enos dal��ho platn�ho znaku
dekom40: xor       al,al                    ; koncov� znak '0'
         stosb                              ; ulo�en� koncov�ho znaku jm�na
                                          ;* otev�en� vstupn�ho souboru
         mov       dx,offset jmeno1         ; vstupn� soubor
         mov       ah,3dh                   ; otev�en� souboru
         mov       al,0                     ; otev�en� pro �ten�
         int       21h                      ; otev�en� souboru
         jnc       dekom91                  ; soubor otev�en OK
                                          ;* chyba vstupn�ho souboru
dekom5:  mov       dx,offset err1           ; chyba otev�en� souboru
         mov       ah,9                     ; funkce tisku textu
         int       21h                      ; tisk chybov�ho textu
         mov       al,2                     ; k�d chyby pro n�vrat
         jmp       short navrat             ; n�vrat z programu s chybou
dekom91:                                  ;* vytvo�en� v�stupn�ho souboru
         mov       [idents1],ax             ; identifik�tor vstupn�ho souboru
         mov       dx,offset jmeno2         ; v�stupn� soubor
         mov       ah,4eh                   ; nalezen� souboru
         mov       cx,0                     ; atributy souboru
         int       21h                      ; nalezen� souboru
         jnc       dek02                    ; soubor existuje - chyba
         mov       dx,offset jmeno2         ; v�stupn� soubor
         mov       ah,3ch                   ; vytvo�en� souboru
         mov       cx,0                     ; atributy souboru
         int       21h                      ; otev�en� souboru
         jnc       soubok                   ; soubory otev�eny OK
                                          ;* chyba v�stupn�ho souboru
dek02:   mov       dx,offset err3           ; chyba v�stupn�ho souboru
         mov       ah,9                     ; funkce tisku textu
         int       21h                      ; tisk chybov�ho hl��en�
         mov       al,4                     ; chybov� k�d
         jmp       short navrat             ; n�vrat s chybou


                                          ;* n�vrat z programu
navrat:  push      ax                       ; �schova n�vratov�ho k�du
         mov       ax,ds:[segbuff1]         ; segment bufferu vstupn�ho souboru
         mov       es,ax                    ; segment bufferu dat
         or        ax,ax                    ; je buffer p�id�len ?
         jz        navr1                    ; nen� definov�n ��dn� buffer
         mov       ah,49h                   ; funkce uvoln�n� pam�ti
         int       21h                      ; uvoln�n� p�id�len� pam�ti
navr1:   mov       ax,ds:[segbuff2]         ; segment bufferu v�stupn�ho souboru
         mov       es,ax                    ; segment bufferu dat
         or        ax,ax                    ; je buffer p�id�len ?
         jz        navr2                    ; nen� definov�n ��dn� buffer
         mov       ah,49h                   ; funkce uvoln�n� pam�ti
         int       21h                      ; uvoln�n� p�id�len� pam�ti
navr2:   mov       bx,ds:[idents1]          ; identifik�tor vstupn�ho souboru
         or        bx,bx                    ; je vstupn� soubor otev�en ?
         jz        navr3                    ; vstupn� soubor nen� otev�en
         mov       ah,3eh                   ; funkce uzav�en� identifik�toru
         int       21h                      ; uzav�en� identifik�toru souboru
navr3:   mov       bx,ds:[idents2]          ; identifik�tor v�stupn�ho souboru
         or        bx,bx                    ; je v�stupn� soubor otev�en ?
         jz        navr4                    ; v�stupn� soubor nen� otev�en
         mov       ah,3eh                   ; funkce uzav�en� identifik�toru
         int       21h                      ; uzav�en� identifik�toru souboru
navr4:   pop       ax                       ; AL=n�vratov� k�d
         cli                                ; z�kaz p�eru�en�
         mov       sp,word ptr ds:[stack]   ; n�vrat ukazatele z�sobn�ku
         mov       ss,word ptr ds:[stack+2] ; n�vrat segmentu ukazatele z�sob.
         sti                                ; povolen� p�eru�en�
         mov       ah,4ch                   ; funkce n�vratu
         int       21h                      ; ukon�en� programu


soubok:                                   ;* soubory otev�eny OK
         mov       [idents2],ax             ; identifik�tor v�stupn�ho souboru
         jmp       encode                   ; zak�dov�n� souboru
         nop
         nop
         nop
         nop
         nop
         nop
         nop
         nop

; -----------------------------------------------------------------------------
;                       rozpakov�n� souboru
; -----------------------------------------------------------------------------

count    dw        1000                     ; ��ta� pro tisk
matchposit dw      0                        ; poloha shody
matchlen dw        0                        ; d�lka shody
len      dw        0                        ; d�lka na�ten� posloupnosti
r        dw        textbuf+buffersize-matchlimit ; adresa ke zpracov�n� dat
s        dw        textbuf                  ; adresa k ukl�d�n� dat (za�. buf.)
mask     db        1                        ; maska
bufptr   dw        1                        ; ��ta� bajt� v bufferu k�du
codebuf  db        17 dup(0)                ; buffer k�du
                                            ; prvn� bajt je n�v��t� 8 bit�:
                                            ; "1"=nek�dovan� znak (1 bajt)
                                            ; "0"=k�d <pozice;d�lka> (2 bajty)
                                            ; n�sleduje 8 bajt�/slov k�du

encode:                                     ; zak�dov�n� souboru
                                            ; pou�it� registr�:
                                            ;  DS:SI=adresa ke zpracov�n� dat
                                            ;  ES:DI=adresa k ukl�d�n� dat

         mov       di,textbuf               ; za��tek bufferu
         mov       cx,buffersize-matchlimit ; velikost bufferu
         mov       al,20h                   ; znak mezery pro inicializaci
         rep       stosb                    ; napln�n� bufferu mezerami
                                          ;* na�ten� jedn� d�lky dat
         mov       si,di                    ; adresa ke zpracov�n� dat
         mov       cx,matchlimit            ; po�et bajt� k na�ten�
encode1: call      readb                    ; na�ten� bajtu dat
         jc        encode2                  ; nejsou dal�� data
         stosb                              ; ulo�en� bajtu dat
         inc       word ptr [len]           ; zv��en� d�lky na�ten� posloupnosti
         loop      encode1                  ; na�ten� dal��ho bajtu
encode2: mov       di,textbuf               ; adresa k ukl�d�n� - za�. bufferu
         cmp       word ptr ds:[len],0      ; jsou na�tena n�jak� data ?
         jnz       encode4                  ; byla na�tena n�jak� data
encode3: stc                                ; p��znak vypr�zdn�n� bufferu
         call      writeb                   ; vypr�zdn�n� bufferu
         jmp       navrat                   ; n�vrat z programu

encode4:                                  ;* za��tek cyklu - zak�dov�n� dat
         call      findstr                  ; nalezen� �et�zce dat DS:SI
                                          ;* omezen� d�lky shody na konci soub.
         mov       ax,ds:[len]              ; d�lka na�ten�ch dat
         cmp       ax,ds:[matchlen]         ; d�lka nalezen� shody
         jnb       encode5                  ; d�lka nen� men�� ne� d�lka shody
         mov       [matchlen],ax            ; omezen� d�lky shody na d�lku dat
encode5:                                  ;* rozhodnut�, zda jsou kompres. data
         cmp       word ptr [matchlen],threshold ; kontrola minim. po�tu bajt�
         ja        encode6                  ; shoda je dostate�n� dlouh�
                                          ;* shoda kr�tk� - p�enos 1 bajtu dat
         mov       word ptr [matchlen],1    ; vy�le se 1 bajt
         mov       al,ds:[mask]             ; maska
         or        ds:[codebuf],al          ; nastaven� masky
         lodsb                              ; na�ten� bajtu ke zpracov�n�
         dec       si                       ; n�vrat zdrojov� adresy
         mov       bx,ds:[bufptr]           ; ukazatel v bufferu k�du
         mov       [bx+codebuf],al          ; ulo�en� do bufferu k�du
         inc       word ptr [bufptr]        ; zv��en� ukazatele v bufferu
         jmp       encode7                  ; pokra�ov�n� v k�dov�n�
encode6:                                  ;* shoda dostate�n� - zak�dov�n� �et.
         mov       al,byte ptr ds:[matchposit] ; ni��� bajt polohy shody
         mov       bx,ds:[bufptr]           ; ukazatel v bufferu k�du
         mov       [bx+codebuf],al          ; ulo�en� bajtu polohy do bufferu
         mov       al,byte ptr ds:[matchposit+1] ; vy��� bajt polohy shody
         shl       al,1
         shl       al,1
         shl       al,1
         shl       al,1                     ; rotace o 4 bity vlevo
         mov       ah,byte ptr ds:[matchlen] ; d�lka shody
         sub       ah,threshold+1           ; ode�ten� minim�ln�ho po�tu
         or        al,ah                    ; druh� bajt k�du
         mov       [bx+codebuf+1],al        ; ulo�en� bajtu d�lky do bufferu
         add       word ptr [bufptr],2      ; zv��en� ukazatele v bufferu
encode7:                                  ;* rotace masky - dal�� k�d
         shl       byte ptr ds:[mask],1     ; rotace masky o bit vlevo
         cmp       byte ptr ds:[mask],0     ; je maska = 0 ?
         jne       encode9                  ; maska nen� = 0
                                          ;* je ji� 8 k�d� - vypr�zdn�n� bufferu
         push      si                       ; �schova adresy ke zpracov�n�
         mov       si,offset codebuf        ; za��tek bufferu k�du
         mov       cx,ds:[bufptr]           ; po�et dat v bufferu
encode8: lodsb                              ; bajt z bufferu k�du
         clc                                ; p��znak - z�pis bajtu na v�stup
         call      writeb                   ; z�pis bajtu do souboru
         loop      encode8                  ; dal�� bajt
         pop       si                       ; n�vrat adresy ke zpracov�n�
         mov       byte ptr ds:[codebuf],0  ; nulov�n� n�v��t� k�du
         mov       byte ptr ds:[mask],1     ; nastaven� masky
         mov       word ptr ds:[bufptr],1   ; nastaven� ukazatele bufferu k�du
                                          ;* na�ten� dal��ch dat ze souboru
encode9: mov       cx,ds:[matchlen]         ; d�lka shody = po�et bajt� v buff.
         add       si,cx                    ; zv��en� adresy ke zpracov�n�
         cmp       si,textbuf+buffersize    ; byl p�ekro�en konec bufferu ?
         jb        encodea                  ; konec bufferu je�t� nep�ekro�en
         sub       si,buffersize            ; p�evod na za��tek bufferu
encodea: call      readb                    ; �ten� bajtu ze souboru
         jnc       encodeb                  ; jsou dal�� data
         dec       word ptr ds:[len]        ; sn��en� po�tu na�ten�ch dat
encodeb: stosb                              ; ulo�en� bajtu do bufferu
         cmp       di,textbuf+matchlimit+1  ;
         jnb       encodec                  ; nen� men��
         push      di
         add       di,buffersize-1          ; adresa kopie bufferu
         stosb                              ; duplik. ulo�en� bajtu do bufferu
         pop       di                       ; n�vrat ukazatele k ukl�d�n�
encodec: cmp       di,textbuf+buffersize    ; je ji� dosa�eno konce bufferu ?
         jb        encoded                  ; nep�esahuje je�t� konec bufferu
         sub       di,buffersize            ; za��tek kruhov�ho bufferu
encoded: loop      encodea                  ; na�ten� dal��ho bajtu dat

         dec       word ptr [count]
         jne       encodeg
         mov       dl,"."
         mov       ah,2
         int       21h
         mov       word ptr [count],1000

encodeg:
         cmp       word ptr ds:[len],1      ; bylo je�t� n�co na�teno ?
         jl        encodee                  ; nejsou dal�� data - konec
         jmp       encode4                  ; dal�� zpracov�n�

encodee:
         mov       si,offset codebuf        ; za��tek bufferu k�du
         mov       cx,ds:[bufptr]           ; po�et dat v bufferu
encodef: lodsb                              ; bajt z bufferu k�du
         clc
         call      writeb                   ; z�pis bajtu do souboru
         loop      encodef                  ; dal�� bajt
         jmp       encode3                  ; konec

findstr:                                    ; nalezen� �et�zce DS:SI
         mov       word ptr ds:[matchlen],0 ; v�choz� d�lka shody = 0
         push      di                       ; �schova adresy k ukl�d�n�
         mov       di,textbuf-1             ; za��tek kruhov�ho bufferu
         mov       cx,buffersize            ; velikost bufferu
findst0: inc       di                       ; n�sleduj�c� �et�zec
         mov       al,ds:[si]               ; bajt k nalezen�
         repnz     scasb                    ; nalezen� shodn�ho bajtu
         jnz       findst8                  ; nejsou nalezena dal�� data
         dec       di                       ; n�vrat adresy textu
         push      cx                       ; �schova CX (��ta� dat)
         push      di                       ; �schova DI (testovan� �et�zec)
         push      si                       ; �schova SI (hledan� �et�zec)
         mov       cx,matchlimit            ; max. po�et porovn�van�ch bajt�
         rep       cmpsb                    ; kontrola shody �et�zc�
         pop       si                       ; n�vrat SI (hledan� �et�zec)
         pop       di                       ; n�vrat DI (testovan� �et�zec)
         mov       ax,matchlimit            ; max. po�et porovn�van�ch bajt�
         sub       ax,cx                    ; po�et shodn�ch bajt�
         pop       cx                       ; n�vrat CX (��ta� dat)
         cmp       ax,ds:[matchlen]         ; porovn�n� s ji� nalezenou shodou
         jng       findst0                  ; shoda nen� v�t�� - dal�� �et�zec
         cmp       di,si                    ; je pod hledan�m �et�zcem ?
         jb        findst1                  ; nalezen� �et�zec je pod hledan�m
         push      si                       ; �schova SI (hledan� �et�zec)
         add       si,matchlimit            ; konec hledan�ho �et�zce
         cmp       di,si                    ; je nad hledan�m �et�zcem ?
         pop       si                       ; n�vrat SI (hledan� �et�zec)
         jb        findst0                  ; je v oblasti hledan�ho �et�zce
findst1: mov       ds:[matchlen],ax         ; nov� d�lka nalezen�ho �et�zce
         push      di
         sub       di,textbuf
         mov       ds:[matchposit],di       ; nov� adresa nalezen�ho �et�zce
         pop       di
         jmp       findst0                  ; hled�n� dal��ho �et�zce
findst8: pop       di                       ; n�vrat adresy k ukl�d�n� dat
         ret




; -----------------------------------------------------------------------------


readb:                                      ; �ten� bajtu ze souboru
                                            ; V�STUP: AL=bajt (pokud CN)
                                            ;         CY=nejsou dal�� data

         cmp       word ptr cs:[pocbyte1],0 ; jsou n�jak� data v bufferu ?
         jne       readb1                   ; jsou dal�� data
         cmp       word ptr cs:[pocbyte1+2],0 ; jsou n�jak� data v bufferu ?
         jne       readb1                   ; jsou dal�� data
                                           ;* na�ten� dat do bufferu
         call      readbuf                  ; �ten� bloku 64KB
         jc        readb2                   ; chyba �ten�
readb3:  call      readbuf                  ; �ten� dal��ho bloku 64KB
         jnc       readb3                   ; na�ten� dal��ch dat
         mov       word ptr ds:[readbyte],0 ; offset adresy �ten�ho bajtu
         mov       ax,ds:[segbuff1]         ; segment adresy �ten�ho bajtu
         mov       word ptr ds:[readbyte+2],ax ; segment adresy �ten�ho bajtu
                                          ;* p�e�ten� bajtu z bufferu
readb1:  push      si                       ; �schova SI
         push      ds                       ; �schova DS
         lds       si,ds:[readbyte]         ; adresa ke �ten� bajtu
         cld                                ; sm�r posunu ukazatele nahoru
         lodsb                              ; na�ten� dal��ho bajtu dat
         pop       ds                       ; n�vrat DS
         pop       si                       ; n�vrat SI
         inc       word ptr ds:[readbyte]   ; zv��en� �tec� adresy bajtu
         jnz       readb10                  ; nen� p�ete�en� p�es okraj segmentu
         add       word ptr ds:[readbyte+2],1000h ; zv��en� adresy segmentu
readb10: sub       word ptr ds:[pocbyte1],1 ; sn��en� po�tu ulo�en�ch bajt�
         jnc       readb11                  ; nen� p�enos
         dec       word ptr ds:[pocbyte1+2] ; p�enos do vy���ho slova
readb11: clc                                ; p��znak - �ten� OK
readb2:  ret

readbuf:                                    ; na�ten� dat 64KB ze vstup. souboru
                                            ; V�STUP: CY=nelze ��st dal�� data

         push      bx                       ; �schova BX
         push      cx                       ; �schova CX
         push      dx                       ; �schova DX
         mov       ax,word ptr ds:[delbuff1] ; d�lka bufferu vstupn�ho souboru
         sub       ax,word ptr ds:[pocbyte1] ; v�po�et voln�ho m�sta
         mov       cx,ax                    ; po�et voln�ch bajt�
         mov       ax,word ptr ds:[delbuff1+2] ; d�lka bufferu - vy��� slovo
         sbb       ax,word ptr ds:[pocbyte1+2] ; vy��� slovo po�tu bajt�
         jz        readb6                   ; nen� v�t�� ne� FFFFh bajt�
         mov       cx,0ffffh                ; n�hradn� po�et bajt� ke �ten�
readb6:  jcxz      readb8                   ; chyba - nen� voln� m�sto
         push      ds                       ; �schova DS
         lds       dx,ds:[pocbyte1]         ; po�et bajt� v bufferu
         mov       ax,dx                    ; ni��� slovo po�tu bajt�
         mov       bx,ds                    ; vy��� slovo po�tu bajt�
         and       dx,0fh                   ; korekce do jednoho odstavce
         shr       bx,1                     ; BX/2
         rcr       ax,1
         shr       bx,1                     ; BX/4
         rcr       ax,1
         shr       bx,1                     ; BX/8
         rcr       ax,1
         shr       bx,1                     ; BX/16 - po�et odstavc�
         rcr       ax,1
         add       ax,cs:[segbuff1]         ; po��te�n� segment bufferu
         mov       ds,ax                    ; segment za��tku dat
         mov       bx,cs:[idents1]          ; identifik�tor vstupn�ho souboru
         mov       ah,3fh                   ; funkce �ten� ze souboru
         int       21h                      ; na�ten� dat z bufferu
         pop       ds
         jnc       readb7                   ; �ten� ze souboru OK
         jmp       dekom5                   ; chyba vstupn�ho souboru
readb7:  add       word ptr [pocbyte1],ax   ; zv��en� po�tu bajt�
         adc       word ptr [pocbyte1+2],0  ; p�i�ten� p�enosu
         or        ax,ax                    ; jsou na�tena n�jak� data ?
         jnz       readb9                   ; jsou na�tena data
readb8:  stc                                ; p��znak - nejsou dal�� data
readb9:  pop       dx
         pop       cx
         pop       bx
         ret


                                          ; * vstupn� soubor
jmeno1   db        128 dup(0)               ; jm�no vstupn�ho souboru
idents1  dw        0                        ; identifikace zdrojov�ho souboru
readbyte dd        0                        ; adresa ke �ten� bajtu
segbuff1 dw        0                        ; adresa datov�ho bufferu 1 (segm.)
pocbyte1 dd        0                        ; po�et bajt� v bufferu vstup.soub.
delbuff1 dd        0                        ; d�lka datov�ho bufferu vstup.soub.


writeb:                                     ; z�pis bajtu do souboru
                                            ; VSTUP: AL=bajt (pokud CN)
                                            ;        CY=vypr�zdn�n� bufferu
                                            ; V�STUP: CY=chyba z�pisu do souboru

                                          ;* z�pis bajtu do bufferu
         push      ax
         jc        writb4                   ; vypr�zdn�n� bufferu
         push      di                       ; �schova DI
         push      es                       ; �schova ES
         les       di,ds:[writbyte]         ; adresa k z�pisu bajtu
         cld                                ; sm�r posunu ukazatele nahoru
         stosb                              ; ulo�en� dal��ho bajtu dat
         pop       es                       ; n�vrat ES
         pop       di                       ; n�vrat DI
         inc       word ptr ds:[writbyte]   ; zv��en� ukl�dac� adresy bajtu
         jnz       writb10                  ; nen� p�ete�en� p�es okraj segmentu
         add       word ptr ds:[writbyte+2],1000h ; zv��en� adresy segmentu
writb10: add       word ptr ds:[pocbyte2],1 ; zv��en� po�tu ulo�en�ch bajt�
         jnc       writb11                  ; nen� p�enos
         inc       word ptr ds:[pocbyte2+2] ; p�enos do vy���ho slova
writb11:
         mov       ax,word ptr ds:[pocbyte2+2] ; vy��� slovo po�tu bajt�
         cmp       ax,word ptr ds:[delbuff2+2] ; kontrola s d�lkou bufferu
         jne       writb12                  ; nen� shoda
         mov       ax,word ptr ds:[pocbyte2] ; ni��� slovo po�tu bajt�
         cmp       ax,word ptr ds:[delbuff2] ; kontrola s d�lkou bufferu
writb12: jc        writb5                   ; buffer je�t� nen� zapln�n
writb4:                                   ;* ulo�en� dat z bufferu
         mov       word ptr ds:[writbyte],0 ; offset adresy zapisovan�ho bajtu
         mov       ax,ds:[segbuff2]         ; segment adresy zapisovan�ho bajtu
         mov       word ptr ds:[writbyte+2],ax ; segment adresy zapisov. bajtu
         call      writbuf                  ; z�pis bloku 64KB
         jc        writb2                   ; chyba z�pisu
writb3:  call      writbuf                  ; z�pis dal��ho bloku 64KB
         jnc       writb3                   ; z�pis dal��ch dat
         mov       word ptr ds:[writbyte],0 ; offset adresy zapisovan�ho bajtu
         mov       ax,ds:[segbuff2]         ; segment adresy zapisovan�ho bajtu
         mov       word ptr ds:[writbyte+2],ax ; segment adresy zapisov. bajtu
writb5:  clc                                ; p��znak - z�pis OK
writb2:  pop       ax
         ret



writbuf:                                    ; z�pis dat 64KB do v�stup. souboru
                                            ; V�STUP: CY=nelze zapsat dal�� data

         push      bx                       ; �schova BX
         push      cx                       ; �schova CX
         push      dx                       ; �schova DX
         mov       cx,word ptr ds:[pocbyte2] ; po�et bajt� v bufferu
         cmp       word ptr ds:[pocbyte2+2],0 ; vy��� slovo po�tu bajt�
         jz        writb6                   ; nen� v�t�� ne� FFFFh bajt�
         mov       cx,0ffffh                ; n�hradn� po�et bajt� ke �ten�
writb6:  jcxz      writb8                   ; chyba - nejsou dal�� data
         push      ds                       ; �schova DS
         lds       dx,ds:[writbyte]         ; adresa dat k z�pisu
         mov       bx,dx                    ; ni��� slovo adresy
         and       dx,0fh                   ; korekce do jednoho odstavce
         shr       bx,1                     ; BX/2
         shr       bx,1                     ; BX/4
         shr       bx,1                     ; BX/8
         shr       bx,1                     ; BX/16 - po�et odstavc�
         mov       ax,ds                    ; segment adresy
         add       ax,bx                    ; p�i�ten� p�enosu z offsetu
         mov       ds,ax                    ; segment za��tku dat
         mov       bx,cs:[idents2]          ; identifik�tor v�stupn�ho souboru
         mov       ah,40h                   ; funkce z�pis do souboru
         int       21h                      ; z�pis dat do bufferu
         pop       ds
         jc        writb9                   ; chyba z�pisu do souboru
         add       word ptr [writbyte],ax   ; zv��en� adresy
         jnc       writb7                   ; nen� p�enos
         add       word ptr [writbyte+2],1000h ; p�i�ten� p�enosu do segmentu
writb7:  sub       word ptr [pocbyte2],ax   ; sn��en� po�tu bajt� v bufferu
         sbb       word ptr [pocbyte2+2],0  ; p�enos do vy���ho slova
         or        ax,ax                    ; byla zaps�na n�jak� data ?
         jnz       writb9                   ; byla zaps�na n�jak� data
writb8:  stc                                ; p��znak - nelze prov�st z�pis
writb9:  pop       dx
         pop       cx
         pop       bx
         ret




                                          ; * v�stupn� soubor
jmeno2   db        128 dup(0)               ; jm�no v�stupn�ho souboru
idents2  dw        0                        ; identifikace c�lov�ho souboru
writbyte dd        0                        ; adresa k z�pisu bajtu
segbuff2 dw        0                        ; adresa datov�ho bufferu 2 (segm.)
pocbyte2 dd        0                        ; po�et bajt� v bufferu v�stup.soub.
delbuff2 dd        0                        ; d�lka datov�ho bufferu v�st.soub.

uvtxt    db        'Pakov�n� souboru: KOMP <vstup.soub.> <v�stup.soub.>'
         db        13,10,'$'

err1     db        'Vstupn� soubor nenalezen nebo chyba �ten� !',13,10,'$'

err2     db        'Chyba p�id�len� pam�ti !',13,10,'$'

err3     db        'V�stupn� soubor ji� existuje nebo chyba z�pisu !',13,10,'$'

         dw        256 dup(0)               ; z�sobn�k
stack    dd        0                        ; vlastn� z�sobn�k


konec:                                      ; konec programu

; Buffer (um�st�n za programem)

; textbuf    db      buffersize+matchlimit dup(?) ; cyklick� buffer

code     ENDS

         END       komp                     ; startovac� adresa
