
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                               M E M O R Y
;
;                             obsluha pamàti
;
; -----------------------------------------------------------------------------
;        InsDat   (FAR)  - vytvo©en° m°sta v datovÇm bloku
;        DelDat   (FAR)  - zru®en° dat z datovÇho bloku
;        CreatDat (FAR)  - vytvo©en° novÇho datovÇho bloku
;        GetDat   (FAR)  - poskytnut° adresy ES datovÇho bloku
;
;        GetFree  (FAR)  - poskytnut° volnÇho m°sta v pamàti
;        GetDFree (FAR)  - poskytnut° volnÇho m°sta v pamàti z omezen°m na 64 KB
;        CreatSeg (FAR)  - vytvo©en° novÇho pamàüovÇho bloku
;        GetSgAdr (FAR)  - poskytnut° adresy pamàüovÇho bloku
;        GetSgSiz (FAR)  - poskytnut° velikosti pamàüovÇho bloku
;        GetSeg   (FAR)  - poskytnut° adresy a velikosti pamàüovÇho bloku
;        DelSeg   (FAR)  - zru®en° pamàüovÇho bloku
;        ModiSegS (FAR)  - modifikace velikosti pamàüovÇho bloku v bajtech
;        ModiSeg  (FAR)  - modifikace velikosti pamàüovÇho bloku
;        SegMove  (FAR)  - p©esun segmentovanÇho bloku pamàti
;
;        TopSeg   (WORD) - segment poá†tku datovÇ pamàti pro pamàüovÇ bloky
;        FreeSeg  (WORD) - zaá†tek volnÇ datovÇ pamàti (nepouëitÇ bloky)
;        EndSeg   (WORD) - segment konce datovÇ pamàti
;        TabBAdr  (WORD) - tabulka adres pamàüovòch blokñ
;        TabBSiz  (WORD) - tabulka velikost° pamàüovòch blokñ
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

INCLUDE  ASM\DEF.ASM

CodeMem  SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeMem,ds:Data

; *****************************************************************************
;                                 InitMem
;                  inicializace pamàti p©i startu programu
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=chyba pamàti
; -----------------------------------------------------------------------------
; uchov†v† jen registr DS, màn° z†sobn°k !
; *****************************************************************************

InitMem  PROC      FAR

; ------ £schova n†vratovÇ adresy

         pop       word ptr cs:[InitMemA]   ; offset n†vratovÇ adresy
         pop       word ptr cs:[InitMemA+2] ; segment n†vratovÇ adresy

; ------ zmen®en° p©idàlenÇho alokaán°ho bloku na minimum

         mov       es,ds:[SegPSP]           ; segment PSP
         mov       bx,SEG KonecS            ; segment konce programu
         test      byte ptr ds:[HelpPar],bit2 ; je n†povàda k menu ?
         jz        InitMem1                 ; je n†povàda k menu
         mov       bx,SEG Konec0S           ; konec bez n†povàdy k menu
InitMem1:sub       bx,ds:[SegPSP]           ; velikost programu v odstavc°ch
         mov       ah,4ah
         int       21h                      ; minimalizace p©idàlenÇ pamàti

; ------ vytvo©en° pamàüovÇho bloku pro z†sobn°k

         mov       ah,48h
         mov       bx,180h                  ; pro z†sobn°k se poëaduje 6 KB
         int       21h                      ; vytvo©en° bloku pro z†sobn°k
         jc        InitMem9                 ; chyba - nedostatek pamàti
         mov       ss,ax                    ; adresa vytvo©enÇho segmentu
         mov       sp,1800h                 ; konec bloku pamàti

; ------ £schova ukazatelñ z†sobn°ku

         mov       ds:[StackSP],sp          ; £schova registru SP
         mov       ds:[StackSS],ax          ; £schova registru SS

; ------ vytvo©en° pamàüovÇho bloku pro data

         mov       ah,48h
         mov       bx,0ffffh                ; maxim†ln° blok pamàti
         int       21h                      ; poskytnut° maxim†ln° velikosti bl.
         mov       ah,48h
         int       21h                      ; p©idàlen° maxim†ln°ho bloku pamàti
         jc        InitMem9                 ; chyba p©idàlen° pamàti
         cmp       bx,1000h                 ; minim†ln° velikost bloku pamàti 64K
         jb        InitMem9                 ; m†lo pamàti

; ------ inicializace ukazatelñ datovòch blokñ

         mov       ds:[TopSeg],ax           ; poá†teán° segment datovÇho bloku
         mov       ds:[FreeSeg],ax          ; poá†t.volnò segment datovÇho bloku
         add       ax,bx                    ; segment konce bloku
         mov       ds:[EndSeg],ax           ; segment konce p©idàlenÇ pamàti

; ------ inicializace tabulek popisovaáñ pamàti

         push      ds
         pop       es                       ; ES <- DS
         mov       di,offset TabBAdr        ; tabulka adres datovòch blokñ
         xor       ax,ax                    ; nulovac° slovo
         cld
         mov       cx,2*BlokMax             ; poáet poloëek v tabulk†ch
         rep       stosw                    ; vymaz†n° tabulek popisovaáñ
;         clc                                ; p©°znak operace OK

; ------ n†vrat z procedury

InitMem9:jmp       dword ptr cs:[InitMemA]

InitMem  ENDP

InitMemA dd        0                        ; n†vratov† adresa z procedury

; *****************************************************************************
;                                 MemErr
;                    chybovÇ hl†®en° - nedostatek pamàti
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY
; *****************************************************************************

MemErr   PROC      FAR

         push      bx
         push      dx
         push      si

         mov       si,offset ChbLnMem       ; text chybovÇho hl†®en°
         call      far ptr Lin0MenF         ; chybovÇ hl†®en°

         pop       si
         pop       dx
         pop       bx
         call      far ptr SetEsc           ; nastaven° p©°znaku p©eru®en° a CY
         ret

MemErr   ENDP

; *****************************************************************************
;                                SetEnv
;         nastaven° parametru v kopii prost©ed° DOS (posouv† segmenty !!!!)
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        ES:SI=jmÇno parametru
;        CX=dÇlka jmÇna parametru
;        DX:DI=text parametru k nastaven°
;        BX=dÇlka textu parametru (0=zru®en° parametru) (max. 255 !)
; VùSTUP: CY=nedostatek pamàti
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) dÇlka jmÇna parametru
;                   SS:[BP-4] (2) dÇlka textu parametru
;                   SS:[BP-6] (2) adresa jmÇna parametru v z†sobn°ku
;                   SS:[BP-8] (2) adresa textu parametru v z†sobn°ku
; *****************************************************************************

SetEnv   PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp
         sub       sp,8

; ------ £schova ukazatelñ

         mov       ss:[bp-2],cx             ; dÇlka jmÇna parametru
         mov       ss:[bp-4],bx             ; dÇlka textu parametru

; ------ £schova jmÇna parametru do z†sobn°ku

         mov       ax,cx                    ; dÇlka jmÇna parametru
         inc       ax
         and       al,not bit0
         sub       sp,ax                    ; m°sto v bufferu
         mov       ax,sp
         mov       ss:[bp-6],ax             ; adresa jmÇna parametru

         push      ds
         push      di

         mov       di,ax                    ; adresa bufferu v z†sobn°ku
         push      es
         pop       ds                       ; DS <- segment jmÇna parametru
         push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku
         cld
         rep       movsb                    ; £schova jmÇna do bufferu

         pop       si                       ; offset textu parametru
         pop       ds

; ------ £schova textu parametru do bufferu v z†sobn°ku

         mov       ax,bx                    ; dÇlka jmÇna parametru
         inc       ax
         and       al,not bit0
         sub       sp,ax                    ; m°sto v bufferu
         mov       ax,sp
         mov       ss:[bp-8],ax             ; adresa jmÇna parametru

         push      ds

         mov       di,ax                    ; adresa bufferu v z†sobn°ku
         mov       ds,dx                    ; DS <- segment textu parametru
         mov       cx,bx                    ; dÇlka textu parametru
         rep       movsb                    ; £schova textu do bufferu

         pop       ds

; ------ nalezen° parametru v prost©ed°

         mov       si,ss:[bp-6]             ; adresa jmÇna parametru
         mov       cx,ss:[bp-2]             ; dÇlka jmÇna parametru
         call      far ptr GetEnv           ; nalezen° parametru v prost©ed°
         jc        SetEnv3                  ; parametr nenalezen

; ------ nalezen° zaá†tku parametru

SetEnv1: dec       si
         cmp       si,2
         jbe       SetEnv2
         cmp       byte ptr es:[si-1],0
         jne       SetEnv1

; ------ nalezen° konce parametru

SetEnv2: mov       di,si                    ; zaá†tek parametru
         mov       cx,-1
         mov       al,0                     ; hledanò bajt
         cld
         repne     scasb                    ; nalezen° konce parametru

; ------ zru®en° nalezenÇho starÇho ©etàzce

         mov       cx,di
         mov       di,si
         sub       cx,di                    ; dÇlka ©etàzce
         mov       ax,ds:[EnvSegm]          ; segment prost©ed°
         call      far ptr DelDat           ; zru®en° starÇho ©etàzce

; ------ test, zda m† bòt ©etàzec uloëen

SetEnv3: cmp       word ptr ss:[bp-4],0     ; je nàjakò text ?
         je        SetEnv9                  ; nen° text parametru

; ------ adresa bufferu prost©ed°

         mov       ax,ds:[EnvSegm]          ; segment bufferu
         call      far ptr GetDat           ; adresa bufferu
         jc        SetEnv9                  ; chyba pamàti

; ------ vytvo©en° m°sta pro parametr

         mov       di,es:[0]                ; velikost dat v segmentu
         dec       di                       ; ukazatel na koncovou 0
         mov       cx,ss:[bp-2]             ; dÇlka jmÇna parametru
         inc       cx                       ; váetnà znaku "="
         add       cx,ss:[bp-4]             ; p©iáten° textu parametru
         inc       cx                       ; váetnà koncovÇ 0
         call      far ptr InsDat           ; vytvo©en° m°sta pro promànnou
         jc        SetEnv9                  ; nedostatek pamàti

; ------ p©enesen° jmÇna parametru

         cld
         push      ds
         push      ss
         pop       ds                       ; DS <- segment z†sobn°ku
         mov       si,ss:[bp-6]             ; adresa jmÇna parametru
         mov       cx,ss:[bp-2]             ; dÇlka jmÇna parametru
SetEnv4: lodsb
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         stosb
         loop      SetEnv4                  ; dal®° znak

; ------ oddàlovac° znak "="

         mov       al,"="
         stosb

; ------ p©enesen° textu parametru

         mov       si,ss:[bp-8]             ; adresa textu parametru
         mov       cx,ss:[bp-4]             ; dÇlka textu parametru
         rep       movsb                    ; p©enesen° textu parametru

; ------ koncov† 0

         mov       al,0
         stosb                              ; koncov† 0
         pop       ds
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

SetEnv9: mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

SetEnv   ENDP

