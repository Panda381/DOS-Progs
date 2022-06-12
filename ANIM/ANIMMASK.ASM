
; *****************************************************************************
;
;                             A N I M M A S K
;
;                     Sestaven¡ masky souboru form tu SCR
;
; *****************************************************************************

code     segment
         assume    cs:code,ds:code
         org       100h

; ------ zobrazen¡ £vodn¡ho textu

start:   mov       dx,offset UvTxt
         mov       ah,9
         int       21h

; ------ nalezen¡ za‡ tku jm‚na souboru

         cld                                ; smˆr nahoru
         mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         mov       ch,0                     ; CH <- 0
         mov       cl,ds:[80h]              ; po‡et znak–
Start1:  jcxz      Help                     ; soubor nenalezen - chyba
         mov       dx,si                    ; za‡ tek jm‚na souboru
         lodsb                              ; na‡ten¡ znaku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         cmp       al," "                   ; je oddˆlova‡ ?
         jbe       Start1                   ; je oddˆlova‡ - dal¨¡ znak

; ------ nalezen¡ konce jm‚na souboru

Start2:  jcxz      Help                     ; chyba zad n¡
         lodsb                              ; na‡ten¡ znaku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         cmp       al," "                   ; je oddˆlova‡ ?
         ja        Start2                   ; nalezen¡ konce jm‚na
         mov       byte ptr ds:[si-1],0     ; ozna‡en¡ konce textu

; ------ nalezen¡ za‡ tku ‡¡sla barvy pozad¡

Start3:  jcxz      Help                     ; nen¡ dal¨¡ znak - chyba
         lodsb                              ; na‡ten¡ znaku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         cmp       al," "                   ; je oddˆlova‡ ?
         jbe       Start3                   ; je oddˆlova‡ - dal¨¡ znak

; ------ dek¢dov n¡ ‡¡sla barvy pozad¡

         xor       bx,bx                    ; st©ada‡ ‡¡sla
         cmp       al,"x"                   ; ru¨¡ se maska ?
         je        Start33                  ; maska se ru¨¡
         cmp       al,"X"
         jne       Start4
Start33: mov       byte ptr ds:[Zrus],1     ; p©¡znak, ‘e se maska ru¨¡
         jmp       short start54
Start4:  sub       al,"0"                   ; je ‡¡slice ?
         jb        Help                     ; nen¡ ‡¡slice - chyba
         cmp       al,9
         ja        Help                     ; nen¡ ‡¡slice - chyba
         push      ax
         mov       al,10
         mul       bl
         pop       bx
         add       bl,al                    ; nov‚ ‡¡slo
         jcxz      Start5                   ; nen¡ dal¨¡ znak
         lodsb
         dec       cx
         cmp       al," "
         ja        Start4                   ; nen¡ oddˆlova‡ - dal¨¡ znak
Start5:  mov       byte ptr ds:[Barva],bl   ; barva pozad¡

; ------ otev©en¡ zadan‚ho souboru

Start54: mov       ax,3d02h                 ; funkce otev©en¡ souboru
         int       21h                      ; otev©en¡ souboru
         jnc       Start6                   ; soubor otev©en OK

; ------ chyba zad n¡ zdrojov‚ho souboru

Help3:   mov       dx,offset Err1Txt        ; text - chybn˜ soubor
         jmp       short Help1              ; zobrazen¡ chyby

; ------ chyba nedostatku pamˆti

Help4:   mov       dx,offset Err3Txt        ; chyba - nedostatek pamˆti
         jmp       short Help1              ; zobrazen¡ chyby

; ------ chyba zad n¡ - zobrazen¡ n povˆdy

Help:    mov       dx,offset HelpTxt        ; text n povˆdy
Help1:   mov       ah,9
         int       21h                      ; zobrazen¡ n povˆdy
Help2:   mov       ax,4c01h
         int       21h                      ; konec programu s chybou

; ------ na‡ten¡ z hlav¡ souboru

