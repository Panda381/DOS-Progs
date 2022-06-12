
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
; ±±±±±±                 ÚÄÄÄÄÄÄÄÄ¿     ÚÄ¿       ÚÄ¿                    ±±±±±±
; ±±±±±±                 ³ ÚÄÄÄÄ¿ À¿    ³ À¿     ÚÙ ³                    ±±±±±±
; ±±±±±±                 ³ ³    À¿ À¿   ³  À¿   ÚÙ  ³                    ±±±±±±
; ±±±±±±                 ³ ³     À¿ À¿  ³ Ú¿À¿ ÚÙÚ¿ ³                    ±±±±±±
; ±±±±±±                 ³ ³      ³  ³  ³ ³À¿ÀÄÙÚÙ³ ³                    ±±±±±±
; ±±±±±±                 ³ ³     ÚÙ ÚÙ  ³ ³ ÀÄÄÄÙ ³ ³                    ±±±±±±
; ±±±±±±                 ³ ³    ÚÙ ÚÙ   ³ ³       ³ ³                    ±±±±±±
; ±±±±±±                 ³ ÀÄÄÄÄÙ ÚÙ    ³ ³       ³ ³                    ±±±±±±
; ±±±±±±                 ÀÄÄÄÄÄÄÄÄÙ     ÀÄÙ       ÀÄÙ                    ±±±±±±
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
; ±±±±±±±±±±±±±±±±±±±±±±±±±± >>   DOS Mana‘er   << ±±±±±±±±±±±±±±±±±±±±±±±±±±±±
; ±±±±±±±±±±±±±±±±±±±±±±±±±± podpora u‘ivatele DOS ±±±±±±±±±±±±±±±±±±±±±±±±±±±±
; ±±±±±±±±±±±±±±±±±±±±±±±±±± (c) Miroslav Nˆme‡ek  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                                    D  M
;
;                        hlavn¡ procedura DOS Mana‘eru
;
;         Tento modul mus¡ b˜t p©ilinkov n jako posledn¡ modul !
;
; Pozor: Turbo Assembler vy¨¨¡ verze ne‘ 1.00 nahrazuje instrukci
;
;                CALL     FAR PTR JUMPBX
; instrukcemi
;                PUSH     CS
;                CALL     NEAR PTR JUMPBX
;                NOP
;
; - provedeno opat©en¡: 1. bajt v tabulce nesm¡ b˜t 90h !
;
; Zmˆna - nastaven¡m parametru "TASM /m5" se odstranila nadbyte‡n  instrukce NOP
;
; =============================================================================
;
; Ve©ejn‚ procedury:
;
;        Start          - start programu
;        Konec          - konec programu
;
; -----------------------------------------------------------------------------
; n vratov‚ k¢dy programu:
;        0 = je proveden¡ povelu v BAT m¢du
;        1 = © dn‚ ukon‡en¡ programu
;        2 = ukon‡en¡ programu s chybou (chyba pamˆti)
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°


INCLUDE  ASM\DEF.ASM

Code     SEGMENT   WORD PUBLIC
         ASSUME    cs:Code,ds:Data

; -----------------------------------------------------------------------------
;                   prvn¡ start a inicializace programu
;    v t‚to ‡ sti je¨tˆ nen¡ p©¡stup na disk, neinstaluj¡ se ani p©eru¨en¡ !
; -----------------------------------------------------------------------------
; P©i startu pomoc¡ PKLITE!!.EXE s £pravou DMPKLITE.COM ukazuj¡ registry
; DI:SI na buffer 2*24 bajt– se jm‚nem u‘ivatele a jm‚nem firmy.
; Na adrese AX:2 je tabulka 25 bajt– licen‡n¡ho ‡¡sla.
; -----------------------------------------------------------------------------

Old03    dd        0                        ; uchovan  adresa INT 03h
Int3:    iret                               ; obsluha INT 3 pro debugger

Start    LABEL     FAR

; ------ zni‡en¡ adresy INT 3

; Zruseno u FREEWARE verze 2.20

;IFNDEF   DEBUG
;         xor       bx,bx                    ; BX <- 0
;         mov       ds,bx                    ; DS <- 0
;
;         push      word ptr ds:[bx+3*4]
;         push      word ptr ds:[bx+3*4+2]   ; p–vodn¡ adresa INT 03h
;
;         mov       ds:[bx+3*4+2],cs         ; segment programu
;         mov       word ptr ds:[bx+3*4],offset Int3 ; obsluha INT 3 (= IRET)
;
;         pop       word ptr cs:[bx+Old03+2] ; £schova adresy INT 03h
;         pop       word ptr cs:[bx+Old03]
;ENDIF

; ------ inicializace segmentov˜ch registr–

         sti
         mov       bx,SEG Data              ; datov˜ segment
         mov       ds,bx                    ; DS <- datov˜ segment
         mov       ds:[SegPSP],es           ; £schova segmentu PSP

; Zruseno u FREEWARE verze 2.20

;         cmp       ax,bx                    ; jsou licen‡n¡ data ?
;         ja        Strt1012                 ; jsou licen‡n¡ data OK
         jmp       Start114                 ; p©esko‡en¡ testu licence

; ------ £schova inicializa‡n¡ch licen‡n¡ch dat ze z hlav¡ PKLITE

Strt1012:push      ds
         pop       es                       ; ES <- datov˜ segment

         push      ds                       ; datov˜ segment

         push      si                       ; offset licen‡n¡ch dat
         push      di                       ; segment licen‡n¡ch dat

         mov       ds,ax                    ; DS <- segment licen‡n¡ch dat
         mov       si,2                     ; offset po‡ tku dat
         mov       di,offset LicDat         ; buffer
         mov       cx,23                    ; d‚lka dat
         cld
         rep       movsb                    ; £schova dat

         pop       ds                       ; DS <- segment dat
         pop       si                       ; SI <- offset dat

; ------ £schova licen‡n¡ch dat u‘ivatele

         mov       di,offset LicJmeno
         mov       cx,32
         rep       movsb
         mov       di,offset LicAdres
         mov       cl,32
         rep       movsb
         mov       di,offset LicMesto
         mov       cl,32
         rep       movsb
         mov       di,offset LicICO
         mov       cl,32
         rep       movsb

         pop       ds                       ; datov˜ segment

; ------ odk¢dov n¡ licen‡n¡ch dat

         mov       ax,ds:[LicDKod]          ; k¢dovac¡ maska
         mov       si,offset LicDKod+2      ; za‡ tek dat
         mov       dx,23-2                  ; d‚lka dat
Strt1013:mov       cl,al                    ; k¢dovac¡ maska
         and       cl,7                     ; po‡et rotac¡
         ror       byte ptr ds:[si],cl
         xor       ds:[si],ah
         add       ax,0b4e3h
         ror       ax,1

         inc       si
         dec       dx
         jnz       Strt1013

; ------ odk¢dov n¡ licen‡n¡ch text–

         mov       ax,ds:[LicDKod]          ; k¢dovac¡ maska
         mov       si,offset LicJmeno       ; licen‡n¡ jm‚no
         call      StOdkLn                  ; odk¢dov n¡ licen‡n¡ho jm‚na
         mov       si,offset LicAdres       ; licen‡n¡ adresa
         call      StOdkLn                  ; odk¢dov n¡ licen‡n¡ adresy
         mov       si,offset LicMesto       ; licen‡n¡ mˆsto
         call      StOdkLn                  ; odk¢dov n¡ licen‡n¡ho mˆsta
         mov       si,offset LicICO         ; licen‡n¡ I€O
         call      StOdkLn                  ; odk¢dov n¡ licen‡n¡ho I€O

; ------ kontrola kontroln¡ho sou‡tu licen‡n¡ch dat

Strt1019:cld
         mov       si,offset LicDNum        ; buffer licen‡n¡ch dat
         mov       cx,23-4                  ; po‡et bajt–
         mov       dx,65a1h                 ; v˜choz¡ hodnota CRC
Start102:lodsb
         xor       dl,al
         ror       dx,1
         loop      Start102
         sub       word ptr ds:[LicDCRC],dx ; kontrola kontroln¡ho sou‡tu
         jz        Start104                 ; kontroln¡ sou‡et je OK
Start103:or        byte ptr ds:[LicDPar0],bit0 ; chyba CRC
Strt1032:jmp       Start114                 ; kontroln¡ sou‡et nesouhlas¡

; ------ odk¢dov n¡ licen‡n¡ho textu

StOdkLn  PROC      NEAR

         mov       dx,32                    ; d‚lka jm‚na
StOdkLn2:mov       cl,al                    ; k¢dovac¡ maska
         and       cl,7                     ; po‡et rotac¡
         ror       byte ptr ds:[si],cl
         xor       ds:[si],ah
         add       ax,3e4bh
         ror       ax,1

         inc       si
         dec       dx
         jnz       StOdkLn2
         ret

StOdkLn  ENDP

StSumLn  PROC      NEAR

         mov       cx,32                    ; d‚lka jm‚na
StSumLn2:lodsb
         cmp       al,0
         jne       StSumLn4
         mov       byte ptr ds:[si-1]," "
StSumLn4:xor       dl,al
         rol       dx,1
         loop      StSumLn2
         ret

StSumLn  ENDP

; ------ kontrola kontroln¡ho sou‡tu licen‡n¡ch text–

Start104:mov       dx,1a56h                 ; v˜choz¡ hodnota CRC

         mov       si,offset LicJmeno       ; licen‡n¡ jm‚no
         call      StSumLn                  ; kontroln¡ sou‡et jm‚na
         mov       si,offset LicAdres       ; licen‡n¡ adresa
         call      StSumLn                  ; kontroln¡ sou‡et adresy
         mov       si,offset LicMesto       ; licen‡n¡ mˆsto
         call      StSumLn                  ; kontroln¡ sou‡et mˆsta
         mov       si,offset LicICO         ; licen‡n¡ I€O
         call      StSumLn                  ; kontroln¡ sou‡et I€O

         cmp       dx,ds:[LicDCrcT]         ; souhlas¡ kontroln¡ sou‡et ?
         jne       Start103                 ; CRC nesouhlas¡

; ------ test, zda se m  prov dˆt kontrola instalace

         test      byte ptr ds:[LicDPar],bit0+bit3+bit5 ; prov d¡ se kontrola ?
Strt1062:jz        Strt1032                 ; kontrola se neprov d¡

; ------ kontrola BIOS

         test      byte ptr ds:[LicDPar],bit0 ; uschov n BIOS ?
         jz        Strt1065                 ; nen¡ uschov n BIOS

         push      ds
         mov       ax,0f000h                ; segment ROM BIOS
         mov       ds,ax                    ; adresa ROM BIOS
         mov       si,0fff5h                ; datum v BIOS
         mov       cx,8                     ; po‡et bajt– pro kontrolu
         mov       ah,"D"                   ; v˜choz¡ hodnota pro sou‡et
         cld
Strt1063:lodsb                              ; na‡ten¡ bajtu
         add       ah,al                    ; p©i‡ten¡ ke st©ada‡i
         loop      Strt1063                 ; dal¨¡ bajt
         pop       ds
         cmp       ah,ds:[LicDBios]         ; souhlas¡ BIOS ?
         je        Strt1062                 ; BIOS souhlas¡ OK

; ------ p©¡prava domovsk‚ho adres ©e

Strt1065:call      far ptr NulBreak         ; nulov n¡ p©¡znaku p©eru¨en¡
         mov       ah,19h
         int       21h                      ; poskytnut¡ aktivn¡ho disku
         add       al,"A"                   ; ozna‡en¡ disku ASCII
         mov       ah,":"                   ; oddˆlova‡ ozna‡en¡ disku
         mov       di,offset HomeDir+2      ; domovsk˜ adres ©
         mov       ds:[di-2],ax             ; ozna‡en¡ disku

         push      ds
         pop       es                       ; ES <- datov˜ segment

         push      ds

         mov       ds,ds:[SegPSP]           ; segment PSP
         mov       ds,ds:[2ch]              ; segment prost©ed¡
         mov       bx,di                    ; BX <- £schova konce cesty
         xor       si,si                    ; ukazatel v prost©ed¡
         cld
Start107:inc       si                       ; zv˜¨en¡ ukazatele v prost©ed¡
         js        Start109                 ; p©ete‡en¡
         cmp       word ptr ds:[si-1],0     ; je konec prost©ed¡ ?
         jne       Start107                 ; nalezen¡ konce prost©ed¡
         inc       si                       ; za‡ tek po‡tu ©etˆzc–
         inc       si
         inc       si                       ; za‡ tek cesty
         mov       cx,FileMax-4             ; max. d‚lka bufferu
         cmp       byte ptr ds:[si+1],":"   ; je zad n disk ?
         jne       Start108                 ; nen¡ zad n disk
         dec       di
         dec       di                       ; n vrat na za‡ tek bufferu
Start108:lodsb                              ; na‡ten¡ jednoho znaku
         call      far ptr UpCase           ; konverze na velk‚ p¡smeno
         cmp       al,"\"                   ; je oddˆlova‡ cesty ?
         jne       Strt1082                 ; nen¡ oddˆlova‡ cesty
         mov       bx,di                    ; BX <- £schova konce cesty
Strt1082:stosb
         cmp       al,0                     ; konec cesty ?
         loopne    Start108                 ; dal¨¡ znak

Start109:pop       ds
         mov       byte ptr ds:[bx],0       ; ozna‡en¡ konce cesty

; ------ kontrola s‚riov‚ho ‡¡sla disku

         test      byte ptr ds:[LicDPar],bit3 ; je s‚riov‚ ‡¡slo disku ?
         jz        Strt1094                 ; nen¡ s‚riov‚ ‡¡slo disku
         mov       al,ds:[HomeDir]          ; disk domovsk‚ho adres ©e
         sub       al,"A"                   ; korekce na ‡¡slo disku
         call      far ptr GetSerN          ; na‡ten¡ s‚riov‚ho ‡¡sla disku
         jc        Strt1094                 ; nen¡ s‚riov‚ ‡¡slo
         add       cx,dx                    ; sou‡et s‚riov‚ho ‡¡sla
         cmp       cx,ds:[LicDSer]          ; kontrola s‚riov‚ho ‡¡sla disku
         je        Start114                 ; s‚riov‚ ‡¡slo souhlas¡ OK
Strt1092:or        byte ptr ds:[LicDPar0],bit1 ; instalace nesouhlas¡
         jmp       short Start114

; ------ Datum a ‡as c¡lov‚ho adres ©e

Strt1094:push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       si,offset HomeDir        ; domovsk˜ adres ©
         call      far ptr ExisFile         ; na‡ten¡ parametr– adres ©e
         jc        Strt1092                 ; adres © neexistuje ? (nap©. ROOT)
         mov       ax,word ptr ds:[BuffDTA+DTATime] ; ‡as adres ©e
         add       ax,word ptr ds:[BuffDTA+DTADate] ; datum adres ©e
         cmp       ax,ds:[LicDDate]         ; kontrola data a ‡asu adres ©e
         jne       Strt1092                 ; datum a ‡as adres ©e nesoulas¡

; ------ p©¡prava licen‡n¡ho ‡¡sla pro zobrazen¡

Start114:mov       di,offset LicCislo+5     ; licen‡n¡ ‡¡slo HIGH
         push      ds
         pop       es
         xor       dx,dx                    ; DX <- 0
         xor       bx,bx                    ; nen¡ barva ani oddˆlova‡

         xor       ax,ax                    ; AX <- 0
         cmp       ds:[LicDNum],ax          ; je DEMO verze ?
         jne       Strt1141                 ; nen¡ DEMO verze
         mov       ds:[LicDNum+2],ax        ; zru¨en¡ ‡¡sla HIGH

Strt1141:mov       ax,ds:[LicDNum+2]        ; licen‡n¡ ‡¡slo HIGH
         call      far ptr DekNumD          ; dek¢dov n¡ ‡¡sla
         mov       di,offset LicCislo+11    ; licen‡n¡ ‡¡slo LOW
         mov       ax,ds:[LicDNum]          ; licen‡n¡ ‡¡slo LOW
         call      far ptr DekNumD          ; dek¢dov n¡ ‡¡sla

; ------ p©¡prava zb˜vaj¡c¡ch dn– ‡asov‚ho omezen¡

         test      byte ptr ds:[LicDPar],bit6 ; je ‡asov‚ omezen¡ ?
         jz        Strt1145                 ; nen¡ ‡asov‚ omezen¡

         mov       ah,2ah
         int       21h                      ; poskytnut¡ aktu ln¡ho data
         mov       bx,dx                    ; BX <- den a mˆs¡c
         call      far ptr KonvDatN         ; konverze na absolutn¡ den

         push      ax                       ; aktu ln¡ datum absolutnˆ
         push      dx

         mov       ax,ds:[LicDDatO]         ; datum instalace
         mov       bl,al                    ; DL <- datum instalace
         and       bl,bit0+bit1+bit2+bit3+bit4 ; den instalace
         mov       cl,5
         shr       ax,cl
         mov       bh,al
         and       bh,(bit5+bit6+bit7+bit8)/bit5 ; mˆs¡c instalace
         mov       cl,9-5
         shr       ax,cl
         add       ax,1980                  ; rok
         xchg      ax,cx                    ; CX <- rok
         call      far ptr KonvDatN         ; p©evod data na po‡et dn– -> DX:AX
         add       ax,1                     ; rezerva
         adc       dx,0

         pop       di                       ; aktu ln¡ datum absolutnˆ
         pop       si

         sub       ax,si
         sbb       dx,di                    ; zb˜vaj¡c¡ po‡et dn–
         jnz       Strt1142                 ; p©ete‡en¡
         cmp       ax,255
         jbe       Strt1144
Strt1142:xor       ax,ax
Strt1144:mov       byte ptr ds:[LicDOmz0],al ; po‡et zb˜vaj¡c¡ch dn– omezen¡

; ------ p©¡prava po‡tu po‡¡ta‡– (BX=0 !)

Strt1145:cmp       word ptr ds:[LicDNum],0  ; je DEMO verze ?
         je        Strt1148                 ; je DEMO verze

         mov       word ptr ds:[KMnuVrt1],offset LicPocNe ; "neomezen  multilicence"
         mov       ax,ds:[LicDPC]           ; po‡et po‡¡ta‡–
         or        ax,ax                    ; je neomezen  multilicence ?
         jz        Strt1148                 ; je neomezen  multilicence

         mov       word ptr ds:[KMnuVrt1],offset LicPocLi ; "licence pro"
         mov       word ptr ds:[KMnuVrt2],offset LicPocVy ; "v˜hradn¡ho"
         mov       word ptr ds:[KMnuVrt3],offset LicPocUz ; "u‘ivatele"

         cmp       word ptr ds:[LicDNum],45000 ; minimum v˜hradn¡ho u‘ivatele
         jb        Strt1146                 ; nen¡ v˜hradn¡ u‘ivatel
         cmp       word ptr ds:[LicDNum],50000 ; maximum v˜hradn¡ho u‘ivatele
         jb        Strt1148                 ; je v˜hradn¡ u‘ivatel OK

Strt1146:mov       word ptr ds:[KMnuVrt2],offset LicPocPC ; ‡¡slo
         mov       word ptr ds:[KMnuVrt3],offset LicPocPo ; "po‡¡ta‡"

         mov       di,offset LicPocPC+1     ; buffer
         xor       bx,bx                    ; nen¡ barva
         call      far ptr DekNumW          ; dek¢dov n¡ ‡¡sla
         xchg      ax,di                    ; AX <- konec ‡¡sla, DI <- po‡¡ta‡–
         sub       ax,offset LicPocPC+1     ; d‚lka textu
         mov       ds:[LicPocPC],al         ; d‚lka ‡¡sla

         dec       di                       ; je 1 po‡¡ta‡ ?
         jz        Strt1147                 ; 1 po‡¡ta‡
         mov       word ptr ds:[KMnuVrt1],offset LicPocMu ; "multilicence"
         inc       byte ptr ds:[LicPocPo]   ; bude koncovka textu "po‡¡ta‡"
         cmp       word ptr ds:[LicDPC],4   ; je 2 a‘ 4 po‡¡ta‡e ?
         jbe       Strt1147                 ; je 2 a‘ 4 po‡¡ta‡e
         mov       byte ptr ds:[LicPocP0],"–" ; je koncovka "po‡¡ta‡–"

Strt1147:cmp       word ptr ds:[LicDNum],60000 ; je OEM verze ?
         jb        Strt1148                 ; nen¡ OEM verze
         mov       word ptr ds:[KMnuVrt1],offset LicPocOE ; OEM verze

; ------ vymaz n¡ inicializa‡n¡ ‡ sti programu

Strt1148:mov       di,offset Start          ; prvn¡ start programu
         mov       si,offset Main0          ; opakovan˜ start programu
         mov       cx,offset(Start115-Start) ; d‚lka dat
         push      ds
         push      cs
         pop       ds
         push      cs
         pop       es
Start115:rep       movsb                    ; vymaz n¡ dat
         pop       ds

; ------ n vrat adresy INT 3 (ES=CS !)

; Zruseno u FREEWARE verze 2.20

;IFNDEF   DEBUG
;         push      ds
;
;         xor       bx,bx                    ; BX <- 0
;         mov       ds,bx                    ; DS <- 0
;
;         push      word ptr cs:[bx+Old03+2]  ; p–vodn¡ adresa INT 03h
;         push      word ptr cs:[bx+Old03]
;
;         pop       word ptr ds:[bx+3*4]
;         pop       word ptr ds:[bx+3*4+2]   ; n vrat adresy INT 03h
;
;         pop       ds
;ENDIF

; ------ dokon‡en¡ vymaz n¡ programu (ES:DI ukazuje na "Start115")

         mov       cl,offset(Strt1158-Start115)
Strt1158:rep       movsb                    ; vymaz n¡ zbytku dat

; ------ kontrola licence (LicDCRC mus¡ b˜t = 0)

         test      byte ptr ds:[LicDPar],bit7 ; je nainstalov n ?
         jnz       Start117  ;Strt1159                 ; nen¡ nainstalov n
         test      byte ptr ds:[LicDPar0],bit0 + bit1 ; souhlas¡ CRC ?
         jnz       Start117                 ; CRC nesouhlas¡
;         jz        Start116                 ; CRC souhlas¡ OK

; ------ chyba licence - n hrada DEMO verz¡

;Strt1159:mov       dx,offset LicErr
;Strt115A:mov       ah,9
;         int       21h
;         mov       ax,4cffh
;IFNDEF   DEBUG
;         int       21h
;ENDIF

; ------ inicializace dat, je-li rezidentn¡ modul

;Start116:
         test      byte ptr ds:[LicDPar],bit6 ; je datum konce platnosti ?
         jz        Start118                 ; nen¡ datum konce platnosti
;         mov       dx,offset LicOmezT       ; text - konec funk‡nosti
         cmp       byte ptr ds:[LicDOmz0],0 ; je konec platnosti ?
         jne       Start118                 ; nen¡ konec platnosti

;IFNDEF   DEBUG
;         je        Strt115A                 ; je konec platnosti
;ENDIF
Start117:
         and       byte ptr ds:[LicDPar],not bit6 ; zru¨en¡ ‡asov‚ho omezen¡
         mov       word ptr ds:[LicDNum],0  ; p©¡znak DEMO verze

; ------ rozli¨en¡, zda je DEMO verze

Start118:cmp       word ptr ds:[LicDNum],0  ; je DEMO verze ?
         je        Start119                 ; je DEMO verze
         and       byte ptr ds:[LicDPar0],not bit4 ; nen¡ DEMO verze

; ------ inicializace dat z rezidentn¡ho modulu

Start119:call      IniDMRez                 ; inicial. dat z rezidentn¡ho modulu
         jnc       Start3                   ; je rezidentn¡ modul OK

; ------ nen¡ rezidentn¡ modul - plat¡ ukazatele pro tento modul

         mov       ax,ds:[SegPSP]
         mov       ds:[RezPSP],ax
         mov       ds:[RezData],ds
         mov       word ptr ds:[RezLoad],SEG CodeLod

; ------ obsluha zobrazen¡ n povˆdy

         mov       si,offset ParCHl1T       ; parametr "?"
         call      far ptr GetCPar          ; nalezen¡ parametru "/?"
         jnc       Start12
         mov       si,offset ParCHl2T       ; parametr "/H"
         call      far ptr GetCPar          ; nalezen¡ parametru "/H"
         jc        Start13
Start12: mov       dx,offset HelpHTxt       ; text n povˆdy
         jmp       Start42                  ; zobrazen¡ n povˆdy

; ------ test, zda m  b˜t vypnuta n povˆda k menu

Start13: mov       si,offset ParCNoHT       ; text "NOHLP"
         call      far ptr GetCPar          ; nalezen¡ parametru "NOHLP"
         jc        Start14
         or        byte ptr ds:[HelpPar],bit2 ; nen¡ n povˆda k menu
Start14:

; -----------------------------------------------------------------------------
;             opakovan˜ start programu (v rezidentn¡m m¢du)
; -----------------------------------------------------------------------------
;þ
ReStart  LABEL     FAR

; ------ zah jen¡ inicializace

Start3:  or        byte ptr ds:[ParInt24],bit0 ; p©¡znak - INT 24h se ignoruje
         call      far ptr ZapKrit          ; zapnut¡ kritick‚ sekce
         call      far ptr InstInt          ; instalace obsluh p©eru¨en¡
         call      far ptr InitLCom         ; inicializace p©¡kazov‚ho © dku
         and       byte ptr ds:[HelpPar],not bit4 ; nen¡ zobrazena n povˆda
         and       byte ptr ds:[StartPar],not bit1+bit6+bit7 ; nen¡ INI/kalend ©/menu p©i startu
         or        byte ptr ds:[StartPar],bit4 ; p©¡znak startovac¡ inicializace
         and       byte ptr ds:[UserSwcM],not bit1 ; zru¨en¡ p©¡kazu s "!"
         and       byte ptr ds:[ParMenu],not (bit1+bit2+bit3+bit4+bit5)
         and       byte ptr ds:[ProgSwc],not bit7 ; nen¡ $DOSMAN$.BAT
         and       byte ptr ds:[ProgSwc2],not bit0 ; nen¡ EXTENSION/MENU
         call      far ptr InfoClos         ; uzav©en¡ informa‡n¡ho © dku
         call      far ptr QSrcEnd          ; ukon‡en¡ re‘imu rychlovyhled v n¡

; ------ povolen¡ pouze adres ©ov˜ch oken nebo stromu

         and       byte ptr ds:[ParamL],not bit3 ; z kaz seznamu
         test      byte ptr ds:[ParamL],bit1+bit2 ; je adres © nebo strom ?
         jnz       Start302                 ; je to OK
         or        byte ptr ds:[ParamL],bit1 ; povolen adres ©