;; *****************************************************************************
;;                                SetSEnv
;;           nastaven° parametru v systÇmovÇm prost©ed° DOS
;; -----------------------------------------------------------------------------
;; VSTUP: DS=datovò segment
;;        ES:SI=jmÇno parametru
;;        CX=dÇlka jmÇna parametru
;;        DX:DI=text parametru k nastaven°
;;        BX=dÇlka textu parametru (0=zru®en° parametru) (max. 255 !)
;; VùSTUP: CY=nedostatek pamàti
;; -----------------------------------------------------------------------------
;; lok†ln° promànnÇ: SS:[BP-2] (2) dÇlka jmÇna parametru
;;                   SS:[BP-4] (2) dÇlka textu parametru
;;                   SS:[BP-6] (2) adresa jmÇna parametru v z†sobn°ku
;;                   SS:[BP-8] (2) adresa textu parametru v z†sobn°ku
;; *****************************************************************************
;
;SetSEnv   PROC      FAR
;
;; ------ £schova registrñ
;
;         push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      si
;         push      di
;         push      bp
;         push      es
;         mov       bp,sp
;         sub       sp,8
;
;; ------ £schova ukazatelñ
;
;         mov       ss:[bp-2],cx             ; dÇlka jmÇna parametru
;         mov       ss:[bp-4],bx             ; dÇlka textu parametru
;
;; ------ £schova jmÇna parametru do z†sobn°ku
;
;         mov       ax,cx                    ; dÇlka jmÇna parametru
;         inc       ax
;         and       al,not bit0
;         sub       sp,ax                    ; m°sto v bufferu
;         mov       ax,sp
;         mov       ss:[bp-6],ax             ; adresa jmÇna parametru
;
;         push      ds
;         push      di
;
;         mov       di,ax                    ; adresa bufferu v z†sobn°ku
;         push      es
;         pop       ds                       ; DS <- segment jmÇna parametru
;         push      ss
;         pop       es                       ; ES <- segment bufferu v z†sobn°ku
;         cld
;         rep       movsb                    ; £schova jmÇna do bufferu
;
;         pop       si                       ; offset textu parametru
;         pop       ds
;
;; ------ £schova textu parametru do bufferu v z†sobn°ku
;
;         mov       ax,bx                    ; dÇlka jmÇna parametru
;         inc       ax
;         and       al,not bit0
;         sub       sp,ax                    ; m°sto v bufferu
;         mov       ax,sp
;         mov       ss:[bp-8],ax             ; adresa jmÇna parametru
;
;         push      ds
;
;         mov       di,ax                    ; adresa bufferu v z†sobn°ku
;         mov       ds,dx                    ; DS <- segment textu parametru
;         mov       cx,bx                    ; dÇlka textu parametru
;         rep       movsb                    ; £schova textu do bufferu
;
;         pop       ds
;
;; ------ nalezen° parametru v prost©ed°
;
;         mov       si,ss:[bp-6]             ; adresa jmÇna parametru
;         mov       cx,ss:[bp-2]             ; dÇlka jmÇna parametru
;         call      far ptr GetSEnv          ; nalezen° parametru v prost©ed° DOS
;         jc        SetSEnv5                 ; parametr nenalezen
;
;; ------ nalezen° zaá†tku parametru
;
;SetSEnv1:dec       si
;         jz        SetSEnv2
;         cmp       byte ptr es:[si-1],0
;         jne       SetSEnv1
;
;; ------ nalezen° dal®°ho ©etàzce
;
;SetSEnv2:mov       di,si                    ; zaá†tek parametru
;         mov       cx,-1
;         mov       al,0                     ; hledanò bajt
;         cld
;         repne     scasb                    ; nalezen° konce parametru
;
;; ------ zru®en° nalezenÇho starÇho ©etàzce
;
;         xchg      si,di                    ; SI=dal®° parametr, DI=zaá†tek
;SetSEnv3:mov       al,es:[si]
;         stosb
;         cmp       al,0
;         je        SetSEnv5
;SetSEnv4:mov       al,es:[si]
;         stosb
;         cmp       al,0
;         jne       SetSEnv4
;         jmp       short SetSEnv3
;
;; ------ test, zda m† bòt ©etàzec uloëen
;
;SetSEnv5:cmp       word ptr ss:[bp-4],0     ; je nàjakò text ?
;         je        SetSEnv9                 ; nen° text parametru
;
;; ------ adresa segmentu prost©ed°
;
;         mov       ax,ds:[EnvParnt]         ; segment prost©ed°
;         or        ax,ax
;         stc
;         jz        SetSEnv9                 ; prost©ed° neplatnÇ
;
;; ------ p©°prava velikosti prost©ed°
;
;         dec       ax
;         mov       es,ax
;         mov       bx,es:[3]                ; velikost prost©ed°
;         inc       ax
;         mov       es,ax                    ; adresa segmentu prost©ed°
;         shl       bx,1
;         shl       bx,1
;         shl       bx,1
;         shl       bx,1                     ; velikost v bajtech
;
;; ------ nalezen° konce ©etàzcñ
;
;         mov       cx,-1
;         xor       di,di
;         mov       al,0
;         cld
;SetSEnv6:repne     scasb
;         jne       SetSEnv9
;         scasb
;         jne       SetSEnv6
;         dec       di                       ; adresa k uloëen° ©etàzce
;
;; ------ test, zda je v segmentu dost m°sta pro ©etàzec
;
;         mov       ax,di                    ; adresa k uloëen° ©etàzce
;         add       ax,ss:[bp-2]             ; p©iáten° jmÇna parametru
;         add       ax,ss:[bp-4]             ; p©iáten° textu parametru
;         inc       ax                       ; váetnà =
;         inc       ax                       ; váetnà koncovÇ 0
;         inc       ax                       ; váetnà 0 na konci
;         cmp       bx,ax                    ; je dost volnÇho m°sta ?
;         jb        SetSEnv9                 ; nedostatek m°sta
;
;; ------ p©enesen° jmÇna parametru
;
;         cld
;         push      ds
;         push      ss
;         pop       ds                       ; DS <- segment z†sobn°ku
;         mov       si,ss:[bp-6]             ; adresa jmÇna parametru
;         mov       cx,ss:[bp-2]             ; dÇlka jmÇna parametru
;SetSEnv7:lodsb
;         call      far ptr UpCase           ; konverze na velkÇ p°smeno
;         stosb
;         loop      SetSEnv7                 ; dal®° znak
;
;; ------ oddàlovac° znak "="
;
;         mov       al,"="
;         stosb
;
;; ------ p©enesen° textu parametru
;
;         mov       si,ss:[bp-8]             ; adresa textu parametru
;         mov       cx,ss:[bp-4]             ; dÇlka textu parametru
;         rep       movsb                    ; p©enesen° textu parametru
;
;; ------ koncov† 0
;
;         mov       al,0
;         stosb                              ; koncov† 0
;         stosb                              ; celkov† koncov† 0
;         pop       ds
;         clc                                ; p©°znak operace OK
;
;; ------ n†vrat registrñ
;
;SetSEnv9:mov       sp,bp
;         pop       es
;         pop       bp
;         pop       di
;         pop       si
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;SetSEnv  ENDP

; *****************************************************************************
;                               Get0Env
;              poskytnut° parametru z kopie prost©ed° DOS
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        DS:SI=hledanò parametr (prvn° bajt = dÇlka jmÇna parametru)
; VùSTUP: ES:SI=adresa nalezenÇho parametru
;         CY=parametr nenalezen
; *****************************************************************************

Get0Env  PROC      FAR

         push      cx

         mov       ch,0                     ; CH <- 0
         mov       cl,ds:[si]               ; dÇlka jmÇna parametru
         inc       si                       ; zaá†tek jmÇna parametru
         push      ds
         pop       es                       ; ES <- datovò segment
         call      far ptr GetEnv           ; nalezen° parametru

         pop       cx
         ret

Get0Env  ENDP

; *****************************************************************************
;                                 GetIEnv
;                  poskytnut° intern°ho parametru DOSMANu
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        ES:SI=hledanò parametr (mus° bòt velk† p°smena!)
;        CX=dÇlka hledanÇho parametru
; VùSTUP: ES:SI=adresa nalezenÇho parametru ASCIIZ (p©i CY je ES:SI nezmànàno)
;         CY=parametr nenalezen (ES uchov†no)
; *****************************************************************************

GetIEnv  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      di

; ------ p©°prava k vyhled†n° parametru

         cld
         mov       bx,si                    ; DX <- zaá†tek parametru
         mov       di,si                    ; ES:DI=hledanò parametr

; ------ test, zda parametr zaá°n† "DM"

         cmp       cx,7                     ; minim†ln° dÇlka parametru
         jb        GetIEnv8                 ; neplatnò parametr
         cmp       word ptr es:[di],"MD"    ; zaá°n† parametr "DM" ?
         jne       GetIEnv8                 ; nezaá°n† "DM"
         inc       di                       ; p©eskoáen° "D"
         dec       cx
         inc       di                       ; p©eskoáen° "M"
         dec       cx

; ------ test, zda je "DMFILE"

         mov       si,offset TabIEnv1       ; DS:SI <- tabulka parametrñ "DM..."
         cmp       word ptr es:[di],"IF"
         jne       GetIEnv6
         cmp       word ptr es:[di+2],"EL"
         jne       GetIEnv6
         add       di,4
         sub       cx,4
         mov       si,offset TabIEnv2       ; tabulka parametrñ "DMFILE..."

; ------ porovn†n° dÇlky parametru

GetIEnv6:mov       ah,0
         lodsb                              ; AX <- dÇlka jmÇna parametru
         cmp       ax,cx                    ; souhlas° dÇlka jmÇna parametru ?
         jne       GetIEnv7                 ; dÇlka parametru nesouhlas°

; ------ porovn†n° jmÇna parametru

         push      cx
         push      si
         push      di
         repe      cmpsb                    ; porovn†n° jmÇna parametru
         pop       di
         pop       si
         pop       cx
         jne       GetIEnv7                 ; parametr nenalezen

; ------ obsluha parametru

         add       si,ax                    ; adresa konce jmÇna parametru
         push      ds
         pop       es                       ; ES <- datovò segment

         push      dx

         call      word ptr ds:[si]         ; skok na obsluhu parametru

         pop       dx
         clc                                ; p©°znak nalezen° parametru
         jmp       short GetIEnv9

; ------ adresa dal®°ho parametru

GetIEnv7:add       si,ax                    ; adresa konce jmÇna parametru
         lodsw                              ; adresa skoku obsluhy parametru
         cmp       byte ptr ds:[si],0       ; je konec tabulky ?
         jne       GetIEnv6                 ; dal®° parametr

; ------ chyba - parametr nenalezen

GetIEnv8:stc                                ; p©°znak chyby
         mov       si,bx                    ; SI <- hledanò parametr

; ------ n†vrat registrñ

GetIEnv9:pop       di
         pop       cx
         pop       bx
         pop       ax
         ret

GetIEnv  ENDP

; ------ parametr DMCODEPAGE (k¢dov† str†nka)

GetIEG11:mov       si,offset TabICPag       ; tabulka p©ep°naáñ
         mov       al,ds:[CodePage]         ; aktivn° k¢dov† str†nka
         jmp       GetIESwc                 ; nastaven° p©ep°naáe

; ------ parametr DMFILERO (atribut R/O)

GetIEG21:mov       al,RO                    ; maska atributu R/O
         jmp       short GtIEG252

; ------ parametr DMFILEHID (atribut HID)

GetIEG22:mov       al,HID                   ; maska atributu HID
         jmp       short GtIEG252

; ------ parametr DMFILESYS (atribut SYS)

GetIEG23:mov       al,SYS                   ; maska atributu SYS
         jmp       short GtIEG252

; ------ parametr DMFILEDIR (atribut DIR)

GetIEG24:mov       al,DIR                   ; maska atributu DIR
         jmp       short GtIEG252

; ------ parametr DMFILEARC (atribut ARC)

GetIEG25 PROC      NEAR

         mov       al,ARC                   ; maska atributu ARC
GtIEG252:test      ds:[FileFAtr],al         ; test atributu
         mov       si,offset TabICN         ; atribut vypnut
         jz        GtIEG253                 ; atribut vypnut
         mov       si,offset TabICY         ; atribut zapnut
GtIEG253:ret

GetIEG25 ENDP

; ------ parametr DMFILESEC (sekundy souboru)

GetIEG26:mov       ax,ds:[FileFTim]         ; áas souboru
         and       ax,bit0+bit1+bit2+bit3+bit4 ; maskov†n° sekund
         shl       ax,1                     ; sekundy
         jmp       short GetIEGNm           ; dek¢dov†n° á°sla

; ------ parametr DMFILEMIN (minuty souboru)

GetIEG27:mov       ax,ds:[FileFTim]         ; áas souboru
         and       ax,bit5+bit6+bit7+bit8+bit9+bit10 ; maskov†n° minut
         mov       cl,5                     ; poáet rotac°
         shr       ax,cl                    ; rotace na pozici
         jmp       short GetIEGNm           ; dek¢dov†n° á°sla

; ------ parametr DMFILEHOUR (hodina souboru)

GetIEG28:mov       ax,ds:[FileFTim]         ; áas souboru
         mov       cl,11                    ; poáet rotac°
         shr       ax,cl                    ; rotace na pozici

; ------ dek¢dov†n° á°selnÇho parametru

