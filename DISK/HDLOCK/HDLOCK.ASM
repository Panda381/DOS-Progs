
; *****************************************************************************
;
;                                 H D L O C K
;
;               uzam�en� pevn�ho disku proti p��stupu z diskety
;
; *****************************************************************************

code     SEGMENT
         ASSUME    cs:code,ds:data,ss:stack

hdlock:
         mov       ax,SEG data              ; datov� segment
         mov       ds,ax                    ; DS <- datov� segment
         mov       ds:[segpsp],es           ; �schova adresy segmentu PSP
         mov       si,offset txtuvod0       ; �vodn� text
         call      outtxt                   ; zobrazen� �vodn�ho textu

;------------------------- test verze opera�n�ho syst�mu ----------------------

                                          ;* test verze opera�n�ho syst�mu
         mov       ah,30h
         int       21h                      ; poskytnut� verze syst�mu
         cmp       al,2                     ; je verze alespo� 2.00 ?
         jge       hdlock1                  ; je verze alespo� 2.00 - OK
         mov       si,offset txtverze       ; text chyby verze syst�mu
hdlock0:                                  ;* hl��en� chyby
         call      outtxt                   ; zobrazen� textu chyby
hdlockx: mov       ax,ds:[segpsp]           ; adresa segmentu PSP
         push      ax                       ; segment pro skok na INT 20h
         xor       ax,ax                    ; AX <- 0
         push      ax                       ; offset pro skok na INT 20h
navrat   PROC      FAR
         ret                                ; skok na instrukci INT 20h
navrat   ENDP

; ----------------------- test pevn�ho disku ----------------------------------

hdlock1:                                  ;* test pevn�ho disku
         mov       ah,0dh
         int       21h                      ; reset diskov�ho syst�mu DOS
         mov       ah,8
         mov       dl,80h
         int       13h                      ; poskytnut� parametr� pevn�ho disku
         mov       si,offset txtdisk        ; text "Nenalezen ��dn� pevn� disk"
         jc        hdlock0                  ; chyba - nen� pevn� disk
         or        dl,dl                    ; je alespo� 1 pevn� disk ?
         jz        hdlock0                  ; nen� ��dn� pevn� disk

; --------------------- na�ten� hlavn�ho zav�d�c�ho sektoru -------------------

         call      rboot                    ; �ten� zav�d�c�ho sektoru
         jc        hdlockx                  ; chyba �ten� zav�d�c�ho sektoru

; -------------------- porovn�n�, zda je vlastn� zavad�� ----------------------

                                          ;* porovn�n�, zda je vlastn� zavad��
         mov       ax,SEG boot
         mov       ds,ax                    ; segment vlastn�ho zavad��e
         mov       cx,offset(bootx-boot0)   ; d�lka programu zavad��e
         xor       si,si                    ; po��te�n� offset ve vlastn�m zav.
         xor       di,di                    ; po��te�n� offset v na�ten�m zav.
         repe      cmpsb                    ; porovn�n� zavad���
         mov       si,offset txtuvod2       ; hl��en�, �e je sektor OK
         je        hdlock2                  ; sektor je OK
         mov       si,offset txtuvod1       ; hl��en�, �e je jin� sektor
         or        byte ptr ds:[param],1    ; p��znak jin�ho sektoru
hdlock2: call      outtxt                   ; zobrazen� textu

hdlock3: mov       si,offset txtmenu        ; text nab�dky funkc�
         call      outtxt                   ; zobrazen� nab�dky funkc�
hdlock4: call      inpch                    ; vstup znaku z kl�vesnice
         jc        hdlock9                  ; je ukon�en� programu
         cmp       al,13
         je        hdlock9                  ; je Enter (=volba 0)
         cmp       al,"0"                   ; je znak men�� ne� "0" ?
         je        hdlock9                  ; je ukon�en� programu
         jb        hdlock4                  ; neplatn� znak
         cmp       al,"4"                   ; je znak v�t�� ne� "4" ?
         ja        hdlock4                  ; je znak v�t�� ne� "4"

         call      outch                    ; zobrazen� znaku
         call      outcr                    ; od��dkov�n� textu
         call      outcr                    ; od��dkov�n� textu

         cmp       al,"1"
         jne       hdlock5                  ; nen� ulo�en� sektoru

         call      ulozb
         jmp       short hdlock3
hdlock5:
         cmp       al,"2"
         jne       hdlock6                  ; nen� ulo�en� sektoru

         call      nactib
         jmp       short hdlock3