Start302:and       byte ptr ds:[ParamR],not bit3
         test      byte ptr ds:[ParamR],bit1+bit2
         jnz       Start303
         or        byte ptr ds:[ParamR],bit1

Start303:sti                                ; p©eru¨en¡ bude povoleno

; ------ £schova verze opera‡n¡ho syst‚mu

         mov       ah,30h
         int       21h                      ; zji¨tˆn¡ verze opera‡n¡ho syst‚mu
         xchg      ah,al
         mov       ds:[VerzeOS],ax          ; verze opera‡n¡ho syst‚mu

; ------ detekce procesoru

         call      far ptr DetCPU           ; detekce procesoru

; ------ inicializace WINDOWS (mus¡ b˜t p©ed inicializac¡ z $DOSMAN$.INI)

         call      InitW95                  ; inicializace pro WINDOWS

; ------ £schova tabulky vybaven¡

         push      ds
         int       11h                      ; poskytnut¡ tabulky vybaven¡
         pop       ds
         mov       ds:[Vybaveni],ax         ; tabulka vybaven¡

; ------ na‡ten¡ COUNTRY informac¡

         call      InitCntr                 ; inicializace COUNTRY informac¡

; ------ instalace pamˆti XMS

         ;call      far ptr InstXMS          ; instalace pamˆti XMS

; ------ inicializace gener toru n hody

         call      InitRnd                  ; inicializace gener toru n hody

; ------ inicializace pamˆti

         call      far ptr InitMem          ; inicializace pamˆti
         jnc       Start5

; ------ chyba - nedostatek pamˆti

Start4:  call      far ptr DeInsInt         ; n vrat obsluh p©eru¨en¡
         mov       dx,offset MemErrT        ; text - nedostatek pamˆti
Start42: mov       ah,9
         int       21h                      ; zobrazen¡ chybov‚ho textu
         mov       ax,4c02h                 ; n vrat s chybou 2
         int       21h                      ; konec programu

; ------ inicializace tabulky disk–

Start5:  call      far ptr InitDPar         ; inicializace diskov˜ch parametr–

; ------ inicializace bufferu koment ©– k disk–m

         call      far ptr IniDSKom         ; inicializace koment ©– k disk–m
         jc        Start4                   ; nedostatek pamˆti

; ------ inicializace bufferu koment ©– k funk‡n¡m kl ves m

         call      far ptr InitFHlp         ; inic.koment ©– k funk‡n¡m kl ves m
         jc        Start4                   ; nedostatek pamˆti

; ------ inicializace segmentu kopie prost©ed¡

         call      far ptr InitEnv          ; inicializace segmentu prost©ed¡
         jc        Start4                   ; nedostatek pamˆti

; ------ inicializace masky oken a segmentu definice skupin

         call      far ptr InitMWin         ; inicializace masky oken a skupin
Start500:jc        Start4                   ; nedostatek pamˆti

; ------ £schova aktivn¡ho adres ©e

         call      far ptr InitAPth         ; inicializace aktivn¡ho adres ©e

; ------ sestaven¡ cesty k domovsk‚mu adres ©i (adres © program–)

         test      byte ptr ds:[StartPar],bit2 ; jsou ji‘ data ?
         jnz       Start50                  ; adres ©e zn m‚
         call      far ptr InitHPth         ; inicializace domovsk‚ho adres ©e

; ------ sestaven¡ cesty ke konfigura‡n¡mu adres ©i (adres © dat)

         mov       si,offset ParCZT         ; parametr "/Z"
         mov       bp,offset TempDir        ; buffer p©echodn‚ho adres ©e
         call      far ptr InitTPth         ; inicializace domovsk‚ho adres ©e

; ------ parametr /RO - z kaz z pisu do datov‚ho adres ©e

         mov       si,offset ParCRO         ; parametr "/RO"
         call      far ptr GetCPar          ; nalezen¡ parametru "RO"
         jc        Start501
         or        byte ptr ds:[TempDirP],bit0 ; z kaz z pisu do adres ©e

; ------ zad n¡ cesty programov‚ho adres ©e z p©¡kazov‚ho © dku

Start501:mov       si,offset ParCXT         ; parametr "/X"
         mov       bp,offset HomeDir        ; buffer domovsk‚ho adres ©e
         call      far ptr InitTPth         ; inicializace domovsk‚ho adres ©e

; ------ inicializace podle konfigura‡n¡ho souboru CNF

Start50: call      InitBCnf                 ; inicializace konfig. z BAT

;IFDEF    DEBUG
;         call      far ptr StopBod
;ENDIF
; ------ ur‡en˜ n rodn¡ k¢d

         mov       al,ds:[CodePag0]         ; ur‡en˜ n rodn¡ k¢d
         mov       ds:[CodePage],al         ; je to aktu ln¡ n rodn¡ k¢d
         mov       byte ptr ds:[CodePagK],1 ; je k¢d Kamenick˜ch
         cmp       al,3                     ; je Kamenick˜ch ?
         je        Start512                 ; je Kamenick˜ch
         inc       byte ptr ds:[CodePagK]   ; je Latin 2
         cmp       al,4                     ; je Latin 2 ?
         je        Start512                 ; je Latin 2
         mov       byte ptr ds:[CodePagK],0 ; jinak k¢d neur‡en˜

; ------ inicializace podle konfigura‡n¡ho souboru INI

Start512:mov       byte ptr ds:[NumVMod],0  ; nejsou videom¢dy

         call      InitIni                  ; inicializace konfigurace

         call      KorCntr                  ; korekce narodnich informaci

; ------ instalace obsluh p©eru¨en¡ - 2. f ze

         call      far ptr Inst2Int         ; instalace obsluh p©eru¨en¡

; ------ zru¨en¡ souboru $DOSMAN$.BAT

         call      DelDMBat                 ; zru¨en¡ souboru $DOSMAN$.BAT

; ------ inicializace podle p©¡kazov‚ho © dku

         call      InitCnf                  ; inicializace podle p©¡kaz. © dku

; ------ inicializace segmentu historie

         call      far ptr InitHist         ; inicializace segmentu histori¡
Start54: jc        Start500                 ; chyba - nedostatek pamˆti

; ------ detekce videokarty a inicializace parametr– displeje

         call      far ptr DetCard          ; detekce videokarty

; ------ p©¡prava implicitn¡ho videom¢du pro prvn¡ nastaven¡

         call      far ptr ImplVMod         ; implicitn¡ videom¢d

; ------ vytvo©en¡ segmentu font–

         call      far ptr InitSFnt         ; inicializace segmentu font–
         jc        Start54                  ; chyba pamˆti

; ------ vytvo©en¡ adres ©ov˜ch oken

         call      far ptr InitWins         ; inicializace oken
         jc        Start54                  ; chyba pamˆti

; ------ inicializace displeje (a inicializace my¨i a v˜¨ky oken)

         call      far ptr PushScr          ; £schova obsahu obrazovky
         and       byte ptr ds:[ParMouse],not bit1 ; nebyla instalace my¨i
         call      far ptr InitVMdI         ; inicializace videom¢du

; ------ obnoven¡ obsahu obrazovky (po p©edchoz¡m vymaz n¡ inicializac¡)

         mov       cl,ds:[Pozic]            ; po‡et pozic na © dek
         mov       ch,ds:[Radku]            ; po‡et © dk– displeje
         xor       dx,dx                    ; po‡ te‡n¡ pozice a © dek
         cmp       byte ptr ds:[STopLine],-1 ; je hlavn¡ menu ?
         jne       Start53                  ; nen¡ hlavn¡ menu
         mov       dh,1                     ; po‡ te‡n¡ © dek 1
Start53: sub       ch,dh                    ; po‡et © dk– k zobrazen¡
         call      far ptr PopScr           ; n vrat obsahu obrazovky

; ------ ukon‡en¡ startovac¡ sekvence

         and       byte ptr ds:[ProgSwc3],not bit1 ; nen¡ extern¡ stm¡va‡
         and       byte ptr ds:[ParInt24],not bit0 ; zru¨.p©¡znaku ignor. INT 24
         and       byte ptr ds:[StartPar],not bit4 ; konec start. inicializace
         call      far ptr VypKrit          ; vypnut¡ kritick‚ sekce
         call      far ptr NulBreak

; ------ start p©¡kazu zadan‚ho parametrem "/C p©¡kaz"

         cmp       byte ptr ds:[LineCNum],0
         je        Start52
         and       byte ptr ds:[StartPar],not bit1 ; nen¡ aktualizace INI souboru
         jmp       far ptr ProgrExe         ; start p©¡kazu
Start52: call      far ptr InitLCom         ; inicializace p©¡kazov‚ho © dku

; ------ na‡ten¡ otev©en˜ch oken

         call      far ptr MainRead         ; na‡ten¡ obsah– oken
         and       byte ptr ds:[DarkParm],not bit1+bit2 ; displej nen¡ ztmaven
         call      far ptr DarkNul          ; nulov n¡ ‡¡ta‡e ztmavov n¡
         call      far ptr DispAll          ; zobrazen¡ cel‚ obrazovky

; ------ DEMO hl ¨en¡ (p©i ka‘d‚m startu)

         call      far ptr DispDemo         ; zobrazen¡ demo hl ¨en¡

         test      byte ptr ds:[LicDPar],bit6 ; je ‡asov‚ omezen¡ ?
         jz        Main0                    ; nen¡ ‡asov‚ omezen¡
         test      byte ptr ds:[StartPar],bit2 ; jsou ji‘ data ?
         jnz       Main0                    ; je opakovan˜ start
         mov       al,ds:[LicDOmz0]         ; po‡et zb˜vaj¡c¡ch dn–
         cmp       al,9                     ; zb˜v  dost dn– ?
         ja        Main0                    ; zb˜v  je¨tˆ dost dn–
         add       al,"0"
         mov       ds:[OmezMnP1],al         ; po‡et dn– omezen¡
         cmp       al,"5"
         jae       Start588
         mov       word ptr ds:[OmezMnP2+1],"yn"
         cmp       al,"1"
         ja        Start588
         mov       word ptr ds:[OmezMnP2+1],"ne"
Start588:mov       si,offset OmezMnu
         call      far ptr Lin0MenF         ; zobrazen¡ hl ¨en¡

; -----------------------------------------------------------------------------
;        n vrat z obsluh funkc¡ (t‚‘ n vrat uvnit© editoru)
; -----------------------------------------------------------------------------
;þ
Main0    label     FAR

; ------ standardn¡ nastaven¡ registr–

         mov       ax,SEG Data              ; datov˜ registr
         mov       ds,ax                    ; inicializace datov‚ho registru
         mov       ss,ds:[StackSS]          ; inicializace registru SS
         mov       sp,ds:[StackSP]          ; inicializace registru SP
         sti                                ; p©eru¨en¡ povoleno

         and       byte ptr ds:[StartPar],not bit1 ; nen¡ aktualizace INI souboru
         and       byte ptr ds:[ProgSwc],not bit7 ; nen¡ $DOSMAN$.BAT
         and       byte ptr ds:[ProgSwc2],not bit0 ; nen¡ EXTENSION/MENU

; ------ nulov n¡ ‡¡ta‡e stm¡v n¡

         and       byte ptr ds:[DarkParm],not bit3 ; nen¡ mo‘n‚ ext. ztmaven¡
         and       byte ptr ds:[ParMenu],not bit4+bit5 ; nen¡ automatick‚ menu
         call      far ptr DarkNul          ; nulov n¡ ‡¡ta‡e stm¡v n¡

         call      far ptr KurzInv          ; nulov n¡ p©¡znaku kurzoru

; ------ n vrat do editoru (z funkce uvnit© editoru)

         test      byte ptr ds:[WindPar],bit6 ; je editace soubor– ?
         jz        Main01                   ; nen¡ editace soubor–
         jmp       far ptr EdiMain0         ; n vrat do editace

; ------ nulov n¡ p©¡znak–, uzav©en¡ menu

Main01:  mov       word ptr ds:[LastErr],0  ; nulov n¡ p©¡znaku chyby
         call      far ptr InfoClos         ; zru¨en¡ p©¡znaku inf. © dku
         call      far ptr DelBuff          ; zru¨en¡ datov‚ho bufferu
         call      far ptr ClosFFil         ; uzav©en¡ vyhled v n¡ soubor–
         call      far ptr FlushEsc         ; vypr zdnˆn¡ bufferu kl vesnice
         call      far ptr NulBreak         ; nulov n¡ p©¡znaku p©eru¨en¡ BREAK
         call      far ptr ClosMnuA         ; uzav©en¡ v¨ech menu

         call      far ptr MainRead         ; obnoven¡ na‡ten¡ oken
         call      far ptr AktADir          ; aktualizace aktivn¡ho adres ©e
         call      far ptr DispAll          ; zobrazen¡ v¨eho

; ------ kalend © p©i startu

         test      byte ptr ds:[StartPar],bit6 ; je kalend © p©i startu ?
         jz        Main02
         and       byte ptr ds:[StartPar],not bit6 ; zru¨en¡ po‘adavku kalend ©e
         jmp       AWKalend                 ; obsluha kalend ©e

; ------ u‘ivatelsk‚ menu p©i startu

Main02:  test      byte ptr ds:[ParMenu],bit7 ; je z kaz opu¨tˆn¡ menu ?
         jnz       Main03                    ; je z kaz opu¨tˆn¡ menu
         test      byte ptr ds:[StartPar],bit7 ; je menu p©i startu ?
         jnz       Main04                   ; menu p©i startu
         test      byte ptr ds:[ParMenu2],bit1 ; navr tit u‘iv. menu ?
         jz        Main                     ; nen¡ navr cen¡ menu
Main03:  or        byte ptr ds:[ParMenu],bit4 ; p©¡znak autom. vno©en¡ do menu
Main04:  and       byte ptr ds:[ParMenu2],not bit1 ; zru¨en¡ po‘adavku
         and       byte ptr ds:[StartPar],not bit7 ; zru¨en¡ po‘adavku menu
         jmp       AWMenu                   ; u‘ivatelsk‚ menu

; -----------------------------------------------------------------------------
;        klidov  smy‡ka - ‡ek n¡ na nˆjakou operaci (‡ek n¡ na kl vesu)
; -----------------------------------------------------------------------------

; ------ test, zda je p©ipraven nˆjak˜ znak z kl vesnice (a obsluha kurzoru my¨i)

Main:    call      far ptr TestChar         ; test, zda je znak z kl vesnice
         jc        Main11                   ; nen¡ p©ipravena kl vesa
         jmp       Main2                    ; je p©ipraven znak z kl vesnice

; ------ obsluha INT 28h

Main11:  mov       ax,SEG Data              ; datov˜ registr
         mov       ds,ax                    ; inicializace datov‚ho registru
         mov       ss,ds:[StackSS]          ; inicializace registru SS
         mov       sp,ds:[StackSP]          ; inicializace registru SP
         int       28h                      ; obsluha INT 28h

; ------ standardn¡ nastaven¡ registr–

         mov       ax,SEG Data              ; datov˜ registr
         mov       ds,ax                    ; inicializace datov‚ho registru
         mov       ss,ds:[StackSS]          ; inicializace registru SS
         mov       sp,ds:[StackSP]          ; inicializace registru SP
         sti                                ; p©eru¨en¡ povoleno

; ------ obsluha zobrazen¡ hodin

         call      far ptr DispTime         ; zobrazen¡ ‡asu

; ------ obsluha stm¡v n¡

         or        byte ptr ds:[DarkParm],bit3 ; je mo‘n‚ extern¡ ztmaven¡ displeje
         call      far ptr Darker           ; obsluha stm¡v n¡

; ------ obsluha extern¡ho stm¡va‡e

         test      byte ptr ds:[DarkParm],bit2 ; po‘aduje se extern¡ stm¡va‡ ?
         jz        Main12                   ; nepo‘aduje se extern¡ stm¡va‡
         or        byte ptr ds:[ProgSwc3],bit1 ; je extern¡ stm¡va‡
         push      ds
         pop       es
         mov       si,offset DarkExec       ; buffer p©¡kazu stm¡va‡e
         call      far ptr UserDekX         ; dek¢dov n¡ p©¡kazu
         and       byte ptr ds:[DarkParm],not bit2 ; zru¨en¡ po‘adavku obsluhy
         and       byte ptr ds:[StartPar],not bit1 ; nen¡ aktualizace INI souboru
         jmp       far ptr ProgrExe         ; proveden¡ p©¡kazu

; ------ obsluha na‡¡t n¡ stromu v pozad¡

Main12:  and       byte ptr ds:[DarkParm],not bit3 ; nen¡ mo‘n‚ ext. ztmaven¡
         mov       ax,ds:[SegmAkt]          ; aktivn¡ okno
         call      far ptr BackTWn          ; na‡¡t n¡ stromu v aktivn¡m oknˆ
         jnc       Main13                   ; okno bylo obslou‘eno
         mov       ax,ds:[SegmNAkt]         ; neaktivn¡ okno
         call      far ptr BackTWn          ; na‡¡t n¡ stromu v neaktivn¡m oknˆ
         jc        Main14                   ; tak‚ nen¡ obsluha
Main13:  call      far ptr DispAWin         ; zobrazen¡ okna

; ------ obsluha zobrazen¡ mal‚ n povˆdy (p©esmyka‡e)

Main14:  call      far ptr DispFHlp         ; zobrazen¡ n povˆdy k fn. kl ves m

; ------ obsluha my¨i

         call      far ptr MouseInt         ; obsluha my¨i

; ------ obsluha p©¡kazov‚ho © dku pomoc¡ my¨i

         call      far ptr MousLin          ; obsluha p©¡kazov‚ho © dku my¨¡
         jc        Main15                   ; nen¡ ‘ dn  obsluha
         jz        Main00                   ; je jen n vrat
         and       byte ptr ds:[StartPar],not bit1 ; nen¡ aktualizace INI souboru
         jmp       far ptr ProgrExe         ; start p©¡kazu

; ------ zobrazen¡ kurzoru v p©¡kazov‚m © dku

Main15:  call      far ptr DispLKur         ; zobrazen¡ kurzoru v p©¡kaz. © dku

; ------ obsluha menu funk‡n¡ch kl ves

         mov       si,offset GMnuVert       ; menu volby funk‡n¡ch kl ves
         call      far ptr MenuFnK          ; menu funk‡n¡ch kl ves
         jc        Main16                   ; funkce nebyla vyvol na
         jnz       Main21                   ; byla zvolena kl vesa
Main00:  jmp       Main0                    ; n vrat z funkce volby kl ves

; ------ obsluha hlavn¡ho menu pomoc¡ my¨i

Main16:  call      far ptr MouseGet         ; test obsluhy my¨i
         jnc       Main21                   ; je po‘adavek obsluhy my¨i

; ------ ukon‡en¡ rychlovyhled v n¡

         test      byte ptr ds:[WindPar2],bit4 ; je mo‘n‚ ukon‡en¡ ?
         jz        Main18                   ; nen¡ ukon‡en¡
         test      byte ptr ds:[WindPar],bit3 ; je rychlovyhled v n¡ ?
         jz        Main18                   ; nen¡ rychlovyhled v n¡
         call      far ptr InpPres0         ; vstup stavu p©esmyka‡–
         test      al,bit6                  ; je kl vesa Alt- ?
         jnz       Main18                   ; nen¡ kl vesa Alt-
         call      far ptr QSrcEnd          ; ukon‡en¡ rychlovyhled v n¡

; ------ automatick  zmˆna adres ©e stromu

Main18:  test      byte ptr ds:[WindPar2],bit5 ; je autodir ?
         jz        Main19                   ; nen¡ autodir
         call      far ptr TestAAWn         ; test aktivn¡ho okna
         jc        Main19                   ; nen¡ aktivn¡ okno
         mov       ax,ds:[SegmAkt]          ; aktivn¡ okno
         call      far ptr GetDat           ; adresa aktivn¡ho okna
         test      byte ptr es:[AWinPrm1],bit4 ; je strom ?
         jz        Main19                   ; nen¡ strom
         call      far ptr TestQVw          ; test, zda je zobrazen¡ QuickView
         jc        Main19                   ; nen¡ QuickView
         jmp       AWEntr03                 ; zmˆna adres ©e

Main19:  jmp       Main                     ; ‡ek n¡ na nˆjakou akci

; -----------------------------------------------------------------------------
;        obsluha stisknut‚ kl vesy
; -----------------------------------------------------------------------------

; ------ vstup znaku z kl vesnice -> BX

Main2:   call      far ptr InputChar        ; vstup znaku z kl vesnice
         xchg      ax,bx                    ; BX <- k¢d p©ijat‚ kl vesy

; ------ inicializace p©¡znak–

Main21:  call      far ptr NulBreak         ; nulov n¡ p©¡znaku p©eru¨en¡ BREAK

;; ------ nulov n¡ p©¡znaku kl vesy Ctrl-K, je-li jin  kl vesa
;
;         cmp       bx,250bh                 ; je kl vesa Ctrl-K ?
;         je        Main22                   ; je kl vesa Ctrl-K
;         and       byte ptr ds:[WindPar],not bit5 ; nulov n¡ p©¡znaku Ctrl-K

; ------ p©¡prava k¢du kl vesy Shift-Esc

Main22:  cmp       bx,11bh                  ; je kl vesa ESC ?
         jne       Main23                   ; nen¡ kl vesa ESC
         test      byte ptr ds:[Presmyk],bit4 ; je Shift- ?
         jz        Main221                  ; nen¡ Shift-Esc
         mov       bh,81h                   ; symbolick˜ k¢d kl vesy Shift-Esc
         jmp       short Main23

; ------ vypnut¡ rychlovyhled v n¡

Main221: test      byte ptr ds:[WindPar],bit3 ; je rychlovyhled v n¡ ?
         jz        Main222                  ; nen¡ rychlovyhled v n¡
         call      far ptr QSrcEnd          ; ukon‡en¡ rychlovyhled v n¡
         jmp       short Main000

; ------ vypnut¡ seznamu, je-li ESC

Main222: call      far ptr GetAAWin         ; adresa aktivn¡ho okna
         jc        Main23                   ; chyba ?
         test      byte ptr es:[AWinPrm1],bit5 ; je seznam ?
         jz        Main23                   ; nen¡ seznam
         call      far ptr HledClos         ; zru¨en¡ okna seznamu
         call      far ptr MainRead         ; na‡ten¡ obsah– oken
         call      far ptr DispAll          ; nov‚ zobrazen¡ oken
         jmp       short Main000            ; n vrat z funkce

; ------ p©¡prava k¢du kl vesy Ctrl-mezera

Main23:  cmp       bx,3920h                 ; je mezera ?
         jne       Main232                  ; nen¡ mezera
         test      byte ptr ds:[Presmyk],bit5 ; je p©esmyka‡ Ctrl- ?
         jz        Main232                  ; nen¡ p©esmyka‡ Ctrl-
         mov       bx,1b00h                 ; n hradn¡ k¢d pro Ctrl-mezera

; ------ kl vesy Shift- [+], [-] a [*]

Main232: cmp       bx,2b1ch                 ; kl vesa Ctrl-\
         je        Main34                   ; je kl vesa Ctrl-\
         call      MNumKey                  ; p©edobsluha kl ves
         jc        Main34                   ; je ©¡dic¡ kl vesa

; ------ obsluha stromu

         cmp       byte ptr ds:[LineCNum],0 ; je nˆco v p©¡kazov‚m © dku ?
         jne       Main27                   ; je nˆco v p©¡kazov‚m © dku
         mov       ax,ds:[SegmAkt]          ; segment aktivn¡ho okna
         call      far ptr EditDTWn         ; obsluha okna stromu
         jc        Main27                   ; nebyla obsluha stromu
Main001: call      far ptr DispAAWn         ; zobrazen¡ okna stromu
Main000: jmp       Main00                   ; n vrat z funkce

; ------ rozli¨en¡ kl vesy pro rychlovyhled v n¡

Main27:  cmp       bx,0e08h
         je        Main28                   ; BackSpace
         cmp       bx,0e00h
         je        Main28                   ; Alt-BackSpace
         cmp       bx,11bh
         je        Main28                   ; Esc
         cmp       bx,4b00h
         je        Main28                   ; vlevo
         cmp       bx,4d00h
         je        Main28                   ; vpravo
         cmp       bl," "
         jb        Main3                    ; ©¡dic¡ kl vesa
Main28:  test      byte ptr ds:[WindPar],bit3 ; je rychlovyhled v n¡ ?
         jnz       Main34                    ; je rychlovyhled v n¡

; ------ proveden¡ p©¡kazu z p©¡kazov‚ho © dku (plat¡ i CR, kv–li "WIN"+CR !)

Main3:   cmp       bl,CR
         jne       Main32                   ; nen¡ CR
         cmp       byte ptr ds:[LineCNum],0 ; je nˆco v p©¡kazov‚m © dku ?
         je        Main34                   ; nen¡ nic v p©¡kazov‚m © dku
         and       byte ptr ds:[StartPar],not bit1 ; nen¡ aktualizace INI souboru
         jmp       far ptr ProgrExe         ; proveden¡ p©¡kazu

; ------ obsluha p©¡kazov‚ho © dku

Main32:  call      far ptr EditLCom         ; editace p©¡kazov‚ho © dku
         or        bx,bx                    ; byla kl vesa obslou‘ena ?
         jz        Main000                  ; kl vesa byla obslou‘ena

; ------ obsluha oken

Main34:  call      far ptr EditAWin         ; ovl d n¡ oken
         or        bx,bx                    ; byla kl vesa obslou‘ena ?
         jz        Main000                  ; kl vesa byla obslou‘ena

; ------ obsluha u‘ivatelsk˜ch funk‡n¡ch kl ves (je-li kl vesa, nen¡ n vrat)

         call      far ptr UserFnc          ; obsluha u‘ivatelsk˜ch kl ves

; -----------------------------------------------------------------------------
;             Obsluha oken
; -----------------------------------------------------------------------------
;þ
Main5:   call      far ptr JumpBX           ; skok na obsluhu podle tabulky

         dw        000dh,AWEnter            ; CR ....... p©¡kaz, zmˆna adres ©e
         dw        1c0dh,AWEnter            ; Enter .... p©¡kaz, zmˆna adres ©e
         dw        1b00h,AWAEnt             ; Ctrl-mezera informace o souboru