GetIEGNm PROC      NEAR

         xor       dx,dx                    ; DX <- 0 á°slo HIGH
GetIEGN2:mov       di,offset TabICBuf       ; buffer k dek¢dov†n° á°sla
         xor       bx,bx                    ; nejsou atributy ani oddàlovaá
         push      di                       ; £schova adresy bufferu
         call      far ptr DekNum           ; dek¢dov†n° á°sla do bufferu
         mov       al,0                     ; koncov† 0
         cld
         stosb                              ; uloëen° koncovÇ 0
         pop       si                       ; SI <- adresa bufferu
         ret

GetIEGNm ENDP

; ------ parametr DMFILEDAY (den souboru)

GetIEG29:mov       ax,ds:[FileFDat]         ; áas souboru
         and       ax,bit0+bit1+bit2+bit3+bit4 ; áas souboru
         jmp       short GetIEGNm           ; dek¢dov†n° á°sla

; ------ parametr DMFILEMONTH (màs°c souboru)

GetIEG2A:mov       ax,ds:[FileFDat]         ; datum souboru
         and       ax,bit5+bit6+bit7+bit8   ; maska màs°ce
         mov       cl,5                     ; poáet rotac°
         shr       ax,cl                    ; rotace na pozici
         jmp       short GetIEGNm           ; dek¢dov†n° á°sla

; ------ parametr DMFILEYEAR (rok souboru)

GetIEG2B:mov       ax,ds:[FileFDat]         ; datum souboru
         mov       cl,9                     ; poáet rotac°
         shr       ax,cl                    ; rotace na pozici
         add       ax,1980                  ; korekce roku
         jmp       short GetIEGNm           ; dek¢dov†n° á°sla

; ------ parametr DMFILESIZE (velikost souboru)

GetUEG2C:mov       ax,word ptr ds:[FileFSiz] ; velikost souboru LOW
         mov       dx,word ptr ds:[FileFSiz+2] ; velikost souboru HIGH
         jmp       short GetIEGN2           ; dek¢dov†n° á°sla

; -----------------------------------------------------------------------------
;        nalezen° ASCIIZ parametru o hodnotà AL=0... v tabulce DS:SI -> DS:SI
; -----------------------------------------------------------------------------

GetIESwc PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx

; ------ p©°prava registrñ

         cld
         mov       ah,0                     ; AX = á°slo hledanÇho parametru
         xchg      ax,cx                    ; CX <- á°slo parametru 0...
         jcxz      GetIESw9                 ; hled†n prvn° parametr

; ------ nalezen° parametru v tabulce

GetIESw2:lodsb                              ; naáten° dal®°ho znaku
         cmp       al,0                     ; je konec jmÇna parametru ?
         jne       GetIESw2                 ; nalezen° konce parametru
         loop      GetIESw2                 ; nalezen° poëadovanÇho parametru

; ------ n†vrat registrñ

GetIESw9:pop       cx
         pop       ax
         ret

GetIESwc ENDP

;; *****************************************************************************
;;                                 GetSEnv
;;               poskytnut° parametru z hlavn°ho prost©ed° DOS
;; -----------------------------------------------------------------------------
;; VSTUP: DS=datovò segment
;;        ES:SI=hledanò parametr (mohou bòt i mal† p°smena)
;;        CX=dÇlka hledanÇho parametru
;; VùSTUP: ES:SI=adresa nalezenÇho parametru
;;         CY=parametr nenalezen (ES nedefinov†no)
;; *****************************************************************************
;
;GetSEnv  PROC      FAR
;
;; ------ £schova registrñ
;
;         push      ax
;         push      dx
;         push      di
;
;; ------ adresa hlavn°ho prost©ed°
;
;         mov       dx,es                    ; DX <- segment jmÇna parametru
;         mov       ax,ds:[EnvParnt]         ; segment prost©ed°
;         or        ax,ax                    ; prost©ed° platnÇ ?
;         stc
;         jz        GetEnv9                  ; nen° platnÇ prost©ed°
;         mov       es,ax
;         cld
;         xor       di,di
;         jmp       short GetEnv2
;
;GetSEnv  ENDP

; *****************************************************************************
;                                 GetEnv
;               poskytnut° parametru z kopie prost©ed° DOS
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        ES:SI=hledanò parametr (mohou bòt i mal† p°smena)
;        CX=dÇlka hledanÇho parametru
; VùSTUP: ES:SI=adresa nalezenÇho parametru
;         CY=parametr nenalezen (ES nedefinov†no)
; *****************************************************************************

GetEnv   PROC      FAR

; ------ £schova registrñ

         push      ax
         push      dx
         push      di

; ------ adresa bufferu kopie prost©ed°

         mov       dx,es                    ; DX <- segment jmÇna parametru
         mov       ax,ds:[EnvSegm]          ; segment bufferu
         call      far ptr GetDat           ; adresa bufferu segmentu
         jc        GetEnv9                  ; nàjak† chyba

; ------ test, zda je dal®° ©etàzec

GetEnv1: cld
         mov       di,2                     ; ukazatel v bufferu prost©ed°
GetEnv2: cmp       byte ptr es:[di],0       ; je konec prost©ed° ?
         stc                                ; p©°znak nenalezen° ©etàzce
         je        GetEnv9                  ; ©etàzec nenalezen

; ------ porovn†n° jmÇna ©etàzce

         push      cx
         push      si
         push      di
         push      ds

         mov       ds,dx                    ; DS <- segment jmÇna parametru
GetEnv3: lodsb
         cmp       al,"a"
         jb        GetEnv4
         cmp       al,"z"
         ja        GetEnv4
         sub       al,32                    ; konverze na velkÇ p°smeno

GetEnv4: mov       ah,es:[di]
         inc       di
         cmp       ah,"a"
         jb        GetEnv5
         cmp       ah,"z"
         ja        GetEnv5
         sub       ah,32

GetEnv5: cmp       al,ah                    ; porovn†n° znakñ
         loope     GetEnv3                  ; je shoda - dal®° bajt
         jne       GetEnv6                  ; jmÇna nejsou shodn†

         cmp       byte ptr es:[di],"="     ; n†sleduj°c° znak mus° bòt "="

GetEnv6: pop       ds
         pop       di
         pop       si
         pop       cx
         je        GetEnv8                  ; ©etàzec nalezen OK

; ------ ©etàzec nesouhlas° - nalezen° dal®°ho ©etàzce

         mov       al,0
GetEnv7: scasb                              ; nalezen konce ©etàzce ?
         jne       GetEnv7                  ; nalezen° konce ©etàzce
         jmp       short GetEnv2            ; test dal®°ho ©etàzce

; ------ ©etàzec nalezen OK

GetEnv8: mov       si,di                    ; SI <- zaá†tek nalezenÇho parametru
         add       si,cx                    ; p©eskoáen° jmÇna parametru
         inc       si                       ; p©eskoáen° znaku "="
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

GetEnv9: pop       di
         pop       dx
         pop       ax
         ret

GetEnv   ENDP

; *****************************************************************************
;                                InitEnv
;               inicializace segmentu kopie prost©ed° DOS
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=nedostatek pamàti
; -----------------------------------------------------------------------------
; zniáenÇ registry: v®echny kromà DS
; *****************************************************************************
;˛
InitEnv  PROC      FAR

; ------ vytvo©en° segmentu kopie prost©ed°

         call      far ptr CreatSeg         ; vytvo©en° datovÇho segmentu
         jc        InitEnv9                 ; chyba
         mov       ds:[EnvSegm],ax          ; segment prost©ed°

; ------ inicializaán° velikost prost©ed° 1 slovo

         mov       bx,4                     ; minim†ln° velikost segmentu
         call      far ptr ModiSegS         ; nastaven° velikosti segmentu
         jc        InitEnv9                 ; chyba pamàti

; ------ inicializace £vodn°ho slova

         call      far ptr GetDat           ; adresa segmentu
         mov       word ptr es:[bx-4],bx    ; velikost dat 4 bajty
         mov       word ptr es:[bx-2],0     ; koncov† nula

; ------ adresa prost©ed° programu

         mov       es,ds:[SegPSP]           ; segment PSP
         mov       es,es:[PSP_ENV]          ; adresa prost©ed° PSP
         mov       ax,es                    ; AX <- segment prost©ed°
         cmp       ax,50h                   ; je adresa
         jb        InitEnv5                 ; prost©ed° nen° platnÇ

; ------ stanoven° velikosti dat v prost©ed°

         mov       cx,0a000h                ; asi tak maxim†ln° velikost dat
         xor       di,di                    ; poá†teán° adresa
         xor       ax,ax                    ; hledanÇ slovo
         cld
InitEnv2:repne     scasb                    ; nalezen° konce ©etàzce 0
         jne       InitEnv5                 ; nenalezeno
         scasb                              ; je konec prost©ed° ?
         jne       InitEnv2                 ; nen° konec prost©ed° - dal®°

; ------ nastaven° velikosti bufferu

         mov       bx,di                    ; adresa konce dat v prost©ed°
         inc       bx
         inc       bx                       ; váetnà £vodn°ho slova
         mov       ax,ds:[EnvSegm]          ; segment prost©ed°
         call      far ptr ModiSegS         ; nastaven° velikosti segmentu
         jc        InitEnv9                 ; chyba pamàti

; ------ p©enesen° prost©ed° do bufferu

         push      ds
         mov       cx,di                    ; CX <- velikost dat
         xor       si,si                    ; poá†teán° adresa v prost©ed°
         mov       di,2                     ; ukl†dac° adresa do bufferu
         push      es                       ; segment prost©ed°
         call      far ptr GetDat           ; ES <- adresa bufferu
         pop       ds                       ; DS <- segment prost©ed°
         cld
         shr       cx,1                     ; CX = velikost dat (slov)
         rep       movsw                    ; p©enos dat prost©ed°
         adc       cx,cx
         rep       movsb                    ; p©enos lichÇho bajtu
         mov       es:[0],di                ; poáet bajtñ v segmentu
         pop       ds

; ------ inicializace pamàüovòch blokñ DOS

InitEnv5:call      InitAMem                 ; inicializace pamàüovòch blokñ DOS

;; ------ adresa otcovskÇho prost©ed° DOS
;
;         call      ParEnv                   ; adresa otcovskÇho prost©ed°
         clc
InitEnv9:ret

InitEnv  ENDP

;; -----------------------------------------------------------------------------
;;        nalezen° otcovskÇho prost©ed°
;; -----------------------------------------------------------------------------
;
;ParEnv   PROC      NEAR
;
;; ------ z°sk†n° PSP z ukazatele DOS nebo z adresy Ctrl-C
;
;         mov       bp,16h                   ; segment otcovskÇho PSP
;         call      ParEnv3                  ; test otcovskÇho prost©ed°
;         jnc       ParEnv8                  ; prost©ed° nalezeno OK
;         mov       bp,10h                   ; segment p©eru®en° Ctrl-C
;
;; ------ adresa PSP otcovskÇho programu
;
;ParEnv3: mov       es,ds:[SegPSP]           ; segment PSP
;         test      byte ptr ds:[StartPar],bit0 ; je rezidentn° modul ?
;         jz        ParEnv4                  ; nen° rezidentn° modul
;         mov       ax,ds:[RezPSP]           ; PSP rezidentn°ho modulu
;         or        ax,ax
;         jz        ParEnv4
;         mov       es,ax
;ParEnv4: mov       es,es:[bp]               ; segment otcovskÇho PSP
;         mov       bp,es                    ; BP <- £schova adresy PSP
;         cmp       bp,ds:[SegPSP]           ; nen° to n†hodou tento program ?
;         je        ParEnv6                  ; je to tento program
;
;; ------ test, zda je to PSP - mus° zaá°nat INT 20h
;
;         cmp       word ptr es:[0],20cdh    ; je instrukce INT 20h ?
;         jne       ParEnv6                  ; nen° PSP programu
;
;; ------ test segmentu otcovskÇho programu
;
;         call      far ptr TestAMem         ; test platnosti alokaán°ho bloku
;         jc        ParEnv6                  ; nen° to platnò alokaán° blok
;
;; ------ adresa prost©ed° otcovskÇho programu
;
;         mov       es,es:[PSP_ENV]          ; segment otcovskÇho prost©ed°
;
;; ------ test, zda je prost©ed° platnò blok
;
;         call      far ptr TestAMem         ; test alokaán°ho bloku prost©ed°
;         jc        ParEnv6                  ; nen° to platnò alokaán° blok
;
;; ------ ukazatel popisovaáe alokaán°ho bloku prost©ed°
;
;         mov       ax,es                    ; segment prost©ed°
;         dec       ax
;         mov       es,ax
;         inc       ax
;
;; ------ kontrola velikosti prost©ed°
;
;         cmp       word ptr es:[3],5        ; minim†ln° velikost prost©ed°
;         jb        ParEnv6                  ; prost©ed° p©°li® malÇ
;         cmp       word ptr es:[3],0f00h    ; maxim†ln° velikost prost©ed°
;         ja        ParEnv6                  ; prost©ed° p©°li® velkÇ
;
;; ------ kontrola vlastn°ka bloku prost©ed°
;
;         cmp       bp,es:[1]                ; souhlas° vlastn°k prost©ed° ?
;         je        ParEnv7                  ; vlastn°k prost©ed° souhlas° OK
;
;; ------ uloëen° adresy nalezenÇho prost©ed°
;
;ParEnv6: xor       ax,ax                    ; prost©edn° neplatnÇ
;         stc                                ; p©°znak chyby
;ParEnv7: mov       ds:[EnvParnt],ax         ; adresa prost©ed° otcovskÇho prog.
;ParEnv8: ret
;
;ParEnv   ENDP