Start6:  mov       ds:[Idents],ax           ; identifik tor souboru
         mov       bx,ax                    ; identifik tor souboru
         mov       dx,offset Zahlavi        ; z hlav¡ souboru
         mov       cx,offset(KonHl-Zahlavi) ; d‚lka z hlav¡
         mov       ah,3fh                   ; funkce ‡ten¡ ze souboru
         int       21h                      ; na‡ten¡ z hlav¡ souboru
Help33:  jc        Help3                    ; chyba ‡ten¡
         cmp       ax,cx                    ; souhlas¡ po‡et bajt– ?
         jne       Help3                    ; chyba ‡ten¡

; ------ kontrola z hlav¡

         cmp       word ptr ds:[Ident],"CS" ; za‡ tek "SCR"
         jne       Help3                    ; nespr vn˜ soubor
         cmp       word ptr ds:[Ident+2],1*256+"R" ; kontrola druh‚ ‡ sti
         jne       Help3                    ; nespr vn˜ soubor
         cmp       byte ptr ds:[Mod],19     ; maxim ln¡ videom¢d displeje
         ja        Help3                    ; nespr vn˜ soubor

; ------ nastaven¡ z sobn¡ku

         mov       ax,ds:[2]                ; konec pamˆti
         sub       ax,1000h                 ; nov˜ segment SS
         mov       ss,ax                    ; nastaven¡ segmentu SS
         mov       sp,0fff8h                ; nov˜ ukazatel z sobn¡ku

; ------ stanoven¡ segmentu vstupn¡ho bufferu

         mov       ax,cs                    ; sou‡asn˜ segment
         mov       bx,offset(Buffer-Start+100h+2000h+15) SHR 4 ; d‚lka programu
         add       ax,bx                    ; segment vstupn¡ho bufferu
         mov       word ptr ds:[SegBuf],ax  ; segment vstupn¡ho bufferu
         mov       dx,ax                    ; po‡ te‡n¡ segment ke ‡ten¡ souboru

; ------ kontrola voln‚ pamˆti (max. KONEC-1000h)

Start7:  mov       ax,ss
         cmp       dx,ax                    ; p©ekro‡en maxim ln¡ konec pamˆti ?
         ja        Help4                    ; chyba - p©ekro‡en konec pamˆti

; ------ na‡ten¡ bloku souboru do pamˆti

         push      dx
         push      ds
         mov       bx,ds:[Idents]           ; identifik tor souboru
         mov       ds,dx                    ; segment k na‡ten¡ bloku ze souboru
         xor       dx,dx                    ; offset ke ‡ten¡ bloku
         mov       cx,0f000h                ; maxim ln¡ velikost bloku ke ‡ten¡
         mov       ah,3fh                   ; funkce ‡ten¡ ze souboru
         int       21h                      ; na‡ten¡ bloku ze souboru
         pop       ds
         pop       dx
         jc        Help33                   ; chyba ‡ten¡

; ------ posun adresy segmentu

         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©epo‡et na odstavce
         add       dx,ax                    ; zv˜¨en¡ ukl dac¡ adresy
         or        ax,ax                    ; bylo nˆco na‡teno ?
         jnz       Start7                   ; bylo nˆco na‡teno - dal¨¡ blok

; ------ posun ukazatele souboru na za‡ tek

         mov       ax,4200h                 ; funkce posunut¡ od za‡ tku
         xor       cx,cx
         xor       dx,dx
         int       21h                      ; posun ukazatele na za‡ tek souboru

; ------ z pis nov‚ho z hlav¡ do souboru

         push      word ptr ds:[Param]      ; £schova parametr– souboru
         and       byte ptr ds:[Param],not 8 ; zru¨en¡ star‚ho p©¡znaku pozad¡
         cmp       byte ptr ds:[Zrus],0     ; ru¨¡ se maska ?
         jne       Start77                  ; maska se ru¨¡
         mov       ax,ds:[Barva]            ; nov  barva
         mov       ds:[Pozadi],ax           ; barva pozad¡
         or        byte ptr ds:[Param],8    ; p©¡znak, ‘e je maska pozad¡