;         dw        1c00h,AWAEnt             ; Alt-Enter  informace o souboru
         dw        1c0ah,AWCEnt             ; Ctrl-Enter jm‚no souboru pod kurz.
         dw        240ah,AWCEnt             ; Ctrl-J ... jm‚no souboru pod kurz.

         dw        4400h,AWMMnu             ; F10 ...... hlavn¡ menu
         dw        1910h,AWAscii            ; Ctrl-P ... tabulka ASCII znak–
         dw        8300h,AWKalk             ; Alt= ..... kalkul tor
         dw        8200h,AWKalend           ; Alt- ..... kalend ©
         dw        3b00h,AWHelp             ; F1 ....... n povˆda
         dw        3c00h,AWMenu             ; F2 ....... u‘ivatelsk‚ menu
         dw        3d00h,AWZobr             ; F3 ....... zobrazen¡
         dw        3e00h,AWEdit             ; F4 ....... EDIT
         dw        3f00h,AWCopy             ; F5 ....... kop¡rov n¡ ozna‡en˜ch
         dw        4000h,AWMove             ; F6 ....... p©esun ozna‡en˜ch
         dw        4100h,AWAdres            ; F7 ....... vytvo©en¡ adres ©e
         dw        4200h,AWZrus             ; F8 ....... zru¨en¡ polo‘ky
;         dw        6a00h,AWAZobr            ; Alt-F3 ... zobrazen¡ extern¡
;         dw        6b00h,AWAEdit            ; Alt-F4 ... editace extern¡
         dw        6c00h,AWACopy            ; Alt-F5 ... kop¡rov n¡ jednoho
         dw        6d00h,AWAMove            ; Alt-F6 ... p©esun jednoho
         dw        6e00h,AWHled             ; Alt-F7 ... hled n¡ soubor–
         dw        6f00h,AWAZrus            ; Alt-F8 ... zru¨en¡ pol. pod kurz.
         dw        7100h,AWTree             ; Alt-F10 .. strom
         dw        5400h,AWSHelp            ; Shift-F1 . opakov n¡ n povˆdy
         dw        5500h,AWSExec            ; Shift-F2 . proveden¡ p©¡kazu
         dw        5600h,AWSZobr            ; Shift-F3 . zobrazen¡ zadan‚
         dw        5700h,AWSEdit            ; Shift-F4 . editace zadan 
         dw        5800h,AWSCopy            ; Shift-F5 . kop¡rov n¡ zadan˜ch
         dw        5900h,AWSMove            ; Shift-F6 . p©esun zadan˜ch
         dw        5a00h,AWObnov            ; Shift-F7 . obnoven¡ soubor–
         dw        5b00h,AWSZrus            ; Shift-F8 . zru¨en¡ zadan˜ch pol.
         dw        5d00h,AWSEgaV            ; Shift-F10  EGA/VGA
         dw        4300h,AWAtrib            ; F9 ....... nastaven¡ atribut–
         dw        6000h,AWCDisk            ; Ctrl-F3 .. zobrazen¡ disku
         dw        6100h,AWCEdit            ; Ctrl-F4 .. editace HEX
         dw        6200h,AWCKopD            ; Ctrl-F5 .. kopie disket
         dw        6300h,AWCJmeno           ; Ctrl-F6 .. jm‚no disku
;         dw        6400h,AWCZvlas           ; Ctrl-F7 .. zvl ¨tn¡ funkce
         dw        6500h,AWFormat           ; Ctrl-F8 .. form tov n¡ disket
         dw        6600h,AWCComp            ; Ctrl-F9 .. srovn n¡ obsahu souboru
         dw        811bh,AWCMenu            ; Shift-Esc . n vrat menu

         dw        6700h,Konec              ; Ctrl-F10 . konec DOSMANu
;         dw        6700h,AWCInit            ; Ctrl-F10 . konfigurace

         dw        2b00h,AWHistW            ; Alt-\ .... historie oken
         dw        2b1ch,AWRootD            ; Ctrl-\ ... zmˆna adres ©e
         dw        1011h,AWCtrlQ            ; Ctrl-Q ... rychloprohl¡‘en¡

;         dw        240ah,AWFMnu             ; Ctrl-J ... menu funk‡n¡ch kl ves

         dw        MousXKod+MousXLP,AWMous1 ; stisk lev‚ho tla‡¡tka my¨i
         dw        MousXKod+MousXLH,AWMous2 ; dr‘en¡ lev‚ho tla‡¡tka my¨i
         dw        MousXKod+MousXLD,AWMous1 ; dvojit˜ stisk lev‚ho tla‡¡tka my¨i

         dw        MousXKod+MousXRP,AWMous1 ; stisk prav‚ho tla‡¡tka my¨i
         dw        MousXKod+MousXRH,AWMous2 ; dr‘en¡ prav‚ho tla‡¡tka my¨i
         dw        MousXKod+MousXRD,AWMous1 ; dvojit˜ stisk prav‚ho tla‡¡tka my¨i
         dw        MousXKod+MousXRR,AWMous0 ; uvolnˆn¡ prav‚ho tla‡¡tka my¨i

         dw        MousXKod+MousXMov,AWMous2; posun my¨¡

         dw        0,Main7                  ; neplatn  kl vesa

Main7:   jmp       far ptr AWinWin

; -----------------------------------------------------------------------------
;        Ctrl-J ... obsluha menu funk‡n¡ch kl ves
; -----------------------------------------------------------------------------

AWFMnu   PROC      NEAR

         mov       al,ds:[Presmyk]
         mov       byte ptr ds:[Presmyk],7+bit4+bit5+bit6
         mov       si,offset GMnuVert       ; menu volby funk‡n¡ch kl ves
         call      far ptr MenuFnK          ; menu funk‡n¡ch kl ves
         mov       ds:[Presmyk],al
         jc        AWFMnu00                 ; funkce nebyla vyvol na
         jz        AWFMnu00
         jmp       Main21

AWFMnu00:jmp       Main0                    ; n vrat z funkce volby kl ves

AWFMnu   ENDP

; -----------------------------------------------------------------------------
;        p©edobsluha kl ves numerick‚ kl vesnice + - * (CY=jsou ©¡dic¡ kl vesy)
; -----------------------------------------------------------------------------

MNumKey  PROC      NEAR

; ------ kl vesa Ctrl-J je ©¡dic¡

         cmp       bx,240ah
         je        MNumKey8                 ; je ©¡dic¡

; ------ test, zda je star˜ v˜znam kl ves

         test      byte ptr ds:[StartPar],bit5 ; je star˜ v˜znam kl ves + - * ?
         jz        MNumKey5                 ; nen¡ star˜ v˜znam kl ves

; ------ n hrada [*] -> Ctrl-[*]

         cmp       bx,372ah                 ; [*]
         jne       MNumKey1                 ; nen¡ [*]
         call      far ptr InpPres0         ; je Shift- ?
         jnz       MNumKey9                 ; je Shift-[*] - je platn  kl vesa
         mov       bx,9600h                 ; n hrada Ctrl-[*]
         jmp       short MNumKey8           ; je ©¡dic¡ kl vesa

; ------ n hrada Ctrl-[*] -> Shift-[*]

MNumKey1:cmp       bx,9600h                 ; Ctrl-[*]
         jne       MNumKey2
         mov       bx,372ah                 ; [*]
         jmp       short MNumKey8           ; je ©¡dic¡ kl vesa

; ------ test, zda je Shift- (star  definice)

MNumKey2:call      far ptr InpPres0         ; je Shift- ?
         jnz       MNumKey7                 ; je Shift-

; ------ n hrada [+][-] -> Shift-[+][-]

         cmp       bx,4e2bh                 ; [+]
         je        MNumKey8
         cmp       bx,4a2dh                 ; [-]
         je        MNumKey8
         jmp       short MNumKey9           ; jinak ASCII kl vesa

; ------ test, zda je Shift- (nov  definice)

MNumKey5:call      far ptr InpPres0         ; test stavu p©esmyka‡e Shift
         jz        MNumKey9                 ; nen¡ p©esmyka‡ Shift-

; ------ kl vesy Shift-[+][-][*] jako ©¡dic¡

         cmp       bx,4e2bh                 ; [+]
         je        MNumKey8
         cmp       bx,4a2dh                 ; [-]
         je        MNumKey8
         cmp       bx,372ah                 ; [*]
         je        MNumKey8

; ------ test, zda je Shift-Enter

MNumKey7:cmp       bx,1c0dh                 ; Shift-Enter
         jne       MNumKey9                 ; nen¡ Enter

MNumKey8:stc                                ; CY = je ©¡dic¡ kl vesa
         ret

MNumKey9:clc                                ; NC = je ASCII kl vesa
         ret

MNumKey  ENDP

; -----------------------------------------------------------------------------
;        aktualizace na‡ten¡ oken
; -----------------------------------------------------------------------------

MainRead PROC      FAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ test, zda je aktivn¡ okno zapnuto

         call      far ptr TestAAWn         ; test, zda je aktivn¡ okno zapnuto
         jnc       MainRe02
         jmp       MainRea4                 ; aktivn¡ okno nen¡ zapnuto

; ------ test, zda m  b˜t v aktivn¡m oknˆ strom

MainRe02:mov       di,offset SegmL          ; segment lev‚ho okna
         mov       si,offset ParamL         ; lev‚ okno
         test      byte ptr ds:[WindPar],bit0 ; je aktivn¡ lev‚ okno ?
         jnz       MainRea1                 ; je aktivn¡ lev‚ okno
         mov       di,offset SegmR          ; segment prav‚ho okna
         mov       si,offset ParamR         ; prav‚ okno
MainRea1:test      byte ptr ds:[si],bit2    ; je v oknˆ zobrazen strom ?
         jz        MainRea3                 ; v aktivn¡m oknˆ nen¡ strom

; ------ test, zda je v aktivn¡m oknˆ strom

         mov       ax,ds:[di]               ; segment aktivn¡ho okna
         call      far ptr GetDat           ; adresa aktivn¡ho okna
         jc        MainRea2                 ; chyba ?
         test      byte ptr es:[AWinPrm1],bit4 ; je v oknˆ strom ?
         jnz       MainRea3                 ; v oknˆ je strom

; ------ vytvo©en¡ okna stromu

MainRea2:xor       byte ptr ds:[si],bit1+bit2 ; zapnut¡ adres ©e
         call      far ptr CreatTWn         ; otev©en¡ okna stromu
         jc        MainRea3
         mov       ds:[di],ax               ; segment aktivn¡ho okna
         xor       byte ptr ds:[si],bit1+bit2 ; zobrazen strom
         call      far ptr InitDInf         ; na‡ten¡ diskov˜ch informac¡
         call      far ptr AktIWin          ; aktualizace oken
         call      far ptr InitTWn          ; inicializace okna

; ------ na‡ten¡ obsahu aktivn¡ho okna

MainRea3:mov       ax,ds:[di]               ; segment aktivn¡ho okna
         call      far ptr GetDat           ; adresa aktivn¡ho okna
         jc        MainRea4
         test      byte ptr es:[AWinPrm1],bit3 ; je to adres © ?
         jz        MainRea4                 ; nen¡ to adres ©

         test      byte ptr es:[AWinPrm0],bit2
         jz        MainRe32                 ; diskov‚ informace nezn m‚

         test      byte ptr es:[AWinPrm1],bit1 ; je adres © na‡ten ?
         jnz       MainRea4                 ; adres © je na‡ten
MainRe32:mov       cx,es:[AWinSouN]         ; po‡et polo‘ek v adres ©i
;         call      far ptr ReadDir ;X         ; nov‚ na‡ten¡ adres ©e
         call      far ptr ReReadD
         call      far ptr NulBreak         ; pro dal¨¡ okno ignorov n¡ p©eru¨en¡
;         mov       ds:[di],ax               ; nov˜ segment okna
         call      far ptr AktIWin          ; aktualizace oken
         or        cx,cx                    ; byly ji‘ nˆjak‚ polo‘ky ?
         jnz       MainRea4                 ; byly ji‘ nˆjak‚ polo‘ky
         call      far ptr ReRetWK          ; n vrat kurzoru

; ------ test, zda je neaktivn¡ okno zapnuto

MainRea4:call      far ptr TestNAWn         ; test, zda je aktivn¡ okno zapnuto
         jnc       MainRe42
         jmp       MainRea8                 ; aktivn¡ okno nen¡ zapnuto

; ------ test, zda m  b˜t v neaktivn¡m oknˆ strom

MainRe42:mov       di,offset SegmL          ; segment lev‚ho okna
         mov       si,offset ParamL         ; lev‚ okno
         test      byte ptr ds:[WindPar],bit0 ; je aktivn¡ lev‚ okno ?
         jz        MainRea5                 ; je aktivn¡ prav‚ okno
         mov       di,offset SegmR          ; segment prav‚ho okna
         mov       si,offset ParamR         ; prav‚ okno
MainRea5:test      byte ptr ds:[si],bit2    ; je v oknˆ zobrazen strom ?
         jz        MainRea7                 ; v neaktivn¡m oknˆ nen¡ strom

; ------ test, zda je v neaktivn¡m oknˆ strom

         mov       ax,ds:[di]               ; segment aktivn¡ho okna
         call      far ptr GetDat           ; adresa aktivn¡ho okna
         jc        MainRea6                 ; chyba ?
         test      byte ptr es:[AWinPrm1],bit4 ; je v oknˆ strom ?
         jnz       MainRea7                 ; v oknˆ je strom

; ------ vytvo©en¡ okna stromu

MainRea6:xor       byte ptr ds:[si],bit1+bit2 ; zapnut¡ adres ©e
         call      far ptr CreatTWn         ; otev©en¡ okna stromu
         jc        MainRea7
         mov       ds:[di],ax               ; segment aktivn¡ho okna
         xor       byte ptr ds:[si],bit1+bit2 ; zobrazen strom
         call      far ptr InitDInf         ; na‡ten¡ diskov˜ch informac¡
         call      far ptr AktIWin          ; aktualizace oken
         call      far ptr InitTWn          ; inicializace okna

; ------ na‡ten¡ obsahu neaktivn¡ho okna

MainRea7:mov       ax,ds:[di]               ; segment aktivn¡ho okna
         call      far ptr GetDat           ; adresa aktivn¡ho okna
         jc        MainRea8
         test      byte ptr es:[AWinPrm1],bit3 ; je to adres © ?
         jz        MainRea8                 ; nen¡ to adres ©

         test      byte ptr es:[AWinPrm0],bit2
         jz        MainRe72                 ; diskov‚ informace nezn m‚

         test      byte ptr es:[AWinPrm1],bit1 ; je adres © na‡ten ?
         jnz       MainRea8                 ; adres © je na‡ten
MainRe72:mov       cx,es:[AWinSouN]         ; po‡et polo‘ek v adres ©i
;         call      far ptr ReadDir ;X         ; nov‚ na‡ten¡ adres ©e
         call      far ptr ReReadD
         call      far ptr NulBreak         ; pro dal¨¡ okno ignorov n¡ p©eru¨en¡
;         mov       ds:[di],ax               ; nov˜ segment okna
         call      far ptr AktIWin          ; aktualizace oken
         or        cx,cx                    ; byly ji‘ nˆjak‚ polo‘ky ?
         jnz       MainRea8                 ; byly ji‘ nˆjak‚ polo‘ky
         call      far ptr ReRetWK          ; n vrat kurzoru

; ------ n vrat registr–

MainRea8:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

MainRead ENDP

; -----------------------------------------------------------------------------
;        inicializace COUNTRY informac¡
; -----------------------------------------------------------------------------

InitCntr PROC      NEAR

         cmp       word ptr ds:[VerzeOS],2*HI + 11
         jb        InitCnt9

         mov       dx,offset COUNTRY        ; buffer COUNTRY informac¡
         mov       ax,3800h
         int       21h                      ; na‡ten¡ COUNTRY informac¡

         mov       al,byte ptr ds:[CNTRFDat] ; form t data
         cmp       al,2
         ja        InitCnt2
         mov       ds:[FormDat],al          ; form t data

InitCnt2:mov       al,ds:[CNTRTis]          ; oddˆlova‡ tis¡c–
         or        al,al
         jz        InitCnt3
         mov       ds:[OddelRad],al         ; oddˆlova‡ tis¡c–

InitCnt3:mov       al,ds:[CNTRDes]          ; oddˆlova‡ desetin
         or        al,al
         jz        InitCnt4
         mov       ds:[OddelDes],al         ; oddˆlova‡ desetin

InitCnt4:mov       al,ds:[CNTRSezn]         ; oddˆlova‡ dat
         or        al,al
         jz        InitCnt5
         mov       ds:[OddelPol],al         ; oddˆlova‡ dat

InitCnt5:mov       al,ds:[CNTRTim]          ; oddˆlova‡ ‡asu
         or        al,al
         jz        InitCnt6
         mov       ds:[ZnakTim],al          ; oddˆlova‡ ‡asu

InitCnt6:mov       al,ds:[CNTRDat]          ; oddˆlova‡ data
         or        al,al
         jz        InitCnt7
         mov       ds:[ZnakDat],al          ; oddˆlova‡ data

; ------ oprava znak–

InitCnt7:call      KorCntr                  ; korekce narodnich informaci

InitCnt9:ret

InitCntr ENDP

; -----------------------------------------------------------------------------
;        korekce narodnich informaci
; -----------------------------------------------------------------------------

KorCntr  PROC      NEAR

         mov       al,ds:[OddelPol]         ; oddelovac dat
         or        al,al
         jz        InitCn71
         cmp       al," "
         je        InitCn71
         cmp       al,ds:[OddelRad]
         je        InitCn71
         cmp       al,ds:[OddelDes]
         jne       InitCn72
InitCn71:mov       byte ptr ds:[OddelPol],";"

InitCn72:mov       al,ds:[OddelDes]
         or        al,al
         jz        InitCn73
         cmp       al," "
         je        InitCn73
         cmp       al,ds:[OddelPol]
         je        InitCn73
         cmp       al,ds:[OddelRad]
         jne       InitCn74
InitCn73:mov       byte ptr ds:[OddelDes],"."

InitCn74:mov       al,ds:[OddelRad]
         or        al,al
         jz        InitCn75
         cmp       al," "
         je        InitCn75
         cmp       al,ds:[OddelPol]
         je        InitCn75
         cmp       al,ds:[OddelDes]
         jne       InitCn76
InitCn75:mov       byte ptr ds:[OddelRad],"'"

InitCn76:ret

KorCntr  ENDP

; -----------------------------------------------------------------------------
;        inicializace WINDOWS (dlouh  jm‚na soubor– WINDOWS 95)
; -----------------------------------------------------------------------------

InitW95  PROC      NEAR

         and       byte ptr ds:[ParDisp],not bit7 ; neinicializuje se displej

         or        byte ptr ds:[Win95Par],bit3 ; p©¡znak, ‘e jsou WINDOWS
         or        byte ptr ds:[ParDisp],bit7 ; displej se inicializuje v‘dy

InitW951:or        byte ptr ds:[Win95Par],bit2 ; nen¡ WINDOWS 95
         cmp       byte ptr ds:[VerzeOS+1],7 ; je DOS 7.0
         jb        InitW952                 ; je n¡zk  verze syst‚mu

         mov       ax,71a1h
         mov       bx,0fedch                ; nesmysln˜ identifik tor
         xor       si,si
         int       21h                      ; je operace podporov na ?
         cmp       ax,7100h                 ; je operace podporov na ?
         je        InitW952                 ; operace nen¡ podporov na

         and       byte ptr ds:[Win95Par],not bit2 ; jsou dlouh  jm‚na soubor–
InitW952:ret

InitW95  ENDP

; -----------------------------------------------------------------------------
;        stisk lev‚ho/prav‚ho tla‡¡tka my¨i (mus¡ n sledovat AWMous2 !)
; -----------------------------------------------------------------------------
;þ
; ------ vyvol n¡ hlavn¡ho menu, je-li prvn¡ © dek

AWMous1: cmp       byte ptr ds:[MousePoz+1],0 ; je prvn¡ © dek ?
         jne       AWMous11                 ; nen¡ prvn¡ © dek
         jmp       AWMMnu                   ; obsluha hlavn¡ho menu F10

; ------ p©¡prava ukazatel– lev‚ho okna

AWMous11:xor       dx,dx                    ; © dek a pozice pro okno 1
         mov       cl,ds:[Pozic]            ; po‡et pozic displeje
         sub       cl,80                    ; zbytek na okraje
         jbe       AWMou112                 ; nen¡ ¨irok˜ displej
         shr       cl,1                     ; polovi‡n¡ okraj
         mov       dl,cl                    ; pozice pro ¨irok˜ displej
AWMou112:mov       cl,40                    ; ¨¡©ka okna
         mov       ch,ds:[NumRows]          ; v˜¨ka oken
         test      byte ptr ds:[ParMenu],bit0 ; je trval‚ hlavn¡ menu ?
         jz        AWMous12                 ; nen¡ trval‚ hlavn¡ menu
         mov       dh,1                     ; po‡ te‡n¡ © dek okna

; ------ test, zda je lev‚ okno

AWMous12:call      far ptr MouseWin         ; test, zda je v oknˆ
         jc        AWMous15                 ; nen¡ lev‚ okno

; ------ zapnut¡ lev‚ho okna

         test      byte ptr ds:[ParamL],bit0 ; je okno zapnuto ?
         jnz       AWMous14                 ; je zapnuto
AWMous13:mov       bx,5e00h                 ; kl vesa Ctrl-F1
         jmp       short AWMous17           ; zapnut¡ lev‚ho okna

; ------ test, zda je horn¡ li¨ta lev‚ho okna (vypnut¡ okna)

AWMous14:push      cx
         mov       ch,3                     ; v˜¨ka li¨ty
         call      far ptr MouseWin         ; test, zda je horn¡ li¨ta
         pop       cx
         jnc       AWMous13                 ; je horn¡ li¨ta - vypnut¡


; ------ test, zda je prav‚ okno

AWMous15:add       dl,40                    ; pozice prav‚ho okna
         call      far ptr MouseWin         ; test, zda je v oknˆ
         jc        AWMous19                 ; nen¡ prav‚ okno

; ------ zapnut¡ prav‚ho okna

         test      byte ptr ds:[ParamR],bit0 ; je okno zapnuto ?
         jnz       AWMous18                 ; je zapnuto
AWMous16:mov       bx,5f00h                 ; kl vesa Ctrl-F2
AWMous17:jmp       Main7                    ; zapnut¡ prav‚ho okna

; ------ test, zda je horn¡ li¨ta prav‚ho okna (vypnut¡ okna)

AWMous18:mov       ch,3                     ; v˜¨ka li¨ty
         call      far ptr MouseWin         ; test, zda je horn¡ li¨ta
         jnc       AWMous16                 ; je horn¡ li¨ta

; ------ veden¡ kurzoru my¨i (jsou soubory, okno je zapnuto)

AWMous19:
                                           ;* n sleduje AWMous2 !

; -----------------------------------------------------------------------------
;        veden¡ kurzoru my¨¡ (mus¡ n sledovat za AWMous1 !)
; -----------------------------------------------------------------------------
;þ
; ------ p©¡prava ukazatel– okna

AWMous2: xor       dx,dx                    ; po‡ te‡n¡ © dek a pozice
         mov       cl,ds:[Pozic]            ; po‡et pozic displeje
         sub       cl,80                    ; zbytek na okraje
         jbe       AWMou202                 ; nen¡ ¨irok˜ displej
         shr       cl,1                     ; polovi‡n¡ okraj
         mov       dl,cl                    ; pozice pro ¨irok˜ displej
AWMou202:mov       cl,40                    ; ¨¡©ka okna
         mov       ch,ds:[NumRows]          ; v˜¨ka oken
         test      byte ptr ds:[ParMenu],bit0 ; je trval‚ hlavn¡ menu ?
         jz        AWMous21                 ; nen¡ trval‚ hlavn¡ menu
         mov       dh,1                     ; po‡ te‡n¡ © dek, je-li menu

; ------ ukon‡en¡ ozna‡ov n¡, nen¡-li prav‚ tla‡¡tko

AWMous21:test      byte ptr ds:[MouseKey],bit1 ; je prav‚ tla‡¡tko my¨i ?
         jnz       AWMous22                 ; je prav‚ tla‡¡tko my¨i
         and       byte ptr ds:[DMMousS],not bit0 ; ukon‡en¡ ozna‡ov n¡

; ------ test, zda je lev‚ okno (a zda je zapnuto)

AWMous22:call      far ptr MouseWin         ; test, zda je v oknˆ
         jc        AWMous25                 ; nen¡ lev‚ okno
         test      byte ptr ds:[ParamL],bit0 ; je okno zapnuto ?
         jz        AWMous25                 ; nen¡ zapnuto

; ------ test, zda je lev‚ okno aktivn¡

         test      byte ptr ds:[WindPar],bit0 ; je lev‚ okno aktivn¡ ?
         jnz       AWMous26                 ; je aktivn¡ - obsluha okna
AWMous23:mov       bx,0f09h                 ; tabul tor
         jmp       short AWMous17           ; p©epnut¡ oken

; ------ test, zda je prav‚ okno

AWMous25:add       dl,40                    ; pozice prav‚ho okna
         call      far ptr MouseWin         ; test, zda je v oknˆ
         jc        AWMous29                 ; nen¡ prav‚ okno
         test      byte ptr ds:[ParamR],bit0 ; je okno zapnuto ?
         jz        AWMous29                 ; nen¡ zapnuto

; ------ test, zda je prav‚ okno aktivn¡

         test      byte ptr ds:[WindPar],bit0 ; je prav‚ okno aktivn¡ ?
         jnz       AWMous23                 ; nen¡ aktivn¡

; ------ obsluha okna (veden¡ kurzoru my¨¡)

AWMous26:mov       ax,ds:[SegmAkt]          ; segment aktivn¡ho okna
         call      AWMouW                   ; obsluha okna

; ------ obsluha ozna‡ov n¡ polo‘ek my¨¡

         pushf
         mov       ax,ds:[SegmAkt]          ; segment aktivn¡ho okna
         call      AWMousS                  ; obsluha ozna‡ov n¡ my¨¡
         popf
         jc        AWMous29                 ; nen¡ na souboru

