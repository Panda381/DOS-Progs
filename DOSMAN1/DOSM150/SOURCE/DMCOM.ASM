
; modul DOSMCOM.ASM - komunikace mezi poá°taái
;                   …ÕÕÕÕª                   …ÕÕÕÕª
;  Konektor Canon:  ∫  7 «ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ∂  7 ∫  GND   zem 0 V
;                   ∫  3 «ƒƒƒƒƒƒƒƒ\ /ƒƒƒƒƒƒƒƒ∂  3 ∫  RxD   p©ij°man† data
;                   ∫  2 «ƒƒƒƒƒƒƒƒ/ \ƒƒƒƒƒƒƒƒ∂  2 ∫  TxD   vys°lan† data
;                   ∫  4 «ƒƒø             ⁄ƒƒ∂  4 ∫  RTS   vys°laá p©ipraven
;                   ∫  5 «<ƒŸ             ¿ƒ>∂  5 ∫  CTS   uvolnàn° p©ij°maáe
;                   ∫  6 «<ƒø             ⁄ƒ>∂  6 ∫  DSR   uvolnàn° vys°laáe
;                   ∫ 20 «ƒƒŸ             ¿ƒƒ∂ 20 ∫  DTR   p©ij°maá p©ipraven
;                   ∫ 22 ∫                   ∫ 22 ∫  RI    vòzva
;                   ∫  1 ∫                   ∫  1 ∫  DCD   £rove§ sign†lu
;                   »ÕÕÕÕº                   »ÕÕÕÕº
;                           (nulovò modem)
;
;   Nastaven° MODE:
;
;   mode COMm[:]b,[,p[,d[,s[,r]]]]
;        m = 1,2,3,4
;        b = rychlost 110,150,300,600,1200,2400,4800,9600,19200
;        p = parita N (ë†dn†), O (lich†), E (sud†), M (znaáka), S (mezera)
;        d = datovòch bitñ 5,6,7,8
;        s = stop-bitñ 1, 1.5, 2
;        r = opakov†n° E (chyba), B (zanepr†zdnàn), R (p©ipraven), NONE (neop.)
;
;  mode COM1:110,E,7,1,NONE

;        Komunikaán° protokol:
;
;        1.- Vysl†n° hlaviáky souboru (23 bajtñ)
;
;                1 Bajt : BEL (vòzva k p©°jmu)
;                1 Bajt : SOH (identifik†tor z†hlav°)    ƒƒƒ p©edpona bloku
;                1 Bajty: atributy souboru               ƒƒø
;                8 Bajty: jmÇno souboru                    ≥
;                3 Bajty: p©°pona jmÇna souboru            ≥
;                4 Bajty: velikost souboru                 √ƒ datovò blok 20 B
;                2 Bajty: datum souboru                    ≥
;                2 Bajty: áas souboru                    ƒƒŸ
;                1 Bajt : kontroln° souáet dat           ƒƒƒ kontroln° souáet
;                1 Bajt : ETB (konec z†hlav°)            ƒƒƒ p©°pona bloku
;        2.- Potvrzen° p©ipravenosti
;                                             1 Bajt : ACK (p©ipravenost)
;                                        nebo 1 Bajt : NAK (chyba)
;        3.- Vysl†n° datovÇho bloku
;                1 Bajt : STX (zaá†tek datovÇho bloku)   ƒƒƒ p©edpona bloku
;                n Bajtñ: data                           ƒƒø
;                1 Bajt : kontroln° souáet               ƒƒ¡ƒ datovò blok
;                1 Bajt : ETX (konec souboru)            ƒƒƒ p©°pona bloku
;        4.- Potvrzen° p©ipravenosti
;                                             1 Bajt : ACK (potvrzen° operace)
;                                       resp. 1 Bajt : NAK (chyba operace)
;        5.- Uzav©en° souboru
;                1 Bajt : EOT (konec p©enosu - uzav©en° souboru)
;        6.- Ovà©en° kontroln°ho souátu souboru
;                1 Bajt : ENQ (identifik†tor ovà©en° kontroln°ho souátu)
;                2 Bajty: kontroln° souáet
;                1 Bajt : EOT
;        7.- N†vrat kontroln°ho souátu
;                                             1 Bajt : ACK (kontroln° souáet OK)
;                                        nebo 1 Bajt : NAK (nesouhlas°)
;
; K¢dov†n° dat: SHI - trvalÇ zapnut° p©esmykaáe (p©iá°t† korekci 20h k datñm)
;               SHO - trvalÇ vypnut° p©esmykaáe
;               SUB - p©echodn† zmàna stavu p©esmykaáe k¢du pro 1 znak
; P©esmykaá je na zaá†tku kaëdÇho bloku vypnutò.
;
; PovolenÇ datovÇ znaky: 08h (BS) aë 0dh (CR)
;                        1bh (ESC) aë 0ffh
;
; Ostatn° znaky se povaëuj° za ©°dic° (jsou-li oáek†v†ny, jinak zpñsob° chybu)

; *****************************************************************************
;
;                          Komunikace, p©en†®en° souborñ
;
; *****************************************************************************

code     segment   public
         assume    cs:code,ds:code

TIMEOUT  equ       9                        ; doba pro TIME-OUT 1/2 sekundy

SOH      equ       1                        ; zaá†tek z†hlav°
STX      equ       2                        ; zaá†tek textu
ETX      equ       3                        ; konec textu
EOT      equ       4                        ; konec p©enosu
ENQ      equ       5                        ; ë†dost o spojen°
ACK      equ       6                        ; potvrzen° operace OK
BEL      equ       7                        ; vòzva k p©°jmu

SHO      equ       0eh                      ; vypnut° p©ep°naáe
SHI      equ       0fh                      ; zapnut° p©ep°naáe
;DLE      equ       10h

NAK      equ       15h                      ; p©°znak chybnÇ operace
SYN      equ       16h                      ; synchronizace
ETB      equ       17h                      ; konec p©en†®enÇho bloku
CAN      equ       18h                      ; p©eru®en° spojen° uëivatelem

SUB      equ       1ah                      ; n†hrada znaku

ifdef    upver

extrn    testaktw:near,txtcom3:byte,txtcom5:byte,port:word,volbyh:near
extrn    windretx:near,setwsel:near,outch1:near,podklad:near,wram1:near
extrn    wram2:near,wnadpis:near,stinw:near,txtcom4:byte,testbreak:near
extrn    outbuf:byte,transtxt:near,txtcom6:byte,kurzout:near,msgcek:near
extrn    txtcom1:byte,inpkey:near,getkurz:near,test1file:near,soucins:near
extrn    flagsc:byte,nadpf1:near,nadpfm:near,bufnadp:byte,txtcom2:byte
extrn    storekall:near,storsel:near,aktdir:near,aktuald:near,setfirst:near
extrn    setkurzn:near,setnext:near,rerdir:near,storekur:near,informc:near
extrn    getakt:near,getnakt:near,deledis:near,iniedis:near,selbuf:byte
extrn    txtcom7:byte,txtcom8:byte,txtcom9:byte,txtcoma:byte,txtcomb:byte
extrn    txtcomc:byte,initukaz0:near,topseged:word,dekfile:near,testex:near
extrn    mouseon:near,mouseoff:near,initukaz:near,informz:near,editmax:word
extrn    nulsel:near,outtxt:near,cittout:byte,testkey:near,parbreak:word
extrn    adrpoldi:near,copycl1:near,inpid:word,outid:word,modiukaz:near
extrn    editnum:word,windret:near,inspol:near,modikap:near
extrn    cmppath:near,settabf:near,window:near,storekur:near,storfile:near
extrn    aktokna:near,sumrec:word,txtcomd:byte,zobrchyb:near
extrn    buffrec:byte,writrec:word,readrec:word,oldcom:dword
extrn    adrport:word,maskaint:byte,vyzvycom:byte,cmpdisk:near
extrn    parint2:byte

endif

; -----------------------------------------------------------------------------
;                              P©°jem
; -----------------------------------------------------------------------------
public   prijem

prijem:                                   ;* p©°jem souborñ z komunik. portu
ifndef   upver
         ret
else
                                          ;* volba komunikaán°ho portu
         call      testaktw                 ; je okno aktivn° ?
         jc        prijem6                  ; okno nen° aktivn°
         lea       di,[txtcom3]             ; nadpis pro p©°jem
         call      commport                 ; volba portu
         jc        prijem6                  ; p©eru®en° operace

                                          ;* p©°prava k p©°jmu
         call      aktokna                  ; aktualizace historie oken
         call      iniedis                  ; vytvo©en° p©enosovÇho bufferu
         jc        prijem6d                 ; chyba vytvo©en° bufferu
         call      storekall                ; £schova pozice kurzorñ obou oken
         mov       si,ds:[bp+4]             ; adres†© okna
         call      aktdir                   ; nastaven° aktivn°ho adres†©e okna
         call      testbreak                ; je p©eru®en° operace ?
         jc        prijem5                  ; je p©eru®en° operace
         call      aktuald                  ; aktualizace adres†©e disku
         jc        prijem5                  ; p©eru®en° operace

         or        byte ptr cs:[vyzvycom],80h ; p©°znak, ëe prob°h† p©°jem
         or        byte ptr cs:[parint2],8  ; z†kaz obsluhy hodin
                                          ;* p©°jem jednotlivòch souborñ