Start77: mov       ah,40h                   ; funkce z pisu na disk
         mov       dx,offset Zahlavi        ; z hlav¡ souboru
         mov       cx,offset(KonHl-Zahlavi) ; d‚lka z hlav¡
         int       21h                      ; z pis nov‚ho z hlav¡ do souboru
         pop       word ptr ds:[Param]      ; n vrat p–vodn¡ho parametru

; ------ textov˜ videom¢d

         mov       al,ds:[Mod]              ; videom¢d souboru
         cmp       al,3
         jbe       Start8                   ; je textov˜ videom¢d
         cmp       al,7
         jne       Start9                   ; nen¡ textov˜ videom¢d
Start8:  call      Txt                      ; konverze textov‚ho videom¢du
         jmp       short Starte

; ------ videom¢d CGA

Start9:  cmp       al,17                    ; je CGA ?
         je        Starta                   ; je CGA
         cmp       al,6
         ja        Startb                   ; nen¡ CGA
         je        Starta
         call      CG4
         jmp       short Starte

Starta:  call      CG6
         jmp       short Starte

; ------ videom¢d EGA

Startb:  cmp       al,18
         ja        Startc                   ; nen¡ EGA
         call      EGA
         jmp       short Starte

; ------ videom¢d MCGA

Startc:  call      MCG                      ; videom¢d 19 = MCGA

; ------ ulo‘en¡ rovin na disk a o©ez n¡ souboru (BH=po‡et rovin)

Starte:  mov       bl,0                     ; ukazatel rovin
Startf:  cmp       bl,bh                    ; jsou ji‘ v¨echny roviny ?
         jae       Starth                   ; jsou ji‘ v¨echny roviny
         mov       cx,ds:[Stranka]          ; d‚lka str nky
         jcxz      Starth                   ; nen¡ nic k ulo‘en¡
         xor       si,si                    ; po‡ te‡n¡ offset
Startg:  call      InpCh                    ; ‡ten¡ bajtu
         call      OutCh                    ; ulo‘en¡ bajtu
         inc       si                       ; zv˜¨en¡ adresy
         loop      Startg                   ; z pis dal¨¡ho bajtu
         inc       bl                       ; zv˜¨en¡ ukazatele rovin
         jmp       short Startf             ; z pis dal¨¡ roviny
Starth:  call      WritBuff                 ; ulo‘en¡ bufferu na disk
         call      WritBuff                 ; useknut¡ konce souboru

; ------ uzav©en¡ souboru

         mov       ah,3eh
         mov       bx,ds:[Idents]           ; identifik tor souboru
         int       21h                      ; uzav©en¡ souboru

; ------ konec programu

         mov       ax,4c00h
         int       21h                      ; konec programu OK

; -----------------------------------------------------------------------------
;        Konverze textov‚ho videom¢du
; -----------------------------------------------------------------------------

PUBLIC   Txt
Txt:
         xor       bh,bh
         ret

; -----------------------------------------------------------------------------
;        Konverze videom¢d– CGA
; -----------------------------------------------------------------------------

PUBLIC   CG4
CG4:

; ------ v˜po‡et d‚lky barevn‚ roviny v bajtech

         mov       ax,ds:[Sirka]            ; ¨¡©ka obr zku (bod–)
         add       ax,3                     ; zaokrouhlen¡ na bajty
         shr       ax,1
         shr       ax,1                     ; p©epo‡et na bajty
         mul       word ptr ds:[Vyska]      ; v˜po‡et po‡tu bajt– na rovinu
         mov       ds:[Stranka],ax          ; po‡et bajt– na rovinu

; ------ pokud se maska ru¨¡, p©esko‡en¡

         cmp       byte ptr ds:[Zrus],0     ; ru¨¡ se maska ?
         jne       CG45                     ; maska se ru¨¡

; ------ registry pro sestaven¡ masky

         xor       si,si                    ; po‡ te‡n¡ ukazatel bajt–
         xor       bl,bl                    ; pouze rovina 0
         xor       bh,bh                    ; st©ada‡ masky