; ------ obsluha stromu

         call      far ptr GetDat           ; adresa okna -> ES
         jc        AWMous29

         test      byte ptr es:[AWinPrm1],bit4 ; je to strom ?
         jz        AWMou268                 ; nen¡ to strom

         cmp       byte ptr ds:[MouseKey],bit0+bit2 ; je stisk lev‚ho tla‡¡tka ?
         je        AWMou269                 ; je stisk lev‚ho tla‡¡tka
         cmp       byte ptr ds:[MouseKey],bit0+bit7 ; je ta‘en¡ lev˜m tla‡¡tkem ?
         je        AWMou269                 ; je ta‘en¡ lev˜m tla‡¡tkem

         cmp       byte ptr ds:[MouseKey],bit0+bit2+bit6 ; je druh˜ stisk ?
         jne       AWMous29                 ; nen¡ druh˜ stisk lev‚ho tla‡¡tka

         call      far ptr GetAKurz         ; polo‘ka pod kurzorem
         jc        AWMous29                 ; nen¡ polo‘ka pod kurzorem

         test      byte ptr es:[si+FileTPar],bit1 ; jsou podadres ©e ?
         jz        AWMous29                 ; nejsou podadres ©e

         mov       bx,4e2bh                 ; kl vesa [+] (rozvinut¡)
         test      byte ptr es:[si+FileTPar],bit2 ; jsou podadres ©e rozvinuty ?
         jz        AWMou266                 ; nejsou rozvinuty
         mov       bx,4a2dh                 ; kl vesa [-] (svinut¡)

AWMou266:call      far ptr EditDTWn         ; obsluha okna stromu
         call      far ptr DispAAWn         ; zobrazen¡ okna stromu
AWMous29:jmp       Main0                    ; n vrat

AWMous0: and       byte ptr ds:[DMMousS],not bit0 ; ukon‡en¡ ozna‡ov n¡
         jmp       short AWMous29

; ------ dvoj¡ stisk - start programu nebo zmˆna adres ©e

AWMou268:cmp       byte ptr ds:[MouseKey],bit0+bit2+bit6 ; je druh˜ stisk ?
         jne       AWMous27                 ; nen¡ druh˜ stisk
AWMou269:jmp       AWEnter                  ; proveden¡ p©¡kazu

AWMous27:
         jmp       short AWMous29

; -----------------------------------------------------------------------------
;        obsluha ozna‡ov n¡ my¨¡
; -----------------------------------------------------------------------------

AWMousS  PROC      NEAR

         test      byte ptr ds:[MouseKey],bit1 ; je prav‚ tla‡¡tko my¨i ?
         jz        AWMousS9                 ; nen¡ prav‚ tla‡¡tko my¨i

         call      far ptr GetAKurz         ; poskytnut¡ polo‘ky pod kurzorem
         jc        AWMousS9                 ; nen¡ ‘ dn  polo‘ka

         test      byte ptr ds:[MouseKey],bit3 ; je stisk prav‚ho tla‡¡tka ?
         jz        AWMousS4                 ; nen¡ stisk prav‚ho tla‡¡tka my¨i
         or        byte ptr ds:[DMMousS],bit0+bit1 ; p©¡znak zah jen¡ ozna‡ov n¡
         test      byte ptr es:[si+FileAtr],ATRO ; je polo‘ka ozna‡ena ?
         jz        AWMousS4                 ; polo‘ka nen¡ ozna‡ena
         and       byte ptr ds:[DMMousS],not bit1 ; bude odzna‡ov n¡

AWMousS4:test      byte ptr ds:[DMMousS],bit0 ; je zah jeno ozna‡ov n¡ ?
         jz        AWMousS9                 ; nen¡ zah jeno ozna‡ov n¡
         test      byte ptr ds:[DMMousS],bit1 ; je ozna‡ov n¡ ?
         jnz       AWMousS6                 ; je ozna‡ov n¡
         test      byte ptr es:[si+FileAtr],ATRO ; je polo‘ka ji‘ odzna‡ena ?
         jz        AWMousS9                 ; polo‘ka je ji‘ odzna‡ena
         jmp       short AWMousS8           ; odzna‡en¡ polo‘ky

AWMousS6:test      byte ptr es:[si+FileAtr],ATRO ; je polo‘ka ji‘ ozna‡ena ?
         jnz       AWMousS9                 ; polo‘ka je ji‘ ozna‡ena

AWMousS8:call      far ptr GetAAWin         ; poskytnut¡ adresy aktivn¡ho okna
         mov       bx,es:[AWinKurz]         ; kurzor
         call      far ptr InvSPol          ; zmˆna ozna‡en¡ polo‘ky
AWMousS9:ret

AWMousS  ENDP

; -----------------------------------------------------------------------------
;        obsluha okna AX my¨i, pozice DX, rozmˆry CX -> CY=nen¡ na souboru
; -----------------------------------------------------------------------------

AWMouW   PROC      NEAR

; ------ adresa okna -> ES

         call      far ptr GetDat           ; adresa okna
         jc        AWMouW9                  ; nen¡ na souboru

; ------ relativn¡ pozice kurzoru my¨i -> DX

AWMouW11:push      ax
         mov       ax,ds:[MousePoz]         ; pozice kurzoru my¨i
         sub       al,dl                    ; relativn¡ pozice
         jnc       AWMouW1                  ; nen¡ podte‡en¡
         mov       al,0                     ; omezen¡ p©i podte‡en¡
AWMouW1: sub       ah,dh                    ; relativn¡ © dek
         jnc       AWMouW2                  ; nen¡ podte‡en¡
         mov       ah,0                     ; omezen¡ p©i podte‡en¡
AWMouW2: xchg      ax,dx                    ; DX <- relativn¡ © dek a pozice
         pop       ax

; ------ test, zda je horn¡ li¨ta okna

         sub       dh,4                     ; po‡et © dk– na horn¡ li¨tu
         jnc       AWMouW4                  ; nen¡ horn¡ li¨ta

; ------ p©i stisku lev‚ho tla‡¡tka my¨i posun o str nku nahoru

         mov       bx,4800h                 ; kurzor nahoru
         cmp       byte ptr ds:[MouseKey],MousXLH ; je dr‘en¡ lev‚ho tla‡¡tka ?
         je        AWMouW3                  ; rolov n¡ © dk–
         cmp       byte ptr ds:[MouseKey],MousXRH ; je dr‘en¡ prav‚ho tla‡¡tka ?
         je        AWMouW3                  ; rolov n¡ © dk–
         test      byte ptr ds:[MouseKey],bit2 ; je stisk lev‚ho tla‡¡tka ?
         jz        AWMouW9                  ; nen¡ stisk lev‚ho tla‡¡tka
         mov       bx,4900h                 ; str nka nahoru
AWMouW3: call      far ptr EditAWin         ; posun o str nku nahoru
         jmp       short AWMouW9

; ------ po‡et platn˜ch © dk–

AWMouW4: sub       ch,4+1                   ; ode‡ten¡ horn¡ a doln¡ li¨ty
         test      byte ptr es:[AWinPrm2],bit4 ; je stavov˜ © dek souboru ?
         jnz       AWMouW5                  ; nen¡ stavov˜ © dek soubory
         sub       ch,2                     ; ode‡ten¡ stavov‚ho © dku

; ------ test, zda je spodn¡ li¨ta

AWMouW5: cmp       dh,ch
         jb        AWMouW6                  ; nen¡ spodn¡ li¨ta

; ------ p©i stisku lev‚ho tla‡¡tka my¨i posun o str nku dol–

         mov       bx,5000h                 ; kurzor dol–
         cmp       byte ptr ds:[MouseKey],MousXLH ; je dr‘en¡ lev‚ho tla‡¡tka ?
         je        AWMouW3                  ; rolov n¡ © dk–
         cmp       byte ptr ds:[MouseKey],MousXRH ; je dr‘en¡ prav‚ho tla‡¡tka ?
         je        AWMouW3                  ; rolov n¡ © dk–
         mov       bx,5100h                 ; str nka dol–
         test      byte ptr ds:[MouseKey],bit2 ; je stisk lev‚ho tla‡¡tka ?
         jnz       AWMouW3                  ; je stisk lev‚ho tla‡¡tka
AWMouW9: stc                                ; p©¡znak - nen¡ soubor
         ret

; ------ v˜po‡et ‡¡sla polo‘ky -> CX

AWMouW6: mov       cl,dh                    ; CL <- ‡¡slo © dku relativnˆ
         push      ax
         mov       al,es:[AWinPrm2]
         and       al,bit5+bit6
         cmp       al,1*bit5                ; je zkr cen‚ zobrazen¡ ?
         pop       ax
         jne       AWMouW7                  ; nejsou 3 sloupce

         sub       dl,12                    ; je prvn¡ sloupec ?
         jb        AWMouW7                  ; je prvn¡ sloupec
         add       cl,ch                    ; posun o sloupec
         sub       dl,12                    ; je druh˜ sloupec
         jb        AWMouW7                  ; je druh˜ sloupec
         add       cl,ch                    ; posun o sloupec
AWMouW7: mov       ch,0                     ; CX = polo‘ka relativnˆ

; ------ nastaven¡ aktivn¡ polo‘ky

         add       cx,es:[AWinFrst]         ; polo‘ka s kurzorem
         cmp       cx,es:[AWinSouN]         ; je p©ete‡en¡ po‡tu polo‘ek ?
         jb        AWMouW8                  ; nen¡ p©ete‡en¡ po‡tu polo‘ek
         mov       cx,es:[AWinSouN]         ; po‡et polo‘ek
         jcxz      AWMouW8                  ; nen¡ ‘ dn  polo‘ka
         dec       cx                       ; korekce na posledn¡ polo‘ku
AWMouW8: cmp       cx,es:[AWinKurz]         ; zmˆnil se kurzor ?
         je        AWMouW82                 ; kurzor se nezmˆnil
         mov       es:[AWinKurz],cx         ; nov˜ kurzor
         call      far ptr InitQVw          ; start rychloprohl¡‘en¡
         call      far ptr AktPthAT         ; aktualizace stromu v aktivn¡m oknˆ
         call      far ptr AktPthAL         ; aktualizace cesty okna seznamu
         call      far ptr DispAWin         ; zobrazen¡ okna
AWMouW82:clc                                ; p©¡znak - je na kurzoru
         ret

AWMouW   ENDP

; -----------------------------------------------------------------------------
;        F1 - n povˆda, Shift-F1 - n povˆda
; -----------------------------------------------------------------------------

AWSHelp: mov       ax,ds:[HlpAStrn]         ; naposledy zvolen  str nka
         jmp       short AWHelp1

AWHelp:  mov       ax,Hlp@Main              ; hlavn¡ str nka
AWHelp1: call      far ptr HelpF            ; n povˆda
         jmp       Main0

;; -----------------------------------------------------------------------------
;;        Ctrl-F10 - nastaven¡ konfigurace
;; -----------------------------------------------------------------------------
;
;AWCInit: jmp       far ptr NastIniF         ; nastaven¡ konfigurace

; -----------------------------------------------------------------------------
;        Alt-\ historie oken
; -----------------------------------------------------------------------------

AWHistW0 label     FAR                      ; proveden¡ funkce z menu

         add       sp,4                     ; zru¨en¡ n vratov‚ adresy
         call      far ptr ClosMnuA         ; uzav©en¡ v¨ech menu
         mov       ax,ds:[SegmL]            ; segment lev‚ho okna
         test      byte ptr ds:[WindPar],bit4 ; je lev‚ okno ?
         jnz       AWHistW1                 ; je lev‚ okno
         mov       ax,ds:[SegmR]            ; segment prav‚ho okna
         jmp       short AWHistW1

AWHistW: call      far ptr QSrcEnd          ; ukon‡en¡ re‘imu rychlovyhled v n¡
         mov       ax,ds:[SegmAkt]          ; segment aktivn¡ho okna

AWHistW1:mov       si,offset HWMnuLin       ; menu nastaven¡ adres ©e
         call      far ptr Lin0Menu         ; volba adres ©e
         jc        AWHistW6                 ; p©eru¨en¡ operace

         call      far ptr NormFilL         ; normalizace jm‚na souboru
         jcxz      AWHistW9
         call      far ptr SetDDir          ; nastaven¡ disku a adres ©e
         jc        AWHistW6

         mov       di,offset ParamR         ; parametry prav‚ho okna
         cmp       ax,ds:[SegmR]            ; je to prav‚ okno ?
         je        AWHistW2                 ; je to prav‚ okno
         mov       di,offset ParamL         ; parametry lev‚ho okna
AWHistW2:or        byte ptr ds:[di],bit0    ; p©¡znak zapnut¡ okna
         or        byte ptr ds:[WindPar],bit1 ; p©¡znak zapnut¡ oken

         call      far ptr GetDat           ; poskytnut¡ adresy okna

         mov       di,AWinDir               ; buffer k na‡ten¡ adres ©e
         call      far ptr GetADir          ; poskytnut¡ aktivn¡ cesty
AWHistW6:jc        AWHistW9                 ; chyba

         mov       es:[AWinDNum],cx         ; po‡et bajt–
         mov       cl,es:[di]
         sub       cl,"A"
         mov       ch,cl                    ; CH <- nov˜ disk
         xchg      cl,es:[AWinDisk]         ; ‡¡slo nov‚ho aktivn¡ho disku

         cmp       ax,ds:[SegmAkt]          ; je to aktivn¡ okno ?
         jne       AWHistW8                 ; nen¡ to aktivn¡ okno
         cmp       cl,ch                    ; byl disk zmˆnˆn ?
         je        AWHistW8                 ; disk nebyl zmˆnˆn

         call      far ptr GetNAWin         ; adresa neaktivn¡ho okna
         cmp       cl,es:[AWinDisk]         ; byt p©edt¡m disk stejn˜ ?
         jne       AWHistW8                 ; disk p©edt¡m nebyl stejn˜
         mov       si,AWinDir               ; adres © neaktivn¡ho okna
         call      far ptr SetDir           ; nastaven¡ adres ©e neaktivn¡ho okna

AWHistW8:call      far ptr ReReadD          ; nov‚ na‡ten¡ okna
         call      far ptr NulBreak         ; pro dal¨¡ okno ignorov n¡ p©eru¨en¡

         call      far ptr GetAAWin         ; poskytnut¡ aktivn¡ho okna
         mov       si,AWinDir               ; buffer adres ©e
         call      far ptr SetDDir          ; nastaven¡ disku a adres ©e

         call      far ptr NulBreak         ; pro dal¨¡ okno ignorov n¡ p©eru¨en¡
         jmp       AWEntr72

;         call      far ptr AktADir          ; aktualizace adres ©e podle okna
;         call      far ptr DispAll          ; zobrazen¡ cel‚ obrazovky

AWHistW9:jmp       Main0

; -----------------------------------------------------------------------------
;        Shift-Esc  n vrat posledn¡ho menu
; -----------------------------------------------------------------------------

AWCMenu: or        byte ptr ds:[ParMenu],bit4 ; p©¡znak autom. vno©en¡ do menu
         test      byte ptr ds:[ParMenu],bit6 ; bylo u‘ivatelsk‚ menu ?
         jz        AWMMnu                   ; nebylo u‘ivatelsk‚ menu - je F10
                                          ;* pokra‡uje F10 a F2 !!!

; -----------------------------------------------------------------------------
;        F2 - u‘ivatelsk‚ menu
; -----------------------------------------------------------------------------

AWMenu   PROC      NEAR

         or        byte ptr ds:[ParMenu],bit6 ; je u‘ivatelsk‚ menu
         jmp       far ptr UserMenu

AWMenu   ENDP

; -----------------------------------------------------------------------------
;        F10 - hlavn¡ menu
; -----------------------------------------------------------------------------

AWMMnu   PROC      NEAR

         and       byte ptr ds:[ParMenu],not bit6 ; nebylo u‘ivatelsk‚ menu
         test      byte ptr ds:[WindPar],bit3 ; je re‘im rychlovyhled v n¡ ?
         jz        AWMMnu2

         call      far ptr QSrcEnd          ; ukon‡en¡ re‘imu rychlovyhled v n¡
         call      far ptr DispAAWn         ; zobrazen¡ aktivn¡ho okna

AWMMnu2: mov       si,offset AMnuMain       ; hlavn¡ adres ©ov‚ menu
         call      far ptr MainMenu         ; obsluha volby hlavn¡ho menu
         jmp       Main0                    ; p©eru¨en¡ volby

AWMMnu   ENDP

; ------ n vrat z menu Konec

AWMMnu0  LABEL     FAR

         add       sp,4
         call      far ptr ClosMnuA         ; uzav©en¡ menu
         jmp       Main0

; -----------------------------------------------------------------------------
;        Podmenu "Zvl ¨tn¡"
; -----------------------------------------------------------------------------

AWMMnuZ  PROC      FAR

         jmp       far ptr VertMenu         ; obsluha vertik ln¡ho menu

AWMMnuZ  ENDP

; -----------------------------------------------------------------------------
;        Podmenu "Soubory"
; -----------------------------------------------------------------------------

AWMMnuS  PROC      FAR

; ------ £schova registr–

         push      si
         push      es

; ------ povolen¡ v¨ech polo‘ek

         mov       di,offset SMnuVBlk       ; blokovac¡ tabulka menu
         mov       cx,16                    ; po‡et polo‘ek v tabulce
AWMMnuS1:and       byte ptr ds:[di],not bit1 ; polo‘ka povolena
         inc       di
         loop      AWMMnuS1

; ------ z kaz polo‘ky "Srovn n¡"

         call      far ptr TestNAWn         ; zapnuto neaktivn¡ okno ?
         jc        AWMMnuS2                 ; nen¡ zapnuto neaktivn¡ okno
         test      byte ptr ds:[ParamL],bit2 ; je to strom ?
         jnz       AWMMnuS2                 ; strom nepovolen
         test      byte ptr ds:[ParamR],bit2 ; strom ?
         jz        AWMMnuS3                 ; strom nepovolen
AWMMnuS2:or        byte ptr ds:[SMnuVBlk+12],bit1 ; z kaz polo‘ky "Srovn n¡"

; ------ z kaz polo‘ky "Informace"

AWMMnuS3:call      far ptr TestAAWn         ; test aktivn¡ho okna
         jc        AWMMnuS4                 ; nen¡ zapnuto
         call      far ptr GetAKurz         ; poskytnut¡ adresy kurzoru
         jc        AWMMnuS4                 ; nen¡ polo‘ka pod kurzorem
         test      byte ptr es:[si+FileAtr],ATRT ; je to platn  polo‘ka ?
         jnz       AWMMnuS5                 ; je to platn  polo‘ka OK
AWMMnuS4:or        byte ptr ds:[SMnuVBlk+5],bit1 ; z kaz polo‘ky "Informace"


AWMMnuS5:


; ------ n vrat registr– a skok do menu

         pop       es
         pop       si
         jmp       far ptr VertMenu         ; obsluha vertik ln¡ho menu

AWMMnuS  ENDP

; -----------------------------------------------------------------------------
;        Podmenu "Disk"
; -----------------------------------------------------------------------------

AWMMnuD  PROC      FAR

         mov       al,ds:[AktPath]          ; aktivn¡ disk
         mov       ds:[DMnuVTit+6],al       ; aktivn¡ disk

         jmp       far ptr VertMenu         ; obsluha vertik ln¡ho menu

AWMMnuD  ENDP

; -----------------------------------------------------------------------------
;        Podmenu "N povˆda"
; -----------------------------------------------------------------------------

AWMMnuN  PROC      FAR

         mov       dl,bit0                  ; odkazy zapnuty
         test      byte ptr ds:[HelpPar],bit5 ; zapnuty odkazy ?
         jnz       AWMMnuN1                 ; odkazy zapnuty
         mov       dl,0                     ; odkazy vypnuty
AWMMnuN1:call      far ptr SetSwch          ; nastaven¡ p©ep¡na‡–

         jmp       far ptr VertMenu         ; obsluha vertik ln¡ho menu

AWMMnuN  ENDP

; -----------------------------------------------------------------------------
;        Podmenu "Konec"
; -----------------------------------------------------------------------------

AWMMnuK  PROC      FAR

         jmp       far ptr VertMenu         ; obsluha vertik ln¡ho menu

;; ------ zmˆna p©ep¡na‡e ukl d n¡ konfigurace
;
;AWMMnuK3 LABEL     FAR
;
;         xor       dl,bit0
;         call      far ptr SetSwch          ; nastaven¡ p©ep¡na‡e
;         call      far ptr DispMnu          ; nov‚ zobrazen¡ menu
;         jmp       short AWMMnuK            ; pokra‡ov n¡ v obsluze menu

AWMMnuK  ENDP

; -----------------------------------------------------------------------------
;        Ctrl-Q rychloprohl¡‘en¡
; -----------------------------------------------------------------------------

AWCtrlQ: call      far ptr GetAAWin         ; aktivn¡ okno
         jc        AWCtrlQ9

         test      byte ptr es:[AWinPrm1],bit4 ; je strom ?
         jz        AWCtrlQ3                 ; nen¡ strom
         xor       byte ptr ds:[WindPar2],bit5 ; zmˆna p©¡znaku Autodir

AWCtrlQ3:


AWCtrlQ9:jmp       Main0

; -----------------------------------------------------------------------------
;        Ctrl-mezera informace o souboru
; -----------------------------------------------------------------------------

AWAEnt   PROC      NEAR

         jmp       far ptr InfoFile         ; informace o souboru

AWAEnt   ENDP

; -----------------------------------------------------------------------------
;        Ctrl-Enter jm‚no souboru pod kurzorem
; -----------------------------------------------------------------------------

AWCEnt   PROC      NEAR

         call      far ptr InpPres0         ; test p©esmyka‡e Shift-
         jz        AWCEnt1                  ; nen¡ p©esmyka‡ Shift-
         call      AWSEnt                   ; vstup adres ©e

; ------ test, zda je okno zapnuto

AWCEnt1: call      far ptr QSrcEnd          ; ukon‡en¡ re‘imu rychlovyhled v n¡
         call      far ptr TestAAWn         ; test aktivn¡ho okna
         jc        AWCEnt9                  ; okno nen¡ zapnuto

; ------ polo‘ka pod kurzorem

         call      far ptr GetAKurz         ; poskytnut¡ polo‘ky pod kurzorem
         jc        AWCEnt9                  ; nen¡ ‘ dn  polo‘ka
         mov       dl,es:[si+FileAtr]       ; atributy
         test      dl,ATRT
         jz        AWCEnt9
         and       dl,DIR
         xor       dl,DIR
         shl       dl,1                     ; pro DIR = 0, soubor = 20h

; ------ dek¢dov n¡ jm‚na souboru do bufferu v z sobn¡ku

         mov       bp,sp
         sub       sp,FileMax
         mov       di,sp

         push      ds

         push      ss
         push      es
         pop       ds
         pop       es
         inc       si
         call      far ptr FileAsc          ; dek¢dov n¡ jm‚na souboru na ASCIIZ

         pop       ds

; ------ p©enesen¡ jm‚na souboru do p©¡kazov‚ho © dku

         mov       si,sp
AWCEnt2: mov       bl,es:[si]
         cmp       bl,"A"
         jb        AWCEnt3
         cmp       bl,"Z"
         ja        AWCEnt3
         add       bl,dl

AWCEnt3: inc       si
         mov       bh,0
         or        bx,bx
         jz        AWCEnt4
         call      far ptr EditLCom         ; vlo‘en¡ znaku do © dku
         jmp       short AWCEnt2

AWCEnt4: mov       bl," "
         call      far ptr EditLCom         ; vlo‘en¡ koncov‚ mezery

         mov       sp,bp

AWCEnt9: jmp       Main0

AWCEnt   ENDP

; -----------------------------------------------------------------------------
;        vstup aktu ln¡ho adres ©e do p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

AWSEnt   PROC      NEAR

         mov       si,offset AktPath        ; aktu ln¡ adres ©
         mov       cx,ds:[AktPathN]
AWSEnt1: cld
         lodsb
         mov       ah,0
         xchg      ax,bx
         call      far ptr EditLCom
         loop      AWSEnt1
         cmp       byte ptr ds:[si-1],"\"
         je        AWSEnt2
         mov       bx,"\"
         call      far ptr EditLCom
AWSEnt2: ret

AWSEnt   ENDP

; -----------------------------------------------------------------------------
;        Ctrl-\ zmˆna adres ©e
; -----------------------------------------------------------------------------

AWRootD: call      far ptr InpPres0         ; vstup p©esmyka‡–
         jnz       AWRootD1                 ; je Shift

         call      far ptr GetAKurz         ; kurzor aktivn¡ho okna
         jc        AWEntr09
         test      byte ptr es:[si+FileAtr],DIR ; je to adres © ?
         jnz       AWEntr01                 ; je to adres ©
         jmp       short AWEntr09

AWRootD1:call      far ptr QSrcEnd          ; ukon‡en¡ rychlovyhled v n¡
         call      far ptr TestAAWn         ; test aktivn¡ho okna
         jc        AWEntr09                 ; nen¡ zapnuto

         mov       ax,ds:[SegmAkt]          ; segment aktivn¡ho okna
         call      far ptr GetDat           ; adresa aktivn¡ho okna
         jc        AWEntr09

         test      byte ptr es:[AWinPrm1],bit5 ; je to seznam ?
         jnz       AWEntr09                 ; pro seznam nic

; ------ £schova za‡ tku cesty (do bufferu FileFCB)

         push      es

         push      ds
         pop       es
         mov       si,offset AktPath+3-DTAName
         call      far ptr GetBFCB          ; konverze na polo‘ku FCB

         mov       byte ptr ds:[AktPath+3],0 ; konec aktivn¡ho adres ©e
         mov       byte ptr ds:[AktPathN],3 ; d‚lka textu adres ©e

         pop       es

         test      byte ptr es:[AWinPrm1],bit4 ; je to strom ?
         jnz       AWEnt014                 ; zmˆna cesty pro strom

; ------ duplikace okna AX -> BX segment, ES adresa

         mov       ax,ds:[SegmAkt]          ; aktivn¡ okno
         call      far ptr DuplAWin         ; duplikace okna
         jc        AWEntr09

; ------ nastaven¡ adres ©e

         push      ds
         pop       es
         mov       si,offset AktPath
         call      far ptr SetDDir          ; nastaven¡ adres ©e a disku

; ------ adresa nov‚ho okna

         xchg      ax,bx
         call      far ptr GetDat           ; adresa okna
         xchg      ax,bx
         jmp       AWEntr44                 ; na‡ten¡ okna

; -----------------------------------------------------------------------------
;        ^M Enter - p©¡kaz, zmˆna adres ©e
; -----------------------------------------------------------------------------

AWEnter0 LABEL     FAR

AWEnter:
         call      far ptr InpPres0         ; test p©esmyka‡e Shift-
         jz        AWEntr01                 ; nen¡ p©esmyka‡ Shift-
         call      AWSEnt                   ; vstup adres ©e
         jmp       Main0

AWEntr01:call      far ptr QSrcEnd          ; ukon‡en¡ re‘imu rychlovyhled v n¡
         call      far ptr TestAAWn         ; test, zda je okno zapnuto
         jnc       AWEnt010

;         jc        AWEnt011                 ; okno nen¡ zapnuto
AWEntr09:jmp       AWEnter9

; ------ test, zda je to okno stromu