prijem2:
         call      prij1f                   ; p©°jem jednoho souboru
         jnc       prijem2                  ; p©°jem OK - dal®° soubor

         and       byte ptr cs:[parint2],not 8 ; zru®en° p©°znaku z†kazu hodin
         and       byte ptr cs:[vyzvycom],not 80h ; zru®en° indikace p©°jmu
                                          ;* aktualizace parametrñ oken

prijem4:
         call      deledis                  ; zru®en° bufferu
         call      windretx                 ; n†vrat zobrazen° oken
         call      cmpdisk
         jne       prijem44                 ; nen° shodnò disk
         call      getnakt
         call      rerdir                   ; nastaven° novÇho naáten° adres†©e
prijem44:call      getakt
         call      rerdir                   ; nastaven° novÇho naáten° adres†©e
prijem5: call      windretx                 ; n†vrat zobrazen° oken
prijem6d:call      deinitport               ; n†vrat portu
prijem6: ret




public   prij1f
prij1f:                                   ;* p©°jem jednoho souboru
         call      flushprij                ; vypr†zdnàn° p©ij°maáe

prij1fa:                                  ;* nav†z†n° spojen°
         sti
                                          ;* hl†®en° o navazov†n° spojen°
prij1f0: call      spojhlas                 ; hl†®en° o navazov†n° spojen°

prij1f1:                                  ;* áek†n° na £vodn° znak
         call      testbreak                ; test p©eru®en° operace
         jc        prij1f9                  ; p©eru®en° operace
         call      prijch                   ; p©°jem £vodn°ho znaku
         jc        prij1f2                  ; chyba - nep©ijat ë†dnò znak
         cmp       al,CAN                   ; je p©eru®en° spojen° ?
         stc
         je        prij1f9                  ; je p©eru®en° spojen°
         cmp       al,EOT
         jne       prij1f11
         mov       al,NAK
         call      potvrd
         jmp       short prij1f1
prij1f11:
         cmp       al,SOH                   ; je to identifik†tor z†hlav° ?
         jne       prij1f2                  ; nen° identifik†tor z†hlav°

                                          ;* p©°jem z†hlav° souboru
         push      es
         mov       es,ds:[topseged]         ; segment k uloëen° z†hlav°
         xor       di,di                    ; offset ukl†dac° adresy
         call      prijtxt                  ; p©°jem textu z†hlav°
         pop       es
         jc        prij1f2                  ; chyba p©°jmu z†hlav°
         cmp       al,ETB                   ; bylo ukonáeno ETB ?
         jne       prij1f2                  ; nebylo z†hlav° souboru
         cmp       cx,20
         je        prij1f3                  ; je z†hlav° souboru

prij1f2:                                  ;* chyba p©°jmu z†hlav° souboru
         jmp       short prij1f1            ; dal®° áek†n°

prij1f3:                                  ;* z†hlav° souboru p©ijato OK
         call      windretx                 ; odstranàn° hl†®en°
prij1f4:
                                          ;* £schova p©ijatÇho z†hlav°
         push      ds
         mov       ds,ds:[topseged]         ; segment s p©ijatòm z†hlav°m
         xor       si,si                    ; adresa z†hlav°
         mov       di,offset outbuf+20      ; z†hlav° p©ij°manÇho souboru
         mov       cx,20
         cld
         rep       movsb                    ; £schova z†hlav° souboru
         pop       ds
         and       ds:[outbuf+20],7fh       ; nulov†n° atributu vòbàru
         or        ds:[outbuf+20],40h       ; atribut doáasnÇho vòbàru

         call      prijfk                   ; p©°jem souboru
         jc        prij1f9                  ; chyba nebo p©eru®en°
         jmp       prij1fa                  ; p©°jem OK - p©°jem dal®°ho souboru

prij1f9: ret


public   prijfk
prijfk:                                   ;* p©°jem souboru ds:[outbuf+20]

         sti                                ; povolen° p©eru®en°
         mov       word ptr ds:[sumrec],0   ; nulov†n° st©adaáe kontr. souátu
                                          ;* p©°prava ukazatelñ
         mov       di,offset outbuf         ; tiskovò buffer
         mov       si,offset outbuf+20      ; p©ij°manò soubor
         call      dekfile                  ; dek¢dov†n° jmÇna souboru
         mov       si,offset outbuf
         mov       di,offset selbuf         ; c°lovò soubor
         call      transtxt                 ; p©enos textu

                                          ;* zobrazen° informaán°ho textu
         call      mouseoff                 ; vypnut° my®i
         call      informc                  ; vymaz†n° informaán°ho ©†dku
         mov       si,offset txtcom8        ; text "P©ij°m†m soubor"
         call      outtxt                   ; zobrazen° £vodn°ho textu
         mov       si,offset outbuf         ; p©°j°manò soubor
         call      outtxt
         mov       si,offset txtcomb        ; text "z portu"
         call      outtxt
         mov       si,offset txtcomc        ; text "COM..."
         call      outtxt
         call      kurzout                  ; vypnut° kurzoru
         call      mouseon                  ; zapnut° my®i

                                          ;* inicializace ukazatele kop°rov†n°
         mov       al,77                    ; konec ukazatele
         sub       al,dl                    ; poáet znakñ do zbytku ©†dku
         jnc       prijfk2                  ; je m°sto na ukazatel
         xor       al,al                    ; nen° ë†dnò volnò znak
prijfk2: mov       si,offset outbuf+20      ; popisovaá souboru
         call      initukaz0                ; inicializace ukazatele

                                          ;* vytvo©en° souboru
         call      msgcek                   ; hl†®en° "áekejte"
ifndef   demo
         mov       ax,4301h
         mov       dx,offset outbuf         ; p©ij°manò soubor
         xor       cx,cx                    ; novÇ atributy
         int       21h                      ; resetov†n° atributñ souboru
         mov       ah,3ch
         xor       cx,cx
         int       21h                      ; vytvo©en° souboru
         jnc       prijfk22                 ; soubor vytvo©en OK
         jmp       prijfk9                  ; chyba vytvo©en° souboru
prijfk22:mov       ds:[outid],ax            ; identifik†tor vòstupn°ho souboru
endif

                                          ;* p©°jem bloku dat souboru

prijfk3:                                  ;* potvrzen° p©ipravenosti
         mov       al,ACK
         call      potvrd                   ; potvrzen° p©ipravenosti
         jc        prijfk7x                 ; chyba
prijfk4:                                  ;* p©°jem jednoho sektoru
         mov       ax,cs:[editmax]          ; velikost bufferu
         mov       di,cs:[editnum]          ; poáet bajtñ v bufferu
         sub       ax,di                    ; velikost zbytku bufferu
         cmp       ax,202h                  ; je dostateánò prostor ?
         ja        prijfk5                  ; je dostateánò prostor
         call      zapisblok                ; z†pis pamàti na disk
         jc        prijfk7x                 ; chyba operace

                                          ;* ignorov†n° p©ijatÇ zpr†vy
         mov       al,NAK
         call      potvrd                   ; p©ijat† zpr†va se ignoruje
         mov       word ptr ds:[writrec],0  ; z†pisov† adresa do bufferu = 0
         mov       word ptr ds:[readrec],0  ; átec° adresa z bufferu = 0

         xor       di,di                    ; nov† ukl†dac° adresa dat

prijfk5:                                   ;* p©°jem jednoho sektoru
         call      prijch                   ; p©°jem £vodn°ho znaku
         jc        prijfk51                 ; chyba p©°jmu
         cmp       al,EOT                   ; konec p©enosu ?
         je        prijfk6                  ; konec souboru
                                          ;* je zase z†hlav° - potvrzen°
         cmp       al,SOH                   ; je zase z†hlav° ?
         jne       prijfk57                 ; nen° z†hlav°
         mov       al,ACK
         call      potvrd                   ; potvrzen° p©ipravenosti
         jmp       short prijfk5            ; dal®° áek†n°

prijfk57:cmp       al,STX                   ; bude to datovò blok ?
         jne       prijfk5                  ; nen° to datovò blok
         push      es
         mov       es,ds:[topseged]         ; segment s daty
         call      prijtxt                  ; p©°jem sektoru dat
         pop       es
         jnc       prijfk52                 ; p©°jem OK
prijfk58:mov       al,NAK
         call      potvrd                   ; chyba p©°jmu
prijfk51:call      testbreak                ; bylo p©eru®en° ?
prijfk7x:jc        prijfk7                  ; bylo p©eru®en° operace
         jmp       short prijfk5            ; byla chyba - znovu
prijfk52:cmp       al,ETX                   ; je oznaáen konec bloku ?
         jne       prijfk58                 ; nen° to datovò blok - znovu
                                          ;* sektor p©ijat OK