; ------ stanoven¡ masky barvy pozad¡

         mov       dl,byte ptr ds:[Barva]   ; po‘adovan  barva pozad¡
         and       dl,3                     ; maskov n¡ barvy
         mov       al,dl
         shl       dl,1
         shl       dl,1
         or        dl,al
         shl       dl,1
         shl       dl,1
         or        dl,al
         shl       dl,1
         shl       dl,1
         or        dl,al                    ; DL = vzorek barvy pozad¡

; ------ sestaven¡ masky

CG43:    call      InpCh                    ; ‡ten¡ bajtu z roviny BL
         xor       al,dl                    ; porovn n¡ bajtu s maskou barvy
         mov       ah,al                    ; bajt v˜sledku porovn n¡
         and       ah,01010101b
         shl       ah,1                     ; bity budou zdvojenˆ
         or        al,ah                    ; rozd¡ln‚ bity zdvojenˆ
         mov       ah,al
         and       ah,10101010b
         shr       ah,1
         or        al,ah
         call      OutCh                    ; z pis bajtu masku do bufferu
         inc       si                       ; zv˜¨en¡ ukazatele bajt–
         cmp       si,ds:[Stranka]          ; jsou ji‘ v¨echny bajty str nky ?
         jb        CG43                     ; je¨tˆ dal¨¡ bajt

CG45:    mov       bh,1                     ; po‡et rovin pro ulo‘en¡ zbytku
         ret

; -----------------------------------------------------------------------------
;        Konverze videom¢d– CG6
; -----------------------------------------------------------------------------

PUBLIC   CG6
CG6:

; ------ v˜po‡et d‚lky barevn‚ roviny v bajtech

         mov       ax,ds:[Sirka]            ; ¨¡©ka obr zku (bod–)
         add       ax,7                     ; zaokrouhlen¡ na bajty
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©epo‡et na bajty
         mul       word ptr ds:[Vyska]      ; v˜po‡et po‡tu bajt– na rovinu
         mov       ds:[Stranka],ax          ; po‡et bajt– na rovinu

; ------ pokud se maska ru¨¡, p©esko‡en¡

         cmp       byte ptr ds:[Zrus],0     ; ru¨¡ se maska ?
         jne       CG65                     ; maska se ru¨¡

; ------ registry pro sestaven¡ masky

         xor       si,si                    ; po‡ te‡n¡ ukazatel bajt–
         xor       bl,bl                    ; pouze rovina 0
         xor       bh,bh                    ; st©ada‡ masky

; ------ stanoven¡ masky barvy pozad¡

         mov       dl,0                     ; maska pro barvu 0
         test      byte ptr ds:[Barva],1    ; po‘adovan  barva pozad¡ 0 ?
         jz        CG62                     ; po‘aduje se barva pozad¡ 0
         not       dl                       ; maska pro barvu 1
CG62:

; ------ sestaven¡ masky

CG63:    call      InpCh                    ; ‡ten¡ bajtu z roviny BL
         xor       al,dl                    ; porovn n¡ bajtu s maskou barvy
         call      OutCh                    ; z pis bajtu masku do bufferu
         inc       si                       ; zv˜¨en¡ ukazatele bajt–
         cmp       si,ds:[Stranka]          ; jsou ji‘ v¨echny bajty str nky ?
         jb        CG63                     ; je¨tˆ dal¨¡ bajt

CG65:    mov       bh,1                     ; po‡et rovin pro ulo‘en¡ zbytku
         ret


; -----------------------------------------------------------------------------
;        Konverze videom¢d– EGA
; -----------------------------------------------------------------------------

PUBLIC   EGA
EGA:

; ------ v˜po‡et d‚lky barevn‚ roviny v bajtech

         mov       ax,ds:[Sirka]            ; ¨¡©ka obr zku (pozic)
         add       ax,7                     ; zaokrouhlen¡ na bajty
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©epo‡et na bajty
         mul       word ptr ds:[Vyska]      ; v˜po‡et po‡tu bajt– na rovinu
         mov       ds:[Stranka],ax          ; po‡et bajt– na rovinu

; ------ pokud se maska ru¨¡, p©esko‡en¡

         cmp       byte ptr ds:[Zrus],0     ; ru¨¡ se maska ?
         jne       EGA6                     ; maska se ru¨¡