; -----------------------------------------------------------------------------
;        inicializace ukazatelñ pamàüovòch blokñ DOS
; -----------------------------------------------------------------------------

InitAMem PROC      NEAR

; ------ poskytnut° ukazatele parametrñ DOS

         xor       bx,bx
         mov       es,bx                    ; ES <- 0
         dec       bx                       ; BX <- -1
         mov       ah,52h
         int       21h                      ; poskytnut° adresy parametrñ DOS

; ------ test platnosti navr†cenÇho vektoru

         cmp       bx,0ff00h                ; asi tak maxim†ln° adresa
         ja        InitAMm4                 ; neplatn† sluëba DOS
         cmp       bx,10
         jb        InitAMm4
         mov       ax,es
         cmp       ax,50h
         jb        InitAMm4                 ; neplatnò vektor

; ------ adresa prvn°ho alokaán°ho bloku

         mov       ax,es:[bx-2]             ; segment prvn°ho alokaán°ho bloku
         inc       ax
         mov       es,ax
         sub       ax,50h
         js        InitAMm4                 ; neplatn† adresa (< 50h, > 8050h)

; ------ test platnosti alokaán°ho bloku

         call      far ptr TestAMem         ; test alokaán°ho bloku
         jnc       InitAMm6                 ; alokaán° blok je OK

; ------ nalezen° adresy pokusnòm zpñsobem

InitAMm4:mov       ax,60h                   ; asi tak vòchoz° adresa
InitAMm5:mov       es,ax
         call      far ptr TestAMem         ; test alokaán°ho bloku
         jnc       InitAMm6                 ; nalezen platnò alok. blok
         inc       ax                       ; zvò®en° adresy alok. bloku
         cmp       ax,ds:[SegPSP]           ; je je®tà platn† adresa ?
         jb        InitAMm5                 ; je je®tà platn† adresa
         ret

; ------ uloëen° adresy alokaán°ho bloku

InitAMm6:mov       ds:[Dos0AMem],es         ; £schova adresy alokaán°ho bloku
         clc                                ; p©°znak operace OK
         ret

InitAMem ENDP

; *****************************************************************************
;                              TestAMem
;                      ovà©en° platnosti alokaán°ho bloku
; -----------------------------------------------------------------------------
; VSTUP: ES=adresa alokaán°ho bloku
;        DS=datovò segment
; VùSTUP: CY=nen° platnò alokaán° blok
; *****************************************************************************

TestAMem PROC      FAR

; ------ test, zda je to platnò alokaán° blok

         call      Tst1AMem                 ; test alokaán°ho bloku
         jc        TestAMm9                 ; nen° to platnò alokaán° blok

; ------ £schova registrñ

         push      ax
         push      bx
         push      es

; ------ p©°prava k testu alokaán°ho bloku

         mov       bx,ds:[SegPSP]           ; segment PSP
         mov       ax,es                    ; testovanò alokaán° blok
         cmp       ax,bx                    ; je testovanò blok p©ed programem ?
         jb        TestAMm2                 ; testovanò blok je p©ed programem
         xchg      ax,bx                    ; oprava po©ad° bajtñ
         mov       es,ax                    ; vòchoz° adresa

; ------ test, zda je prñchod p©es blok

TestAMm2:mov       ax,es
         cmp       ax,bx                    ; je prñchod p©es testovanò blok ?
         jne       TestAMm3                 ; nen°
         xor       bx,bx                    ; p©°znak prñchodu p©es blok

; ------ nalezen° dal®°ho bloku

TestAMm3:call      far ptr NextAMem         ; nalezen° dal®°ho bloku
         jc        TestAMm8                 ; chyba - nen° platnò blok
         jne       TestAMm2                 ; je dal®° alokaán° blok

; ------ test, zda byl prñchod p©es blok

         or        bx,bx                    ; byl prñchod p©es program ?
         jz        TestAMm8                 ; byl prñchod p©es program
         stc                                ; p©°znak chyby

; ------ n†vrat registrñ

TestAMm8:pop       es
         pop       bx
         pop       ax
TestAMm9:ret

TestAMem ENDP

; *****************************************************************************
;                                NextAMem
;                   dal®° alokaán° blok ©etàzce blokñ DOS
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        ES=segment alokaán°ho bloku pamàti (mus° bòt platnò !)
; VùSTUP: ZY=je posledn°, nen° dal®° blok (a NC)
;         CY=chyba ©etàzce pamàti
;         ES=adresa dal®°ho alokaán°ho bloku (p©i ZY nebo CY je ES nedefinov†n)
; *****************************************************************************

NextAMem PROC      FAR

; ------ £schova registrñ

         push      ax

; ------ adresa prefixu alokaán°ho bloku

         mov       ax,es
         dec       ax
         mov       es,ax                    ; ES <- adresa alokaán°ho bloku
         inc       ax

; ------ test, zda je to posledn° alokaán° blok

         cmp       byte ptr es:[0],"Z"
         jne       NxtAMem6                 ; bude dal®° blok

; ------ test, zda je konec UMB

         cmp       ax,0b800h
         jae       NxtAMem5                 ; nen° dal®° blok

; ------ test, zda dal®° blok p©eskakuje hranici B800

         push      ax
         push      es

         stc
         adc       ax,es:[3]                ; adresa dal®°ho bloku
         jc        NxtAMem4                 ; chyba
         mov       es,ax                    ; ES <- adresa
         call      Tst1AMem                 ; test alokaán°ho bloku
         jc        NxtAMem4                 ; chyba
         cmp       ax,0b800h                ; je poá†tek p©ed hranic° B800 ?
         cmc
         jc        NxtAMem4                 ; nen° p©ed hranic° B800
         dec       ax
         mov       es,ax
         inc       ax
         stc
         adc       ax,es:[3]                ; adresa dal®°ho bloku
         jc        NxtAMem4                 ; chyba
         cmp       ax,0b800h                ; je za hranic° B800 ? (CY=nen°)

NxtAMem4:pop       es
         pop       ax
         jnc       NxtAMem6                 ; je dal®° blok OK
NxtAMem5:xor       ax,ax                    ; p©°znak, ëe nen° dal®° blok
         jmp       short NxtAMem9           ; nen° dal®° alokaán° blok

; ------ adresa dal®°ho bloku

NxtAMem6:stc
         adc       ax,es:[3]                ; adresa dal®°ho bloku
         jc        NxtAMem9                 ; chyba p©eteáen°

; ------ test, zda je dal®° alokaán° blok platnò

         mov       es,ax                    ; ES <- segment alokaán°ho bloku
         call      Tst1AMem                 ; test alokaán°ho bloku
         jc        NxtAMem9                 ; chyba
         or        ax,ax                    ; nastaven° p©°znaku NZ, NC

; ------ n†vrat registrñ

NxtAMem9:pop       ax
         ret

NextAMem ENDP

; -----------------------------------------------------------------------------
;                              Tst1AMem
;                test alokaán°ho bloku s testem vlastn°ka
; -----------------------------------------------------------------------------
; VSTUP: ES=segment alokaán°ho bloku
; VùSTUP: CY=z†hlav° alokaán°ho bloku je neplatnÇ
; -----------------------------------------------------------------------------

Tst1AMem PROC      NEAR

; ------ test alokaán°ho bloku

         call      Tst0AMem                 ; test tohoto alokaán°ho bloku
         jc        Tst1AMm9                 ; alokaán° blok je neplatnò

; ------ £schova registrñ

         push      ax
         push      es

; ------ adresa z†hlav° alokaán°ho bloku

         mov       ax,es
         dec       ax
         mov       es,ax                    ; ES <- z†hlav° alokaán°ho bloku

; ------ adresa vlastn°ka alokaán°ho bloku

         mov       ax,es:[1]                ; adresa vlastn°ka alokaán°ho bloku
         cmp       ax,70h                   ; tento blok se netestuje
         cmc
         jnc       Tst1AMm8                 ; alokaán° blok je volnò/DOS
         mov       es,ax                    ; ES <- adresa vlastn°ka alok. bloku

; ------ test vlastn°ka alokaán°ho bloku

         call      Tst0AMem                 ; test vlastn°ka alokaán°ho bloku

; ------ n†vrat registrñ

Tst1AMm8:pop       es
         pop       ax
Tst1AMm9:ret

Tst1AMem ENDP

; -----------------------------------------------------------------------------
;                               Tst0AMem
;                     test z†hlav° alokaán°ho bloku
; -----------------------------------------------------------------------------
; VSTUP: ES=segment alokaán°ho bloku
; VùSTUP: CY=z†hlav° alokaán°ho bloku je neplatnÇ
; -----------------------------------------------------------------------------

Tst0AMem PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      ds

; ------ adresa prefixu alokaán°ho bloku

         mov       ax,es                    ; segment alokaán°ho bloku
         cmp       ax,50h                   ; minim†ln° adresa alokaán°ho bloku
         jbe       Tst0AMm8                 ; neplatn† adresa bloku
         dec       ax                       ; adresa z†hlav° alokaán°ho bloku
         mov       ds,ax                    ; ES <- adresa alokaán°ho bloku

; ------ test typu alokaán°ho bloku

         cmp       byte ptr ds:[0],"M"
         je        Tst0AMm9                 ; st©edn° alokaán° blok
         cmp       byte ptr ds:[0],"Z"
         je        Tst0AMm9                 ; posledn° alokaán° blok

; ------ n†vrat registrñ

Tst0AMm8:stc                                ; p©°znak neplatnosti z†hlav° bloku
Tst0AMm9:pop       ds
         pop       ax
         ret

Tst0AMem ENDP

; *****************************************************************************
;                                   InsDat
;      vytvo©en° m°sta v datovÇm bloku (prvn° slovo = dÇlka bloku v bajtech)
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo datovÇho bloku (1,2,3, ... BlokMax)
;        DI=adresa v datovÇm bloku
;        CX=poáet vkl†danòch bajtñ
; VùSTUP:CY=nedostatek pamàti, chybnÇ á°slo bloku nebo adresa za koncem bloku
; *****************************************************************************

InsDat   PROC      FAR

; ------ £schova registrñ

         push      bx
         push      si
         push      es

; ------ poskytnut° adresy datovÇho bloku

         call      far ptr GetDat           ; poskytnut° adresy bloku
         jc        InsDat9                  ; chybnÇ á°slo bloku

; ------ kontrola adresy

         mov       bx,es:[0]                ; souáasn† velikost bloku (bajtñ)
         cmp       bx,di                    ; je adresa OK ?
         jb        InsDat9                  ; chyba - adresa je za koncem bloku