AWEnt010:mov       ax,ds:[SegmAkt]
         call      far ptr GetDat           ; adresa okna
;         jc        AWEnt011
         jc        AWEntr09
         test      byte ptr es:[AWinPrm1],bit5 ; seznam ?
         jnz       AWEntSZ                 ; hled n¡
         test      byte ptr es:[AWinPrm1],bit4 ; je to strom ?
         jnz       AWEntr03
         jmp       AWEnt016                 ; nen¡ to strom

; ====== extern¡ vstupn¡ bod p©i automatick‚ zmˆnˆ adres ©e !!!

AWEntr03:

; ------ dek¢dov n¡ cesty podle polo‘ky pod kurzorem

;         mov       dx,es                    ; DX <- £schova segmentu okna
;         call      far ptr GetAKurz         ; poskytnut¡ polo‘ky pod kurzorem
;AWEnt011:jc        AWEnte98                 ; nen¡ polo‘ka
;         push      ds
;         push      es
;         pop       ds                       ; DS <- segment polo‘ky
;         mov       es,dx                    ; ES <- segment okna
;         mov       di,AWinDir               ; buffer adres ©e
;         call      far ptr GetPthTW         ; sestaven¡ cesty k polo‘ce
;         sub       di,AWinDir
;         mov       es:[AWinDNum],di         ; nov  d‚lka cesty
;         pop       ds
;         mov       bx,es:[AWinKurz]
;         mov       es:[AWinATre],bx         ; nov˜ aktivn¡ adres ©

;         mov       si,AWinDir               ; cesta adres ©e
AWEnt014:push      ds
         pop       es
         mov       si,offset AktPath
         call      far ptr SetDDir          ; nastaven¡ adres ©e a disku
;         call      far ptr AktADir          ; aktualizace adres ©e podle okna

         call      far ptr GetDat
         mov       bx,es:[AWinFrst]
         call      far ptr InitTWn          ; inicializace ukazatele stromu
         mov       es:[AWinFrst],bx

         mov       ax,ds:[SegmRAdr]
         test      byte ptr ds:[WindPar],bit0 ; je aktivn¡ lev‚ okno ?
         jnz       AWEnt012                  ; je aktivn¡ lev‚ okno
         mov       ax,ds:[SegmLAdr]
AWEnt012:call      far ptr GetDat
         mov       di,AWinDir               ; buffer cesty
         call      far ptr GetADir          ; poskytnut¡ aktivn¡ cesty
         mov       es:[AWinDNum],cx         ; po‡et bajt–
         mov       cl,es:[AWinDir]          ; disk
         sub       cl,"A"                   ; ‡¡slo disku
         mov       es:[AWinDisk],cl         ; disk okna

         or        byte ptr es:[AWinPrm0],bit0 ; neuchov vat kurzor
         call      far ptr ReReadD          ; nov‚ na‡ten¡ okna
         call      far ptr NulBreak         ; pro dal¨¡ okno ignorov n¡ p©eru¨en¡

AWEnt013:call      far ptr DispAll
AWEnt015:jmp       Main0


; ------ zmˆna adres ©e v oknˆ seznamu (Alt-F7)

AWEntSZ: mov       bx,es:[AWinKurz]         ; kurzor
         sub       bx,es:[AWinFrst]         ; offset od po‡ tku
         mov       ds:[AWinKOff],bx         ; po‡ te‡n¡ polo‘ka relativnˆ
         mov       di,offset AWinKFil       ; buffer kurzoru
         mov       byte ptr ds:[di+1],0     ; soubor neplatn˜

         call      far ptr GetAKurz         ; kurzor aktivn¡ho okna
         jc        AWEntSZ2                 ; nen¡
         test      byte ptr es:[si+FileAtr],ATRT ; je to platn  polo‘ka ?
         jz        AWEntSZ2                 ; nen¡ to platn  polo‘ka

         mov       cx,FileSumm              ; d‚lka polo‘ky
AWEntSZ1:mov       al,es:[si]
         mov       ds:[di],al
         inc       si
         inc       di
         loop      AWEntSZ1

AWEntSZ2:mov       si,offset AktPath
         mov       di,offset LinBuff
         mov       cx,ds:[AktPathN]
         inc       cx
         push      ds
         pop       es
         cld
         rep       movsb

         call      far ptr HledClos         ; uzav©en¡ okna seznamu

         push      ds
         pop       es
         mov       si,offset LinBuff        ; aktivn¡ cesta
         call      far ptr SetDDir          ; nastaven¡ disku a adres ©e
         jc        AWEntSZ9

         mov       ax,ds:[SegmAkt]          ; aktivn¡ okno
         call      far ptr GetDat           ; poskytnut¡ adresy okna
         mov       di,AWinDir               ; buffer k na‡ten¡ adres ©e
         call      far ptr GetADir          ; poskytnut¡ aktivn¡ cesty
         jc        AWEntSZ9                 ; chyba

         mov       es:[AWinDNum],cx         ; po‡et bajt–
         mov       cl,es:[di]
         sub       cl,"A"
         mov       es:[AWinDisk],cl         ; ‡¡slo nov‚ho aktivn¡ho disku
         or        byte ptr es:[AWinPrm0],bit0 ; neuchov vat kurzor

         call      far ptr ReReadD          ; nov‚ na‡ten¡ okna
         call      far ptr NulBreak         ; pro dal¨¡ okno ignorov n¡ p©eru¨en¡
         call      far ptr ReRetWK          ; n vrat kurzoru
         call      far ptr AktADir          ; aktualizace adres ©e podle okna

         call      far ptr DispAll          ; zobrazen¡ cel‚ obrazovky

AWEntSZ9:jmp       Main0



; ------ polo‘ka pod kurzorem

AWEnt016:call      far ptr GetAKurz         ; poskytnut¡ polo‘ky pod kurzorem
AWEnte98:jc        AWEnte99                 ; nen¡ ‘ dn  polo‘ka
         test      byte ptr es:[si+FileAtr],ATRT
         jz        AWEnte99

; ------ test, zda je polo‘ka adres ©

         test      byte ptr es:[si+FileAtr],DIR ; je to adres © ?
         jnz       AWEnter1                 ; je to adres ©

; ------ £schova parametr– souboru (pro pou‘it¡ intern¡ch parametr–)

         push      si
         mov       di,offset FileFPol
         mov       cx,FileTime+2
AWEnte9A:mov       al,es:[si]
         mov       ds:[di],al
         inc       si
         inc       di
         loop      AWEnte9A
         pop       si

; ------ p©¡prava jm‚na polo‘ky do bufferu p©¡kazov‚ho © dku

         call      far ptr TestProg         ; test, zda to je program
         pushf

         push      ds
         push      ds
         push      es
         pop       ds                       ; DS <- segment polo‘ky
         pop       es                       ; ES <- segment bufferu
         mov       di,offset LineCBuf       ; buffer p©¡kazov‚ho © dku
         inc       si                       ; za‡ tek jm‚na polo‘ky
         call      far ptr FileAsc          ; dek¢dov n¡ jm‚na souboru na ASCIIZ
         pop       ds

         xchg      ax,di                    ; AX <- konce jm‚na polo‘ky
         sub       ax,offset LineCBuf       ; d‚lka jm‚na polo‘ky
         mov       ds:[LineCNum],al         ; po‡et znak– v p©¡kazov‚m © dku

         popf
         jne       AWEntr02                 ; nen¡ program
         test      byte ptr ds:[ProgSwc],bit6 ; je p©¡pona pro COM/EXE/BAT ?
         jnz       AWEntr08                 ; COM/EXE/BAT bez p©¡pony

AWEntr02:jmp       far ptr Extens           ; proveden¡ podle p©¡pony
;         jc        AWEnte99                 ; nen¡ p©¡pona

AWEntr08:or        byte ptr ds:[ProgSwc2],bit0 ; je p©¡kaz z EXTENSION/MENU
         and       byte ptr ds:[StartPar],not bit1 ; nen¡ aktualizace INI souboru
         jmp       far ptr ProgrExe         ; proveden¡ p©¡kazu

AWEnte99:jmp       AWEnter9                 ; konec


; ------ test, zda je p©echod do nadadres ©e

AWEnter1:cmp       word ptr es:[si+FileName],".." ; nadadres © ?
         jne       AWEntr16                 ; nen¡ p©echod do nadadres ©e
         call      far ptr GetAAWin
         mov       si,es:[AWinDNum]         ; d‚lka textu adres ©e
         cmp       si,3                     ; je to ROOT ?
         jbe       AWEnte99                 ; nen¡ ‘ dn˜ adres ©
         add       si,AWinDir               ; adresa konce textu adres ©e
         cmp       byte ptr es:[si-1],"\"
         je        AWEnte99                 ; je to ROOT

; ------ nalezen¡ koncov‚ho adres ©e

AWEntr12:dec       si
         cmp       byte ptr es:[si-1],"\"
         jne       AWEntr12                 ; nalezen¡ posledn¡ polo‘ky v cestˆ

; ------ £schova konce cesty (do bufferu FileFCB)

         push      si
         sub       si,DTAName               ; fiktivn¡ polo‘ka DTA
         call      far ptr GetBFCB          ; konverze na polo‘ku FCB
         pop       si

; ------ duplikace okna AX -> BX segment, ES adresa

         mov       ax,ds:[SegmAkt]          ; aktivn¡ okno
         call      far ptr DuplAWin         ; duplikace okna
         jc        AWEnte99                 ; chyba pamˆti

; ------ nov  d‚lka cesty

         cmp       byte ptr es:[si-2],":"   ; je to ROOT ?
         je        AWEntr13                 ; je to ROOT
         dec       si                       ; zru¨en¡ znaku "\"
AWEntr13:mov       byte ptr es:[si],0       ; ozna‡en¡ konce cesty
         sub       si,AWinDir               ; d‚lka cesty
         mov       es:[AWinDNum],si         ; nov  d‚lka cesty
         jmp       short AWEnter4           ; nov‚ na‡ten¡ adres ©e (okno BX)

; ------ dek¢dov n¡ jm‚na polo‘ky pod kurzorem

AWEntr16:mov       byte ptr ds:[FileFCB]," " ; polo‘ka FCB neplat¡
         push      ds
         push      cs
         push      es
         pop       ds                       ; DS <- segment polo‘ky
         pop       es                       ; ES <- segment bufferu jm‚na
         mov       di,offset AWEntBff       ; buffer k dek¢dov n¡ polo‘ky ASCII
         inc       si                       ; za‡ tek jm‚na polo‘ky
         call      far ptr FileAsc          ; dek¢dov n¡ jm‚na souboru na ASCIIZ
         pop       ds

; ------ duplikace okna AX -> BX segment, ES adresa

         mov       ax,ds:[SegmAkt]          ; aktivn¡ okno
         call      far ptr DuplAWin         ; duplikace okna
         jc        AWEnte99                 ; chyba pamˆti

; ------ p©id n¡ polo‘ky k cestˆ

         mov       si,offset AWEntBff       ; buffer se jm‚nem polo‘ky
         mov       di,es:[AWinDNum]         ; sou‡asn  d‚lka textu adres ©e
         add       di,AWinDir               ; konec textu adres ©e
         cld
         mov       al,"\"
         cmp       byte ptr es:[di-1],al    ; je to ROOT ?
         je        AWEntr17                 ; je ROOT
         stosb                              ; ozna‡en¡ konce cesty
AWEntr17:cmp       di,AWinDir0              ; je p©ete‡en¡ d‚lky cesty ?
         jae       AWEntr19                 ; je p©ete‡en¡ d‚lky cesty
         mov       al,cs:[si]
         inc       si
         stosb
         cmp       al,0
         jne       AWEntr17
         sub       di,AWinDir+1
         mov       es:[AWinDNum],di         ; nov  d‚lka cesty
         jmp       short AWEnter4           ; na‡ten¡ adres ©e

; ------ chyba - zru¨en¡ nov‚ho okna

AWEntr18:xchg      ax,dx                    ; AX <- star‚ okno, DX <- nov‚ okno
         call      far ptr XchgWSeg         ; n vrat segmentu okna
AWEntr19:xchg      ax,bx                    ; AX <- ‡¡slo nov‚ho okna
         call      far ptr DeletAWn         ; zru¨en¡ nov‚ho okna
         jmp       AWEnter9

; ------ nastaven¡ adres ©e okna

AWEnter4:mov       si,AWinDir               ; cesta adres ©e
         call      far ptr SetDDir          ; nastaven¡ adres ©e a disku
         jc        AWEntr19                 ; chyba

; ------ na‡ten¡ nov‚ho aktivn¡ho adres ©e

AWEntr44:mov       di,AWinDir               ; buffer cesty
         call      far ptr GetADir          ; poskytnut¡ aktivn¡ cesty
         jc        AWEntr19                 ; chyba
         mov       es:[AWinDNum],cx         ; po‡et bajt–
         or        byte ptr es:[AWinPrm0],bit0 ; neuchov vat kurzor

; ------ nov‚ na‡ten¡ okna

         mov       dx,ds:[SegmAkt]          ; DX <- p–vodn¡ aktivn¡ okno
         mov       ax,bx                    ; AX <- nov‚ okno
         call      far ptr XchgWSeg         ; v˜mˆna ‡¡sla okna v ukazatel¡ch
         push      ax
         xchg      ax,dx                    ; AX <- segment star‚ho okna
         call      far ptr DeletAWn         ; zru¨en¡ star‚ho okna
         pop       ax

         call      far ptr ReReadD          ; nov‚ na‡ten¡ okna
         call      far ptr NulBreak         ; pro dal¨¡ okno ignorov n¡ p©eru¨en¡
;         jc        AWEntr18                 ; n vrat segmentu okna

; ------ nastaven¡ pozice kurzoru

         call      far ptr GetDat           ; adresa okna
         mov       word ptr es:[AWinKurz],0 ; kurzor na po‡ tek okna
         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       si,offset FileFCB        ; jm‚no adres ©e FCB
         cmp       byte ptr ds:[si]," "     ; je platn‚ jm‚no ?
         je        AWEnter5                 ; nen¡ platn‚ jm‚no
         call      far ptr RetWKur          ; n vrat pozice kurzoru

; ------ korekce po‡ tku okna

AWEnter5:call      far ptr GetDat           ; adresa okna
         mov       ah,0
         mov       al,ds:[NumRows]          ; celkov  v˜¨ka okna
         sub       al,5                     ; ode‡ten¡ bˆ‘n‚ho z hlav¡ a paty
         test      byte ptr es:[AWinPrm2],bit4 ; je stavov˜ © dek souboru ?
         jnz       AWEnter6                 ; nen¡ stavov˜ © dek soubory
         sub       al,2                     ; ode‡ten¡ stavov‚ho © dku
AWEnter6:mov       cx,2
         test      byte ptr es:[AWinPrm2],bit5 ; je zkr cen‚ zobrazen¡ ?
         jz        AWEntr62                 ; nen¡ zkr cen‚ zobrazen¡
         test      byte ptr es:[AWinPrm2],bit6
         jnz       AWEntr62                 ; nen¡ zkr cen‚ zobrazen¡
         mov       cl,6                     ; n sobek pro 3 sloupce
AWEntr62:mul       cx
         mov       cl,5
         div       cx                       ; 2/5 v˜¨ky okna
         mov       cx,es:[AWinKurz]         ; polo‘ka s kurzorem
         sub       cx,ax                    ; posun po‡ tku okna
         jnc       AWEnter7
         xor       cx,cx
AWEnter7:mov       es:[AWinFrst],cx         ; po‡ tek okna

AWEntr72:call      far ptr AktADir          ; aktualizace adres ©e podle okna

; ------ aktualizace stromu, je-li v druh‚m oknˆ

         mov       ax,ds:[SegmNAkt]         ; neaktivn¡ okno
         call      far ptr GetDat
         jc        AWEntr74
         test      byte ptr es:[AWinPrm1],bit4 ; je to strom ?
         jz        AWEntr74                 ; nen¡ to strom
         call      far ptr InitTWn          ; aktualizace aktivn¡ho adres ©e

AWEntr74:call      far ptr DispAll

AWEnter9:
         call      far ptr AktADir          ; aktualizace adres ©e podle okna
         jmp       Main0

AWEntBff label     byte
         db        13 dup(0)                ; buffer k dek¢dov n¡ jm‚na polo‘ky

; -----------------------------------------------------------------------------
;                              Konec
;                 odinstalov n¡ programu z pamˆti
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; -----------------------------------------------------------------------------

Konec    PROC      FAR

         call      far ptr QSrcEnd          ; ukon‡en¡ re‘imu rychlovyhled v n¡
         call      far ptr ClosMnuA         ; uzav©en¡ v¨ech menu
         call      far ptr StoSHist         ; ulo‘en¡ historie na disk

         push      ds
         pop       es
         mov       si,offset AktPath        ; aktu ln¡ adres ©
         call      far ptr SetDDir          ; nastaven¡ aktu ln¡ho adres ©e

; ------ n vrat obrazovky

         cmp       byte ptr ds:[STopLine],-1
         jne       Konec1
         mov       word ptr ds:[STopAdr],0
         mov       byte ptr ds:[STopLine],0

Konec1:  xor       dx,dx
         mov       cl,ds:[Pozic]            ; po‡et pozic na © dek
         mov       ch,ds:[Radku]
         call      far ptr PopScr
         mov       dx,ds:[SKurzor]          ; uschovan˜ syst‚mov˜ kurzor

         cmp       dh,ds:[MaxRow]           ; p©ekro‡en maxim ln¡ © dek ?
         jbe       Konec2                   ; © dek je OK
         mov       dh,ds:[MaxRow]           ; omezen¡ © dku
Konec2:  cmp       dl,ds:[MaxPoz]           ; p©ekro‡ena maxim ln¡ pozice ?
         jbe       Konec3                   ; pozice je OK
         mov       dl,ds:[MaxPoz]           ; omezen¡ pozice
Konec3:
         call      far ptr SetKurz          ; nastaven¡ kurzoru

; ------ vypnut¡ my¨i

         call      far ptr MouseOff         ; vypnut¡ kurzoru my¨i
         call      far ptr PopFont          ; n vrat definice font–
         test      byte ptr ds:[ParDisp],bit6 ; maj¡ se navracet fonty ?
         jnz       Konec32                  ; fonty se maj¡ vracet
         call      far ptr InitFont         ; inicializace font–
Konec32: call      far ptr DeInsInt         ; odinstalov n¡ obsluh p©eru¨en¡

; ------ nastaven¡ p©echodn‚ho z sobn¡ku

         push      ss
         pop       es                       ; £schova segmentu z sobn¡ku
         mov       ax,SEG StackS            ; segment z sobn¡ku
         mov       ss,ax                    ; segment z sobn¡ku
         mov       sp,256                   ; adresa konce z sobn¡ku

; ------ uvolnˆn¡ aloka‡n¡ho bloku z sobn¡ku

         mov       ah,49h
         int       21h                      ; uvolnˆn¡ bloku z sobn¡ku

; ------ uvolnˆn¡ datov‚ho bloku pamˆti

         mov       es,ds:[TopSeg]           ; aloka‡n¡ datov˜ blok pamˆti
         mov       ah,49h
         int       21h                      ; uvolnˆn¡ bloku pamˆti

         sti
         cld

         mov       es,ds:[RezPSP]
         mov       byte ptr es:[80h],0      ; zru¨en¡ p©¡kazov‚ho © dku

         mov       ax,4c01h
         int       21h                      ; n vrat z programu

Konec    ENDP

; -----------------------------------------------------------------------------
;        Alt-  tabulka ASCII
; -----------------------------------------------------------------------------

AWAscii  PROC      NEAR

         call      far ptr TabAscii         ; obsluha tabulky ASCII
         jmp       Main0

AWAscii  ENDP

; -----------------------------------------------------------------------------
;        Alt= kalkul tor
; -----------------------------------------------------------------------------

AWKalk   PROC      NEAR

         call      far ptr Kalkul           ; obsluha kalkul toru
         jmp       Main0

AWKalk   ENDP

; -----------------------------------------------------------------------------
;        Alt- kalend ©
; -----------------------------------------------------------------------------

AWKalend PROC      NEAR

         call      far ptr Kalend           ; obsluha kalend ©e
         jmp       Main0

AWKalend ENDP

; -----------------------------------------------------------------------------
;        Shift-F2 proveden¡ p©¡kazu
; -----------------------------------------------------------------------------

AWSExec  PROC      NEAR

         jmp       far ptr Progr500

AWSExec  ENDP

; -----------------------------------------------------------------------------
;        F3 - zobrazen¡ souboru
; -----------------------------------------------------------------------------

AWZobr   PROC      NEAR

         mov       ax,bit0 + (bit1+bit2+bit3)*HI ;+bit7
         jmp       short AWEdit2

AWZobr   ENDP

;; -----------------------------------------------------------------------------
;;        Alt-F3 - zobrazen¡ souboru extern¡
;; -----------------------------------------------------------------------------
;
;AWAZobr  PROC      NEAR
;
;         mov       ax,bit0 + (bit2+bit3)*HI ;+bit7
;         jmp       short AWEdit2
;
;AWAZobr  ENDP
;
; -----------------------------------------------------------------------------
;        Shift-F3 - zobrazen¡ souboru zadan‚
; -----------------------------------------------------------------------------

AWSZobr  PROC      NEAR

         mov       ax,bit3 + (bit1+bit2+bit3)*HI
         jmp       short AWEdit2

AWSZobr  ENDP

; -----------------------------------------------------------------------------
;        F4 - editace souboru
; -----------------------------------------------------------------------------

AWEdit   PROC      NEAR

         mov       ax,bit0 + 0*HI
AWEdit2: call      far ptr QSrcEnd          ; ukon‡en¡ re‘imu rychlovyhled v n¡
         jmp       far ptr EditF

AWEdit   ENDP

;; -----------------------------------------------------------------------------
;;        Alt-F4 - editace souboru extern¡
;; -----------------------------------------------------------------------------
;
;AWAEdit  PROC      NEAR
;
;         mov       ax,bit0 + (bit2)*HI ;+bit7
;         jmp       short AWEdit2
;
;AWAEdit  ENDP
;
; -----------------------------------------------------------------------------
;        Ctrl-F3 zobrazen¡ disku
; -----------------------------------------------------------------------------

AWCDisk  PROC      NEAR

         call      far ptr QSrcEnd          ; ukon‡en¡ re‘imu rychlovyhled v n¡
         jmp       far ptr ZobDiskF

AWCDisk  ENDP

; -----------------------------------------------------------------------------
;        Ctrl-F4 - editace souboru HEX
; -----------------------------------------------------------------------------

AWCEdit  PROC      NEAR

         mov       ax,bit0 + (bit0+bit1)*HI
         jmp       short AWEdit2

AWCEdit  ENDP

; -----------------------------------------------------------------------------
;        Shift-F4 - editace souboru zadan 
; -----------------------------------------------------------------------------

AWSEdit  PROC      NEAR

         mov       ax,bit3 + 0*HI
         jmp       short AWEdit2

AWSEdit  ENDP

; -----------------------------------------------------------------------------
;        F5 - kop¡rov n¡ ozna‡en˜ch polo‘ek
; -----------------------------------------------------------------------------

AWCopy   PROC      NEAR

         mov       al,bit1 + bit4 + bit6 + bit7 ; kop¡ruj¡ se ozna‡en‚ polo‘ky
AWCopy2: call      far ptr QSrcEnd          ; ukon‡en¡ re‘imu rychlovyhled v n¡
         jmp       far ptr CopyFilF         ; obsluha kop¡rov n¡ souboru

AWCopy   ENDP

; -----------------------------------------------------------------------------
;        Alt-F5 - kop¡rov n¡ jedn‚ polo‘ky
; -----------------------------------------------------------------------------

AWACopy  PROC      NEAR

         mov       al,bit0 + bit4 + bit6 + bit7; kop¡ruje se polo‘ka pod kurzorem
         jmp       short AWCopy2

AWACopy  ENDP

; -----------------------------------------------------------------------------
;        Shift-F5 - kop¡rov n¡ zvolen˜ch polo‘ek
; -----------------------------------------------------------------------------

AWSCopy  PROC      NEAR

         mov       al,bit3 + bit4 + bit6    ; kop¡ruj¡ se zadan‚ polo‘ky
         jmp       short AWCopy2

AWSCopy  ENDP

; -----------------------------------------------------------------------------
;        F6 - p©esun ozna‡en˜ch polo‘ek
; -----------------------------------------------------------------------------

AWMove   PROC      NEAR

         mov       al,bit1 + bit4 + bit6 + bit7 ; p©esouvaj¡ se ozna‡en‚ polo‘ky
AWMove2: call      far ptr QSrcEnd          ; ukon‡en¡ re‘imu rychlovyhled v n¡
         jmp       far ptr MoveFilF         ; obsluha kop¡rov n¡ souboru

AWMove   ENDP

; -----------------------------------------------------------------------------
;        Alt-F6 - p©esun jedn‚ polo‘ky
; -----------------------------------------------------------------------------

AWAMove  PROC      NEAR

         mov       al,bit0 + bit4 + bit6 + bit7 ; p©esouv  se polo‘ka pod kurzorem
         jmp       short AWMove2

AWAMove  ENDP

; -----------------------------------------------------------------------------
;        Shift-F6 - p©esun zvolen˜ch polo‘ek
; -----------------------------------------------------------------------------

AWSMove  PROC      NEAR

         mov       al,bit3 + bit4 + bit6           ; p©esouvaj¡ se zadan‚ polo‘ky
         jmp       short AWMove2

AWSMove  ENDP

; -----------------------------------------------------------------------------
;        Ctrl-F5 kopie disket
; -----------------------------------------------------------------------------

AWCKopD  PROC      NEAR

         call      far ptr QSrcEnd          ; ukon‡en¡ re‘imu rychlovyhled v n¡
         jmp       far ptr KopDiskF

AWCKopD  ENDP

; -----------------------------------------------------------------------------
;        Ctrl-F6 - jm‚no disku
; -----------------------------------------------------------------------------

AWCJmeno PROC      NEAR

         call      far ptr QSrcEnd          ; ukon‡en¡ re‘imu rychlovyhled v n¡
         jmp       far ptr LabsF

AWCJmeno ENDP

;; -----------------------------------------------------------------------------
;;        Ctrl-F7 zvl ¨tn¡ funkce
;; -----------------------------------------------------------------------------
;
;AWCZvlas PROC      NEAR
;
;         call      far ptr QSrcEnd          ; ukon‡en¡ re‘imu rychlovyhled v n¡
;         mov       si,offset ZMn2Vert       ; menu zvl ¨tn¡ch funkc¡
;         call      far ptr CentMenu         ; vyst©edˆn¡ okna menu
;         call      far ptr VertMenu
;         jmp       Main0
;
;AWCZvlas ENDP