; ------ sestaven¡ masky

         xor       si,si                    ; po‡ te‡n¡ ukazatel bajt–
EGA2:    xor       bl,bl                    ; po‡ te‡n¡ rovina
         xor       bh,bh                    ; st©ada‡ masky
         mov       dl,byte ptr ds:[Barva]   ; po‘adovan  barva pozad¡
EGA3:    call      InpCh                    ; ‡ten¡ bajtu z roviny BL
         shr       dl,1                     ; je rovina obsa‘ena v pozad¡ ?
         jnc       EGA4                     ; rovina nen¡ obsa‘ena v pozad¡
         not       al                       ; inverze bajtu
EGA4:    or        bh,al                    ; st© d n¡ masky
         inc       bl                       ; zv˜¨en¡ ‡¡ta‡e roviny
         cmp       bl,byte ptr ds:[Rovin]   ; jsou ji‘ v¨echny roviny ?
         jb        EGA3                     ; nejsou - je¨tˆ dal¨¡ rovina
         mov       al,bh                    ; nast© dan  maska
         call      OutCh                    ; z pis bajtu masku do bufferu
         inc       si                       ; zv˜¨en¡ ukazatele bajt–
         cmp       si,ds:[Stranka]          ; jsou ji‘ v¨echny bajty str nky ?
         jb        EGA2                     ; je¨tˆ dal¨¡ bajt

EGA6:    mov       bh,byte ptr ds:[Rovin]   ; po‡et rovin pro ulo‘en¡ zbytku
         ret

; -----------------------------------------------------------------------------
;        Konverze videom¢d– MCGA
; -----------------------------------------------------------------------------

PUBLIC   MCG
MCG:
         xor       bh,bh
         ret

; -----------------------------------------------------------------------------
;        €ten¡ bajtu ze zadan‚ roviny (BL=rovina, SI=offset bajtu)
; -----------------------------------------------------------------------------

PUBLIC   InpCh
InpCh:   push      bx
         push      dx
         push      ds

; ------ korekce ‡¡sla roviny, pokud je u‘ maska nadefinovan 

         test      byte ptr cs:[Param],8    ; je maska pozad¡ ?
         jz        InpCh1                   ; nen¡ maska pozad¡
         inc       bl                       ; je o rovinu v¡ce

; ------ v˜po‡et adresy roviny

InpCh1:  mov       bh,0                     ; BX = ‡¡slo roviny
         push      ax
         mov       ax,cs:[Stranka]          ; d‚lka roviny v bajtech
         mul       bx                       ; v˜po‡et offsetu roviny
         add       ax,si                    ; p©i‡ten¡ offsetu ve str nce
         adc       dx,0                     ; p©enos do vy¨¨¡ho slova

; ------ normalizace adresy na segment a offset

         mov       bx,ax                    ; ni‘¨¡ slovo adresy
         and       bx,0fh                   ; normalizovan˜ offset
         shr       dx,1
         rcr       ax,1
         shr       dx,1
         rcr       ax,1
         shr       dx,1
         rcr       ax,1
         shr       dx,1
         rcr       ax,1                     ; v˜po‡et segmentu
         add       ax,cs:[SegBuf]           ; segment vstupn¡ho bufferu
         mov       ds,ax                    ; segment adresy
         pop       ax

; ------ ‡ten¡ bajtu z vypo‡ten‚ adresy

         mov       al,ds:[bx]               ; bajt z vypo‡ten‚ adresy

; ------ n vrat registr–

         pop       ds
         pop       dx
         pop       bx
         ret

; -----------------------------------------------------------------------------
;        Z pis bajtu do v˜stupn¡ho bufferu
; -----------------------------------------------------------------------------

PUBLIC   OutCh
OutCh:   push      si
         mov       si,cs:[NumBuf]           ; ukazatel bajt– v bufferu
         cmp       si,2000h                 ; je buffer ji‘ zaplnˆn ?
         jbe       OutCh2                   ; buffer je¨tˆ nen¡ zaplnˆn

         call      WritBuff                 ; z pis obsahu bufferu na disk
         xor       si,si                    ; nov˜ ukazatel bajt– v bufferu