; ------ nastaven° velikosti bloku

         mov       si,bx                    ; starò konec dat
         add       bx,cx                    ; nov† velikost bloku
         jc        InsDat9                  ; p©eteáen° velikosti segmentu
         call      far ptr ModiSegS         ; nastaven° novÇ velikosti bloku
         jc        InsDat9                  ; chyba - nedostatek pamàti
         mov       es:[0],bx                ; nov† velikost bloku plat° OK
         cmp       si,di                    ; jsou nàjak† data k odsunu ?
         je        InsDat9                  ; nen° nic k odsunu

; ------ odsun zbytku dat v bloku

         push      cx
         push      di
         push      ds

         push      es
         pop       ds                       ; DS <- segment dat
         mov       cx,si                    ; starò konec dat
         sub       cx,di                    ; poáet bajtñ k odsunu
         dec       si
         dec       si                       ; starò konec dat - posledn° slovo
         mov       di,bx                    ; novò konec dat
         dec       di
         dec       di                       ; novò konec dat - posledn° slovo
         std                                ; smàr dolñ
         shr       cx,1                     ; p©evod na slova
         rep       movsw                    ; p©enos slov
         adc       cx,cx                    ; lichò bajt
         inc       si
         inc       di                       ; n†vrat na posledn° bajt
         rep       movsb                    ; p©enos lichÇho bajtu

         pop       ds
         pop       di
         pop       cx
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

InsDat9: pop       es
         pop       si
         pop       bx
         ret

InsDat   ENDP

; *****************************************************************************
;                                 DelDat
;       zru®en° dat z datovÇho bloku (prvn° slovo = dÇlka bloku v bajtech)
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo datovÇho bloku (1,2,3, ... BlokMax)
;        DI=adresa v datovÇm bloku
;        CX=poáet ru®enòch bajtñ
; VùSTUP:CY=chybnÇ á°slo dat. bloku nebo chybn† adresa v bloku
; *****************************************************************************

DelDat   PROC      FAR

; ------ £schova registrñ

         push      bx
         push      es

; ------ poskytnut° adresy datovÇho bloku

         call      far ptr GetDat           ; poskytnut° adresy bloku
         jc        DelDat9                  ; chybnÇ á°slo bloku

; ------ kontrola adresy a velikosti bloku

         mov       bx,es:[0]                ; souáasn† velikost bloku
         sub       bx,cx                    ; nov† velikost bloku
         jc        DelDat9                  ; chybnò poáet bajtñ
         cmp       bx,di                    ; je adresa OK ?
         jb        DelDat9                  ; adresa je za koncem bloku
         je        DelDat8                  ; ru®ena v®echna data za adresou

; ------ p©°sun zbytku dat v bloku

         push      cx
         push      si
         push      di
         push      ds

         push      es
         pop       ds                       ; DS <- adresa bloku
         mov       si,di                    ; zaá†tek dat
         add       si,cx                    ; zaá†tek dat k p©°sunu
         mov       cx,bx                    ; novò konec dat
         sub       cx,di                    ; poáet bajtñ k p©°sunu
         cld                                ; smàr nahoru
         shr       cx,1                     ; p©evod na slova
         rep       movsw                    ; p©°sun zbytku dat po slovech
         adc       cx,cx                    ; lichò bajt
         rep       movsb                    ; p©°sun lichÇho bajtu

         pop       ds
         pop       di
         pop       si
         pop       cx

; ------ nastaven° velikosti bloku

DelDat8: call      far ptr ModiSegS         ; nastaven° novÇ velikosti bloku
         mov       es:[0],bx                ; nov† velikost bloku

; ------ n†vrat registrñ

DelDat9: pop       es
         pop       bx
         ret

DelDat   ENDP

; *****************************************************************************
;                             CreatDat
;                    Vytvo©en° datovÇho bloku (do 64 KB)
;         Vytvo©en° bloku nesm° posunout ostatn° pamàüovÇ bloky !!!
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        BX=poëadovan† minim†ln° velikost (bajtñ)
; VùSTUP:AX=á°slo p©idàlenÇho datovÇho bloku (1,2,3, ... BlokMax)
;        BX=skuteán† velikost datovÇho bloku (bajtñ)
;        CY=nedostatek pamàti (AX a BX = 0)
; *****************************************************************************

CreatDat PROC      FAR

; ------ poëadovan† minim†ln° velikost bloku v odstavc°ch

         add       bx,15                    ; zaokrouhlen°
         rcr       bx,1
         shr       bx,1
         shr       bx,1
         shr       bx,1

; ------ stanoven° velikosti datovÇho bloku

         mov       ax,ds:[EndSeg]           ; konec pamàti
         sub       ax,ds:[FreeSeg]          ; voln† pamàü
         cmp       ax,bx                    ; je dost volnÇ pamàti ?
         jb        CreatDt9                 ; nedostatek pamàti
         sub       ax,100h                  ; rezerva 4 KB
         jnc       CreatDt2                 ; je v°ce neë 4 KB
         add       ax,100h                  ; n†vrat skuteánÇ velikosti pamàti
CreatDt2:cmp       ax,1000h                 ; je vàt®° neë 64 KB ?
         jbe       CreatDt3                 ; je men®° neë 64 KB
         mov       ax,1000h                 ; omezen° velikosti na 64 KB
CreatDt3:cmp       ax,bx                    ; je to mÇnà neë je pot©eba ?
         jb        CreatDt4                 ; je pot©eba vàt®° blok
         mov       bx,ax                    ; velikost bloku pamàti

; ------ vytvo©en° datovÇho bloku

CreatDt4:or        bx,bx                    ; je nàjak† velikost ?
         jnz       CreatDt5                 ; je nàco zad†no OK
         inc       bx                       ; alespo§ 1 odstavec
CreatDt5:call      far ptr CreatSeg         ; vytvo©en° datovÇho bloku
         jc        CreatDt9                 ; chyba - nedostatek pamàti
         call      far ptr ModiSeg          ; nastaven° velikosti bloku
         jc        CreatDt8                 ; chyba - nedostatek pamàti
         shl       bx,1
         shl       bx,1
         shl       bx,1
         shl       bx,1                     ; velikost bloku v bajtech
         jnz       CreatDt7                 ; nen° p©eteáen° velikosti
         dec       bx                       ; velikost bloku 0ffffh bajtñ
CreatDt7:clc
         ret

; ------ chyba - nedostatek pamàti

CreatDt8:call      far ptr DelSeg           ; zru®en° p©i nedostatku pamàti
CreatDt9:xor       ax,ax                    ; p©i chybà á°slo bloku = 0
         xor       bx,bx                    ; p©i chybà velikost bloku = 0
         stc                                ; p©°znak chyby
         ret

CreatDat ENDP

; *****************************************************************************
;                               GetDat
;                 poskytnut° adresy datovÇho bloku
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo datovÇho bloku (1,2,3, ... BlokMax)
;        DS=datovò segment
; VùSTUP:CY=chybnÇ á°slo dat. bloku
;        ES=adresa datovÇho bloku
; *****************************************************************************

GetDat   PROC      FAR

; ------ £schova registrñ

         push      si

; ------ kontrola á°sla bloku

         mov       si,ax                    ; á°slo datovÇho bloku 1,2,...
         dec       si                       ; á°slo datovÇho bloku 0,1,...
         cmp       si,BlokMax               ; kontrola p©ekroáen° á°sla bloku
         jae       GetDat9                  ; chybnÇ á°slo bloku
         shl       si,1                     ; offset v tabulce blokñ
         cmp       word ptr ds:[si+TabBAdr],0 ; je platnò datovò blok ?
         je        GetDat9                  ; neplatnò datovò blok

; ------ poskytnut° parametrñ bloku

         mov       es,ds:[si+TabBAdr]       ; adresa pamàüovÇho bloku
         pop       si
         ret                                ; zde je NC !

; ------ chybnÇ á°slo bloku

GetDat9: pop       si
         stc                                ; p©°znak chyby
         ret

GetDat   ENDP

; *****************************************************************************
;                                 GetFree
;                        poskytnut° volnÇ pamàti
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:BX=voln† pamàü (v odstavc°ch)
; *****************************************************************************

GetFree  PROC      FAR

         mov       bx,ds:[EndSeg]           ; konec pamàti
         sub       bx,ds:[FreeSeg]          ; voln† pamàü
         and       bl,not 0fh               ; zaokrouhlen° na str†nky 256 B dolñ
         ret

GetFree  ENDP

; *****************************************************************************
;                               GetDFree
;        poskytnut° maxim†ln° velikosti datovÇho bloku (z volnÇ pamàti)
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: BX=voln† pamàü v bajtech (0 aë 0ffffh bajtñ)
; *****************************************************************************

GetDFree PROC      FAR

         mov       bx,ds:[EndSeg]           ; konec pamàti
         sub       bx,ds:[FreeSeg]          ; voln† pamàü
         and       bl,not 0fh               ; zaokrouhlen° na str†nky 256 B dolñ
         cmp       bx,1000h                 ; je v°ce volnÇ pamàti neë 64 KB ?
         jb        GetDFre2                 ; je mÇnà volnÇ pamàti neë 64 KB
         mov       bx,1000h                 ; omezen° volnÇ pamàti na 64 KB
GetDFre2:shl       bx,1
         shl       bx,1
         shl       bx,1
         shl       bx,1
         sbb       bx,0                     ; odeáten° p©enosu p©i 64 KB
         ret

GetDFree ENDP

; *****************************************************************************
;                              CreatSeg
;                   Vytvo©en° novÇho datovÇho bloku
;             Blok mus° bòt vytvo©en na konci blokñ, aby jeho modifikac°
;                     se neposouvaly ostatn° bloky !
; -----------------------------------------------------------------------------
; VSTUP:  DS=datovò segment
; VùSTUP: AX=á°slo p©idàlenÇho datovÇho bloku (1,2,3, ... BlokMax) (p©i chybà 0)
;         CY=nen° volnÇ m°sto pro dal®° blok (AX=0)
; *****************************************************************************

CreatSeg PROC      FAR

; ------ £schova registrñ

         push      cx
         push      di
         push      es

; ------ nalezen° volnÇho popisovaáe

         push      ds
         pop       es                       ; ES <- DS
         mov       di,offset TabBAdr        ; tabulka adres blokñ
         xor       ax,ax                    ; hledanÇ slovo 0
         mov       cx,BlokMax               ; maxim†ln° poáet slov
         cld
         repne     scasw                    ; nalezen° volnÇho popisovaáe bloku
         stc                                ; p©°znak chyby
         jne       CreatSg9                 ; chyba - nen° volnÇ m°sto

; ------ nastaven° parametrñ novÇho bloku

         mov       cx,ds:[FreeSeg]          ; zaá†tek volnÇ pamàti
         mov       ds:[di-2],cx             ; nastaven° adresy bloku
         sub       di,offset TabBAdr        ; offset v tabulce adres + 2
         mov       word ptr ds:[TabBSiz+di-2],ax ; velikost bloku = 0
         xchg      ax,di                    ; offset popisovaáe + 2
         shr       ax,1                     ; á°slo datovÇho bloku (1,...)
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

CreatSg9:pop       es
         pop       di
         pop       cx
         ret

CreatSeg ENDP

; *****************************************************************************
;                               GetSgAdr
;                 Poskytnut° adresy pamàüovÇho bloku
; -----------------------------------------------------------------------------
; VSTUP:  AX=á°slo pamàüovÇho bloku (1,2,3, ... BlokMax)
;         DS=datovò segment
; VùSTUP: DX=adresa pamàüovÇho bloku (segment) (p©i chybà se nemàn°)
;         CY=neplatnÇ á°slo datovÇho bloku (DX zñst†v† nezmànàno)
; *****************************************************************************

GetSgAdr PROC      FAR

; ------ £schova registrñ

         push      si

; ------ kontrola á°sla bloku

         mov       si,ax                    ; á°slo datovÇho bloku 1,2,...
         dec       si                       ; á°slo datovÇho bloku 0,1,...
         cmp       si,BlokMax               ; kontrola p©ekroáen° á°sla bloku
         jae       GetSgA9                  ; chybnÇ á°slo bloku
         shl       si,1                     ; offset v tabulce blokñ
         cmp       word ptr ds:[si+TabBAdr],0 ; je platnò datovò blok ?
         je        GetSgA9                  ; neplatnò datovò blok