prijfk55:add       cs:[editnum],cx          ; zvò®en° dat v pamàti
         mov       ax,cx                    ; poáet zapsanòch bajtñ
         call      modiukaz                 ; modifikace ukazatele
         jmp       short prijfk3            ; dal®i sektor

prijfk6:                                  ;* nastaven° data a áasu souboru
         stc
         call      modiukaz                 ; plnÇ zobrazen° ukazatele kop°rov.
         call      zapisblok                ; vypr†zdnàn° bufferu
         jc        prijfk7
         mov       bx,ds:[outid]            ; vòstupn° soubor
         mov       dx,word ptr ds:[outbuf+20+16] ; datum
         mov       cx,word ptr ds:[outbuf+20+18] ; áas
ifndef   demo
         mov       ax,5701h                 ; funkce nastaven° data a áasu
         int       21h                      ; nastaven° data a áasu souboru
endif
         clc

prijfk7:                                  ;* uzav©en° p©ij°manÇho souboru
ifndef   demo
         pushf
         mov       bx,ds:[outid]            ; identifik†tor vòstupn°ho souboru
         mov       ah,3eh                   ; funkce uzav©en° identifik†toru
         int       21h                      ; uzav©en° vòstupn°ho souboru
         popf
endif
         lea       dx,[selbuf]              ; c°lovò soubor
         jc        prijfk73                 ; je chyba operace - zru®en° souboru

                                          ;* nastaven° atributñ souboru
ifndef   demo
         pushf
         mov       cl,[outbuf+20]           ; atributy pñvodn°ho souboru
         and       cx,27h                   ; ponech†n° norm†ln°ch atributñ
         mov       ax,4301h
         int       21h                      ; nastaven° atributñ souboru
         popf
endif
         jc        prijfk69
ifndef   demo
         or        byte ptr ds:[bp+0],4     ; p©°znak, ëe se adres. nenuluje
         lea       si,[outbuf+20]           ; vkl†dan† poloëka
         call      storekur                 ; £schova pozice kurzoru
         call      storfile                 ; vloëen° novÇ poloëky
         call      settabf                  ; n†vrat pozice kurzoru
         call      window                   ; novÇ zobrazen° okna
endif
         call      modikap                  ; modifikace kapacity disku
         push      bp
         mov       bp,cs:[bp+1]             ; adresa druhÇho okna
ifndef   demo
         call      cmpdisk
         jne       prijfk6c                 ; nen° shodnò disk
         call      cmppath
         jne       prijfk6a
         lea       si,[outbuf+20]           ; vkl†dan† poloëka
         call      storekur                 ; £schova pozice kurzoru
         call      storfile                 ; vloëen° novÇ poloëky
         call      settabf                  ; n†vrat pozice kurzoru
         call      window                   ; novÇ zobrazen° okna
prijfk6a:
endif
         call      modikap                  ; modifikace kapacity o soubor
prijfk6c:pop       bp
         clc
prijfk69:
         jmp       short prijfk9            ; n†vrat z operace



prijfk73:                                 ;* chyba - zru®en° vòstupn°ho souboru
         pushf
ifndef   demo
         mov       ah,41h                   ; funkce ru®en° souboru
         int       21h                      ; zru®en° souboru
endif
         call      getnakt
         call      rerdir
         call      getakt
         call      rerdir
         popf

prijfk9:
         jc        prijfka                  ; byla chyba

                                          ;* áek†n° na kontroln° souáet
prijfka2:call      testbreak                ; test p©eru®en° operace
         jc        prijfka                  ; p©eru®en° operace
         call      prijch                   ; p©°jem £vodn°ho znaku
         jc        prijfka2                 ; chyba - nep©ijat ë†dnò znak
         cmp       al,CAN                   ; je p©eru®en° spojen° ?
         stc
         je        prijfka                  ; je p©eru®en° spojen°
         cmp       al,ENQ                   ; je to identifik†tor dotazu ?
         jne       prijfka2                 ; nen° identifik†tor dotazu

                                          ;* p©°jem kontroln°ho souátu
         push      es
         mov       es,ds:[topseged]         ; segment k uloëen° z†hlav°
         xor       di,di                    ; offset ukl†dac° adresy
         call      prijtxt                  ; p©°jem textu z†hlav°
         mov       bx,es:[0]                ; p©ijatò kontroln° souáet
         pop       es
         jc        prijfka2                 ; chyba p©°jmu kontroln°ho souátu
         cmp       al,EOT                   ; bylo ukonáeno EOT ?
         jne       prijfka2                 ; nebyl kontroln° souáet
         cmp       cx,2                     ; byly 2 bajty ?
         jne       prijfka2                 ; nebyly 2 bajty
                                          ;* odpovàÉ na kontroln° souáet
         cmp       bx,ds:[sumrec]           ; souhlas° kontroln° souáet ?
         mov       al,ACK
         je        prijfka3                 ; kontroln° souáet souhlas°
         mov       al,NAK                   ; nesouhlas°
prijfka3:
         call      potvrd                   ; potvrzen° p©ipravenosti
         call      testbreak
prijfka:
         call      windretx                 ; n†vrat zobrazen° oken
         ret


public   zapisblok
zapisblok:                                ;* z†pis bloku dat na disk
                                            ; VùSTUP: CY=chyba operace, p©eru®en°

         call      sumdat                   ; kontroln° souáet dat v pamàti
         mov       ah,40h                   ; funkce z†pisu do souboru
         mov       bx,ds:[outid]            ; vòstupn° soubor
         mov       cx,ds:[editnum]          ; velikost dat v bufferu
         jcxz      zapblk1                  ; nejsou ë†dn† data v bufferu
         push      ds
         mov       ds,ds:[topseged]         ; segment bloku
         xor       dx,dx                    ; offset v bufferu
ifndef   demo
         int       21h                      ; z†pis bufferu na disk
endif
         pop       ds
         jnc       zapblk2                  ; operace OK
zapblk3: mov       al,CAN
         call      potvrd                   ; p©eru®en° spojen° p©i chybà
         stc                                ; chyba operace, p©eru®en°
         ret
zapblk2: cmp       ax,cx                    ; souhlas° poáet zapsanòch dat ?
         jne       zapblk3                  ; poáet dat nesouhlas°
         call      testbreak                ; je p©eru®en° operace ?
         jc        zapblk1                  ; je p©eru®en° operace
         mov       word ptr cs:[editnum],0  ; poáet bajtñ v bufferu k z†pisu
zapblk1: ret


endif
; -----------------------------------------------------------------------------
;                             Vys°l†n°
; -----------------------------------------------------------------------------
ifdef    upver
public   potvrd
potvrd:                                   ;* vysl†n° znaku potvrzen°
                                            ; VSTUP: AL=znak k vysl†n°
                                            ; VùSTUP: CY=p©eru®en°

         push      cx
         mov       cx,10
potvrd1: call      vysch                    ; vysl†n° znaku AL
         jnc       potvrd2                  ; znak vysl†n OK
         call      testbreak
         jnc       potvrd1                  ; dal®° pokus
         jmp       short potvrd3
potvrd2: loop      potvrd1                  ; dal®° znak
potvrd3: pop       cx
         ret
endif
; -----------------------------------------------------------------------------
public   vysil
vysil:                                    ;* vys°l†n° souborñ

ifdef    upver
                                          ;* test opr†vnànosti poëadavku
         mov       byte ptr ds:[flagsc],0   ; nastaven° typu operace
         call      testaktw                 ; test zapnut° okna
         jc        vysil33                  ; okno je vypnutÇ
         call      getkurz                  ; test, zda je kurzor platnò
         jc        vysil33                  ; kurzor nen° platnò
         call      soucins                  ; seáten° oznaáenòch souborñ
         jnz       vysil3                   ; je oznaáen alespo§ 1 soubor - OK
         or        byte ptr cs:[flagsc],4   ; p©°znak - operace s 1 souborem
         test      byte ptr ds:[si],10h     ; je adres†© ?
         jz        vysil3                   ; nen° adres†© - OK
vysil33: ret

vysil3:                                   ;* zad†n° portu pro vòstup
         push      cs
         pop       ds
         call      vysvolb                  ; volba portu pro vys°l†n°
         jc        vysil33                  ; p©eru®en° operace

                                          ;* inicializace bufferu
         call      aktokna                  ; aktualizace historie oken
         call      iniedis                  ; vytvo©en° p©enosovÇho bufferu
         jc        vysil33d                 ; chyba vytvo©en° bufferu

                                          ;* p©°prava operace
         call      storekall                ; £schova pozice kurzorñ obou oken
         call      storsel                  ; uschov†n° vòbàrñ souborñ
         mov       si,ds:[bp+4]             ; adres†© okna
         call      aktdir                   ; nastaven° aktivn°ho adres†©e okna
         jc        vysil9                   ; je p©eru®en° operace nebo chyba
         call      aktuald                  ; aktualizace adres†©e disku
         jc        vysil9                   ; p©eru®en° operace
         call      setfirst                 ; nastaven° prvn°ho souboru
         jc        vysil9                   ; nen° prvn° soubor
         jmp       short vysil72            ; zpracov†n° prvn°ho souboru