hdlock6:


         jmp       hdlock3

hdlock9:
         mov       ax,4c00h
         int       21h

; ------------------ �schova zav�d�c�ho sektoru do souboru --------------------
ulozb:                                    ;* ulo�en� zav�d�c�ho sektoru na disk
         call      rboot                    ; �ten� zav�d�c�ho sektoru
         jc        ulozb9                   ; chyba �ten� zav�d�c�ho sektoru
         mov       si,offset txtzad1        ; v�zva "zadejte soubor k ulo�en�.."
         call      outtxt                   ; zobrazen� v�zvy
         call      inptxt                   ; zad�n� jm�na souboru
         jc        ulozb9                   ; p�eru�en� operace
         cmp       byte ptr ds:[si],0
         je        ulozb9                   ; nen� zad�n ��dn� znak
                                          ;* pokus o nalezen� souboru
         mov       ah,4eh
         mov       cx,07h                   ; atributy souboru
         int       21h                      ; pokus o nalezen� souboru
         jc        ulozb4                   ; soubor neexistuje - OK
                                          ;* soubor ji� existuje - dal�� dotaz
         mov       si,offset txtzad2        ; dotaz "P�ep��e se ?"
         call      outtxt                   ; zobrazen� v�zvy
ulozb2:  call      inpch                    ; vstup znaku z kl�vesnice
         jnc       ulozb1                   ; nen� p�eru�en� operace
         mov       al,"N"                   ; p�eru�en� operace
ulozb1:  cmp       al,13                    ; je Enter ?
         je        ulozb3                   ; je Enter
         cmp       al,"A"                   ; je potvrzen� Ano ?
         je        ulozb3                   ; je potvrzen� Ano
         cmp       al,"N"
         jne       ulozb2                   ; neplatn� znak
         call      outch                    ; zobrazen� znaku volby
         call      outcr
         call      outcr
         jmp       short ulozb9

ulozb3:  call      outcr
         call      outcr
ulozb4:                                   ;* ulo�en� souboru na disk
         mov       ah,3ch
         xor       cx,cx
         int       21h                      ; vytvo�en� zadan�ho souboru
         jc        ulozb8                   ; chyba zad�n� souboru
         mov       bx,ax                    ; identifik�tor souboru
         mov       ax,SEG buffer            ; segment bufferu s na�ten�m sektorem
         mov       ds,ax                    ; segment bufferu s na�ten�m sektorem
         mov       ah,40h
         mov       cx,512                   ; d�lka sektoru
         xor       dx,dx                    ; adresa v pam�ti
         int       21h                      ; z�pis sektoru do souboru
         jc        ulozb6                   ; chyba z�pisu do souboru
         cmp       ax,cx                    ; souhlas� po�et zapsan�ch bajt� ?
ulozb6:  pushf
         mov       ah,3eh
         int       21h                      ; uzav�en� souboru
         popf
         jnc       ulozb9                   ; operace OK

ulozb8:  mov       si,offset txtuloz        ; text "Chyba zadani .."
         call      outtxt                   ; zobrazen� chybov�ho textu
ulozb9:
         ret

; ----------------- navr�cen� zav�d�c�ho sektoru ze souboru -------------------
nactib:                                   ;* navr�cen� zav�d�c�ho sektoru
         call      rboot                    ; �ten� zav�d�c�ho sektoru
         jc        nactib9                  ; chyba �ten� zav�d�c�ho sektoru
         mov       si,offset txtzad3        ; v�zva "zadejte soubor ke �ten�.."
         call      outtxt                   ; zobrazen� v�zvy
         call      inptxt                   ; zad�n� jm�na souboru
         jc        nactib9                  ; p�eru�en� operace
         cmp       byte ptr ds:[si],0
         je        nactib9                  ; nen� zad�n ��dn� znak
                                          ;* na�ten� souboru z disku
         mov       ax,3d00h
         int       21h                      ; otev�en� zadan�ho souboru
         jc        nactib8                  ; chyba zad�n� souboru
         mov       bx,ax                    ; identifik�tor souboru
         mov       ax,SEG buffer2           ; segment bufferu k na�ten� souboru
         mov       ds,ax                    ; segment bufferu k na�ten� souboru
         mov       ah,3fh
         mov       cx,512                   ; d�lka sektoru
         xor       dx,dx                    ; adresa v pam�ti
         int       21h                      ; �ten� sektoru ze souboru
         jc        nactib6                  ; chyba �ten� ze souboru
         cmp       ax,cx                    ; souhlas� po�et na�ten�ch bajt� ?