; ------ poskytnut° parametrñ bloku

         mov       dx,ds:[si+TabBAdr]       ; adresa pamàüovÇho bloku
         pop       si
         ret                                ; zde je NC !

; ------ chybnÇ á°slo bloku

GetSgA9: pop       si
         stc                                ; p©°znak chyby
         ret

GetSgAdr ENDP

; *****************************************************************************
;                                GetSgSiz
;                 Poskytnut° velikosti pamàüovÇho bloku
; -----------------------------------------------------------------------------
; VSTUP:  AX=á°slo pamàüovÇho bloku (1,2,3, ... BlokMax)
;         DS=datovò segment
; VùSTUP: BX=velikost bloku (v odstavc°ch)
;         CY=neplatnÇ á°slo datovÇho bloku (BX se nezmàn°)
; *****************************************************************************

GetSgSiz PROC      FAR

; ------ £schova registrñ

         push      si

; ------ kontrola á°sla bloku

         mov       si,ax                    ; á°slo datovÇho bloku 1,2,...
         dec       si                       ; á°slo datovÇho bloku 0,1,...
         cmp       si,BlokMax               ; kontrola p©ekroáen° á°sla bloku
         jae       GetSgS9                  ; chybnÇ á°slo bloku
         shl       si,1                     ; offset v tabulce blokñ
         cmp       word ptr ds:[si+TabBAdr],0 ; je platnò datovò blok ?
         je        GetSgS9                  ; neplatnò datovò blok

; ------ poskytnut° parametrñ bloku

         mov       bx,ds:[si+TabBSiz]       ; velikost pamàüovÇho bloku
         pop       si
         ret                                ; zde je NC !

; ------ chybnÇ zad†n° á°sla bloku

GetSgS9: pop       si
         stc                                ; p©°znak chyby
         ret

GetSgSiz ENDP

; *****************************************************************************
;                                 GetSeg
;               Poskytnut° adresy a velikosti pamàüovÇho bloku
; -----------------------------------------------------------------------------
; VSTUP:  AX=á°slo pamàüovÇho bloku (1,2,3, ... BlokMax)
;         DS=datovò segment
; VùSTUP: BX=velikost bloku (v odstavc°ch)
;         DX=adresa pamàüovÇho bloku (segment)
;         CY=neplatnÇ á°slo datovÇho bloku (BX a DX se nezmàn°)
; *****************************************************************************

GetSeg   PROC      FAR

; ------ £schova registrñ

         push      si

; ------ kontrola á°sla bloku

         mov       si,ax                    ; á°slo datovÇho bloku 1,2,...
         dec       si                       ; á°slo datovÇho bloku 0,1,...
         cmp       si,BlokMax               ; kontrola p©ekroáen° á°sla bloku
         jae       GetSeg9                  ; chybnÇ á°slo bloku
         shl       si,1                     ; offset v tabulce blokñ
         cmp       word ptr ds:[si+TabBAdr],0 ; je platnò datovò blok ?
         je        GetSeg9                  ; neplatnò datovò blok

; ------ poskytnut° parametrñ bloku

         mov       dx,ds:[si+TabBAdr]       ; adresa pamàüovÇho bloku
         mov       bx,ds:[si+TabBSiz]       ; velikost pamàüovÇho bloku
         pop       si
         ret                                ; zde mus° bòt NC !

; ------ chybnÇ zad†n° á°sla bloku

GetSeg9: pop       si
         stc                                ; p©°znak chyby
         ret

GetSeg   ENDP

; *****************************************************************************
;                                   InsSDat
;      vytvo©en° m°sta v segmentu (prvn° 3 bajty = dÇlka bloku v bajtech)
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo segmentu (1,2,3, ... BlokMax)
;        DX:DI=adresa v segmentu (DX=segmentovò offset) - nesm° bòt za daty !
;        BL:CX=poáet vkl†danòch bajtñ
; VùSTUP:CY=nedostatek pamàti, chybnÇ á°slo bloku nebo adresa za koncem bloku
; *****************************************************************************
;˛
InsSDat  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ poskytnut° adresy datovÇho bloku

         call      far ptr GetDat           ; poskytnut° adresy bloku
         jc        InsSDat0                 ; chybnÇ á°slo bloku

; ------ stanoven° novÇ velikosti bloku BX:CX

         mov       bh,0
         add       cx,es:[0]                ; novò konec dat
         adc       bl,es:[2]
         jc        InsSDat0                 ; p©eteáen°
         test      bl,0f0h                  ; je v°ce neë 1 MB ?
         stc
         jnz       InsSDat0                 ; to je p©eteáen°

; ------ nastaven° novÇ velikosti bloku

         push      bx
         push      cx

         add       cx,15                    ; zarovn†n° na odstavec
         adc       bl,0

         REPT      4
         shr       bx,1
         rcr       cx,1
         ENDM

         mov       bx,cx

         call      far ptr ModiSeg          ; nastaven° novÇ velikosti bloku

         pop       cx
         pop       bx
         jnc       InsSDat1                 ; operace OK
InsSDat0:jmp       InsSDat9                 ; chyba

; ------ uloëen° novÇ velikosti bloku BL:CX;  BX:CX <- star† velikost bloku

InsSDat1:xchg      cx,es:[0]                ; nov† velikost bloku
         xchg      bl,es:[2]

; ------ p©epoáet adresy DX:DI na offset v segmentu AX:DI

         xor       ax,ax

         REPT      4
         shl       dx,1
         rcl       ax,1
         ENDM

         add       di,dx
         adc       al,0

; ------ stanoven° poátu bajtñ k odsunu BX:CX

         mov       dh,bl                    ; starò konec dat HIGH
         push      cx
         sub       cx,di
         sbb       bx,ax
         pop       ax                       ; starò konec dat LOW
         jc        InsSDat0                 ; chyba zad†n°-adresa za koncem dat
         jne       InsSDat2                 ; je v°ce neë 64 KB dat k odsunu
         jcxz      InsSDat0                 ; nejsou ë†dn† data k odsunu - OK

; ------ p©°prava zdrojovÇ adresy k p©enosu dat DS:SI

InsSDat2:mov       dl,ah
         mov       ah,0
         xchg      si,ax
         shl       dx,1
         shl       dx,1
         shl       dx,1
         shl       dx,1
         mov       ax,es
         add       ax,dx
         mov       ds,ax                    ; zdrojov† adresa DS:SI

; ------ p©°prava c°lovÇ adresy k p©enosu dat ES:DI

         mov       di,es:[0]                ; offset novÇho konce dat
         and       di,0ffh
         mov       ax,es:[1]
         shl       ax,1
         shl       ax,1
         shl       ax,1
         shl       ax,1
         mov       dx,es
         add       ax,dx                    ; adresa za koncem dat
         mov       es,ax

; ------ p©°prava ostatn°ch registrñ

         mov       dx,cx                    ; DX <- á°taá dat LOW
         dec       si
         dec       di                       ; p©ednastaven° na posledn° bajt
         std                                ; smàr dolñ

; ------ korekce adres DS:SI a ES:DI

InsSDat3:add       si,0fe00h
         add       di,0fe00h
         mov       ax,es
         sub       ax,0fe0h
         mov       es,ax
         mov       ax,ds
         sub       ax,0fe0h
         mov       ds,ax

; ------ p©°prava velikosti bloku pro jeden p©esun -> CX

         mov       cx,0fdfch                ; asi tak velikost jednoho bloku dat
         or        bl,bl                    ; je v°ce neë 64 KB ?
         jnz       InsSDat4                 ; zbòv† v°ce neë 64 KB
         cmp       cx,dx
         jb        InsSDat4                 ; zbòv† v°ce dat
         mov       cx,dx                    ; omezen° velikosti bloku dat
InsSDat4:sub       dx,cx                    ; sn°ëen° á°taáe velikosti dat
         sbb       bl,0

; ------ p©esun jednoho bloku dat

         dec       si                       ; ukazatel na posledn° slovo dat
         dec       di
         shr       cx,1                     ; poáet slov k p©esunu
         rep       movsw                    ; p©esun bloku dat po slovech
         adc       cx,cx
         inc       si                       ; ukazatel na posledn° bajt dat
         inc       di
         rep       movsb                    ; p©esun lichÇho bajtu

; ------ test, zda jsou dal®° data

         mov       ax,dx
         or        ax,bx                    ; jsou dal®° data ?
         jnz       InsSDat3                 ; jsou dal®° data
;         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

InsSDat9:pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InsSDat  ENDP

; *****************************************************************************
;                                 DelSDat
;       zru®en° dat z datovÇho bloku (prvn° 3 bajty = dÇlka bloku v bajtech)
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo segmentu (1,2,3, ... BlokMax)
;        DX:DI=adresa v segmentu (DX=segmentovò offset) - nesm° bòt za daty !
;        BL:CX=poáet ru®enòch bajtñ (nesm° p©etÇct skuteán† data !)
; VùSTUP:CY=chybnÇ á°slo bloku nebo adresa za koncem bloku
; *****************************************************************************
;˛
DelSDat  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ poskytnut° adresy datovÇho bloku

         call      far ptr GetDat           ; poskytnut° adresy bloku
         jnc       DelSDat1
         jmp       DelSDat9
DelSDat1:xchg      ax,bp                    ; BP <- á°slo bloku

         push      ds

; ------ sn°ëen° ukazatele velikosti dat v bufferu

         sub       es:[0],cx                ; sn°ëen° ukazatele velikosti dat
         sbb       es:[2],bl

; ------ poáet bajtñ dat k p©°sunu BH:AX

         push      dx
         push      di

         xor       ax,ax                    ; AX <- 0
         REPT      4
         shl       dx,1                     ; p©evod segmentu DX na bajty
         rcl       ax,1                     ; p©enos segmentu (nejvy®®° 4 bity)
         ENDM
         add       di,dx                    ; DI <- offsetov† adresa LOW
         xchg      ax,dx                    ; DX <- offsetov† adresa HIGH

         mov       ax,es:[0]                ; AX <- novò poáet bajtñ LOW
         mov       bh,es:[2]                ; BH <- novò poáet bajtñ HIGH

         sub       ax,di                    ; AX <- poáet bajtñ k p©°sunu LOW
         sbb       bh,dl                    ; BH <- poáet bajtñ k p©°sunu HIGH

         pop       di                       ; offset adresy v segmentu
         pop       dx                       ; segment adresy v segmentu

         push      ax                       ; poáet bajtñ k p©°sunu LOW
         push      bx                       ; poáet bajtñ k p©°sunu HIGH

; ------ c°lov† adresa dat ES:DI

         mov       ax,es                    ; AX <- adresa zaá†tku bloku
         add       ax,dx                    ; segment c°lovÇ adresy
         mov       dx,di                    ; offset c°lovÇ adresy
         and       di,0fh                   ; normalizace offsetu adresy
         shr       dx,1
         shr       dx,1
         shr       dx,1
         shr       dx,1                     ; p©evod offsetu na segment
         add       ax,dx                    ; p©enos do segmentu
         mov       es,ax                    ; segment c°lovÇ adresy

; ------ zdrojov† adresa dat DS:SI

         mov       si,di                    ; offset c°lovÇ adresy
         add       si,cx                    ; offset zdrojovÇ adresy
         mov       cx,si                    ; CX <- offset zdrojovÇ adresy
         adc       bl,0                     ; p©enos do velikosti HIGH
         and       si,0fh                   ; normalizace offsetu zdrojovÇ adresy
         REPT      4
         shr       bl,1                     ; poáet bajtñ HIGH
         rcr       cx,1                     ; p©evod offsetu na segment
         ENDM
         add       ax,cx                    ; segment zdrojovÇ adresy
         mov       ds,ax                    ; segment zdrojovÇ adresy

; ------ poáet bajtñ dat k p©°sunu BL:DX

         pop       bx
         mov       bl,bh                    ; BL <- poáet bajtñ k p©°sunu HIGH
         mov       bh,0
         pop       dx                       ; DX <- poáet bajtñ k p©°sunu LOW
         cld

; ------ p©°prava velikosti bloku dat CX

DelSDat3:mov       cx,0ff00h
         or        bl,bl                    ; jsou dal®° data HIGH ?
         jnz       DelSDat4                 ; jsou dal®° data
         cmp       cx,dx
         jb        DelSDat4
         mov       cx,dx