vysil7:  call      setkurzn                 ; nastaven° na dal®° poloëku
         jc        vysil71                  ; je jië konec seznamu
vysil70: call      setnext                  ; nastaven° dal®°ho souboru
vysil72: jc        vysil71                  ; nen° jië dal®° soubor
         call      storekur                 ; £schova pozice kurzoru
         call      vys1f                    ; vysl†n° 1 souboru
         jnc       vysil70                  ; operace OK - dal®° soubor
vysil71:                                  ;* n†vrat parametrñ oken
         mov       al,CAN
         call      potvrd                   ; p©eru®en° spojen°
         call      windretx
         call      cmpdisk
         jne       vysil77                  ; nen° shodnò disk
         call      getnakt
         call      rerdir                   ; nastaven° novÇho naáten° adres†©e
vysil77: call      getakt
         call      rerdir                   ; nastaven° novÇho naáten° adres†©e
vysil9:  call      deledis                  ; zru®en° bufferu
         call      windretx                 ; n†vrat zobrazen° oken
vysil33d:call      deinitport               ; deinicializace portu COM
endif
         ret



ifdef    upver

public   vys1f
vys1f:                                    ;* vysl†n° jednoho souboru
                                            ; VùSTUP: CY=chyba operace

                                          ;* zobrazen° informaán°ho textu
         lea       si,[txtcom7]             ; text "Vys°l†m"
         call      informz                  ; zobrazen° z†kladn°ho inform. ©†dku
         call      mouseoff                 ; vypnut° my®i
         mov       si,offset txtcom9        ; text "na port ..."
         call      outtxt
         call      mouseon                  ; zapnut° my®i
         mov       al,77                    ; konec ukazatele
         sub       al,dl                    ; poáet znakñ do zbytku ©†dku
         jnc       vys1f6                   ; je m°sto na ukazatel
         xor       al,al                    ; nen° ë†dnò volnò znak
vys1f6:  call      initukaz                 ; nastaven° ukazatele kop°rov†n°

         call      vysfk                    ; vys°l†n° souboru pod kurzorem
         jc        vys1f9                   ; chyba operace

         call      nulsel                   ; OK - nulov†n° vòbàru poloëky
vys1f9:
         call      windretx                 ; n†vrat zobrazen° oken
         ret

; -----------------------------------------------------------------------------
;                       Vysl†n° jednoho souboru
; -----------------------------------------------------------------------------
public   vysfk
vysfk:                                    ;* vysl†n° souboru oznaáenÇho kurzorem


;         mov       ah,0dh
;         int       21h                      ; reset diskovÇho systÇmu
         sti                                ; povolen° p©eru®en°
         mov       word ptr cs:[sumrec],0   ; nulov†n° kontroln°ho souátu
                                          ;* otev©en° zdrojovÇho souboru
         lea       dx,[outbuf]              ; zdrojovò soubor
         mov       ax,3d00h                 ; otev©en° pro áten°
         int       21h                      ; otev©en° zdrojovÇho souboru
         jnc       vysfk00
         jmp       vysfka                   ; chyba otev©en° souboru

vysfk00: mov       ds:[inpid],ax            ; identifik†tor vstupn°ho souboru

         call      flushprij                ; vypr†zdnàn° p©ij°maáe

                                          ;* nav†z†n° spojen°
         sti
                                          ;* hl†®en° o navazov†n° spojen°
vysfk0:
         call      spojhlas                 ; hl†®en° o navazov†n° spojen°
         mov       byte ptr cs:[cittout],0  ; p©°znak TIME-OUT
vysfk1:                                   ;* vysl†n° z†hlav° souboru
         call      commtout                 ; je TIME-OUT ?
         jnc       vysfk2                   ; nen° je®tà TIME-OUT

         push      es
         push      di
         push      bx
         mov       al,BEL                   ; vòzva k p©°jmu BEL
         call      vysch                    ; vysl†n° vòzvy BEL
         mov       bx,cs:[bp+11]            ; á°slo souboru s kurzorem
         call      adrpoldi                 ; poskytnut° adresy souboru
         mov       ax,ETB*256+SOH           ; zaá†tek a konec z†hlav°
         mov       cx,20                    ; dÇlka z†hlav°
         call      vystxt                   ; vysl†n° z†hlav°
         pop       bx
         pop       di
         pop       es

                                          ;* p©°jem odpovàdi od protistanice
vysfk2:  call      testbreak                ; test p©eru®en° operace
         jc        vysfk9                   ; je p©eru®en°
         call      prijch                   ; p©°jem znaku
         jc        vysfk1                   ; nen° p©ijat znak OK
         cmp       al,ACK                   ; je potvrzen° p©ipravenosti ?
         jne       vysfk1                   ; nen° oáek†vanò znak ACK

vysfk4:                                   ;* spojen° nav†z†no - bude vys°l†n°
         call      windret                  ; n†vrat zobrazen° okna
vysfk5:
         call      msgcek
         call      testbreak                ; test p©eru®en° operace
         jc        vysfk9                   ; je p©eru®en°
         sti
         cld

vysfk6:                                   ;* vysl†n° bloku dat
         call      ctiblok                  ; áten° bloku dat
         jc        vysfk9                   ; chyba operace - p©eru®en°
         jz        vysfk9                   ; konec operace
         xor       di,di                    ; poá†teán° adresa s daty

vysfk63:                                  ;* vysl†n° jednoho sektoru
         mov       cx,cs:[editnum]          ; poáet bajtñ v bufferu k z†pisu
         sub       cx,di                    ; poáet zbylòch dat
         jbe       vysfk6                   ; naáten° dal®°ho bloku dat
         cmp       cx,80h
         jbe       vysfk64
         mov       cx,80h                   ; omezen° na 128 bajtñ
vysfk64: mov       ax,ETX*256 + STX         ; poá†teán° a koncovò znak
         push      es
         push      di
         mov       es,ds:[topseged]         ; segment s daty
         call      vystxt                   ; vysl†n° bloku dat
         pop       di
         pop       es
         jnc       vysfk65                  ; operace OK - dal®° sektor
         call      testbreak
         jc        vysfk9                   ; p©eru®en° operace
         jmp       short vysfk64            ; opakov†n° vys°l†n°
vysfk65:
                                          ;* áek†n° na p©ipravenost
vysfk66: call      prijch                   ; p©°jem znaku potvrzen° p©°jmu
         jnc       vysfk67
         call      testbreak
         jc        vysfk9                   ; p©eru®en° operace
         call      commtout                 ; je TIME-OUT ?
         jc        vysfk63                  ; je TIME-OUT - opakov†n° sektoru
         jmp       short vysfk66            ; dal®° áek†n° na znak
vysfk67: cmp       al,NAK                   ; negativn° potvrzen°
         je        vysfk63                  ; opakov†n° p©enosu
         cmp       al,ACK                   ; je potvrzen° ?
         jne       vysfk66                  ; nen° potvrzen°
                                          ;* sektor odesl†n
         add       di,cx                    ; zvò®en° adresy v pamàti
         mov       ax,cx                    ; poáet zapsanòch bajtñ
         call      modiukaz                 ; modifikace ukazatele
         jmp       short vysfk63            ; dal®i sektor

vysfk9:  call      copycl1                  ; uzav©en° vys°lanÇho souboru
         pushf
         mov       al,EOT
         call      potvrd                   ; konec souboru
         popf
         jc        vysfka                   ; p©eru®en° operace
                                          ;* potvrzen° kontroln°ho souátu
vysfkb2:
         push      cs
         pop       es
         mov       cx,2                     ; dÇlka kontroln°ho souátu
         mov       ax,EOT*256 + ENQ         ; poá†teán° a koncovò znak
         mov       di,offset sumrec         ; kontroln° souáet
         call      vystxt                   ; vysl†n° kontroln°ho souátu
vysfkb3:                                  ;* áek†n° na potvrzen° kontr. souátu
         call      commtout                 ; je TIME-OUT ?
         jc        vysfkb2                  ; je TIME-OUT
         call      testbreak                ; test p©eru®en° operace
         jc        vysfka                   ; je p©eru®en°
         call      prijch                   ; p©°jem znaku
         jc        vysfkb3                  ; nen° p©ijat znak OK
         cmp       al,ACK                   ; je potvrzen° p©ipravenosti ?
         je        vysfka                   ; kontroln° souáet potvrzen OK
         cmp       al,NAK
         jne       vysfkb3                  ; nen° platnò znak

         pop       ax                       ; zru®en° n†vratovÇ adresy
         jmp       vys1f                    ; opakov†n° vys°l†n°

vysfka:  ret