; -----------------------------------------------------------------------------
;        F7 - vytvo©en¡ adres ©e
; -----------------------------------------------------------------------------

AWAdres  PROC      NEAR

         call      far ptr QSrcEnd          ; ukon‡en¡ re‘imu rychlovyhled v n¡
         jmp       far ptr CAdresar

AWAdres  ENDP

; -----------------------------------------------------------------------------
;        F8 - zru¨en¡ polo‘ky
; -----------------------------------------------------------------------------

AWZrus   PROC      NEAR

         mov       al,bit1 + bit4 + bit6 + bit7 ; ru¨¡ se ozna‡en‚ polo‘ky
AWZrus2: call      far ptr QSrcEnd          ; ukon‡en¡ re‘imu rychlovyhled v n¡
         jmp       far ptr RusSoubF         ; obsluha ru¨en¡ souboru

AWZrus   ENDP

; -----------------------------------------------------------------------------
;        Alt-F8 - zru¨en¡ jedn‚ polo‘ky
; -----------------------------------------------------------------------------

AWAZrus  PROC      NEAR

         mov       al,bit0 + bit4 + bit6 + bit7 ; ru¨¡ se polo‘ka pod kurzorem
         jmp       short AWZrus2

AWAZrus  ENDP

; -----------------------------------------------------------------------------
;        Shift-F7 - obnoven¡ zru¨en˜ch polo‘ek
; -----------------------------------------------------------------------------

AWObnov  PROC      NEAR

         call      far ptr QSrcEnd          ; ukon‡en¡ re‘imu rychlovyhled v n¡
         jmp       far ptr Undelete         ; obnoven¡ soubor–

AWObnov  ENDP

; -----------------------------------------------------------------------------
;        Shift-F8 - zru¨en¡ zvolen˜ch polo‘ek
; -----------------------------------------------------------------------------

AWSZrus  PROC      NEAR

         mov       al,bit3 + bit4 + bit6    ; ru¨¡ se zadan‚ polo‘ky
         jmp       short AWZrus2

AWSZrus  ENDP

; -----------------------------------------------------------------------------
;        F9 - modifikace parametr–
; -----------------------------------------------------------------------------

AWAtrib  PROC      NEAR

         mov       al,bit1 + bit6           ; modifikace ozna‡en˜ch polo‘ek
         call      far ptr QSrcEnd          ; ukon‡en¡ re‘imu rychlovyhled v n¡
         jmp       far ptr ModiFilF         ; obsluha modifikace parametr–

AWAtrib  ENDP

; -----------------------------------------------------------------------------
;        Ctrl-F8 form tov n¡ disket
; -----------------------------------------------------------------------------

AWFormat PROC      NEAR

         call      far ptr QSrcEnd          ; ukon‡en¡ re‘imu rychlovyhled v n¡
         jmp       far ptr FormatF

AWFormat ENDP

; -----------------------------------------------------------------------------
;        Ctrl-F9 porovn n¡ obsahu souboru
; -----------------------------------------------------------------------------

AWCComp  PROC      NEAR

         call      far ptr QSrcEnd
         jmp       far ptr CompFile         ; porovn n¡ obsahu souboru

AWCComp  ENDP

; -----------------------------------------------------------------------------
;        Alt-F7 vyhled v n¡ soubor–
; -----------------------------------------------------------------------------

AWHled   PROC      NEAR

         call      far ptr QSrcEnd          ; ukon‡en¡ re‘imu rychlovyhled v n¡
         jmp       far ptr Hledej

AWHled   ENDP

; -----------------------------------------------------------------------------
;        Shift-F10 EGA/VGA
; -----------------------------------------------------------------------------

AWSEgaV  PROC      NEAR

         call      far ptr ShiftF10         ; zmˆna videom¢du
         jmp       Main0

AWSEgaV  ENDP

; -----------------------------------------------------------------------------
;        Alt-F10 strom
; -----------------------------------------------------------------------------

AWTree   PROC      NEAR

         call      far ptr QSrcEnd          ; ukon‡en¡ re‘imu rychlovyhled v n¡
         jmp       far ptr Strom

AWTree   ENDP

; *****************************************************************************
;                              InpChar
;                 vstup znaku s dynamickou podporou
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; VSTUP: BX=kl vesa
;         CY=je kl vesa ESC (p©eru¨en¡)
; *****************************************************************************
;þ
InpChar  PROC      FAR

; ------ £schova registr–

         push      ax
         push      dx
         push      si

; ------ automatick‚ vyno©en¡ z menu

         call      far ptr NulBreak         ; nulov n¡ p©¡znaku p©eru¨en¡
         test      byte ptr ds:[ParMenu],bit5 ; je automatick‚ vyno©en¡ z menu ?
         jz        InpChar1                 ; nen¡ automatick‚ vyno©en¡ z menu
         mov       ax,11bh                  ; kl vesa Esc
         test      byte ptr ds:[ParMenu],bit2 ; je je¨tˆ nˆjak‚ menu ?
         jnz       InpChar6                 ; je je¨tˆ nˆjak‚ menu -> ESC
         and       byte ptr ds:[ParMenu],not bit5 ; zru¨en¡ p©¡znaku vyno©en¡

; ------ ‡ek n¡ na zad n¡ znaku

InpChar1:call      far ptr MouseInt         ; obsluha my¨i
         call      far ptr DispTime         ; obsluha zobrazen¡ ‡asu
         call      far ptr Darker           ; obsluha stm¡va‡e
         call      far ptr InpPresm         ; test p©esmyka‡–

; ------ test my¨i

         call      far ptr MouseGet         ; test stavu my¨i
         xchg      ax,bx
         jc        InpChar2                 ; nen¡ zmˆna
         test      byte ptr ds:[ParMenu],bit3 ; je p©echodn‚ vypnut¡ menu
         jz        InpChar7                 ; nen¡ p©echodn‚ vypnut¡ menu
         test      al,bit2+bit3             ; je stisk tla‡¡tka ?
         jnz       InpChar7                 ; stisk tla‡¡tka povolen

; ------ vstup znaku

InpChar2:call      far ptr TestChar         ; test, zda je p©ipraven znak
         jc        InpChar1                 ; nen¡ p©ipraven znak z kl vesnice
         call      far ptr InputChar        ; vstup znaku

; ------ p©i p©echodn‚m vypnut¡ menu Ctrl-O se pouze navr t¡ znak

         test      byte ptr ds:[ParMenu],bit3 ; je p©echodn‚ vypnut¡ menu ?
         jz        InpChar3                 ; nen¡ p©echodn‚ vypnut¡ menu
         jmp       InpChr74                 ; je p©echodn‚ vypnut¡ menu

; ------ vyvol n¡ tabulky ASCII (pouze nen¡-li zat¡m aktivn¡)

InpChar3:cmp       ax,1910h                 ; Ctrl-P ?
         jne       InpChar5                 ; nen¡ tabulka ASCII
         test      byte ptr ds:[ParZvl],bit0 ; je ASCII tabulka zapnuta ?
         jnz       InpChar5                 ; ASCII tabulka je ji‘ zapnuta
         call      far ptr TabAscii         ; obsluha tabulky ASCII
InpChar4:jmp       short InpChar1           ; pokra‡ov n¡ v ‡ek n¡

; ------ automatick‚ vyno©en¡ z menu Shift-Esc

InpChar5:cmp       ax,11bh                  ; Esc ?
         jne       InpChar6
         test      byte ptr ds:[Presmyk],bit4 ; je Shift- ?
         jz        InpChar6                 ; nen¡ Shift-Esc
         test      byte ptr ds:[ParMenu],bit2 ; je nˆjak‚ menu ?
         jz        InpChar6                 ; nen¡ ‘ dn‚ menu
         or        byte ptr ds:[ParMenu],bit5 ; automatick‚ vyno©en¡ z menu

; ------ vyvol n¡ kalkul toru (pouze nen¡-li zat¡m aktivn¡)

InpChar6:cmp       ax,8300h                 ; Alt-=
         jne       InpChr64                 ; nen¡ kalkul tor
         test      byte ptr ds:[ParZvl],bit3 ; je kalkul tor zapnut ?
         jnz       InpChr64                 ; kalkul tor je ji‘ zapnut
         call      far ptr Kalkul           ; obsluha kalkul toru
         jmp       short InpChar4

; ------ vyvol n¡ kalend ©e

InpChr64:cmp       ax,8200h                 ; Alt--
         jne       InpChar7                 ; nen¡ kalend ©
         test      byte ptr ds:[ParZvl],bit2 ; je kalend © zapnut ?
         jnz       InpChar7                 ; kalend © je ji‘ zapnut
         call      far ptr Kalend           ; obsluha kalend ©e
         jmp       short InpChar4

; ------ posouv n¡ oken menu

InpChar7:cmp       word ptr ds:[NumMenu],0  ; je nˆjak‚ menu ?
         je        InpChr71                 ; nen¡ ‘ dn‚ menu otev©eno
         mov       si,ds:[AktMenu]          ; adresa aktivn¡ho menu
         cmp       ax,MousXKod+MousXLP      ; je stisk lev‚ho tla‡¡tka my¨i ?
         jne       InpCh705                 ; nen¡ stisk lev‚ho tla‡¡tka
         cmp       byte ptr ds:[si+MnuTyp],0 ; je hlavn¡ menu ?
         je        InpCh705                 ; hlavn¡ menu nelze posunout

         mov       dx,ds:[MousePoz]         ; pozice my¨i
         or        dh,dh
         jz        InpCh705
         cmp       dh,ds:[si+MnuRad]        ; souhlas¡ © dek menu ?
         jne       InpCh705                 ; nesouhlas¡
         sub       dl,ds:[si+MnuPoz]        ; souhlas¡ pozice ?
         cmp       dl,ds:[si+MnuSir]
         jae       InpCh705                 ; nen¡ na horn¡m okraji

InpCh792:call      far ptr MouseInt         ; obsluha my¨i
         call      far ptr DispTime         ; obsluha zobrazen¡ ‡asu
         call      far ptr MouseGet         ; test stavu my¨i
         jc        InpCh792                 ; nen¡ zmˆna
         test      bl,MousXMov+MousXLR      ; je posun my¨i nebo uvolnˆn¡ ?
         jz        InpCh792                 ; nen¡ posun
         mov       ax,ds:[MousePoz]         ; © dek a pozice my¨i
         sub       al,dl
         jnc       InpCh793
         mov       al,0
InpCh793:or        ah,ah
         jnz       InpCh794
         mov       ah,1
InpCh794:mov       word ptr ds:[si+MnuPoz],ax
         mov       bx,ds:[NumMenu]
         shl       bx,1
         mov       word ptr ds:[bx+PozMenu-2],ax
         call      far ptr DispAll
         test      byte ptr ds:[MouseKey],bit0 ; je lev‚ tla‡¡tko ?
         jnz       InpCh792                 ; je lev‚ tla‡¡tko
         call      far ptr NulBreak         ; nulov n¡ p©¡znaku p©eru¨en¡
         jmp       InpChar1

; ------ obsluha helpu F1

InpCh705:cmp       byte ptr ds:[si+MnuTyp],20 ; je n povˆda ?
         je        InpChr74                 ; je n povˆda - kl vesy plat¡
         cmp       byte ptr ds:[si+MnuTyp],18 ; je u‘ivatelsk‚ menu ?
         je        InpChr74                 ; u‘ivatelsk‚ menu nem  n povˆdu

InpChr71:cmp       ax,3B00h                 ; je kl vesa F1 ?
         jne       InpChr72                 ; nen¡ F1
         call      far ptr HelpAF           ; obsluha n povˆdy
         jmp       InpChar4                 ; dal¨¡ kl vesa

; ------ obsluha helpu Shift-F1

InpChr72:cmp       ax,5400h                 ; je kl vesa Shift-F1 ?
         jne       InpChr74                 ; nen¡ Shift-F1
         mov       ax,ds:[HlpAStrn]         ; naposledy zvolen  str nka
         call      far ptr HelpF            ; n povˆda
         jmp       InpChar4                 ; dal¨¡ kl vesa

; ------ test, zda je p©eru¨en¡ kl vesou ESC

InpChr74:cmp       ax,11bh                  ; je kl vesa ESC ?
         xchg      ax,bx                    ; BX <- k¢d p©ijat‚ kl vesy
         stc
         je        InpChar8                 ; je kl vesa ESC
         clc                                ; p©¡znak - nen¡ kl vesa ESC

; ------ n vrat registr–

InpChar8:pop       si
         pop       dx
         pop       ax
         ret

InpChar  ENDP

; *****************************************************************************
;                            DetCPU
;                       detekce procesoru
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; *****************************************************************************

DetCPU   PROC      NEAR

         call      GetProc                  ; poskytnut¡ procesoru
         mov       ds:[CPU],al              ; typ procesoru
         ret

DetCPU   ENDP

; -----------------------------------------------------------------------------
;        zji¨tˆn¡ procesoru
; -----------------------------------------------------------------------------

GetProc  PROC      NEAR

         push      cs
         pop       es                       ; ES <- segment programu

                                          ;* rozli¨en¡ 808x,Vx0/vy¨¨¡
         pushf                              ; £schova registru p©¡znak–
         xor       ax,ax                    ; AX <- 0
         push      ax                       ; 0 -> stack
         popf                               ; F <- 0
         pushf                              ; F -> stack
         pop       ax                       ; AX <- F
         popf                               ; n vrat p©¡znak–
         and       ax,0f000h                ; test bit– 12 a‘ 15
         cmp       ax,0f000h                ; jsou napevno nastaveny na 1 ?
         jne       testpro2                 ; nejsou nast. - je 80186 nebo vyssi

                                          ;* rozli¨en¡ 8088,8086/V20,V30
                                            ; testuje, zda instrukce MUL AL
                                            ; ovliv¤uje p©¡znak ZF

         xor       al,al                    ; nastaven¡ p©¡znaku ZY
         mov       al,40h                   ; n soben‚ ‡¡slo
         mul       al                       ; vyn soben¡ 40h*40h
         mov       ax,1                     ; procesor 8088,8086
         jnz       testpro1                 ; je procesor 8088,8086
         mov       ax,3                     ; nemˆn¡ ZF - je procesor V20, V30

testpro1:                                 ;* test 8-bitov‚ sbˆrnice
         push      ax                       ; £schova k¢du procesoru
         EVEN                               ; nastaven¡ na sudou adresu
         mov       di,offset testproa       ; konec testovac¡ posloupnosti
         std                                ; smˆr dol–
         mov       al,byte ptr cs:[testpro9]; posledn¡ instrukce STI
         mov       cx,3                     ; po‡et bajt– k testu
         cli                                ; z kaz p©eru¨en¡
         rep       stosb                    ; p©epis instrukc¡ STI
         cld                                ; n vrat smˆru dol–
         nop
         nop
testpro8:nop                                ; sem se zap¡¨¡ 3 instrukce STI
         inc       cx                       ; u 8086 tato instrukce z–stane
testpro9:sti
testproa:sti
         pop       ax
         add       ax,cx                    ; korekce procesoru podle sbˆrnice
         ret

testpro2:                                 ;* rozli¨en¡ 8018x/vy¨¨¡
                                            ; testuje, zda instrukce PUSH SP
                                            ; ulo‘¡ do z sobn¡ku stav SP p©ed
                                            ; operac¡ nebo po operaci (=8018x)

         push      sp                       ; ulo‘en¡ ukazatele z sobn¡ku
         pop       bx                       ; n vrat ‡¡sla, kter‚ se ulo‘ilo
         cmp       bx,sp                    ; ulo‘il se stav SP p©ed operac¡ ?
         mov       ax,5                     ; procesor 80188, 80186
         jne       testpro1                 ; je procesor 80188, 80186

                                          ;* test procesoru 80286
         pushf                              ; £schova registru p©¡znak–
         mov       ax,0f000h                ; AX <- F000h
         push      ax                       ; F000h -> stack
         popf                               ; F <- F000h
         pushf                              ; F -> stack
         pop       ax                       ; AX <- F
         popf                               ; n vrat registru p©¡znak–
         and       ax,0f000h                ; test bit– 12 a‘ 15
         jnz       testpro3                 ; nejsou v¨echny 0 - nen¡ 80286
         mov       ax,7                     ; jsou napevno 0 - je procesor 80286
         ret

testpro3:                                 ;* test procesoru 80486
                                            ; testuje se, zda lze mˆnit bit 18
                                            ; registru p©¡znak– FD
                                            ; VSTUP: AX=1 (lze mˆnit-je 80486)

db 0C8h,0,0,0       ;ENTER  0000,00         ; m¢d 32 bit–
db 66h,8Bh,0D4h     ;MOV    EDX,ESP         ; £schova ukazatele z sobn¡ku ESP
db 66h,83h,0E4h,0FCh;AND    ESP,FFFC        ; zaokrouhlen¡ ukazat. na dvojslovo
db 66h,9Ch          ;PUSHFD                 ; FD -> stack
db 66h,58h          ;POP    EAX             ; EAX <- FD
db 66h,8Bh,0C8h     ;MOV    ECX,EAX         ; ECX <- EAX (£schova FD)
db 66h,35h,0,0,4,0  ;XOR    EAX,00040000    ; zmˆna bitu 18 registru FD
db 66h,50h          ;PUSH   EAX             ; EAX -> stack
db 66h,9Dh          ;POPFD                  ; FD <- p–vodn¡ FD se zmˆnou bitu 18
db 66h,9Ch          ;PUSHFD                 ; FD -> stack (jak to FD ovlivnil ?)
db 66h,58h          ;POP    EAX             ; AX <- FD (nov  hodnota)
db 66h,33h,0C1h     ;XOR    EAX,ECX         ; XOR nov‚ho stavu FD se star˜m
db 66h,0C1h,0E8h,12h;SHR    EAX,12          ; rotace mˆnˆn‚ho p©¡znaku do bitu 0
db 66h,83h,0E0h,1   ;AND    EAX,+01         ; ponech  testovan˜ p©¡znak FD
db 66h,51h          ;PUSH   ECX             ; p–vodn¡ nastaven¡ FD
db 66h,9Dh          ;POPFD                  ; n vrat registru p©¡znak– FD
db 66h,8Bh,0E2h     ;MOV    ESP,EDX         ; n vrat ukazatele z sobn¡ku ESP
db 0C9h             ;LEAVE                  ; opustˆn¡ m¢du 32 bit–

         dec       ax                       ; je procesor 80486 ?
         jnz       testpro4                 ; nen¡ procesor 80486

.486
         cli
         pushfd                             ; £schova EFLAGS

         pushfd                             ; EFLAGS do z sobn¡ku
         pop       eax                      ; EAX <- EFLAGS
         mov       ebx,eax                  ; EBX <- £schova star‚ho stavu EFLAGS
         xor       eax,00200000h            ; zmˆna p©¡znaku CPUID
         push      eax                      ; nov˜ stav EFLAGS do z sobn¡ku
         popfd                              ; EFLAGS <- nov  hodnota
         pushfd                             ; EFLAGS do z sobn¡ku
         pop       eax                      ; EAX <- nov  hodnota EFLAGS

         popfd                              ; n vrat EFLAGS
         sti

         cmp       eax,ebx                  ; lze zmˆnit bit CPUID ?
         je        testpr34                 ; nelze zmˆnit - je 486

         xor       eax,eax                  ; EAX <- 0
db 0fh,0a2h                                 ; instrukce CPUID
         dec       eax                      ; instrukce podporov na ?
         jnz       testpr34                 ; nen¡ podporov na
         mov       dword ptr ds:[VendrCPU],ebx ; vendor ©etˆzec
         mov       dword ptr ds:[VendrCPU+4],edx ; vendor ©etˆzec
         mov       dword ptr ds:[VendrCPU+8],ecx ; vendor ©etˆzec

         inc       eax                      ; EAX <- 1
db 0fh,0a2h                                 ; instrukce CPUID
         mov       ds:[ModelCPU],ax         ; model procesoru
.8086
         cmp       ax,500h                  ; je Pentium ?
         mov       ax,12                    ; procesor Pentium
         jae       testpr32                 ; je Pentium
testpr31:mov       ax,11                    ; procesor 80486+
testpr32:ret

testpr34:mov       ax,10                    ; je procesor 80486
         ret

testpro4:                                 ;* rozli¨en¡ 80386/80386 SX
                                            ; testuje bit 4 ©¡dic¡ho registru 0
                                            ; - pokud lze vynulovat, je 80386

db 0C8h,0,0,0       ;ENTER  0000,00         ; m¢d 32 bit–
db 0Fh,20h,0C3h     ;MOV    EBX,CR0         ; £schova ©¡dic¡ho registru CR0
db 0Fh,20h,0C0h     ;MOV    EAX,CR0         ; EAX <- CR0
db 66h,83h,0E0h,0EFh;AND    EAX,FFEF        ; vynulov n¡ bitu 4 reg. EAX
db 0Fh,22h,0C0h     ;MOV    CR0,EAX         ; CR0 <- nov  hodnota s nul. bit. 4
db 0Fh,20h,0C0h     ;MOV    EAX,CR0         ; EAX <- CR0 - vynuloval se bit 4 ?
db 66h,0C1h,0E8h,4  ;SHR    EAX,4           ; rotace bitu 4 do bitu 0
db 66h,83h,0E0h,1   ;AND    EAX,+01         ; bit 0 - p©¡znak nastav. bitu 4 CR0
db 0Fh,22h,0C3h     ;MOV    CR0,EBX         ; n vrat ©¡dic¡ho registru CR0
db 0C9h             ;LEAVE                  ; opustˆn¡ m¢du 32 bit–

         dec       ax                       ; je procesor 80386 SX ?
         mov       ax,8                     ; procesor 80386
         jnz       testpro5                 ; nen¡ procesor 80386 SX
         inc       ax                       ; je procesor 80386 SX (=9)
testpro5:ret

GetProc  ENDP

; *****************************************************************************
;                                 Cekej
;                      ‡ek n¡ po zadanou dobu
; -----------------------------------------------------------------------------
; VSTUP: CX=po‡et impuls– 1/18 s
; *****************************************************************************

Cekej    PROC      FAR

         push      ax
         push      cx
         push      ds

         xor       ax,ax
         mov       ds,ax
         jcxz      Cekej3
         sti

Cekej1:  mov       ax,ds:[46ch]
Cekej2:  cmp       ax,ds:[46ch]
         je        Cekej2
         loop      Cekej1

Cekej3:  pop       ds
         pop       cx
         pop       ax
         ret

Cekej    ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ cel‚ obrazovky (pozor na vol n¡ DOS bˆhem INT 24h !!!)
; -----------------------------------------------------------------------------
;þ
DispAll  PROC      FAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

; ------ zobrazen¡ oken editoru

         test      byte ptr ds:[WindPar],bit6 ; je re‘im editoru ?
         jz        DispAl00                 ; nen¡ re‘im editoru
         call      far ptr DispAEdi         ; zobrazen¡ v¨ech oken editoru
         jmp       DispAll9                 ; zobrazen¡ n povˆdy a menu

; ------ p©¡prava registr–

DispAl00:xor       dx,dx
         mov       cl,ds:[Pozic]
         shr       cl,1                     ; polovina obrazovky
         cmp       cl,40
         ja        DispAl01
         mov       cl,40
DispAl01:mov       ch,ds:[NumRows]          ; v˜¨ka oken
         test      byte ptr ds:[ParMenu],bit0 ; je trval‚ menu ?
         jz        DispAl02                 ; nen¡ trval‚ menu
         inc       dh                       ; © dek pro trval‚ menu
         jmp       short DispAll5

DispAl02:test      byte ptr ds:[ParMenu],bit3 ; p©echodn‚ vypnut¡ oken ?
         jnz       DispAll5                 ; je p©echodn‚ vypnut¡ oken
         test      byte ptr ds:[ParMenu],bit1 ; je hlavn¡ menu ?
         jz        DispAll5                 ; nen¡ hlavn¡ menu
         inc       dh
         dec       ch

; ------ zobrazen¡ lev‚ho okna

DispAll5:call      far ptr TestLAWn
         jnc       DispAl11
         call      far ptr PopScr
         jmp       short DispAll2

DispAl11:cmp       cl,40
         jbe       DispAll1
         push      cx
         sub       cl,40
         call      far ptr PopScr           ; zobrazen¡ podkladu vlevo od okna
         pop       cx

DispAll1:;cmp       byte ptr ds:[TypL],1     ; je lev‚ okno adres © ?
         ;jne       DispAl12                 ; nen¡ adres ©
         mov       ax,ds:[SegmL]
         ;call      far ptr ReadDirX
         call      far ptr DispAWin         ; zobrazen¡ adres ©e
DispAl12:;cmp       byte ptr ds:[TypL],2     ; je lev‚ okno seznam ?
         ;jne       DispAl14                 ; nen¡ seznam
         ;mov       ax,ds:[SegmLL]
         ;call      far ptr DispList         ; zobrazen¡ seznamu
DispAl14:

; ------ zobrazen¡ prav‚ho okna

DispAll2:call      far ptr TestRAWn
         jnc       DispAl21
         mov       dl,ds:[Pozic]
         shr       dl,1
         cmp       dl,40
         jb        DispAll4
         call      far ptr PopScr
         jmp       short DispAll4

DispAl21:cmp       cl,40
         jbe       DispAll3
         push      dx
         push      cx
         mov       dl,ds:[Pozic]
         shr       dl,1
         add       dl,40
         sub       cl,40
         call      far ptr PopScr           ; zobrazen¡ podkladu vpravo od okna
         pop       cx
         pop       dx

DispAll3:;cmp       byte ptr ds:[TypR],1     ; je prav‚ okno adres © ?
         ;jne       DispAL32                 ; nen¡ adres ©
         mov       ax,ds:[SegmR]
         ;call      far ptr ReadDirX
         call      far ptr DispAWin         ; zobrazen¡ adres ©e
DispAL32:;cmp       byte ptr ds:[TypR],2     ; je lev‚ okno seznam ?
         ;jne       DispAL34                 ; nen¡ seznam
         ;mov       ax,ds:[SegmLR]
         ;call      far ptr DispList         ; zobrazen¡ seznamu
DispAL34:

; ------ zobrazen¡ podkladu pod okny

DispAll4:;call      far ptr MaxLAWin         ; poskytnut¡ max. v˜¨ky oken
         mov       ch,ds:[LineCRad]         ; © dek k zobrazen¡ p©¡kaz. © dku
         mov       dh,ds:[NumRows]          ; po‡et © dk– oken
         test      byte ptr ds:[ParMenu],bit0 ; je trval‚ menu ?
         jz        DispAl42                 ; nen¡ trval‚ menu
         inc       dh                       ; oprava o trval‚ menu