DelSDat4:sub       dx,cx
         sbb       bl,0

; ------ p©esun jednoho bloku dat

         shr       cx,1                     ; poáet slov k p©esunu
         rep       movsw                    ; p©esun bloku dat po slovech
         adc       cx,cx
         rep       movsb                    ; p©esun lichÇho bajtu

; ------ posun adresy dat

         sub       si,0ff00h
         mov       ax,ds
         add       ax,0ff00h/16
         mov       ds,ax
         sub       di,0ff00h
         mov       ax,es
         add       ax,0ff00h/16
         mov       es,ax

; ------ test, zda jsou dal®° data

         mov       ax,dx
         or        ax,bx                    ; jsou dal®° data ?
         jnz       DelSDat3                 ; jsou dal®° data

         pop       ds

; ------ nastaven° novÇ velikosti bloku

         xchg      ax,bp
         call      far ptr GetDat

         mov       bx,es:[0]
         mov       cl,es:[2]

         add       bx,15                    ; zarovn†n° na odstavec
         adc       cl,0

         REPT      4
         shr       cl,1
         rcr       bx,1
         ENDM

         call      far ptr ModiSeg          ; nastaven° novÇ velikosti bloku

         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

DelSDat9:pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DelSDat   ENDP

; *****************************************************************************
;                               DelSeg
;                      Zru®en° pamàüovÇho bloku
; -----------------------------------------------------------------------------
; VSTUP:  AX=á°slo pamàüovÇho bloku (1,2,3, ... BlokMax)
;         DS=datovò segment
; VùSTUP: CY=chybnÇ á°slo datovÇho bloku
;         AX=0
; *****************************************************************************

DelSeg   PROC      FAR

         push      bx                       ; £schova BX
         xor       bx,bx                    ; nov† velikost bloku = 0
         call      far ptr ModiSeg          ; modifikace bloku na 0
         xchg      ax,bx                    ; BX <- á°slo bloku, AX <- 0
         jc        DelSeg9                  ; chybnÇ á°slo datovÇho bloku
         shl       bx,1                     ; offset v tabulce popisovaáe + 2
         mov       word ptr ds:[bx+TabBAdr-2],ax; zru®en° popisovaáe bloku
DelSeg9: pop       bx                       ; n†vrat BX
         ret

DelSeg  ENDP

; *****************************************************************************
;                               ModiSegS
;             Modifikace velikosti pamàüovÇho bloku do 64 KB
; -----------------------------------------------------------------------------
; VSTUP:  AX=á°slo pamàüovÇho bloku (1,2,3, ... BlokMax)
;         BX=poëadovan† velikost pamàüovÇho bloku (v bajtech)
;         DS=datovò segment
; VùSTUP: CY=nedostatek pamàti nebo chybnÇ á°slo bloku
; *****************************************************************************

ModiSegS PROC      FAR

         push      bx
         add       bx,15                    ; zaokrouhlen° na odstavec
         rcr       bx,1                     ; rotace s bitem p©eteáen°
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; p©evod offsetu na odstavce
         call      far ptr ModiSeg          ; modifikace velikosti pamàti
         pop       bx
         ret

ModiSegS ENDP

; *****************************************************************************
;                               ModiSeg
;                 Modifikace velikosti pamàüovÇho bloku
; -----------------------------------------------------------------------------
; VSTUP:  AX=á°slo pamàüovÇho bloku (1,2,3, ... BlokMax)
;         BX=poëadovan† velikost pamàüovÇho bloku (v odstavc°ch)
;         DS=datovò segment
; VùSTUP: CY=nedostatek pamàti nebo chybnÇ á°slo bloku
; *****************************************************************************

ModiSeg  PROC      FAR

; ------ £schova registrñ 1

         push      bx
         push      cx
         push      dx

; ------ porovn†n° skuteánÇ velikosti s poëadovanou

         mov       cx,bx                    ; poëadovan† velikost
         add       cx,15                    ; bude zaokrouhlen° na 256 bajtñ
         jc        ModiSeg4                 ; chyba - p©°li® velkÇ á°slo
         and       cl,not 0fh               ; zaokrouhlen° na 256 bajtñ
         call      far ptr GetSeg           ; poskytnut° adresy a velikosti
         jc        ModiSeg4                 ; chybnÇ á°slo dat. bloku
         cmp       bx,cx                    ; odpov°d† velikost ?
         je        ModiSeg4                 ; velikost odpov°d† OK

; ------ £schova registrñ 2

         push      ax
         push      si
         push      es

; ------ vòpoáet zdrojovÇ a c°lovÇ adresy a velikosti dat k p©esunu

         add       cx,dx                    ; novò konec bloku (= c°l. segment)
         jc        ModiSeg3                 ; p©eteáen° pamàti
         add       bx,dx                    ; souáasnò konec bloku (=zdroj.seg.)
         mov       si,ds:[FreeSeg]          ; konec dat v pamàti
         sub       si,bx                    ; velikost zbytku dat k p©esunu

; ------ oprava konce pamàti

         mov       dx,cx                    ; novò konec bloku
         add       dx,si                    ; novò konec pamàti
         cmp       dx,ds:[EndSeg]           ; je p©eteáen° pamàti ?
         cmc
         jc        ModiSeg3                 ; p©eteáen° pamàti
         mov       ds:[FreeSeg],dx          ; novò konec pamàti

; ------ p©esun zbytku dat za blokem

         push      ds                       ; £schova DS
         mov       ds,bx                    ; zdrojov† adresa p©esunu
         mov       es,cx                    ; c°lov† adresa p©esunu
         mov       bx,si                    ; velikost zbytku dat k p©esunu
         call      far ptr SegMove          ; p©esun zbytku dat za blokem
         mov       bx,ds                    ; zdrojovò segment
         pop       ds                       ; n†vrat DS

; ------ zmàna velikosti bloku v tabulce

         sub       cx,bx                    ; zmàna velikosti bloku (+ nebo -)
         mov       dx,cx                    ; posun adres blokñ (+ nebo -)
         mov       si,ax                    ; á°slo pamàüovÇho bloku 1, 2, 3, ..
         dec       si                       ; á°slo bloku 0, 1, 2, ...
         shl       si,1                     ; offset v tabulce blokñ
         add       ds:[si+TabBSiz],dx       ; zmàna velikosti pamàüovÇho bloku
         mov       ax,si                    ; £schova offsetu popisovaáe bloku

; ------ modifikace adres datovòch blokñ v tabulce

         mov       cx,BlokMax               ; poáet datovòch blokñ
         mov       si,offset TabBAdr        ; offset zaá†tku tabulky
         add       ax,si                    ; adresa modifikovanÇho bloku
ModiSeg1:cmp       ax,si                    ; je to modifikovanò blok ?
         je        ModiSeg2                 ; modifikovanò blok - neupravuje se
         cmp       ds:[si],bx               ; je blok pod modifikovanòm ?
         jb        ModiSeg2                 ; blok nebyl posouvanò
         add       ds:[si],dx               ; oprava adresy bloku
ModiSeg2:inc       si                       ; adresa dal®°ho popisovaáe
         inc       si
         loop      ModiSeg1                 ; oprava dal®°ho popisovaáe
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ 2

ModiSeg3:pop       es
         pop       si
         pop       ax

; ------ n†vrat registrñ 1

ModiSeg4:pop       dx
         pop       cx
         pop       bx
         ret

ModiSeg  ENDP

; *****************************************************************************
;                                SegMove
;                  P©esun segmentovanÇho pamàüovÇho bloku
; -----------------------------------------------------------------------------
; VSTUP: DS=segment zdrojovÇ adresy
;        ES=segment c°lovÇ adresy
;        BX=dÇlka bloku (v odstavc°ch)
; *****************************************************************************

SegMove  PROC      FAR

         or        bx,bx                    ; jsou nàjak† data k p©esunu ?
         jz        SegMove6                 ; nejsou ë†dn† data k p©esunu

; ------ £schova registrñ

         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ poá†teán° nastaven° registrñ (p©°prava pro p©enos dolñ)

         cld                                ; p©°znak smàru nahoru
         xor       si,si                    ; SI <- 0
         xor       di,di                    ; DI <- 0
         mov       dx,ds                    ; zdrojov† adresa
         mov       cx,es                    ; c°lov† adresa
         cmp       dx,cx                    ; porovn†n° adres
         mov       dx,1000h                 ; p©°rustek pro smàr nahoru 1000h
         je        SegMove5                 ; adresy jsou shodnÇ - nen° p©esun
         ja        SegMove3                 ; zdrojov† nad c°lovou = p©enos dolñ

; ------ p©ednastaven° ukazatelñ pro p©enos nahoru

         std                                ; p©°znak smàru dolñ
         neg       dx                       ; p©°rustek pro smàr dolñ -1000h
         add       cx,bx                    ; konec c°lovÇho segmentu
         mov       es,cx                    ; novò c°lovò segment
         mov       cx,ds                    ; zdrojovò segment
         add       cx,bx                    ; konec zdrojovÇho segmentu
         mov       ds,cx                    ; novò zdrojovò segment
         dec       si
         dec       si                       ; korekce adresy (0fffeh)
         dec       di
         dec       di                       ; korekce adresy (0fffeh)

; ------ p©enos dal®°ho bloku dat

SegMove2:mov       cx,es                    ; c°lovò segment
         add       cx,dx                    ; posun o 1 segment 64 KB
         mov       es,cx                    ; novò c°lovò segment
         mov       cx,ds                    ; zdrojovò segment
         add       cx,dx                    ; posun o 1 segment 64 KB
         mov       ds,cx                    ; novò zdrojovò segment

; ------ nastaven° velikosti p©en†®enÇho bloku

SegMove3:mov       cx,1000h                 ; omezen° na 64 KB
         cmp       bx,cx                    ; je blok vàt®° neë 1 segment ?
         ja        SegMove4                 ; zbytek dat je vàt®° neë 64 KB
         mov       cx,bx                    ; velikost bloku v odstavc°ch
SegMove4:shl       cx,1
         shl       cx,1
         shl       cx,1                     ; p©evod odstavcñ na slova

; ------ p©enos jednoho bloku dat

         rep       movsw                    ; p©enos jednoho segmentu
         sub       bx,1000h                 ; je dal®° segment k p©enosu ?
         ja        SegMove2                 ; p©enos dal®°ho segmentu

; ------ n†vrat registrñ

SegMove5:pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
SegMove6:ret

SegMove  ENDP