public   ctiblok
ctiblok:                                  ;* áten° bloku dat z disku
                                            ; VùSTUP: CY=chyba operace, p©eru®en°
                                            ;         ZY=nejsou jië dal®° data
                                            ;         AX=dÇlka naátenÇho bloku

         mov       ah,3fh                   ; funkce áten° ze souboru
         mov       bx,ds:[inpid]            ; vstupn° soubor
         mov       cx,ds:[editmax]          ; velikost bufferu
         push      ds
         mov       ds,ds:[topseged]         ; segment bloku
         xor       dx,dx                    ; offset v bufferu
         int       21h                      ; naáten° bloku dat
         pop       ds
         jc        ctiblk1                  ; chyba operace, p©eru®en°
         call      testbreak                ; je p©eru®en° operace ?
         jc        ctiblk1                  ; je p©eru®en° operace
         mov       cs:[editnum],ax          ; poáet bajtñ v bufferu k z†pisu
         or        ax,ax                    ; poáet naátenòch dat
ctiblk1: call      sumdat                   ; kontroln° souáet dat v pamàti
         ret

; -----------------------------------------------------------------------------
;                       Univerz†ln° podprogramy
; -----------------------------------------------------------------------------
public   sumdat
sumdat:                                   ;* kontroln° souáet dat v pamàti

         pushf
         push      ds
         push      si
         push      cx
         push      ax
         mov       cx,cs:[editnum]          ; poáet dat v pamàti
         mov       ds,ds:[topseged]         ; segment bloku
         xor       si,si                    ; poá†teán° adresa dat v pamàti
         mov       ax,cs:[sumrec]
         jcxz      sumdat2
sumdat1: xor       ah,ds:[si]
         inc       si
         ror       ax,1
         loop      sumdat1
sumdat2: mov       cs:[sumrec],ax
         pop       ax
         pop       cx
         pop       si
         pop       ds
         popf
         ret
; -----------------------------------------------------------------------------
public   spojhlas
spojhlas:                                 ;* hl†®en° o navazov†n° spojen°
         push      cs
         pop       ds
         lea       si,[txtcom4]             ; nadpis
         mov       bx,3                     ; poáet ©†dkñ okna

public   hlaseni
hlaseni:                                  ;* zobrazen° hl†®en° SI

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

         call      setwsel                  ; nastaven° parametrñ okna
         mov       al,7                     ; barva pro okno volby
         call      outch1                   ; nastaven° barvy á°slo 7
         call      podklad                  ; vykreslen° podkladu okna
         call      wram1                    ; zobrazen° vnit©n°ho r†meáku
         call      wram2                    ; zobrazen° vnàj®°ho r†meáku
         call      wnadpis                  ; zobrazen° nadpisu okna
         call      stinw                    ; zobrazen° st°nu okna
         call      kurzout                  ; vypnut° kurzoru

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
vysvolb:                                  ;* volba portu pro vys°l†n°

         mov       di,offset bufnadp        ; nadpis pro vys°l†n°
         push      di
         mov       si,offset txtcom1        ; text "Vy®lu"
         call      transtxt                 ; p©enesen° zaá†tku textu
         call      test1file                ; je pr†ce s kurzorem ?
         jnz       vysvolb2                 ; je 1 soubor
         call      soucins                  ; seáten° oznaáenòch souborñ
         cmp       cx,1                     ; poáet oznaáenòch souborñ
         ja        vysvolb3                 ; je oznaáen v°ce neë 1 soubor
vysvolb2:call      nadpf1                   ; parametr nadpisu pro 1 soubor
         jmp       short vysvolb4
vysvolb3:call      nadpfm                   ; parametr nadpisu pro v°ce souborñ
vysvolb4:mov       si,offset txtcom2        ; text "na komunikaán° port:"
         call      transtxt
         pop       di

                                          ;* volba portu pro vys°l†n°/p©°jem
public   commport
commport:                                 ;* volba portu (DI=nadpis)
         mov       si,offset txtcom5        ; volby pro nastaven° portu
         mov       al,byte ptr ds:[port]    ; p©ednastavenò port
         call      volbyh                   ; volba p©°jmovÇho portu
         call      windretx                 ; n†vrat okna
         jc        commport2                ; p©eru®en° operace
         mov       byte ptr ds:[port],al    ; nastaven° novÇho portu
         add       al,"1"                   ; korekce na znak ASCII
         mov       ds:[txtcom6],al          ; oznaá. portu pro nav†z†n° spojen°
         mov       ds:[txtcoma],al          ; oznaáen° portu pro vys°l†n°
         call      initport                 ; inicializace komun. portu
         jnz       commport2                ; port je nainstalovanò - OK
         mov       si,offset txtcomd        ; text - port nen° nainstalovanò
         call      zobrchyb                 ; zobrazen° chybovÇho hl†®en°
commport2:ret
; -----------------------------------------------------------------------------
public   initport
initport:                                 ;* inicializace komunikaán°ho portu
         push      ax
         push      bx
         push      dx
         push      ds
         push      es
                                          ;* zji®tàn° adresy komunikaán°ho portu
         mov       ax,40h
         mov       ds,ax
         mov       bx,cs:[port]             ; á°slo portu
         add       bx,bx                    ; á°slo portu * 2
         mov       ax,ds:[bx]               ; adresa komunikaán°ho portu
         push      cs
         pop       ds
         mov       ds:[adrport],ax          ; adresa komunikaán°ho portu
         or        ax,ax                    ; je port nainstalovanò ?
         jz        initport2                ; port nen° nainstalovanò
         cli                                ; p©echodnà z†kaz p©eru®en°

                                          ;* zru®en° poëadavkñ od portu
         mov       dx,ax                    ; adresa portu COM
         in        al,dx                    ; zru®en° p©ij°mac°ho bufferu
         inc       dx                       ; ©°dic° registr p©eru®en°
         xor       al,al                    ; AL <- 0
         out       dx,al                    ; z†kaz v®ech p©eru®en°
         add       dx,3                     ; ©°dic° registr modemu
         out       dx,al                    ; z†kaz p©eru®en° a sign†lñ modemu
         inc       dx                       ; stavovò registr linky
         in        al,dx                    ; zru®en° stavovÇho registru linky
         inc       dx                       ; stavovò registr modemu
         in        al,dx                    ; zru®en° stavovÇho registru modemu

                                          ;* inicializace p©ij°mac°ho bufferu
         mov       word ptr ds:[writrec],0  ; z†pisov† adresa do bufferu = 0
         mov       word ptr ds:[readrec],0  ; átec° adresa z bufferu = 0

                                          ;* £schova pñvodn° adresy p©eru®en°
         call      getintcom                ; poskytnut° p©eru®en° COM
         push      ax                       ; £schova á°sla a masky p©eru®en°
         mov       ah,35h
         int       21h                      ; poskytnut° adresy COM
         mov       word ptr ds:[oldcom],bx  ; £schova offsetu adresy p©eru®en°
         mov       word ptr ds:[oldcom+2],es; £schova segmentu adresy p©eru®en°
         pop       ax

                                          ;* nastaven° novÇ adresy p©eru®en°
         push      ax
         mov       ah,25h
         mov       dx,offset intcom         ; adresa obsluhy portu COM
         int       21h                      ; instalace vlastn° obsluhy
         pop       ax

                                          ;* inicializace portu COM
         mov       dx,ds:[adrport]          ; adresa portu
         add       dx,3                     ; ©°dic° registr linky
         mov       al,7                     ; parametry - 8 bitñ bez parity
         out       dx,al                    ; nastaven° 8 bitñ bez parity
         inc       dx                       ; ©°dic° registr modemu
         mov       al,8                     ; pouze sign†l OUT2
         out       dx,al                    ; povolen° p©eru®en° od portu COM
         sub       dx,3                     ; ©°dic° registr p©eru®en°
         mov       al,5                     ; p©eru®en° p©i p©°jmu
         out       dx,al                    ; povolen° p©eru®en° p©i p©°jmu

                                          ;* nastaven° registru p©eru®en°
         in        al,[21h]                 ; áten° masky p©eru®en°
         mov       ds:[maskaint],al         ; £schova masky p©eru®en°
         and       al,ah                    ; povolen° p©eru®en° od portu COM
         out       [21h],al                 ; povolen° p©eru®en°

         or        dx,dx                    ; p©°znak NZ = port nainstalov†n
initport2:
         pop       es
         pop       ds
         pop       dx
         pop       bx
         pop       ax
         sti
         cld
         ret