nactib6: pushf
         mov       ah,3eh
         int       21h                      ; uzav�en� souboru
         popf
         jc        nactib8                  ; byla chyba operace �ten�
                                          ;* kontrola struktury zavad. sektoru
         cmp       word ptr ds:[1feh],0aa55h ; identifika�n� slovo zavad��e
         jne       nactib7                  ; chybn� identifikace zavad��e


                                          ;* ulo�en� sektoru
         mov       ax,SEG buffer            ; buffer pro z�pis
         mov       es,ax
         xor       si,si
         xor       di,di
         mov       cx,512                   ; d�lka zav�d�c�ho sektoru
         cld
         rep       movsb                    ; p�enos sektoru
         call      wboot                    ; z�pis sektoru na disk
         jmp       short nactib9

nactib7:                                  ;* �patn� struktura sektoru
         mov       si,offset txtvarov
         call      outtxt
         ret

nactib8: mov       si,offset txtcti         ; text "Chyba zadani .."
         call      outtxt                   ; zobrazen� chybov�ho textu
nactib9:
         ret

; --------------------- �ten� zavad��e z disku --------------------------------
rboot:                                    ;* �ten� zav�d�c�ho sektoru z disku
                                            ; V�STUP: CY=chyba operace

         mov       ah,0dh
         int       21h                      ; reset diskov�ho syst�mu DOS
         xor       ax,ax
         mov       dl,80h
         int       13h                      ; reset pevn�ho disku 0
         mov       ax,SEG buffer            ; buffer pro na�ten� sektoru
         mov       es,ax                    ; segment buff. pro na�ten� sektoru
         xor       bx,bx                    ; offset bufferu = 0
         mov       ax,201h                  ; na�ten� 1 sektoru
         mov       cx,1                     ; po��te�n� sektor 1
         mov       dx,80h                   ; disk 0, hlava 0
         int       13h                      ; �ten� hlavn�ho zav�d�c�ho sektoru
         jnc       rboot2                   ; sektor na�ten OK
         mov       si,offset txtrboot       ; text "Chyba �ten� sektoru.."
         call      outtxt                   ; zobrazen� chybov�ho textu
rboot2:  ret
; --------------------- ulo�en� zavad��e na disk ------------------------------
wboot:                                    ;* z�pis zav�d�c�ho sektoru na disk
                                            ; V�STUP: CY=chyba operace

         mov       ah,0dh
         int       21h                      ; reset diskov�ho syst�mu DOS
         xor       ax,ax
         mov       dl,80h
         int       13h                      ; reset pevn�ho disku 0
         mov       ax,SEG buffer            ; buffer pro z�pis sektoru
         mov       es,ax                    ; segment buff. pro z�pis sektoru
         xor       bx,bx                    ; offset bufferu = 0
         mov       ax,301h                  ; z�pis 1 sektoru
         mov       cx,1                     ; po��te�n� sektor 1, v�lec 0
         mov       dx,80h                   ; disk 0, hlava 0
         int       13h                      ; z�pis hlavn�ho zav�d�c�ho sektoru
         jnc       wboot2                   ; sektor zaps�n OK
         mov       si,offset txtwboot       ; text "Chyba z�pisu sektoru.."
         call      outtxt                   ; zobrazen� chybov�ho textu
wboot2:  ret
; --------------------------- vstup textu -------------------------------------
inptxt:                                   ;* vstup textu
                                            ; V�STUP: CY=p�eru�en�

         mov       ax,SEG data
         mov       es,ax
         mov       ds,ax
         mov       di,offset textbuf        ; buffer pro zad�n� textu
         mov       si,di
         mov       dx,di
         xor       cx,cx                    ; ��ta� zadan�ch znak�
inptxt1: call      inpch1                   ; vstup znaku z kl�vesnice
         jc        inptxt3                  ; p�eru�en� operace
         cmp       al,13                    ; je <Enter> ?
         je        inptxt3                  ; je <Enter> - konec zad�n�
         cmp       al,8                     ; je <BS> ?
         je        inptxt2                  ; je <BS>
         cmp       ax,4b00h                 ; je kurzor vlevo ?
         je        inptxt2                  ; je kurzor vlevo
         cmp       ax,4d00h                 ; je kurzor vpravo ?
         jne       inptxt4                  ; nen� kurzor vpravo
         mov       al,es:[di]               ; znak v bufferu