;; *****************************************************************************
;;                           Instalace pamàti XMS
;; -----------------------------------------------------------------------------
;; VSTUP: DS=datovò segment
;; *****************************************************************************
;
;InstXMS  PROC      FAR
;
;; ------ test instalace XMS
;
;         mov       ax,4300h
;         call      far ptr Int2F            ; test instalace XMS
;         cmp       al,80h
;         jne       InstXMS3                 ; nen° XMS
;
;; ------ adresa ovladaáe XMS
;
;         mov       bx,-1
;         xor       ax,ax
;         mov       es,ax
;         mov       ax,4310h
;         call      far ptr Int2F            ; adresa ovladaáe XMS
;         mov       word ptr ds:[DriveXMS],bx ; adreas vladaáe XMS
;         mov       word ptr ds:[DriveXMS+2],es
;         inc       bx
;         jz        InstXMS3
;         mov       ax,es
;         cmp       ax,50h
;         jb        InstXMS3
;
;; ------ verze ovladaáe XMS
;
;         or        byte ptr ds:[ParamXMS],bit0 ; p©°znak ovladaáe XMS
;         mov       ah,0
;         call      far ptr XMS              ; zji®tàn° verze XMS
;         mov       ds:[VerzeXMS],ax         ; verze ovladaáe XMS
;         cmp       ax,200h                  ; minim†ln° verze 2.00
;         jae       InstXMS4                 ; verze je OK
;
;InstXMS3:and       byte ptr ds:[ParamXMS],not bit0 ; nen° ovladaá XMS
;
;InstXMS4:ret
;
;InstXMS  ENDP
;
;; *****************************************************************************
;;                               AlokXMS
;;                          p©idàlen° pamàti XMS
;; -----------------------------------------------------------------------------
;; VSTUP: BX=poëadovan† velikost v odstavc°ch
;; VùSTUP: DX=á°slo pamàüovÇho bloku
;;         CY=chyba (nedostatek pamàti)
;; *****************************************************************************
;
;AlokXMS  PROC      FAR
;
;; ------ £schova registrñ
;
;         push      ax
;         push      bx
;         push      cx
;
;; ------ p©epoáet velikosti bloku na KB
;
;         mov       dx,bx                    ; poëadovan† velikost v odstavc°ch
;         add       dx,1023/16               ; zaokrouhlen° nahoru
;         shr       dx,1
;         shr       dx,1
;         shr       dx,1
;         shr       dx,1
;         shr       dx,1
;         shr       dx,1                     ; p©evod na KB
;         mov       ah,9
;         call      far ptr XMS              ; p©idàlen° alokaán°ho bloku XMS
;
;; ------ n†vrat registrñ
;
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;AlokXMS  ENDP
;
;; *****************************************************************************
;;                                FreeXMS
;;                    uvolnàn° alokaán°ho bloku XMS
;; -----------------------------------------------------------------------------
;; VSTUP: DX=á°slo bloku XMS
;;        DS=datovò segment
;; VùSTUP: CY=chyba
;; *****************************************************************************
;
;FreeXMS  PROC      FAR
;
;         push      ax
;         push      bx
;         push      cx
;         push      dx
;
;         mov       ah,0ah
;         call      far ptr XMS              ; uvolnàn° alokaán°ho bloku XMS
;
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;FreeXMS  ENDP
;
;; *****************************************************************************
;;                               WritXMS
;;                       z†pis dat do bloku XMS
;; -----------------------------------------------------------------------------
;; VSTUP: DX=ovladaá bloku XMS
;;        ES=segment dat k z†pisu
;;        BX=poáet odstavcñ dat k z†pisu
;;        DS=datovò segment
;; VùSTUP: CY=chyba
;; *****************************************************************************
;
;WritXMS  PROC      FAR
;
;; ------ £schova registrñ
;
;         push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      si
;
;; ------ c°lovò identifik†tor
;
;         mov       si,offset TabWXMS        ; tabulka popisovaáe operace XMS
;         mov       ds:[si+10],dx            ; c°lovò identifik†tor
;
;; ------ poáet bajtñ k z†pisu
;
;         xor       ax,ax                    ; AX <- 0
;         xchg      ax,bx                    ; AX <- poáet odstavcñ dat k z†pisu
;         shl       ax,1
;         rcl       bx,1
;         shl       ax,1
;         rcl       bx,1
;         shl       ax,1
;         rcl       bx,1
;         shl       ax,1
;         rcl       bx,1                     ; p©evod na bajty
;         mov       ds:[si],ax               ; poáet bajtñ k z†pisu
;         mov       ds:[si+2],bx
;
;; ------ zdrojov† adresa
;
;         mov       ax,es                    ; AX <- segment dat
;         xor       bx,bx
;         shl       ax,1
;         rcl       bx,1
;         shl       ax,1
;         rcl       bx,1
;         shl       ax,1
;         rcl       bx,1
;         shl       ax,1
;         rcl       bx,1                     ; p©evod na bajty
;         mov       ds:[si+6],ax             ; zdrojov† adresa
;         mov       ds:[si+6+2],bx
;
;; ------ proveden° operace
;
;         mov       ah,0bh
;         call      far ptr XMS              ; proveden° p©esunu dat
;
;; ------ n†vrat registrñ
;
;         pop       si
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;WritXMS  ENDP
;
;; *****************************************************************************
;;                               ReadXMS
;;                       naáten° dat z bloku XMS
;; -----------------------------------------------------------------------------
;; VSTUP: DX=ovladaá bloku XMS
;;        ES=segment bufferu
;;        BX=poáet odstavcñ dat ke áten°
;;        DS=datovò segment
;; VùSTUP: CY=chyba
;; *****************************************************************************
;
;ReadXMS  PROC      FAR
;
;; ------ £schova registrñ
;
;         push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      si
;
;; ------ zdrojovò identifik†tor
;
;         mov       si,offset TabRXMS        ; tabulka popisovaáe operace XMS
;         mov       ds:[si+4],dx             ; zdrojovò identifik†tor
;
;; ------ poáet bajtñ k naáten°
;
;         xor       ax,ax                    ; AX <- 0
;         xchg      ax,bx                    ; AX <- poáet odstavcñ dat k naáten°
;         shl       ax,1
;         rcl       bx,1
;         shl       ax,1
;         rcl       bx,1
;         shl       ax,1
;         rcl       bx,1
;         shl       ax,1
;         rcl       bx,1                     ; p©evod na bajty
;         mov       ds:[si],ax               ; poáet bajtñ k naáten°
;         mov       ds:[si+2],bx
;
;; ------ c°lov† adresa
;
;         mov       ax,es                    ; AX <- segment dat
;         xor       bx,bx
;         shl       ax,1
;         rcl       bx,1
;         shl       ax,1
;         rcl       bx,1
;         shl       ax,1
;         rcl       bx,1
;         shl       ax,1
;         rcl       bx,1                     ; p©evod na bajty
;         mov       ds:[si+12],ax            ; c°lov† adresa
;         mov       ds:[si+12+2],bx
;
;; ------ proveden° operace
;
;         mov       ah,0bh
;         call      far ptr XMS              ; proveden° p©esunu dat
;
;; ------ n†vrat registrñ
;
;         pop       si
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;ReadXMS  ENDP
;
;; *****************************************************************************
;;                               XMS
;;                        vol†n° funkce XMS
;; -----------------------------------------------------------------------------
;; VSTUP: AH=á°slo funkce
;;        DS=datovò segment
;; VùSTUP: CY=chyba funkce (AX=0)
;; *****************************************************************************
;
;XMS      PROC      FAR
;
;         test      byte ptr ds:[ParamXMS],bit0 ; je ovladaá nainstalov†n ?
;         jz        XMS9                     ; ovladaá nen° nainstalov†n
;
;         push      si
;         push      di
;         push      bp
;         push      ds
;         push      es
;
;         call      dword ptr ds:[DriveXMS]  ; vol†n° funkce ovladaáe XMS
;         cmp       ax,1                     ; je operace OK ?
;
;         pop       es
;         pop       ds
;         pop       bp
;         pop       di
;         pop       si
;         ret
;
;XMS9:    xor       ax,ax
;         stc
;         ret
;
;XMS      ENDP
;
;; *****************************************************************************
;;        vol†n° INT 2Fh s £schovou registrñ
;; *****************************************************************************
;
;Int2F    PROC      FAR
;
;         pushf
;         push      si
;         push      di
;         push      ds
;
;         int       2fh
;
;         pop       ds
;         pop       di
;         pop       si
;         popf
;         ret
;
;Int2F    ENDP

CodeMem  ENDS

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                                 Data
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
Data     SEGMENT

; ------ intern° p©ep°naáe DOSMANu

TabIEnv1 label     byte
         db        8,'CODEPAGE'             ; "DMCODEPAGE"
         dw        GetIEG11                 ; k¢dov† str†nka
         db        0

TabIEnv2 label     byte
         db        2,'RO'                   ; "DMFILERO"
         dw        GetIEG21                 ; atribut R/O
         db        3,'HID'                  ; "DMFILEHID"
         dw        GetIEG22                 ; atribut HID
         db        3,'SYS'                  ; "DMFILESYS"
         dw        GetIEG23                 ; atribut SYS
         db        3,'DIR'                  ; "DMFILEDIR"
         dw        GetIEG24                 ; atribut DIR
         db        3,'ARC'                  ; "DMFILEARC"
         dw        GetIEG25                 ; atribut ARC

         db        3,'SEC'                  ; "DMFILESEC"
         dw        GetIEG26                 ; sekunda souboru
         db        3,'MIN'                  ; "DMFILEMIN"
         dw        GetIEG27                 ; minuta souboru
         db        4,'HOUR'                 ; "DMFILEHOUR"
         dw        GetIEG28                 ; màs°c souboru
         db        3,'DAY'                  ; "DMFILEDAY"
         dw        GetIEG29                 ; den souboru
         db        5,'MONTH'                ; "DMFILEMON"
         dw        GetIEG2A                 ; màs°c souboru
         db        4,'YEAR'                 ; "DMFILEYEAR"
         dw        GetIEG2B                 ; rok souboru

         db        4,'SIZE'                 ; "DMFILESIZE"
         dw        GetUEG2C                 ; velikost souboru
         db        0

TabICN   db        'N',0                    ; vyp
TabICY   db        'Y',0                    ; zap

TabICPag db        'NO',0                   ; 0: neuráeno
         db        'NO',0                   ; 1: bez diakritiky
         db        'IBM',0                  ; 2: omezen† diakritika IBM
         db        'KEYBCS2',0              ; 3: Kamenickòch
         db        'LATIN2',0               ; 4: Latin 2

TabICBuf db        11 dup(0)                ; dek¢dovanÇ á°slo jako parametr

; -----------------------------------------------------------------------------
;        chybovÇ hl†®en° - nedostatek pamàti
; -----------------------------------------------------------------------------

ChbLnMem label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        ChbLnMeP                 ; zaá†tek definice poloëek menu
         dw        ChbLnMeH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@Main                 ; á°slo str†nky velkÇ n†povàdy
         dw        ChbLnMeB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        ChbLnMeT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        49                       ; ®°©ka okna
         db        9                        ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie
         db        0                        ; poáet p©edvoleb


ChbLnMeP db        bit6,6,0,'CHYBA'
         db        bit6,39,'Nedostatek pamàti k proveden° operace !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,6,'N†vrat'

ChbLnMeB db        0                        ; blokovac° tabulka

ChbLnMeT db        17,'nedostatek pamàti'

HelpS    SEGMENT   BYTE PUBLIC
ChbLnMeH db        39,'Stisknàte kl†vesu Esc nebo Enter...'
HelpS    ENDS


;ParamXMS db        0                        ; parametry manaëeru pamàti
;                                            ;   bit 0: 1=XMS nainstalov†n
;
;DriveXMS dd        0                        ; adresa ovladaáe XMS
;VerzeXMS dw        0                        ; verze ovladaáe XMS
;
;; ------ tabulka pro z†pis dat do XMS
;
;TabWXMS  label     word
;TabWXMSN dd        0                        ; poáet bajtñ k z†pisu
;         dw        0                        ; zdrojovò identifik†tor
;TabWXMSA dd        0                        ; zdrojov† adresa
;TabWXMSI dw        0                        ; c°lovò identifik†tor
;         dd        0                        ; c°lov† adresa
;
;; ------ tabulka pro áten° dat z XMS
;
;TabRXMS  label     word
;TabRXMSN dd        0                        ; poáet bajtñ ke áten°
;TabRXMSI dw        0                        ; zdrojovò identifik†tor
;         dd        0                        ; zdrojov† adresa
;         dw        0                        ; c°lovò identifik†tor
;TabRXMSA dd        0                        ; c°lov† adresa

; ------ definice prost©ed° DOS

Dos0AMem dw        0                        ; poá†teán° alok. blok DOS (0=nen°)
;EnvParnt dw        0                        ; prost©ed° otcovskÇho programu (0=nen°)
EnvSegm  dw        0                        ; segment kopie prost©ed°

; ------ ukazatele datovÇho bloku

TopSeg   dw        ?                        ; segment zaá†tku datovÇ pamàti
FreeSeg  dw        ?                        ; segment zaá†tku volnÇ pamàti
EndSeg   dw        ?                        ; segment konce datovÇ pamàti

; ------ tabulka popisovaáñ datovòch blokñ (zachovat po©ad° tabulek !)
; Ä°slo datovÇho bloku = 1, 2, 3, ... BlokMax (0=neplatnò blok)
; Velikost datovòch blokñ se modifikuje po p©°rustku 256 bajtñ.

TabBAdr  label     word
         dw        BlokMax dup(?)           ; tabulka adres dat. blokñ (0=volnò)
TabBSiz  label     word
         dw        BlokMax dup(?)           ; tabulka velikost° datovòch blokñ

Data     ENDS
         END