; -----------------------------------------------------------------------------
public   deinitport
deinitport:                               ;* n†vrat inicializace portu
         push      ax
         push      dx
         push      ds

         call      prerus                   ; p©eru®en° spojen°
         push      cs
         pop       ds
         cli                                ; p©echodnà z†kaz p©eru®en°

                                          ;* n†vrat masky p©eru®en°
         mov       al,ds:[maskaint]         ; pñvodn° maska p©eru®en°
         out       [21h],al                 ; n†vrat masky p©eru®en°

                                          ;* z†kaz p©eru®en° od portu
         mov       dx,ds:[adrport]          ; adresa portu
         in        al,dx                    ; zru®en° p©ijatÇho znaku
         inc       dx                       ; ©°dic° registr p©eru®en°
         xor       al,al                    ; v®echna p©eru®en° zak†z†na
         out       dx,al                    ; z†kaz v®ech p©eru®en°
         inc       dx                       ; stavovò registr p©eru®en°
         in        al,dx                    ; zru®en° stavovÇho registru p©eru®.
         add       dx,2                     ; ©°dic° registr modemu
         xor       al,al                    ; v®echny sign†ly vypnuty
         out       dx,al                    ; vypnut° v®ech sign†lñ modemu
         inc       dx                       ; stavovò registr linky
         in        al,dx                    ; zru®en° stavovÇho registru linky
         inc       dx                       ; stavovò registr modemu
         in        al,dx                    ; zru®en° stavovÇho registru modemu

         call      getintcom                ; poskytnut° p©eru®en° COM
         mov       ah,25h
         lds       dx,ds:[oldcom]           ; pñvodn° adresa INT COM
         int       21h                      ; n†vrat pñvodn° adresy portu

         sti                                ; opàt se povol° p©eru®en°
         pop       ds
         pop       dx
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   getintcom
getintcom:                                ;* poskytnut° á°sla p©eru®en° COM
                                            ; AL=á°slo p©eru®en°,AH=maska p©er.
         mov       ax,0ef0ch                ; maska a p©eru®en° pro COM1 a COM3
         test      byte ptr cs:[port],1     ; je port COM1 nebo COM3 ?
         jz        getintc2                 ; je port COM1 nebo COM3
         mov       ax,0f70bh                ; maska a p©eru®en° pro COM2 a COM4
getintc2:ret
; -----------------------------------------------------------------------------
public   prerus
prerus:                                   ;* p©eru®en° spojen°
         push      ax
         push      cx
         push      dx
         mov       cx,10000                 ; max. poáet pokusñ
         mov       dx,cs:[adrport]
         add       dx,5                     ; stavovò registr portu
prerus2: in        al,dx                    ; áten° stavovÇho registru
         test      al,40h                   ; je vys°laá pr†zdnò ?
         loopz     prerus2                  ; áek†n° na uvolnàn° vys°laáe
         sub       dx,5
         mov       al,CAN
         out       dx,al                    ; vysl†n° znaku CAN
         pop       dx
         pop       cx
         pop       ax
         ret
; -----------------------------------------------------------------------------
;                      Obsluha komunikaán°ho portu
; -----------------------------------------------------------------------------
public   vystxt
vystxt:                                   ;* vysl†n° textu na port
                                            ; VSTUP: AL=£vodn° znak
                                            ;        AH=koncovò znak
                                            ;        ES:DI=adresa dat k vysl†n°
                                            ;        CX=poáet znakñ k vysl†n°
                                            ; VùSTUP:CY=chyba nebo p©eru®en°
                                            ;        ES:DI=nov† adresa dat
         push      cx
         push      dx
         call      flushprij                ; vypr†zdnàn° p©ij°maáe

         call      vysch                    ; vysl†n° £vodn°ho znaku


         jc        vystxt9                  ; chyba vys°laáe
         xor       dx,dx                    ; DL:st©adaá kontroln°ho souátu
                                            ; DH:p©°znak p©esmykaáe



                                          ;* vysl†n° jednoho znaku
         jcxz      vystxt7                  ; konec vys°l†n°
vystxt1: mov       al,es:[di]               ; znak z bufferu
         inc       di                       ; zvò®en° adresy v bufferu
         rol       dl,1                     ; p©°prava pro kontroln° souáet
         xor       dl,al                    ; nastaven° kontroln°ho souátu
         call      vyschk                   ; vysl†n° k¢dovanÇho znaku
         jc        vystxt9                  ; chyba nebo p©eru®en°
         loop      vystxt1                  ; vysl†n° dal®°ho znaku

vystxt7:                                  ;* vysl†n° konce textu
         mov       al,dl                    ; kontroln° souáet
         rol       al,1                     ; p©edrotace pro kontroln° souáet
         call      vyschk                   ; vysl†n° kontroln°ho souátu
         jc        vystxt9                  ; chyba nebo p©eru®en°
         mov       al,ah                    ; koncovò znak
         call      vysch                    ; vysl†n° koncovÇho znaku
vystxt9: call      flushprij                ; vypr†zdnàn° p©ij°maáe
         pop       dx
         pop       cx
         ret
; -----------------------------------------------------------------------------
public   vyschk
vyschk:                                   ;* vysl†n° k¢dovanÇho znaku
                                            ; VSTUP: DH=p©°znak p©esmykaáe
                                            ;           bit 0: 1=p©esm. zapnut
                                            ;        AL=vys°lanò znak
                                            ;        CY=p©eru®en°

         push      ax
         test      dh,1                     ; je trvalò p©esmykaá ?
         jnz       vyschk2                  ; je nastaven p©esmykaá

                                          ;* nen° trvalò p©esmykaá
         call      testctr                  ; test znaku, zda je ©°dic°
         jnc       vyschk6                  ; je norm†ln° znak - jeho vysl†n°
         call      vystest                  ; p©evaëuj° ©°dic° znaky ?
         jnc       vyschk3                  ; ©°dic° znaky nep©evaëuj°
         push      ax
         mov       al,SHI                   ; zapnut° trvalÇho p©esmykaáe
         call      vysch                    ; vysl†n° p©esmykaáe
         pop       ax
         or        dh,1                     ; zapnut° p©°znaku p©esmykaáe
         jc        vyschk9                  ; chyba, p©eru®en°
         jmp       short vyschk3            ; vysl†n° znaku

vyschk2:                                  ;* je trvalò p©esmykaá
         cmp       al,223                   ; je znak > 223 ?
         jbe       vyschk5                  ; je norm†ln° znak - jeho vysl†n°
         call      vystest5                 ; p©evaëuj° znaky > 223 ?
         jnc       vyschk3                  ; nep©evaëuj° znaky > 223
         and       dh,not 1                 ; vypnut° p©°znaku p©esmykaáe
         push      ax
         mov       al,SHO                   ; vypnut° trvalÇho p©esmykaáe
         call      vysch                    ; vysl†n° p©esmykaáe
         pop       ax
         jc        vyschk9                  ; chyba, p©eru®en°

vyschk3:                                  ;* p©echodnÇho zapnut° p©esmykaáe
         test      dh,1                     ; je trvalò p©esmykaá ?
         jz        vyschk4                  ; p©esmykaá je vypnutò
                                          ;* trvalò p©esmykaá je zapnutò
         cmp       al,223                   ; je znak vàt®° neë 223 ?
         jbe       vyschk5                  ; norm†ln° znak - vysl†n° s korekc°
         push      ax
         mov       al,SUB                   ; substituce
         call      vysch
         pop       ax
         jc        vyschk9                  ; p©eru®en°
         jmp       short vyschk6            ; p©echodnà znak bez korekce

vyschk4:                                  ;* trvalò p©esmykaá je vypnutò
         call      testctr                  ; je ©°dic° znak ?
         jnc       vyschk6                  ; nen° ©°dic° znak - norm†ln° znak
         push      ax
         mov       al,SUB                   ; substituce
         call      vysch
         pop       ax
         jc        vyschk9                  ; chyba, p©eru®en°

vyschk5:                                  ;* korekce znaku
         add       al," "                   ; korekce znaku
vyschk6:
         call      vysch                    ; vysl†n° znaku
vyschk9: pop       ax
         ret
; -----------------------------------------------------------------------------
public   vystest
vystest:                                  ;* test obsahu pamàti na ©°dic° znaky
                                            ; VSTUP: AL=prvn° znak (testovanò)
                                            ;        ES:DI=vys°lac° buffer
                                            ; VùSTUP: CY=p©evaëuj° ©°dic° znaky
         push      ax
         push      cx
         push      dx
         push      di
         mov       cx,5                     ; poáet testovanòch bajtñ = 5
         xor       dx,dx                    ; á°taá platnòch znakñ
vystest1:                                 ;* spoá°t†n° ne©°dic°ch znakñ
         call      testctr                  ; test ©°dic°ho znaku
         jc        vystest3                 ; je ©°dic° znak
         inc       dx                       ; á°taá ne©°dic°ch znakñ
vystest3:inc       di                       ; zvò®en° adresy
         mov       al,es:[di]               ; dal®° znak
         loop      vystest1                 ; test dal®°ho znaku
         cmp       dx,3                     ; p©evaëuj° ©°dic° znaky ?
         pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

testctr:                                  ;* test ©°dic°ho znaku
         cmp       al,8                     ; je ©°dic° znak ?
         jb        testctr1                 ; je ©°dic° znak
         cmp       al,0eh                   ; je znak men®° neë SHO (0eh) ?
         cmc
         jnb       testctr1                 ; je platnò znak
         cmp       al,1bh                   ; je platnò znak ?
testctr1:ret

; -----------------------------------------------------------------------------
public   vystest5
vystest5:                                 ;* test obsahu pamàti na znaky > 223
                                            ; VSTUP: AL=prvn° znak (testovanò)
                                            ;        ES:DI=vys°lac° buffer
                                            ; VùSTUP: CY=p©evaëuj° znaky > 223
         push      ax
         push      cx
         push      dx
         push      di
         mov       cx,5                     ; poáet testovanòch bajtñ = 5
         xor       dx,dx                    ; á°taá platnòch znakñ