OutCh2:  mov       cs:[si+Buffer],al        ; ulo‘en¡ bajtu do bufferu
         inc       word ptr cs:[NumBuf]     ; zv˜¨en¡ ‡¡ta‡e bajt– v bufferu
         pop       si
         ret

; -----------------------------------------------------------------------------
;        Ulo‘en¡ v˜stupn¡ho bufferu na disk
; -----------------------------------------------------------------------------

PUBLIC   WritBuff

; ------ £schova registr–

WritBuff:push      ax
         push      bx
         push      cx
         push      dx
         push      ds
         push      cs
         pop       ds

; ------ z pis bufferu na disk

         mov       ah,40h                   ; funkce z pisu na disk
         mov       bx,ds:[Idents]           ; identifik tor souboru
         mov       cx,ds:[NumBuf]           ; po‡et bajt– v souboru
         mov       dx,offset Buffer         ; v˜stupn¡ buffer
         int       21h                      ; z pis bufferu do souboru
         mov       word ptr ds:[NumBuf],0   ; ozna‡en¡ bufferu jako pr zdn˜
         jc        WritBuf2                 ; chyba z pisu
         cmp       ax,cx                    ; bylo zaps no v¨echno ?
         je        WritBuf4                 ; bylo zaps no v¨echno

; ------ chyba z pisu

WritBuf2:mov       ah,3eh                   ; funkce uzav©en¡ souboru
         int       21h                      ; uzav©en¡ v˜stupn¡ho souboru
         mov       dx,offset Err2Txt
         mov       ah,9
         int       21h                      ; zobrazen¡ chybov‚ho textu
         mov       ax,4c01h                 ; funkce ukon‡en¡ programu s chybou
         int       21h                      ; konec programu s chybou

; ------ n vrat registr–

WritBuf4:pop       ds
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        Data
; -----------------------------------------------------------------------------

UvTxt    db        'ANIMMASK V1.0 - sestaveni masky SCR; (c) Miroslav Nemecek',13,10,'$'

HelpTxt  db        'Zadejte jmeno souboru a cislo barvy pozadi (x=zrusit) !',13,10,'$'

Err1Txt  db        'Chybne zadani souboru nebo neplatny format SCR !',13,10,'$'
Err2Txt  db        'Chyba zapisu souboru na disk !',13,10,'$'
Err3Txt  db        'Chyba - nedostatek pameti !',13,10,'$'
; -----------------------------------------------------------------------------
Zahlavi  label     byte                   ;* z hlav¡ souboru SCREEN (d‚lka 16 B)
Ident    db        'SCR'                    ; identifikace souboru displeje
Verze    db        1                        ; verze souboru
Sirka    dw        0                        ; ¨¡©ka v˜©ezu (pozic)
Vyska    dw        0                        ; v˜¨ka v˜©ezu (linek)
Rovin    dw        0                        ; po‡et barevn˜ch rovin
Pozadi   dw        0                        ; barva pozad¡
Palet    dw        0                        ; po‡et bajt– palet
Mod      db        0                        ; videom¢d displeje
Param    db        0                        ; parametry
                                            ;  bit 0: 1=textov˜ videom¢d
                                            ;  bit 1: 1=komprese
                                            ;  bit 2: 1=paraleln¡ barvy
                                            ;  bit 3: 1=je maska pozad¡
KonHl    label     byte                     ; konec z hlav¡

Zrus     db        0                        ; p©¡znak, ‘e se maska ru¨¡

SegBuf   dw        0                        ; segment vstupn¡ho bufferu
Barva    dw        0                        ; barva pozad¡
Stranka  dw        0                        ; d‚lka str nky (v bajtech)
; -----------------------------------------------------------------------------
Idents   dw        0                        ; identifik tor souboru
NumBuf   dw        0                        ; po‡et bajt– ve v˜stupn¡m bufferu
Buffer   label     byte                     ; v˜stupn¡ buffer

code     ends
         end       start