DispAl42:sub       ch,dh                    ; v˜¨ka okna k vymaz n¡
         jbe       DispAll9                 ; nen¡ nic k vymaz n¡
         mov       cl,ds:[Pozic]            ; ¨¡©ka obrazovky
         mov       dl,0                     ; po‡ te‡n¡ pozice
         call      far ptr PopScr           ; obnoven¡ obrazovky pod okny

; ------ zobrazen¡ n povˆdy

DispAll9:
         call      far ptr Disp0Hlp

         test      byte ptr ds:[InfoPar],bit0 ; zobraz¡ se n povˆda ?
         jz        DispAl92                 ; nen¡ informa‡n¡ © dek
         test      byte ptr ds:[ParInt24],bit5 ; je obsluha INT 24h ?
         jnz       DispAl92                 ; prob¡h  INT 24h
         test      byte ptr ds:[ParMenu],bit3 ; p©echodn‚ vypnut¡ oken ?
         jnz       DispAl92                 ; je p©echodn‚ vypnut¡ oken
         call      far ptr InfoDisp         ; zobrazen¡ informa‡n¡ho © dku
DispAl92:
         call      far ptr DispLCom         ; zobrazen¡ p©¡kazov‚ho © dku

; ------ zobrazen¡ trval‚ho menu (nejsou-li menu aktivn¡)

         test      byte ptr ds:[ParMenu],bit3 ; je p©echodn‚ vypnut¡ oken ?
         jnz       DispAl62                 ; je p©echodn‚ vupnut¡ oken
         test      byte ptr ds:[ParMenu],bit1 ; zobrazeno trval‚ menu ?
         jnz       DispAll6                 ; trval‚ menu je obslou‘eno jinde
DispAl62:test      byte ptr ds:[ParMenu],bit0 ; je zobrazeno trval‚ menu ?
         jz        DispAll6                 ; nen¡ zobrazeno trval‚ menu
         mov       si,offset AMnuMain       ; hlavn¡ menu pro adres ©e
         test      byte ptr ds:[WindPar],bit6 ; je editace soubor– ?
         jz        DispAl63                 ; nen¡ editace soubor–
         mov       si,offset EMnuMain       ; hlavn¡ menu pro editor
DispAl63:call      far ptr DispMMnu         ; zobrazen¡ trval‚ho hlavn¡ho menu

; ------ zobrazen¡ otev©en˜ch oken menu

DispAll6:mov       bx,offset TabMenu        ; tabulka menu
         mov       cx,ds:[NumMenu]          ; po‡et otev©en˜ch oken menu
         jcxz      DispAll8                 ; nen¡ ‘ dn‚ okno menu
DispAll7:mov       si,ds:[bx]               ; adresa definice menu
         call      far ptr DispMnu          ; zobrazen¡ okna menu
         inc       bx
         inc       bx                       ; zv˜¨en¡ ukazatele v tabulce
         loop      DispAll7                 ; zobrazen¡ dal¨¡ho menu

DispAll8:

DispAl82:
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax

         ret

DispAll  ENDP

; -----------------------------------------------------------------------------
;                    skok na obsluhu podle BX
; -----------------------------------------------------------------------------
; Procedura se vol  instrukc¡ CALL FAR JumpBX, za kterou n sleduje tabulka
; skok–. Procedura zmˆn¡ svou n vratovou adresu na adresu podle nalezen‚
; polo‘ky v tabulce (nebo podle polo‘ky pro nenalezenou hodnotu).
; Pro TASM verze vy¨¨¡ ne‘ 1 provedena korekce - prvn¡ bajt 90h (= NOP) se p©esko‡¡
;  !!!!!!       POZOR - 1. bajt tabulky nesm¡ b˜t proto 90h        !!!!!!!
; -----------------------------------------------------------------------------
; VSTUP: v z sobn¡ku 2 slova (n vratov  adresa FAR) = za‡ tek tabulky skok–
;             stuktura tabulky: 1 slovo testovan  hodnota BX
;                               1 slovo adresa NEAR obsluhy
;             konec tabulky: 1 slovo = 0 (p©¡znak konce tabulky)
;                            1 slovo adresa NEAR obsluhy p©i nenalezen¡ k¢du
; -----------------------------------------------------------------------------

JumpBX   PROC      FAR

; ------ £schova registr–

                                            ; SS:[BP+8] = CS
                                            ; SS:[BP+6] = IP
         push      si                       ; SS:[BP+4] = SI
         push      bp                       ; SS:[BP+2] = BP
         push      ds                       ; SS:[BP+0] = DS
         mov       bp,sp

; ------ nalezen¡ hodnoty v tabulce

         mov       ds,ss:[bp+8]             ; segment adresy tabulky
         mov       si,ss:[bp+6]             ; offset adresy tabulky
         cmp       byte ptr ds:[si],90h     ; je p©elo‘eno jako NEAR ?
         jne       JumpBX1                  ; nen¡ NEAR
         inc       si                       ; p©esko‡en¡ instrukce NOP
JumpBX1: cmp       word ptr ds:[si],0       ; je konec tabulky ?
         je        JumpBX2                  ; konec tabulky - nenalezeno
         cmp       word ptr ds:[si],bx      ; je to hledan  hodnota ?
         je        JumpBX2                  ; hodnota nalezena
         add       si,4                     ; adresa dal¨¡ polo‘ky
         jmp       short JumpBX1            ; test dal¨¡ polo‘ky

; ------ nastaven¡ n vratov‚ adresy podle tabulky

JumpBX2: mov       si,ds:[si+2]             ; adresa skoku
         mov       ss:[bp+6],si             ; nov  n vratov  adresa

; ------ n vrat registr–

         pop       ds
         pop       bp
         pop       si

RETFAR:  ret                                ; instrukce RET FAR

JumpBX   ENDP

; -----------------------------------------------------------------------------
;        inicializace gener toru n hody (ni‡¡ AX a ES)
; -----------------------------------------------------------------------------

InitRnd  PROC      NEAR

         xor       ax,ax
         mov       es,ax
         mov       ax,es:[46ch]             ; ‡¡ta‡ syst‚mov‚ho ‡asova‡e
         mov       word ptr ds:[RandomR],ax ; inicializa‡n¡ konstanta
         ret

InitRnd  ENDP

; *****************************************************************************
;                               Random
;                     generov n¡ n hodn‚ho ‡¡sla
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; VSTUP: AX=n hodn‚ ‡¡slo
; *****************************************************************************

Random   PROC      FAR

         push      bx
         push      cx
         push      dx

         mov       ax,word ptr ds:[RandomR]
         mov       bx,word ptr ds:[RandomR+2]
         mov       cx,ax
         mul       word ptr ds:[RandomD]
         shl       cx,1
         shl       cx,1
         shl       cx,1
         add       ch,cl
         add       dx,cx
         add       dx,bx
         shl       bx,1
         shl       bx,1
         add       dx,bx
         add       dh,bl
         mov       cl,5
         shl       bx,cl
         add       dh,bl
         add       ax,1
         adc       dx,0
         mov       word ptr ds:[RandomR],ax
         mov       word ptr ds:[RandomR+2],dx
         xchg      ax,dx

         pop       dx
         pop       cx
         pop       bx
         ret

Random   ENDP

; *****************************************************************************
;                              SUpCase
;                syst‚mov  konverze znaku na velk  p¡smena
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
;        AL=znak ke konverzi
; *****************************************************************************

SUpCase  PROC      FAR

         pushf
         cmp       al,128
         jae       SUpCase1
         cmp       al,"a"
         jb        SUpCase2
         cmp       al,"z"
         ja        SUpCase2
         sub       al,32
         jmp       short SUpCase2

SUpCase1:push      bx
         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         push      ds

         call      dword ptr ds:[CNTRUpC]   ; konverze znaku na velk‚ p¡smeno

         pop       ds
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         mov       bl,al
         pop       ax
         mov       al,bl
         pop       bx
SUpCase2:popf
         ret

SUpCase  ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                   Inicializace programu z p©¡kazov‚ho © dku
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; -----------------------------------------------------------------------------
;        Inicializace dat, je-li rezidentn¡ modul (CY=nen¡ rezidentn¡ modul)
;              rezidentn¡ modul p©ed v  parametry v p©¡kazov‚m © dku !
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; VSTUP: CY=nen¡ rezidentn¡ modul
; zni‡en‚ registry: v¨echny kromˆ DS
; -----------------------------------------------------------------------------

IniDMRez PROC      NEAR

; ------ test, zda je start z rezidentn¡ho modulu (parametry v p©¡kazov‚m © dku)

         mov       es,ds:[SegPSP]           ; segment PSP
         mov       di,80h                   ; p©¡kazov˜ © dek ES:DI
         mov       si,offset RezIdent       ; identifik tor DS:SI
         mov       cx,5                     ; d‚lka dat k porovn n¡
         cld
         repe      cmpsb                    ; porovn n¡ dat
         stc                                ; p©¡znak, ‘e nen¡ rezidentn¡ modul
         jne       IniDMRz9                 ; nen¡ rezidentn¡ modul
         mov       byte ptr es:[80h],0      ; zru¨en¡ p©¡kazov‚ho © dku

; ------ adresa ukazatel– ze z hlav¡

         mov       ax,es:[di]               ; segment PSP
         mov       ds:[RezPSP],ax           ; segment PSP
         mov       ax,es:[di+2]             ; datov˜ segment
         mov       ds:[RezData],ax          ; datov˜ segment
         push      ax                       ; datov˜ segment
         mov       ax,es:[di+4]             ; segment programu
         mov       ds:[RezLoad],ax          ; segment CodeLod
         pop       es                       ; datov˜ segment

; ------ kontrola datov‚ho modulu

         mov       di,offset ConfBeg        ; za‡ tek datov‚ho modulu
         call      far ptr TestDSum         ; kontrola datov‚ho modulu
         jc        IniDMRz9                 ; data nesouhlas¡

; ------ n vrat dat z rezidentn¡ho modulu

         push      ds
         push      ds                       ; datov˜ segment
         push      es                       ; rezidentn¡ datov˜ segment
         pop       ds                       ; rezidentn¡ datov˜ segment
         pop       es                       ; datov˜ segment
         mov       si,di                    ; za‡ tek rezidentn¡ch dat
         mov       cx,offset ConfEnd        ; konec dat
         sub       cx,si                    ; d‚lka rezidentn¡ch dat
         cld
         shr       cx,1
         rep       movsw
         adc       cx,cx
         rep       movsb                    ; n vrat dat z rezidentn¡ho modulu
         pop       ds

         call      far ptr RetPCnf          ; n vrat parametr– z modulu

         or        byte ptr ds:[StartPar],bit0+bit2 ; je rezidentn¡ modul+data
                                            ; NC = p©¡znak operace OK
IniDMRz9:ret

IniDMRez ENDP

; -----------------------------------------------------------------------------
;                               InitBCnf
;      inicializace parametr– z konfigura‡n¡ch souboru CNF (n vrat z BAT)
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; zni‡en‚ registry: v¨echny kromˆ DS
; -----------------------------------------------------------------------------

InitBCnf PROC      NEAR

; ------ vytvo©en¡ segmentu pro na‡ten¡ souboru

         call      far ptr CreatSeg         ; vytvo©en¡ datov‚ho segmentu
         jc        InitBCn9                 ; chyba pamˆti
         mov       bp,ax                    ; £schova ‡¡sla segmentu

; ------ nastaven¡ velikosti segmentu

         mov       bx,offset ConfEnd+15+FileMax+40 ; konec konfigurace
         sub       bx,offset ConfBeg        ; velikost konfigura‡n¡ch dat
         call      far ptr ModiSegS         ; nastaven¡ velikosti segmentu
         jc        InitBCn8                 ; chyba
         call      far ptr GetDat           ; adresa bufferu

; ------ sestaven¡ jm‚na souboru $DOSMAN$.CFG

         mov       si,offset DosmCnf        ; konfigura‡n¡ soubor
         xor       di,di                    ; ukl dac¡ adresa
         call      far ptr TempFile         ; sestaven¡ jm‚na souboru

; ------ otev©en¡ souboru

         xor       si,si
         call      far ptr OpenR            ; otev©en¡ souboru pro ‡ten¡
         jc        InitBCn8                 ; chyba - soubor nenalezen

; ------ na‡ten¡ souboru do pamˆti

         mov       cx,offset ConfEnd        ; konec konfigurace
         sub       cx,offset ConfBeg        ; d‚lka konfigura‡n¡ch dat
         mov       bx,cx                    ; £schova velikosti dat
         mov       di,FileMax               ; ukl dac¡ adresa
         inc       cx                       ; 1 bajt pro test velikosti souboru
         call      far ptr ReadFile         ; na‡ten¡ dat ze souboru

; ------ uzav©en¡ souboru

         call      far ptr ClosFile         ; uzav©en¡ souboru

; ------ zru¨en¡ souboru $DOSMAN$.CFG

         xor       si,si
         call      far ptr DelFile          ; zru¨en¡ konfigura‡n¡ho souboru

; ------ test, zda souhlas¡ velikost souboru

         cmp       cx,bx                    ; souhlas¡ po‡et na‡ten˜ch bajt– ?
         jne       InitBCn8                 ; po‡et bajt– nesouhlas¡

; ------ kontrola souboru

         call      far ptr TestDSum         ; kontrola na‡ten˜ch dat
         jc        InitBCn8                 ; data nesouhlas¡

; ------ n vrat dat ze souboru

         mov       al,ds:[HelpPar]          ; parametry n povˆdy
         push      ds
         push      es
         push      ds
         pop       es                       ; ES <- datov˜ segment
         pop       ds                       ; DS <- segment s daty
         cld
         mov       si,FileMax               ; buffer s daty
         mov       di,offset ConfBeg        ; buffer k ulo‘en¡ dat
         rep       movsb                    ; n vrat dat ze souboru
         pop       ds
         and       al,bit2                  ; p©¡znak, ‘e nen¡ n povˆda k menu
         and       byte ptr ds:[HelpPar],not bit2
         or        ds:[HelpPar],al          ; p©¡znak, ‘e nen¡ n povˆda

; ------ inicializace parametr–

         call      far ptr RetPCnf          ; n vrat parametr– z modulu
         or        byte ptr ds:[StartPar],bit2 ; jsou ji‘ konfigura‡n¡ data

; ------ zru¨en¡ datov‚ho segmentu

InitBCn8:xchg      ax,bp                    ; vytvo©en˜ datov˜ segment
         call      far ptr DelSeg           ; zru¨en¡ datov‚ho bloku
InitBCn9:ret

InitBCnf ENDP

; -----------------------------------------------------------------------------
;        zru¨en¡ souboru $DOSMAN$.BAT
; -----------------------------------------------------------------------------

DelDMBat PROC      NEAR

         test      byte ptr ds:[TempDirP],bit0 ; je z kaz z pisu ?
         jnz       DelDMBt2                 ; je z kaz z pisu
         sub       sp,FileMax
         push      ss
         pop       es
         mov       di,sp                    ; ES:DI ukl dac¡ adresa
         mov       si,offset DosmBat        ; DS:SI soubor $DOSMAN$.BAT
         call      far ptr TempFile         ; sestaven¡ jm‚na souboru
         mov       si,sp
         call      far ptr DelFile          ; zru¨en¡ souboru
         add       sp,FileMax
DelDMBt2:ret

DelDMBat ENDP

; -----------------------------------------------------------------------------
;        Inicializace podle p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------
;þ
InitCnf  PROC      NEAR

; ------ pou‘¡t ¨ed‚ palety VGA "/MVGA"

         mov       si,offset ParCMVGT       ; parametr /MVGA
         call      far ptr GetCPar          ; test parametru
         jc        InitCnf1
         or        byte ptr ds:[ParDisp2],bit4 ; pou‘¡t ¨ed‚ palety VGA

; ------ mono barvy pro LCD displej "/LCD"

InitCnf1:mov       si,offset ParCLCDT       ; parametr /LCD
         call      far ptr GetCPar          ; test parametru
         jc        InitCn12
         or        byte ptr ds:[MonoMod],bit0 ; po‘adavek MONO barev

; ------ v˜stup na displej v ANSI m¢du

InitCn12:mov       si,offset ParCAnsT       ; parametr /ANSI
         call      far ptr GetCPar          ; test parametru
         jc        InitCn13
         or        byte ptr ds:[MonoMod],bit4 ; po‘adavek ANSI v˜stupu

; ------ zobrazen¡ v oknˆ WINDOWS

InitCn13:mov       si,offset ParCWinT       ; parametr /WINDOWS
         call      far ptr GetCPar          ; test parametru
         jc        InitCnf2
         or        byte ptr ds:[ParDisp2],bit6 ; p©¡znak parametru WINDOWS

; ------ automatick˜ kalend © /J

InitCnf2:test      byte ptr ds:[StartPar],bit2 ; opakovan˜ start ?
         jnz       InitCnf4                 ; je opakovan˜ start

         mov       si,offset ParCJT         ; parametr /J
         call      far ptr GetCPar          ; test parametru
         jc        InitCnf3
         or        byte ptr ds:[StartPar],bit6 ; p©¡znak parametru "/J"
InitCnf3:

; ------ automatick‚ menu /N (p©i startu)

         mov       si,offset ParCNT         ; parametr /N
         call      far ptr GetCPar
         jc        InitCnf4
         or        byte ptr ds:[StartPar],bit7 ; p©¡znak parametru "/N"

; ------ z kaz opu¨tˆn¡ menu /!M

InitCnf4:mov       si,offset ParCMT         ; parametr /!M
         call      far ptr GetCPar
         jc        InitCn42
         or        byte ptr ds:[ParMenu],bit7 ; p©¡znak parametru "/!M"

; ------ znovuvyvol n¡ u‘ivatelsk‚ho menu /!N

InitCn42:mov       si,offset ParCNT2        ; parametr /!N
         call      far ptr GetCPar
         jc        InitCnf5
         or        byte ptr ds:[ParMenu2],bit0 ; p©¡znak parametru "/!N"

; ------ n rodn¡ k¢d Kamenick˜ch /KAM

InitCnf5:mov       si,offset ParCKAM        ; parametr /KAM
         call      far ptr GetCPar
         jc        InitCn52
         mov       byte ptr ds:[CodePage],3 ; n rodn¡ k¢d Kamenick˜ch
         mov       byte ptr ds:[CodePag0],3 ; n rodn¡ k¢d Kamenick˜ch ur‡en˜
         mov       byte ptr ds:[CodePagK],1 ; k¢dov n¡ Kamenick˜ch

; ------ n rodn¡ k¢d Latin 2 /LAT

InitCn52:mov       si,offset ParCLAT        ; parametr /LAT
         call      far ptr GetCPar
         jc        InitCn54
         mov       byte ptr ds:[CodePage],4 ; k¢d Latin 2
         mov       byte ptr ds:[CodePag0],4 ; k¢d Latin 2 ur‡en˜
         mov       byte ptr ds:[CodePagK],2 ; k¢dov n¡ Latin 2

; ------ n rodn¡ k¢d IBM /IBM

InitCn54:mov       si,offset ParCIBM        ; parametr /IBM
         call      far ptr GetCPar
         jc        InitCn56
         mov       byte ptr ds:[CodePage],2 ; k¢d IBM
         mov       byte ptr ds:[CodePag0],2 ; k¢d IBM ur‡en˜
         mov       byte ptr ds:[CodePagK],0 ; k¢dov n¡ neur‡eno

; ------ velikost prost©ed¡ /E:

InitCn56:mov       si,offset ParCET         ; parametr /E:
         call      far ptr GetCPar
         jc        InitCnfB
         xor       bx,bx                    ; st©ada‡
         dec       di
IniCnfA2:inc       di
         mov       al,es:[di]
         cmp       al,TAB
         je        IniCnfA2
         cmp       al," "
         je        IniCnfA2

         dec       di
IniCnfA3:inc       di
         mov       al,es:[di]
         sub       al,"0"
         jb        IniCnfA4
         cmp       al,9
         ja        IniCnfA4
         mov       ah,0
         push      ax
         mov       ax,10
         mul       bx
         pop       bx
         add       bx,ax
         jnc       IniCnfA3
         mov       bx,-1

IniCnfA4:xchg      ax,bx
         or        ax,ax
         jz        IniCnfA6
         cmp       ax,160
         jae       IniCnfA5
         mov       ax,160
IniCnfA5:cmp       ax,32768
         jb        IniCnfA6
         mov       ax,32768
IniCnfA6:mov       ds:[EnvSize],ax          ; velikost prost©ed¡

; ------ proveden¡ p©¡kazu p©i startu

InitCnfB:test      byte ptr ds:[StartPar],bit2 ; opakovan˜ start ?
         jnz       InitCnfC                 ; je opakovan˜ start
         mov       si,offset ParCCT         ; parametr "/C"
         call      far ptr GetCPar          ; nalezen¡ parametru
         jc        InitCnfC                 ; nen¡ parametr "/C"
         mov       si,offset LineCBuf       ; buffer p©¡kazu
         xor       cx,cx                    ; ‡¡ta‡ po‡tu znak–
         cmp       byte ptr es:[di]," "
         jne       IniCnfB2
         inc       di
IniCnfB2:mov       al,es:[di]
         inc       di
         cmp       al,TAB
         je        IniCnfB3
         cmp       al," "
         jb        IniCnfB4
IniCnfB3:mov       ds:[si],al
         inc       si
         inc       cx
         jmp       short IniCnfB2

IniCnfB4:mov       ds:[LineCNum],cl         ; po‡et znak– p©¡kazu

InitCnfC:ret

InitCnf  ENDP

Code     ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;
;                                 Data
;
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

Data     SEGMENT   BYTE PUBLIC
;þ
; ------ instala‡n¡ data (p©evzato ze z hlav¡ PKLITE) (23 bajt–)

LicDat   label     byte                     ; licen‡n¡ instala‡n¡ data
LicDKod  dw        0                        ; 0: k¢dovac¡ maska
LicDCRC  dw        0                        ; 2: kontroln¡ sou‡et dat po odk¢dov n¡
LicDNum  dw        45000,18820              ; 4: licen‡n¡ ‡¡slo (0=DEMO verze)
LicDVer  db        0,0                      ; 8: verze programu (setiny+cel )
LicDPar  db        0                        ; 10: parametry - uchovan‚ hodnoty
                                            ;     bit 0: 1=kontroln¡ sou‡et BIOS
                                            ;     bit 1:
                                            ;     bit 2:
                                            ;     bit 3: 1=s‚riov‚ ‡¡slo disku
                                            ;     bit 4:
                                            ;     bit 5: 1=datum + ‡as adres ©e
                                            ;     bit 6: 1=je ‡asov‚ omezen¡
                                            ;     bit 7: 1=nen¡ instalov n
LicDBios db        0                        ; 11: BIOS
LicDPC   dw        0                        ; 12: po‡et po‡¡ta‡– licence
LicDSer  dw        0                        ; 14: s‚riov‚ ‡¡slo disku
         db        0                        ; 16: (po‡et dn– omezen¡)
LicDDate dw        0                        ; 17: datum + ‡as adres ©e
LicDDatO dw        0                        ; 19: datum konce platnosti (tvar soubor–)
LicDCrcT dw        0                        ; 21: kontroln¡ sou‡et lic. textu
LicDat0  label     byte

;LicErr   db        13,10,'? LICENCE ?',13,10,'$'
;
;LicOmezT db        13,10,'Lituji, uplynula povolena lhuta'
;         db        13,10,'pro provoz programu DOS Manazer!',13,10,13,10,'$'

LicDOmz0 db        0                        ; po‡et zb˜vaj¡c¡ch dn– omezen¡

LicDPar0 db        bit4                     ; parametry licence
                                            ;     bit 0: 1=nesouhlas¡ CRC
                                            ;     bit 1: 1=nesouhlas¡ instalace

                                            ;     bit 4: 1=je DEMO verze
                                            ;            (licen‡n¡ ‡¡slo 00000)

                                            ;     bit 6: 1=disk vzd len˜
                                            ;     bit 7: 1=disk v˜mˆnn˜


; -----------------------------------------------------------------------------
;        varov n¡ - ‡asov‚ omezen¡
; -----------------------------------------------------------------------------

OmezMnu  label     byte
         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        1                        ; po‡et platn˜ch polo‘ek menu
         dw        6                        ; celkov˜ po‡et polo‘ek menu

         dw        OmezMnuP                 ; za‡ tek definice polo‘ek menu
         dw        ChbLnMeH                 ; adresa tabulky text– n povˆdy
         dw        Hlp@Main                 ; ‡¡slo str nky velk‚ n povˆdy
         dw        OmezMnuB                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        OmezMnuT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        23                       ; po‡ te‡n¡ pozice okna
         db        7                        ; po‡ te‡n¡ © dek okna
         db        57                       ; ¨¡©ka okna
         db        10                       ; v˜¨ka okna

         dw        255                      ; maxim ln¡ d‚lka textu © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        bit3                     ; maska zad van˜ch znak–
         db        0,'      '               ; zak zan‚ znaky

         db        0                        ; historie
         db        0                        ; po‡et p©edvoleb

OmezMnuP db        bit6,9,0,'Varov n¡'
         db        bit6,55,'Zb˜v  ',0
OmezMnP1 db         '0',0,' '
OmezMnP2 db         'dn– do konce funk‡nosti programu DOS Mana‘er.'
         db        bit6,51,'Bli‘¨¡ informace naleznete v souboru '
         db         0,'CTI_MNE.TXT',0,'.'
         db        bit6,0
         db        bit6+bit7,0
         db        1,6,'N vrat'

OmezMnuB db        0                        ; blokovac¡ tabulka

OmezMnuT db        14,'‡asov‚ omezen¡'

; ------ hl ¨en¡ pro DEMO

DemoMenu label     byte

         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        2                        ; po‡et platn˜ch polo‘ek menu
         dw        19                       ; celkov˜ po‡et polo‘ek menu

         dw        DemoMnuP                 ; za‡ tek definice polo‘ek menu
         dw        DemoMHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@Main                 ; ‡¡slo str nky velk‚ n povˆdy
         dw        DemoMnuB                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        DemoMnuT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        23                       ; po‡ te‡n¡ pozice okna
         db        7                        ; po‡ te‡n¡ © dek okna
         db        68                       ; ¨¡©ka okna
         db        22                       ; v˜¨ka okna

         dw        255                      ; maxim ln¡ d‚lka textu © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        bit3                     ; maska zad van˜ch znak–
         db        0,'      '               ; zak zan‚ znaky

         db        0                        ; historie
         db        0                        ; po‡et p©edvoleb