inptxt4: cmp       al," "                   ; je platn� znak ?
         jbe       inptxt1                  ; je neplatn� znak
         cmp       cx,45                    ; je ji� maxim�ln� po�et znak� ?
         jae       inptxt1                  ; je ji� maxim�ln� po�et znak�
         stosb                              ; ulo�en� nov�ho znaku
         inc       cx                       ; zv��en� ��ta�e znak�
         call      outch                    ; zobrazen� znaku
         jmp       short inptxt1            ; vstup dal��ho znaku
inptxt2: jcxz      inptxt1                  ; v bufferu nen� ��dn� znak
         call      outbs                    ; vymaz�n� p�edchoz�ho znaku
         dec       cx                       ; sn��en� znak� v bufferu
         dec       di                       ; sn��en� ukazatele v bufferu
         jmp       short inptxt1            ; vstup dal��ho znaku
inptxt3: pushf
         xor       ax,ax
         stosb                              ; ozna�en� konce textu
         call      outcr                    ; od��dkov�n� textu
         call      outcr
         popf
         ret
; -------------------------- vymaz�n� znaku -----------------------------------
outbs:                                    ;* vymaz�n� p�edchoz�ho znaku
         push      ax
         mov       al,8
         call      outch                    ; posun kurzoru vlevo <BS>
         mov       al," "
         call      outch                    ; vymaz�n� posledn�ho znaku
         mov       al,8
         call      outch                    ; posun kurzoru zp�t vlevo
         pop       ax
         ret
; ------------------------- vstup znaku z kl�vesnice --------------------------
inpch:                                    ;* vstup znaku z kl�vesnice
                                            ; V�STUP: AX=k�d kl�vesy
                                            ;         CY=p�eru�en�

         mov       ah,1
         int       16h                      ; test stavu kl�vesnice
         jz        inpch1                   ; nen� p�ipravena dal�� kl�vesa
         xor       ax,ax
         int       16h                      ; zru�en� kl�vesy z bufferu
         jmp       short inpch              ; vstup dal�� kl�vesy

inpch1:  xor       ax,ax
         int       16h                      ; vstup znaku
         cmp       al,"a"
         jb        inpch2                   ; je men�� ne� "a" - nen� mal� p�sm.
         cmp       al,"z"
         ja        inpch2                   ; je v�t�� ne� "z" - nen� mal� p�sm.
         sub       al,32                    ; korekce na velk� p�smeno
inpch2:
         or        ax,ax
         jz        inpch3                   ; je Ctrl-Break
         cmp       al,3
         je        inpch3                   ; je Ctrl-C
         cmp       al,27
         je        inpch3                   ; je Esc
         stc
inpch3:  cmc                                ; p��znak - p�eru�en� operace
         ret
; ---------------------------- od��dkov�n� textu -----------------------------
outcr:                                    ;* od��dkov�n� textu
         push      ax
         mov       al,13
         call      outch
         mov       al,10
         call      outch
         pop       ax
         ret
; ------------------------- v�stup textu na displej ---------------------------
outtxt:                                   ;* v�stup textu na displej
                                            ; VSTUP: SI=adresa textu

         pushf
         push      ds
         mov       ax,SEG data
         mov       ds,ax
outtxt1: lodsb                              ; na�ten� znaku k zobrazen�
         or        al,al                    ; je ji� konec textu ?
         jz        outtxt2                  ; je konec textu
         call      outch                    ; zobrazen� znaku
         jmp       short outtxt1            ; zobrazen� dal��ho znaku
outtxt2: pop       ds
         popf
         ret
; ------------------------- v�stup znaku na displej ---------------------------
outch:                                    ;* v�stup znaku na displej
                                            ; VSTUP: AL=znak k zobrazen�

         push      ax
         push      dx
         mov       dl,al                    ; znak k zobrazen�
         mov       ah,2
         int       21h                      ; zobrazen� znaku
         pop       dx
         pop       ax
         ret

code     ENDS

; *****************************************************************************
;                          Datov� segment
; *****************************************************************************
data     SEGMENT

param    db        0                        ; parametry
                                            ;   bit 0: 1=je jin� zav�d�c� sektor

segpsp   dw        0                        ; adresa segmentu PSP

txtverze db        'Chybna verze operacniho systemu !',13,10,0
txtdisk  db        'Nenalezen zadny pevny disk !',13,10,0

txtrboot db        'Chyba cteni zavadeciho sektoru z pevneho disku !',13,10,0
txtwboot db        'Chyba zapisu zavadeciho sektoru na pevny disk !',13,10,0