vystest6:                                 ;* spoá°t†n° znakñ <= 223
         cmp       al,223                   ; je znak ?
         ja        vystest7                 ; nen° znak <= 223
         inc       dx                       ; á°taá znakñ <= 223
vystest7:inc       di                       ; zvò®en° adresy
         mov       al,es:[di]               ; dal®° znak
         loop      vystest6                 ; test dal®°ho znaku
         cmp       dx,3                     ; p©evaëuj° znaky > 223 ?
         pop       di
         pop       dx
         pop       cx
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   prijtxt
prijtxt:                                  ;* p©°jem textu z portu
                                            ; VSTUP: ES:DI=ukl†dac° adresa
                                            ; VùSTUP: CX=poáet znakñ
                                            ;         CY=chyba nebo p©eru®en°
                                            ;         AL=ukonáovac° bajt
                                            ;         ES:DI=nov† ukl†dac° adresa

         push      dx
         xor       cx,cx                    ; á°taá bajtñ
         xor       dx,dx                    ; DL:st©adaá kontroln°ho souátu
                                            ; DH:p©°znak p©esmykaáe
                                          ;* p©°jem jednoho znaku
prijtxt1:cmp       di,cs:[editmax]          ; je jië konec bufferu ?
         cmc
         jb        prijtxt9                 ; je p©eteáen° bufferu
         call      prijchk                  ; p©°jem k¢dovanÇho znaku
         jc        prijtxt9                 ; p©eru®en° nebo TIME-OUT
         je        prijtxt8                 ; konec bloku
         stosb                              ; uloëen° znaku do bufferu
         rol       dl,1                     ; p©°prava pro kontroln° souáet
         xor       dl,al                    ; nastaven° kontroln°ho souátu
         inc       cx                       ; zvò®en° á°taáe znakñ
         jmp       short prijtxt1           ; p©°jem dal®°ho znaku
prijtxt8:                                 ;* konec vàty - test spr†vnosti
         or        dl,dl                    ; je kontroln° souáet = 0 ?
         stc
         jnz       prijtxt9                 ; kontroln° souáet nen° 0 - chyba
         jcxz      prijtxt9                 ; nen° ë†dnò znak - chyba
         dec       cx                       ; zru®en° kontr. souátu v bufferu
         dec       di                       ; sn°ëen° ukl†dac° adresy
         clc                                ; p©°znak - operace OK
prijtxt9:pop       dx
         ret
; -----------------------------------------------------------------------------
public   prijchk
prijchk:                                  ;* p©°jem k¢dovanÇho znaku
                                            ; VSTUP: DH=p©°znak p©esmykaáe
                                            ;           bit 0: 1=p©esm. zapnut
                                            ; VùSTUP: AL=p©ijatò znak
                                            ;         CY=p©eru®en°
                                            ;         NZ=je platnò znak
                                            ;         ZY=©°dic° znak konce

prijchk1:call      prijch                   ; p©°jem znaku
         jc        prijchk9                 ; p©eru®en° nebo TIME-OUT
                                          ;* test konce p©enosu
prijchk2:cmp       al,EOT                   ; konec p©enosu ?
         je        prijchk9                 ; je konec p©enosu
         cmp       al,ETX                   ; konec vàty ?
         je        prijchk9                 ; konec vàty
         cmp       al,ETB                   ; konec bloku ?
         je        prijchk9                 ; konec bloku
         cmp       al,8                     ; spodn° hranice - znak BS
         jb        prijchk9                 ; zak†zanò znak
                                          ;* trvalÇ p©esmykaáe
         cmp       al,SHI                   ; je zapnut° p©esmykaáe ?
         jne       prijchk3                 ; nen° zapnut° p©esmykaáe
         or        dh,1                     ; zapnut° trvalÇho p©esmykaáe
         jmp       short prijchk1           ; p©°jem dal®°ho znaku
prijchk3:cmp       al,SHO                   ; je vypnut° p©esmykaáe ?
         jne       prijchk4                 ; nen° vypnut° p©esmykaáe
         and       dh,not 1                 ; vypnut° trvalÇho p©esmykaáe
         jmp       short prijchk1           ; p©°jem dal®°ho znaku
prijchk4:                                 ;* p©echodnò p©esmykaá
         cmp       al,SUB                   ; je p©echodn† n†hrada znaku ?
         jne       prijchka                 ; nen° n†hrada znaku SUB
         or        dh,2                     ; p©°znak p©echodnÇ n†hrady znaku
         jmp       short prijchk1           ; p©°jem dal®°ho znaku
prijchka:                                 ;* test platnÇho znaku
         cmp       al,0eh                   ; je platnò znak ?
         jb        prijchk5                 ; je platnò znak
         cmp       al,1bh                   ; je platnò znak ?
         jb        prijchk9                 ; je chybnò znak
prijchk5:                                 ;* p©evod znaku
         test      dh,1                     ; je trvalò p©evod znaku ?
         jz        prijchk6                 ; nen° trvalò p©evod znaku
         test      dh,2                     ; je p©echodnÇ vypnut° ?
         jnz       prijchk8                 ; je p©echodnÇ vypnut°
         jmp       short prijchk7           ; p©evod znaku
prijchk6:test      dh,2                     ; je p©echodnÇ zapnut° ?
         jz        prijchk8                 ; nen° p©echodnÇ zapnut°
prijchk7:                                 ;* je p©evod znaku
         sub       al," "                   ; korekce znaku
prijchk8:and       dh,not 2                 ; zru®en° p©°znaku p©echodnÇ zmàny
         cmp       dh,0ffh                  ; nastaven° p©°znaku NZ
         clc                                ; p©°znak znaku OK
prijchk9:
         ret
; -----------------------------------------------------------------------------
public   testprij
testprij:                                 ;* test p©°jmu znaku
                                            ; VùSTUP: CY=nen° p©ipraven znak

         push      ax
         push      dx
         sti                                ; povolen° p©eru®en° pro p©°jem
                                          ;* test p©ipravenosti modemu
         mov       dx,cs:[adrport]          ; adresa komunikaán°ho portu
         add       dx,4                     ; ©°dic° registr modemu
         mov       al,9
         out       dx,al                    ; vòzva k vys°l†n° dat
         mov       ax,cs:[readrec]          ; ukazatel pro áten° z bufferu
         cmp       ax,cs:[writrec]          ; jsou nàjak† data ?
         clc

;         mov       dx,cs:[port]             ; á°slo komunikaán°ho portu
;         mov       ax,300h
;         int       14h                      ; dotaz na stav sÇriovÇho portu
;         test      ah,1                     ; jsou data p©ipravena ?

testpri1:jnz       testpri2                 ; data jsou p©ipravena
testpri3:call      testbreak                ; test p©eru®en°
         stc                                ; p©°znak - nen° p©ipraven znak
testpri2:pop       dx
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   testvys
testvys:                                  ;* test vysl†n° znaku
                                            ; VùSTUP: CY=vys°laá nen° p©ipraven

         push      ax
         push      dx

         mov       dx,cs:[adrport]          ; adresa portu COM
         add       dx,4                     ; ©°dic° registr modemu
         mov       al,0bh
         out       dx,al                    ; ozn†men° o vys°l†n° dat
         add       dx,2                     ; stavovò registr modemu
         in        al,dx                    ; áten° stavovÇho registru modemu
         test      al,10h                   ; je moënÇ vys°lat ?
         jz        testpri3                 ; nen° moënÇ vys°lat
         dec       dx                       ; stavovò registr linky
         in        al,dx                    ; áten° stavovÇho registru linky

;         mov       dx,cs:[port]             ; á°slo komunikaán°ho portu
;         mov       ax,300h
;         int       14h                      ; dotaz na stav sÇriovÇho portu
         test      al,20h                   ; je vys°lac° buffer pr†zdnò ?
         jmp       short testpri1
; -----------------------------------------------------------------------------
public   flushprij
flushprij:                                ;* vyái®tàn° p©ij°maáe
         pushf
         push      ax
flushp1: call      testprij                 ; test p©ij°maáe
         jc        flushp2                  ; nen° p©ipraven dal®° znak
         call      prijch                   ; zru®en° znaku z bufferu
         jnc       flushp1                  ; znak p©ijat OK
flushp2: pop       ax
         popf
         ret
; -----------------------------------------------------------------------------
public   prijch
prijch:                                   ;* p©°jem znaku
                                            ; VùSTUP: AL=p©ijatò znak
                                            ;         CY=TIME-OUT nebo BREAK

         push      dx
         push      ax
         mov       byte ptr cs:[cittout],TIMEOUT ; TIME-OUT 1/2 sekundy
         xor       ax,ax                    ; p©ednastaven° p©ijatÇho znaku