DemoMnuP db        bit6,31,0,'DOS Mana‘er',0,' verze '
         db           DMVerze1+"0",'.',DMVerze2+"0",DMVerze3+"0",' ',0,'DEMO',0
         db        bit6,57,'diskov˜ a souborov˜ mana‘er pro DOS, WINDOWS a WINDOWS 95'
         db        bit6+bit7,21,0,' Omezen¡ DEMO verze '
         db        bit6,60,'- po‡et zobrazen˜ch soubor– a adres ©– v oknˆ omezen na 15  '
         db        bit6,60,'- po‡et zobrazen˜ch © dk– v editoru omezen na 50            '
         db        bit6,60,'- po‡et zobrazen˜ch © dk– v prohl¡‘e‡i omezen na 500        '
         db        bit6,60,'- po‡et zobrazen˜ch z znam– souboru DBF omezen na 30        '
         db        bit6,60,'- tabulka kalkul toru omezena na 16 © dk– a 4 sloupce       '
         db        bit6,60,'- nelze editovat disk diskov˜m editorem                     '
         db        bit6+bit7,35,0,' Licen‡n¡ podm¡nky pro DEMO verzi '
         db        bit6,64,'DEMO verze slou‘¡ pouze k sezn men¡ s funkcemi programu  DOSMAN,'
         db        bit6,64,'nen¡ ur‡ena k bˆ‘n‚mu pou‘¡v n¡. Pokud by byla pou‘¡v na k jin˜m'
         db        bit6,64,'£‡el–m ne‘ k seznamovac¡m nebo po dobu del¨¡ ne‘ 30 dn–, bylo by'
         db        bit6,64,'to stejn‚ poru¨en¡ licen‡n¡ch podm¡nek programu  jako  nez konn‚'
         db        bit6,64,'pou‘¡v n¡ pln‚ verze programu. U‘ivatel takto poru¨uj¡c¡ licenci'
         db        bit6,64,'by se vystavoval nebezpe‡¡ mo‘nosti trestn¡ho st¡h n¡!          '
         db        bit6+bit7,0
         db        1,35,'P©ij¡m m licen‡n¡ podm¡nky pro DEMO'
         db        1,16,'Leg ln¡ software'

DemoMnuB db        0,0
DemoMnuT db        4,'DEMO'

HelpS    SEGMENT   BYTE PUBLIC
DemoMHlp db        41,'Potvrzen¡ hl ¨en¡ stiskem kl vesy Enter'
         db        36,'N vod, jak pou‘¡vat leg ln¡ software'
HelpS    ENDS

;DobryTxt db        'program DOS Manazer 2.00 Vam preje DOBRY DEN'

MemErrT  db        'Nedostatek pameti ke spusteni DOS Manazeru !',13,10,'$'

HelpHTxt db        'DOSMAN verze ',DMVerze1+"0",".",DMVerze2+"0",DMVerze3+"0"
         db        '; (c) Miroslav Nemecek',13,10

;         db        '      soubor .... specifikace souboru k editaci',13,10
         db        '      /?, /H .... tato napoveda',13,10
         db        '      /ANSI ..... vystup na displej v modu ANSI (musi byt nainstalovan',13,10
         db        '                  ovladac ANSI.SYS nebo musi byt vystup presmerovan ">")',13,10
         db        '      /NOHLP .... neni napoveda k menu (uvolni se 50 KB pameti)',13,10
         db        '      /MVGA ..... cernobily displej s kartou VGA (pouzit sede palety)',13,10
         db        '      /LCD ...... displej LCD (pouzit sadu barev pro MONO)',13,10
         db        '      /E:n ...... velikost prostredi COMMAND.COM (n=160 az 32768, 0=stand.)',13,10
         db        '      /KAM ...... pouzit narodni kod KEYBCS2 (Kamenickych)',13,10
         db        '      /LAT ...... pouzit narodni kod Latin 2',13,10
         db        '      /IBM ...... pouzit narodni kod IBM (omezena diakritika)',13,10
         db        '      /J ........ vyvolani kalendare pri startu',13,10
         db        '      /N ........ zobrazeni uzivatelskeho menu pri startu',13,10
         db        '      /!N ....... navraceni uzivatelskeho menu po provedeni volby',13,10
         db        '      /!M ....... zakaz opusteni uzivatelskeho menu',13,10
         db        '      /X adr .... programovy adresar (utility, napoveda pro DOSMAN)',13,10
         db        '      /X* ....... programovy adresar nastaven stejne jako /Z adr',13,10
         db        '      /Z adr .... datovy adresar (konfigurace pro DOSMAN, uzivatelska data)',13,10
         db        '      /RO ....... zakaz zapisu do datoveho adresare (provoz z diskety)',13,10
         db        '      /WINDOWS .. program spusten v okne WINDOWS',13,10
         db        '      /C prikaz . provedeni prikazu po startu DOS Manazeru',13,10
         db        '                  - musi byt uveden jako posledni parametr !',13,10
         db        '$'

VerzeOS  dw        600h                     ; verze opera‡n¡ho syst‚mu (p©ednastaveno !)

CPU      db        0                        ; typ procesoru
                                            ;   1=Intel 8088
                                            ;   2=Intel 8086
                                            ;   3=NEC V20
                                            ;   4=NEC V30
                                            ;   5=Intel 80188
                                            ;   6=Intel 80186
                                            ;   7=Intel 80286
                                            ;   8=Intel 80386
                                            ;   9=Intel 80386 SX
                                            ;  10=Intel 80486
                                            ;  11=Intel 80486+
                                            ;  12=Pentium

ModelCPU dw        0                        ; model CPU (0=nen¡ zn m)

VendrCPU label     byte
         db        13 dup(0)                ; Vendor ©etˆzec CPU

Vybaveni dw        0                        ; tabulka vybaven¡
                                            ;   bit 0: 1=diskety p©¡tomny
                                            ;   bit 1: 1=matematick˜ koprocesor
                                            ;   bit 2:  -
                                            ;   bit 3:  -
                                            ;   bit 4, bit 5: inicial. videom¢d
                                            ;          00=EGA/VGA
                                            ;          01=40 x 25 barevn˜
                                            ;          10=80 x 25 barevn˜
                                            ;          11=80 x 25 mono
                                            ;   bit 6, bit 7: po‡et disket - 1
                                            ;   bit 8:  -
                                            ;   bit 9 a‘ bit 11: po‡et port– COM
                                            ;   bit 12: 1=instalov n GAME port
                                            ;   bit 13: 1=instalov n modem
                                            ;   bit 14, bit15: po‡et port– LPT

RandomR  dd        21510d31h                ; promˆnn  pro gener tor n hody
RandomD  dw        8405h                    ; pomocn  konstanta

LastErr  dw        0                        ; posledn¡ k¢d chyby

;EnvSize  dw        0                        ; velikost prost©ed¡ (0=standardn¡)

StartPar db        0                        ; startovac¡ parametry
                                            ;   bit 0: 1=je rezidentn¡ modul
                                            ;   bit 1: 1=je aktualizace INI souboru
                                            ;   bit 2: 1=jsou ji‘ konfig. data
                                            ;            (je opakovan˜ start)
                                            ;   bit 3:
                                            ;   bit 4: 1=inicializace p©i startu
                                            ;   bit 5: 1=star˜ v˜znam + - *
                                            ;   bit 6: 1=kalend © p©i startu
                                            ;   bit 7: 1=menu p©i startu

Win95Par db        0                        ; parametry pro WINDOWS
                                            ;   bit 2: 1=z kaz dlouh˜ch jmen
                                            ;            (nen¡ WINDOWS 95)
                                            ;   bit 3: 1=jsou WINDOWS

CodePage db        0                        ; k¢dov  str nka displeje a kl ves.
                                            ;    0 = neur‡eno (nutn  detekce)
                                            ;    1 = bez diakritiky
                                            ;    2 = IBM (omezen  diakritika)
                                            ;    3 = KEYBCS2 (Kamenick˜ch)
                                            ;    4 = Latin 2

CodePagK db        0                        ; k¢dov  str nka pro k¢dov n¡ dat
                                            ;    0 = neur‡eno
                                            ;    1 = KEYBCS2 (Kamenick˜ch)
                                            ;    2 = Latin 2

Cod0PagK db        0                        ; kopie CodePagK p©i otev©en¡ INI

; ------ parametry rezidentn¡ho modulu

RezPSP   dw        0                        ; PSP rezidentn¡ho modulu
RezData  dw        0                        ; data rezidentn¡ho modulu
RezLoad  dw        0                        ; segment rezidentn¡ho zavadˆ‡e

; ------ £schova nastaven¡ z sobn¡ku

StackSP  dw        0                        ; uschovan˜ offset z sobn¡ku SP
StackSS  dw        0                        ; uschovan˜ segment z sobn¡ku SS

; ------ p©ep¡na‡e z p©¡kazov‚ho © dku

ParCHl1T db        1,'?'                    ; n povˆda
ParCHl2T db        1,'H'                    ; n povˆda
ParCAnsT db        4,'ANSI'                 ; v˜stup v ANSI m¢du
;ParCBatT db        3,'BAT'                  ; n vrat v m¢du povelov‚ho souboru
ParCMVGT db        4,'MVGA'                 ; ¨ed‚ palety displeje VGA
ParCLCDT db        3,'LCD'                  ; mono barvy pro LCD displej
ParCNoHT db        5,'NOHLP'                ; nen¡ n povˆda k menu
ParCET   db        2,'E:'                   ; velikost prost©ed¡
ParCJT   db        1,'J'                    ; automatick˜ kalend ©
ParCKAM  db        3,'KAM'                  ; n rodn¡ k¢d Kamenick˜ch
ParCLAT  db        3,'LAT'                  ; n rodn¡ k¢d Latin 2
ParCIBM  db        3,'IBM'                  ; n rodn¡ k¢d IBM
ParCNT   db        1,'N'                    ; automatick‚ u‘iv. menu p©i startu
ParCNT2  db        2,'!N'                   ; znovuvyvol n¡ u‘iv. menu
ParCMT   db        2,'!M'                   ; z kaz opu¨tˆn¡ u‘iv. menu
ParCXT   db        1,'X'                    ; programov˜ adres ©
ParCZT   db        1,'Z'                    ; datov˜ adres ©
ParCRO   db        2,'RO'                   ; z kaz z pisu do datov‚ho adres ©e
ParCCT   db        1,'C'                    ; p©¡kaz p©i startu
ParCWinT db        7,'WINDOWS'              ; spu¨tˆno v oknˆ WINDOWS

; ------ z kladn¡ p©ep¡na‡e

;DosMITxt db        6,'DosMan'               ; skupina z kladn¡ch p©ep¡na‡–
;PermMenu db        8,'PermMenu'             ; permanentn¡ menu
;FNHelpTx db        6,'FNHelp'               ; n povˆda k funk‡n¡m kl ves m
;FN12Txt  db        4,'FN12'                 ; funk‡n¡ kl vesy 12 kl ves
;HelpMnuT db        8,'HelpMenu'             ; n povˆda k menu
;LineComT db        7,'LineCom'              ; po‡et © dk– p©¡kaz. © dku
;VerifyT  db        6,'Verify'               ; nastaven¡ VERIFY disk. operac¡ DOS
;EnvSizT  db        7,'EnvSize'              ; velikost prost©ed¡
;GMouseT  db        10,'GraphMouse'          ; grafick˜ kurzor my¨i
;CodePagT db        8,'CodePage'             ; k¢dov  str nka displeje
;ExecCOMT db        7,'ExecCOM'              ; COM/EXE/BAT se spou¨tˆj¡ bez p©¡p.
;ExtnsTxt db        9,'Extension'            ; skupina definice p©¡pon
;UserMTxt db        8,'UserMenu'             ; u‘ivatelsk‚ menu

;HelpFNTT db        10,'HelpCAFN12'          ; n povˆda ke kl vese
;
;HelpFNT  db        6,'HelpFN'               ; n povˆda k funk‡n¡m kl ves m
;         db        7,'HelpSFN'              ; n povˆda k Shift-FN
;         db        7,'HelpCFN'              ; n povˆda k Ctrl-FN
;         db        7,'HelpAFN'              ; n povˆda k Alt-FN
;         db        8,'HelpSCFN'             ; n povˆda k Shift-Ctrl-FN
;         db        8,'HelpSAFN'             ; n povˆda k Shift-Alt-FN
;         db        8,'HelpCAFN'             ; n povˆda k Ctrl-Alt-FN
;         db        0

;FormDatT db        8,'FormDate'             ; form t data MDY|DMY|YMD
;CharDatT db        8,'CharDate'             ; oddˆlovac¡ znak data "znak"
;CharTimT db        8,'CharTime'             ; oddˆlovac¡ znak ‡asu "znak"
;CharNumT db        7,'CharNum'              ; oddˆlovac¡ znak © d– ‡¡sel "znak"

;DarkerT  db        6,'Darker'               ; doba ztm¡v n¡
;DarkExeT db        7,'DarkExe'              ; program pro ztm¡v n¡
;PathPrmT db        10,'PathPrompt'          ; zobraz¡ se cesta v promptu

;DatFrmTx db        3,'MDY'                  ; USA
;         db        3,'DMY'                  ; EVROPA
;         db        3,'YMD'                  ; JAPONSKO
;         db        0

;CodePgTx db        2,'NO'                   ; nen¡ ‡e¨tina
;         db        3,'IBM'                  ; omezen  ‡e¨tina
;         db        7,'KeybCS2'              ; Kamenick˜ch
;         db        6,'Latin2'               ; Latin 2
;         db        4,'KOI8'                 ; KOI8
;         db        5,'Cyril'                ; Cyrilic
;         db        0

; ------ inicializace programu

YNIniTxt db        1,'Y'                    ; volba p©ep¡na‡e inicializace "Y"
         db        1,'N'                    ; volba p©ep¡na‡e inicializace "N"
         db        0

; ------ inicializa‡n¡ soubor

GroupAdr dw        InitData                 ; adresa otev©en‚ skupiny v souboru
SegmIni  dw        0                        ; segment se souborem
DosmIni  db        10,'DOSMAN.INI'          ; inicializa‡n¡ soubor
DosmCnf  db        12,'$DOSMAN$.CFG'        ; konfigura‡n¡ soubor
DosmLst  db        12,'$DOSMAN$.LST'

; ------ tabulka aktivn¡ch polo‘ek menu k uschov n¡ (pevn˜ po‡et polo‘ek !!!!)

TabAMenu label     word
         dw        AMnuMain                 ; hlavn¡ adres ©ov‚ menu
         dw        SMnuVert                 ;   menu soubor–
         dw        SBMnVert                 ;     menu v˜bˆru polo‘ek
         dw        SBPMVert                 ;       v˜bˆr porovn n¡m
         dw        SEMnVert                 ;     menu editace soubor–
         dw        SFMnVert                 ;     menu filtru soubor–
         dw        SFSMVert                 ;       vstupn¡ k¢d filtru
         dw        SFVMVert                 ;       v˜stupn¡ k¢d filtru
         dw        SJMnVert                 ;     p©esun soubor–
         dw        SKMnVert                 ;     kop¡rov n¡ soubor–
         dw        SMMnVert                 ;     modifikace soubor–
         dw        SPMnVert                 ;     start programu
         dw        SRMnVert                 ;     ru¨en¡ soubor–
         dw        STMnVert                 ;     tisk soubor–
         dw        STTMVert                 ;       vstupn¡ za©¡zen¡
         dw        SVMnVert                 ;     menu verifikace soubor–
         dw        SZMnVert                 ;     menu zobrazen¡ soubor–
         dw        DMnuVert                 ;   menu obsluhy disku
         dw        NulDMnu                  ;     menu nulov n¡ disku
         dw        ZMnuVert                 ;   zvl ¨tn¡ funkce
         dw        ZNMnVert                 ;     nastaven¡
         dw        DspNMnu                  ;       nastaven¡ displeje
         dw        KodNMnu                  ;       nastaven¡ n rodn¡ho k¢du
         dw        ZAMnuLin                 ;     ASCII tabulka
         dw        OMnuVert                 ;   menu oken
         dw        LMnuVert                 ;     lev‚ okno
         dw        RMnuVert                 ;     prav‚ okno
         dw        LZMnVert                 ;       zobrazen¡ okna
         dw        LTMnVert                 ;       t©¡dˆn¡ okna
         dw        NMnuVert                 ;   menu n povˆdy
         dw        KMnuVert                 ;   menu ukon‡en¡ programu
         dw        0

; -----------------------------------------------------------------------------
;        COUNTRY informace
; -----------------------------------------------------------------------------

COUNTRY  label     byte

CNTRFDat dw        1                        ; form t data
                                            ;   0 = USA      MMDDYY
                                            ;   1 = EVROPA   DDMMYY
                                            ;   2 = JAPONSKO YYMMDD
CNTRMena db        '$',0,0,0,0              ; znak mˆny (©etˆzec ASCIIZ)
CNTRTis  db        "'",0                    ; oddˆlova‡ tis¡c– (©etˆzec ASCIIZ)
CNTRDes  db        '.',0                    ; oddˆlova‡ desetin (©etˆzec ASCIIZ)
CNTRDat  db        '.',0                    ; oddˆlova‡ data (©etˆzec ASCIIZ)
CNTRTim  db        ':',0                    ; oddˆlova‡ ‡asu (©etˆzec ASCIIZ)
CNTRFMen db        0                        ; form t mˆny
                                            ;  bit 0: 1=symbol mˆny za ‡¡slem
                                            ;         0=symbol mˆny p©ed ‡¡slem
                                            ;  bit 1: 1=mezera mezi znakem mˆny a ‡¡slem
                                            ;  bit 2: 1=symbo mˆny nahrazuje desetinnou ‡ rku
CNTRNDes db        2                        ; po‡et desetinn˜ch m¡st v mˆnˆ
CNTRFTim db        1                        ; form t ‡asu
                                            ;  bit 0: 1=24 hodin, 0=12 hodin
CNTRUpC  dd        RETFAR                   ; procedura pro velk  p¡smena (v AL, >= 80h))
CNTRSezn db        ',',0                    ; oddˆlova‡ seznamu dat (©etˆzec ASCIIZ)
         db        10 dup(0)                ; rezervov no

; -----------------------------------------------------------------------------
;        Definice adres ©ov‚ho hlavn¡ho menu
; -----------------------------------------------------------------------------

AMnuMain label     byte                   ;* hlavn¡ adres ©ov‚ menu

         db        0                        ; typ menu - hlavn¡ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        6                        ; aktivn¡ polo‘ka menu
         dw        6                        ; po‡et polo‘ek v menu
         dw        6                        ; celkov˜ po‡et polo‘ek v menu

         dw        offset AMnuMAk1          ; adresa definice polo‘ek menu
         dw        offset AMnuMAh1          ; adresa text– n povˆd
         dw        Hlp@HlavniMenu           ; ‡¡slo str nky velk‚ n povˆdy
         dw        offset AMnuMAk7          ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡– (0=nen¡)
         dw        0                        ; adresa titulu okna (0=nen¡)
         dw        AMnuExec                 ; tabulka obsluh voleb menu
         dw        AMnuAdr                  ; tabulka odvozen˜ch menu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        11                       ; po‡ te‡n¡ pozice okna menu
         db        0                        ; po‡ te‡n¡ © dek okna menu
         db        0                        ; ¨¡©ka okna menu
         db        1                        ; v˜¨ka okna menu

         db        0                        ; lev˜ okraj menu
         db        0                        ; mezera na okraji polo‘ky
         db        0                        ; oddˆlovac¡ mezera mezi polo‘kami
         db        0                        ; prav˜ okraj menu
         db        0                        ; omezen¡ d‚lky polo‘ky

AMnuMAk1 db        1,7,'Soubory'
         db        1,4,'Disk'
         db        1,8,'Zvl ¨tn¡'
         db        1,4,'Okna'
         db        1,8,'N povˆda'
         db        1,5,'Konec'

AMnuMAk7 db        0,0,0,0,0,0              ; blokovac¡ tabulka polo‘ek

HelpS    SEGMENT   BYTE PUBLIC
AMnuMAh1 db        60,'Operace se soubory a adres ©i - kop¡rov n¡, editace, hled n¡'
         db        61,'Operace s disky - kop¡rov n¡, form tov n¡, hled n¡, parkov n¡'
         db        67,'Zvl ¨tn¡ funkce - kalkul tor, z pisn¡k, u‘ivatelsk‚ menu, nastaven¡'
         db        56,'Ovl d n¡ oken - p©epnut¡, porovn n¡, zobrazen¡, ozna‡en¡'
         db        53,'N povˆda k programu DOS Mana‘er, u‘ivatelsk  n povˆda'
         db        58,'Konec programu DOS Mana‘er, n vrat do syst‚mu (Ctrl-F10)'
HelpS    ENDS

AMnuExec label     dword                    ; tabulka obsluh voleb menu
         dd        AWMMnuS                  ; Soubory
         dd        AWMMnuD                  ; Disk
         dd        AWMMnuZ                  ; Zvl ¨tn¡
         dd        AWMMnuO                  ; Okna
         dd        AWMMnuN                  ; N povˆda
         dd        AWMMnuK                  ; Konec

AMnuAdr  label     word                     ; adresy definic podmenu
         dw        SMnuVert                 ; soubory
         dw        DMnuVert                 ; disk
         dw        ZMnuVert                 ; zvl ¨tn¡ funkce
         dw        OMnuVert                 ; okna
         dw        NMnuVert                 ; n povˆda
         dw        KMnuVert                 ; konec

; -----------------------------------------------------------------------------
;        Definice vertik ln¡ho menu - ukon‡en¡ programu
; -----------------------------------------------------------------------------

KMnuVert label     byte                   ;* menu ukon‡en¡

         db        1                        ; typ menu - vertik ln¡ menu hlavn¡

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        2                        ; po‡et platn˜ch polo‘ek menu
         dw        10                       ; celkov˜ po‡et polo‘ek menu
         dw        offset KMnuVA1           ; adresa definice polo‘ek menu
         dw        offset KMnuVH1           ; adresa n povˆd
         dw        Hlp@HlavniMenu           ; ‡¡slo str nky velk‚ n povˆdy
         dw        offset KMnuVA5           ; adresa blokovac¡ tabulky
         dw        0                          ; adresa tabulky p©ep¡na‡–
         dw        KMnuVT1                  ; adresa titulu okna
         dw        KMnuVExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        54                       ; po‡ te‡n¡ pozice
         db        1                        ; po‡ te‡n¡ © dek
         db        36                       ; ¨¡©ka
         db        12                       ; v˜¨ka
;þ
IFDEF    DEBUG
KMnuVA1  db        1,24,'ANO, KONEC DEBUG M•DU  !'
ELSE
KMnuVA1  db        5,28,'    Ano, ukon‡it DOS Mana‘er'
ENDIF
         db        7,25,'      Ne, pokra‡ovat d le'

         db        bit6+bit7,9,' licence '
         db        bit6,12,0
LicCislo db        '00000-00000'

         db        bit6,11,1
KMnuVrt1 dw        LicPocDm
         db        0,1
KMnuVrt2 dw        LicPoc0
         db        0,1
KMnuVrt3 dw        LicPoc0

         db        bit6+bit7,0

         db        bit6,33,0
LicJmeno db        '                                '
         db        bit6,32
LicAdres db        '                                '
         db        bit6,32
LicMesto db        '                                '
         db        bit6,32
LicICO   db        '                                '

LicPocLi db        12,'licence pro '
LicPocMu db        17,'multilicence pro '
LicPocOE db        16,0,'OEM',0,' verze pro '
LicPocNe db        22,'neomezen  multilicence'
LicPocDm db        9,'DEMOVERZE'

LicPocPC db        1,'1     '               ; po‡et po‡¡ta‡– licence
LicPoc0  db        0
LicPocVy db        12,0,'v˜hradn¡ho',0

LicPocPo db        8,' po‡¡ta‡'
LicPocP0 db        'e'
LicPocUz db        10,' u‘ivatele'

KMnuVA5  db        0,0

KMnuVT1  db        5,'konec'

HelpS    SEGMENT   BYTE PUBLIC
KMnuVH1  db        73,'Ukon‡en¡ programu DOS Mana‘er a n vrat do opera‡n¡ho syst‚mu (Ctrl-F10)'
         db        45,'N vrat z volby a pokra‡ov n¡ v dal¨¡ ‡innosti'
HelpS    ENDS

KMnuVExe label     dword                    ; tabulka obsluh menu
         dd        Konec                    ; ano, konec
         dd        AWMMnu0                  ; ne

; -----------------------------------------------------------------------------
;        Definice © dkov‚ho menu - zmˆna adres ©e
; -----------------------------------------------------------------------------

HWMnuLin label     byte                   ;* menu vytvo©en¡ adres ©e
         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        3                        ; po‡et platn˜ch polo‘ek menu
         dw        5                        ; celkov˜ po‡et polo‘ek menu

         dw        HWMnLPol                 ; za‡ tek definice polo‘ek menu
         dw        HWMnLHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@NavratKAdresariUschovanemVHistorii ; ‡¡slo str nky velk‚ n povˆdy
         dw        HWMnLBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        HWMnLTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        20                       ; po‡ te‡n¡ pozice okna
         db        0                        ; po‡ te‡n¡ © dek okna
         db        50                       ; ¨¡©ka okna
         db        8                        ; v˜¨ka okna

         dw        FileMax                  ; maxim ln¡ d‚lka textu © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        1                        ; celkov˜ po‡et © dk–
         dw        1                        ; po‡et zobrazen˜ch © dk–

         db        bit3                     ; maska zad van˜ch znak– - soubor
         db        2,'?*    '               ; zak zan‚ znaky

         db        HistAdr                  ; historie adres ©–
         db        0                        ; po‡et p©edvoleb

; ------ polo‘ky voleb

HWMnLPol db        bit6,28,'Zadejte adres © k nastaven¡:'
         db        0,0
         db        bit6+bit7,0
         db        1,6,'Nastav'
         db        1,5,'Konec'

HWMnLBlk db        0,0,0                    ; blokovac¡ tabulka

HWMnLTit db        15,'n vrat adres ©e'

; ------ n povˆda

HelpS    SEGMENT   BYTE PUBLIC
HWMnLHlp db        48,'Zadejte adres © k nastaven¡ jako aktivn¡ adres ©'
         db        35,'Nastaven¡ nov‚ho aktivn¡ho adres ©e'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

DMMousS  db        0                        ; p©¡znak ozna‡ov n¡ soubor–
                                            ;   bit 0: 1=zah jeno ozna‡ov n¡
                                            ;   bit 1: 1=je ozna‡ov n¡

Data     ENDS

         END       Start