txtuvod0 db        'Uzamykani pevneho disku; (c) Miroslav Nemecek',13,10
         db        '=============================================',13,10
         db        0
txtuvod1 db        'Hlavni zavadeci sektor, ktery je nyni umisten',13,10
         db        'na pevnem disku, neumoznuje uzamykani pevneho',13,10
         db        'disku. Bude proto nahrazen vlastnim zavadecim',13,10
         db        'sektorem.  Nejdrive si zalohujte pomoci volby',13,10
         db        '1  puvodni zavadeci sektor pevneho disku, aby',13,10
         db        'bylo  mozno v pripade havarie zavadeci sektor',13,10
         db        'pevneho disku zpetne rekonstruovat.',13,10,13,10
         db        0

txtuvod2 db        'Zavadeci sektor pevneho disku je v poradku.',13,10,13,10
         db        0

txtmenu  db        '        1 - uschova zavadeciho sektoru',13,10
         db        '        2 - navraceni zavadeciho sektoru',13,10
         db        '        3 - uzamceni pevneho disku',13,10
         db        '        4 - odemceni pevneho disku',13,10
         db        13,10
         db        'Zvolte pozadovanou operaci (0=konec): 0',8
         db        0

txtzad1  db        'Zadejte jmeno souboru, do ktereho bude hlavni',13,10
         db        'zavadeci sektor disku ulozen: ',0

txtzad2  db        'Zadany soubor jiz existuje. Chcete jej',13,10
         db        'prepsat (A=Ano, N=Ne) ? A',8,0

txtzad3  db        'Zadejte jmeno souboru, z ktereho bude hlavni',13,10
         db        'zavadeci sektor disku navracen: ',0


txtuloz  db        '*** Chyba zadani vystupniho souboru ! ***',13,10,13,10,0
txtcti   db        '*** Chyba zadani vstupniho souboru ! ***',13,10,13,10,0
txtvarov db        'VAROVANI: Nacteny zavadeci sektor nema spravnou',13,10
         db        '          strukturu !  Ulozenim  tohoto sektoru',13,10
         db        '          na  disk se vystavujete nebezpeci, ze',13,10
         db        '          disk  se  stane nepristupny nebo data',13,10
         db        '          na disku budou znicena !',13,10,13,10
         db        'Chcete i nadale pokracovat (A=Ano, N=Ne) ? N',8,0

textbuf  db        'HDBOOT.SYS',52 dup(?)   ; buffer textu

data     ENDS

; *****************************************************************************
;                     Zav�d�c� sektor pevn�ho disku
; *****************************************************************************
boot     SEGMENT
         ASSUME    cs:boot,ds:boot
                                          ;* Zav�d�c� sektor je um�st�n na
                                          ;* pevn�m disku 0: v�lec 0, hlava 0,
                                          ;* sektor 1. P�i inicializaci se
                                          ;* zavede do pam�ti od adresy
                                          ;* 0000:7c00h
boot0:   cli                                ; z�kaz p�eru�en�
         xor       ax,ax                    ; AX <- 0
         mov       ss,ax                    ; SS <- 0
         mov       sp,7c00h                 ; konec z�sobn�ku (pod t�mto prog.)
         mov       si,sp                    ; SI <- 7c00h
         push      ax
         pop       es                       ; ES <- 0
         push      ax
         pop       ds                       ; DS <- 0
         sti                                ; povolen� p�eru�en�
         cld                                ; sm�r p�enosu nahoru
         mov       di,600h                  ; nov� adresa pro p�enesen� sektoru
         mov       cx,100h                  ; d�lka sektoru ve slovech
         rep       movsw                    ; kopie zavad��e na adresu 0:600h
         db        0eah                     ; instrukce JMP FAR
         dw        offset boot1 + 600h      ; offset adresy v kopii
         dw        0                        ; segment adresy v kopii
boot1:                                    ;* pokra�ov�n� zavad��e v kopii

                                          ;* zde se nalezne prvn� aktivn� odd�l
         mov       si,7beh                  ; tabulka odd�l� pevn�ho disku
         mov       bl,4                     ; po�et odd�l� pevn�ho disku
boot2:   cmp       byte ptr ds:[si],80h     ; je aktivn� odd�l ?
         je        boot3                    ; je aktivn� odd�l
         cmp       byte ptr ds:[si],0       ; je neaktivn� odd�l ?
         jne       boot5                    ; chyba - neplatn� tabulka disku
         add       si,10h                   ; adresa dal��ho odd�lu disku
         dec       bl                       ; ��ta� odd�l�
         jne       boot2                    ; dal�� odd�l
         int       18h                      ; skok na zavad�� BASIC

                                          ;* kontrola ostatn�ch odd�l�
boot3:   mov       dx,ds:[si]               ; po��te�n� hlava a ��slo disku
         mov       cx,ds:[si+2]             ; po��te�n� v�lec a sektor
         mov       bp,si                    ; �schova ukazatele tabulky odd�lu
boot4:   add       si,10h                   ; zv��en� adresy odd�lu
         dec       bl                       ; ��ta� odd�lu
         jz        boot8                    ; v�echny odd�ly - OK
         cmp       byte ptr ds:[si],0       ; je odd�l neaktivn� ?
         jz        boot4                    ; je neaktivn� - OK

boot5:                                    ;* chyba - neplatn� tabulka
         mov       si,offset errpart + 600h ; chyba "Chybn� tabulka disku"
boot6:   lodsb                              ; znak k zobrazen�
         or        al,al                    ; je konec textu ?
         jz        boot7                    ; je konec textu - zablokov�n�
         push      si                       ; �schova ukazatele textu
         mov       bx,7                     ; barva textu b�l� na �ern�m
         mov       ah,0eh
         int       10h                      ; zobrazen� znaku
         pop       si                       ; n�vrat ukazatele textu
         jmp       short boot6              ; zobrazen� dal��ho znaku z textu
boot7:   jmp       short boot7              ; zablokov�n� programu p�i chyb�

                                          ;* na�ten� zav�d�c�ho sektoru disku
boot8:   mov       di,5                     ; po�et pokus� o zaveden� sektoru
boot9:   mov       bx,7c00h                 ; adresa pro na�ten� sektoru
         mov       ax,201h                  ; funkce na�ten� 1 sektoru
         push      di                       ; �schova ��ta�e pokus�
         int       13h                      ; zaveden� 1 sektoru z disku
         pop       di                       ; n�vrat ��ta�e pokus�
         jnc       boota                    ; sektor zaveden OK
         xor       ax,ax                    ; AX <- 0
         int       13h                      ; resetov�n� disku
         dec       di                       ; sn��en� ��ta�e pokus�
         jnz       boot9                    ; dal�� pokus o na�ten� sektoru
bootb:   mov       si,offset errload + 600h ; text "Chyba zaveden� syst�mu"
         jmp       short boot6              ; zobrazen� chybov�ho textu
                                          ;* pokud je zavad��, p�ed�n� ��zen�
boota:   mov       di,7dfeh                 ; adresa identifika�n�ho slova
         cmp       word ptr ds:[di],0aa55h  ; je to zav�d�c� sektor ?
         jne       bootb                    ; nen� - chybov� hl��en�
         mov       si,bp                    ; n�vrat ukazatele tabulky disku
         db        0eah                     ; instrukce JMP FAR
         dw        7c00h                    ; offset zav�d�c�ho sektoru
         dw        0                        ; segment zav�d�c�ho sektoru

errpart  db        'Chybn� tabulka PARTITION',0
errload  db        'Chyba zaveden� syst�mu z disku',0

;         db     80h                  ; zav�d�c� p��znak (80h=aktivn�)
;         db     1                    ; za��tek odd�lu - ��slo hlavy
;         dw     1                    ; za��tek odd�lu - sektor a v�lec
;         db     6                    ; k�d syst�mu FAT (6=
;         db     5                    ; konec odd�lu - ��slo hlavy
;         dw     32d1h                ; konec odd�lu - sektor a v�lec
;         dd     00000011h            ; ��slo po��te�n�ho rel. sektoru
;         dd     00014641h            ; po�et sektor� odd�lu
bootx    label     near

boot     ENDS

; *****************************************************************************
;                              Z�sobn�k
; *****************************************************************************
stack    SEGMENT   stack
         dw        200h dup(?)
stack    ENDS

; *****************************************************************************
;                      Pomocn� buffer pro �ten� souboru
; *****************************************************************************
buffer2  SEGMENT
         db        512 dup(?)               ; buffer pro na�ten� souboru
buffer2  ENDS

; *****************************************************************************
;                      Na�ten� zav�d�c� sektor disku
; *****************************************************************************
buffer   SEGMENT
         db        1000h dup(?)             ; buffer pro na�ten� zav�d. sektoru
buffer   ENDS

         END       hdlock