prijch1: call      commbreak                ; test - je p©eru®en° BREAK ?
         jc        prijch3                  ; je p©eru®en°
         call      commtout                 ; test - je TIME-OUT ?
         jc        prijch3                  ; je TIME-OUT
         call      testprij                 ; test p©°jmu znaku
         jc        prijch1                  ; nen° p©ipraven p©ijatò znak
                                          ;* áten° znaku z bufferu
         push      bx
         mov       bx,cs:[readrec]          ; átec° adresa z bufferu
         mov       al,cs:[bx+buffrec]       ; p©eáten° znaku z bufferu
         call      incukaz                  ; zvò®en° ukazatele BX
         mov       cs:[readrec],bx          ; nov† átec° adresa z bufferu
         pop       bx

;         mov       dx,cs:[port]             ; á°slo komunikaán°ho portu
;         mov       ah,2
;         int       14h                      ; p©°jem znaku z portu
;         test      ah,80h                   ; je TIME-OUT ?
;         jnz       prijch2                  ; je TIME-OUT

         cmp       al,BEL                   ; je vòzva od protistanice ?
         jne       prijch4                  ; nen° vòzva od protistanice
         test      byte ptr cs:[vyzvycom],80h ; prob°h† obsluha p©°jmu ?
         jnz       prijch4                  ; prob°h† obsluha p©°jmu
         or        byte ptr cs:[vyzvycom],40h ; nastaven° p©°znaku vòzvy
prijch4:
         cmp       al,CAN                   ; je p©eru®en° od protistanice ?
         clc                                ; p©°znak p©°jmu OK
         jne       prijch3                  ; nen° p©eru®en° od protistanice
         int       23h                      ; nastaven° p©°znaku p©eru®en°
prijch2: stc                                ; p©°znak p©eru®en°/TIME-OUT
prijch3: mov       dl,al                    ; £schova p©ijatÇho znaku
         pop       ax
         mov       al,dl                    ; p©ijatò znak
         pop       dx

         ret
; -----------------------------------------------------------------------------
public   vysch
vysch:                                    ;* vysl†n° znaku
                                            ; VSTUP: AL=znak k vysl†n°
                                            ; VùSTUP: CY=BREAK nebo TIME-OUT

         push      dx
         push      ax
         mov       byte ptr cs:[cittout],TIMEOUT ; TIME-OUT 1/2 sekundy

vysch1:  call      commbreak                ; test - je p©eru®en° BREAK ?
         jc        vysch3                   ; je p©eru®en°
         call      commtout                 ; test - je TIME-OUT ?
         jc        vysch3                   ; je TIME-OUT
         call      testvys                  ; test pr†zdnÇho vys°lac°ho bufferu
         jc        vysch1
                                          ;* vysl†n° znaku na port
         mov       dx,cs:[adrport]          ; adresa portu
         out       dx,al                    ; vysl†n° znaku na port

;         mov       dx,cs:[port]             ; á°slo komunikaán°ho portu
;         mov       ah,1
;         int       14h                      ; vysl†n° znaku na port
;         test      ah,80h                   ; je TIME-OUT ?
;         jz        vysch3                   ; nen° TIME-OUT
;         stc                                ; p©°znak TIME-OUT

vysch3:  pop       ax
         pop       dx
         ret
; -----------------------------------------------------------------------------
public   commbreak
commbreak:                                ;* test BREAK
                                            ; VùSTUP: CY=je BREAK

         cmp       word ptr cs:[parbreak],0 ; je p©eru®en° ?
         jne       commtou1                 ; je p©eru®en°
commbrk1:clc
         ret
; -----------------------------------------------------------------------------
public   commtout
commtout:                                 ;* test TIME-OUT
                                            ; VùSTUP: CY=je TIME-OUT

         cmp       byte ptr cs:[cittout],0  ; je TIME-OUT ?
         jne       commbrk1                 ; nen° TIME-OUT
commtou1:stc                                ; je TIME-OUT
         ret
; -----------------------------------------------------------------------------
public   incukaz
incukaz:                                  ;* zvò®en° adresy BX p©ij°mac°ho buff.
         inc       bx
         cmp       bx,200
         jb        incukaz2
         xor       bx,bx
incukaz2:ret
; -----------------------------------------------------------------------------
public   intcom
intcom:                                   ;* p©eru®en° od komunikaán°ho portu

         push      ax
         push      bx
         push      dx
                                          ;* prvn° áten° stav. reg. p©eru®en°
         mov       dx,cs:[adrport]          ; adresa komunikaán°ho portu
         add       dx,2                     ; adresa stav. registru p©eru®en°
         in        al,dx                    ; áten° stav. registru p©eru®en°
         jmp       short intcom2            ; test, zda je znak
                                          ;* opakovan† áten° reg. p©eru®en°
intcom1: mov       dx,cs:[adrport]          ; adresa komunikaán°ho portu
         add       dx,2                     ; adresa stav. registru p©eru®en°
         in        al,dx                    ; áten° stav. registru p©eru®en°
         test      al,1                     ; je p©ipraveno dal®° p©eru®en° ?
         jnz       intcom4                  ; nen° p©ipraveno dal®° p©eru®en°
                                          ;* bylo p©eru®en° p©i p©°jmu ?
intcom2: cmp       al,4                     ; je p©eru®en° p©ijatòmi daty ?
         jne       intcom3                  ; nebyla p©ijata data
         sub       dx,2                     ; datovò registru komunik. portu
         in        al,dx                    ; áten° p©ijatòch dat
                                          ;* uloëen° znaku do bufferu
         mov       bx,cs:[writrec]          ; z†pisov† adresa do bufferu
         mov       cs:[buffrec+bx],al       ; uloëen° znaku do bufferu
         call      incukaz                  ; zvò®en° ukazatele BX
         mov       cs:[writrec],bx          ; nov† ukl†dac° adresa
                                          ;* zru®en° staròch dat p©i p©eteáen°
         mov       bx,cs:[readrec]          ; átec° adresa z bufferu
         cmp       bx,cs:[writrec]          ; je p©eteáen° bufferu ?
         jne       intcom1                  ; nen° p©eteáen° bufferu
         call      incukaz                  ; zvò®en° átec° adresy
         mov       cs:[readrec],bx          ; nov† átec° adresa
         jmp       short intcom1            ; zji®tàn°, zda je dal®° poëadavek
                                          ;* zru®en° stavovÇho registru linky
intcom3: add       dx,3                     ; stavovò registr linky
         in        al,dx                    ; zru®en° poëadavku stav. registru
         jmp       short intcom1            ; zji®tàn°, zda je dal®° poëadavek
                                          ;* n†vrat z obsluhy p©eru®en°
intcom4: mov       al,20h
         out       [20h],al                 ; uvolnàn° ©adiáe p©eru®en°
         sti                                ; povolen° p©eru®en°
         pop       dx
         pop       bx
         pop       ax
         iret
; -----------------------------------------------------------------------------
endif

public   vyzvy
vyzvy:                                    ;* testov†n° vòzev od portñ COM
ifdef    upver
         push      ax
         push      bx
         push      cx
         push      dx
         push      ds

         mov       cx,4                     ; poáet portñ COM
         mov       al,cs:[vyzvycom]         ; vòzvy od komunikaán°ch portñ
         test      al,80h                   ; prob°h† obsluha p©°jmu ?
         jnz       vyzvy6                   ; prob°h† obsluha p©°jmu
         xor       bx,bx                    ; á°slo portu COM
vyzvy1:  test      al,1                     ; m† bòt p©°jem vòzvy ?
         jz        vyzvy5                   ; nen° p©°jem vòzvy
                                          ;* testov†n° jednoho portu
         push      ax
         mov       ax,40h
         mov       ds,ax
         mov       ax,ds:[bx]               ; adresa portu COM
         or        ax,ax                    ; je port definov†n ?
         jz        vyzvy4                   ; port nen° definov†n
         mov       dx,ax                    ; adresa portu
         push      dx
         add       dx,3                     ; ©°dic° registr linky
         mov       al,7
         out       dx,al                    ; nastaven° ©°dic°ho registru
         add       dx,2                     ; stavovò registr linky
         in        al,dx                    ; áten° stavovÇho registru linky
         pop       dx
         test      al,1                     ; je p©ijatò nàjakò znak ?
         jz        vyzvy4                   ; nen° p©ijat ë†dnò znak
         in        al,dx                    ; p©°jem znaku
         cmp       al,BEL                   ; je vòzva ?
         jne       vyzvy4                   ; nen° vòzva
         or        byte ptr cs:[vyzvycom],40h ; indik†tor vòzvy
         mov       ax,bx                    ; á°slo portu * 2
         shr       ax,1                     ; á°slo portu COM
         mov       cs:[port],ax             ; p©ednastaven° á°sla portu COM
vyzvy4:  pop       ax

vyzvy5:  shr       al,1                     ; rotace dal®°ho portu
         add       bx,2                     ; zvò®en° ukazatele portñ
         loop      vyzvy1                   ; dal®° port COM

vyzvy6:  pop       ds
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

endif
         ret

code     ends

         end
