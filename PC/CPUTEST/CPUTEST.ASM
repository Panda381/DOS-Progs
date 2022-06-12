
MAXMEM   EQU       2000h                    ; (u PC pro vˆt¨¡ buffer p©et‚k  ‡as)

; N mˆty:
; --------------------------------------------------------------------
; - namˆ©en‚ v˜sledky v *.LST jsou p©i jak‚msi standardn¡m nastaven¡
;   ‡asov n¡ v SETUP BIOS (READ WAIT STATE = 3, WRITE WAIT STATE = 2 atd.),
;   p©i jin‚m nastaven¡ se to velmi li¨¡. Zmˆny ale p©itom nejsou
;   po cel˜ch taktech, ale i po velmi mal˜ch ‡ stech, jako by se to
;   projevovalo jen n hodnˆ u nˆkter˜ch instrukc¡. Je to divn  nejednozna‡nost.
; - zmˆ©it dobu pro proveden¡ 0 cykl– instrukc¡ (tj. jen ob lku kolem),
;   tuto dobu potom p©i mˆ©en¡ v‘dy ode‡¡tat
; - zmˆ©it d‚lku instrukce nejd©¡ve jen nahrubo pro p r cykl–, z toho
;   ur‡it po‡et cykl– pro p©esn‚ mˆ©en¡ tak, aby se to ve¨lo maxim lnˆ
;   do bufferu (pak se m–‘e zvˆt¨it MAXMEM) a p©itom aby se to ve¨lo
;   ‡asovˆ do 55 ms (perioda ‡asova‡e).
; - p©i mˆ©en¡ zak zat p©eru¨en¡ od ©adi‡e p©eru¨en¡ (port 21h), zak zat
;   p©¡stupy od DMA ©adi‡e, zak zat nemaskovateln‚ p©eru¨en¡ (port CMOS)
; - kromˆ intern¡ CACHE pamˆti nˆjak zablokovat i extern¡ CACHE pamˆŸ
; - mˆ©en¡ rychlosti procesoru umo‘nit (a doladit) i pro ni‘¨¡ procesory
; - mˆ©en¡ rychlosti procesoru prov‚st stejnou procedurou jako mˆ©en¡ doby
;   instrukc¡ - umo‘n¡ vyu‘¡t vyp¡n n¡ CACHE apod.
; - p©i startu ovˆ©it funk‡nost portu 42h pro mˆ©en¡ doby (viz ROBOTRON XT)
; - zajistit o¨et©en¡ nˆkter˜ch chybov˜ch stav–, kter‚ by mohly vzniknout
;   p©i prov dˆn¡ testu (nap©. p©eru¨en¡ dˆlen¡m nulou nebo nezn mou instrukc¡)
; - mo‘nost na‡¡tat i velk˜ £sek programu ze souboru
; - mo‘nost zad vat instrukce v symbolick‚m tvaru (tj. p©eklada‡)
; - mo‘nost zadat rychlost procesoru i pomoc¡ desetinn‚ ‡ sti
; - rychlost procesoru si vnit©nˆ evidovat skute‡nˆ pomoc¡ desetinn‚ ‡ sti
;   a ne jako po‡et setin
; - zprocedurovat v˜po‡ty v˜sledk– (je to bastl) a jin‚ ‡ sti programu
; - detekce procesor– CYRIX, DLL, Pentium a vyhodnocen¡ jejich rychlost¡
; - ovˆ©it v˜po‡ty a zjistit, pro‡ je v˜sledek nestabiln¡ u instrukc¡
;   p©¡stupu k pamˆti (MOV AL,[adresa] - z le‘¡ na tom, zda adresuje p©ed
;   instrukci, za instrukci nebo na pevnou adresu a p©itom tam nen¡
;   ‘ dn  CACHE pamˆŸ ?!?!)
; - nen¡ vyzkou¨eno pou‘it¡ pro vy¨¨¡ instrukce (nap©. PUSHALL, CR0 atd.)
; - asi je pot©eba p©i startu programu inicializovat z sobn¡k a segment programu,
;   aby p©i vyvol n¡ nap©. POP AX se neobjevila u PC chyba parity
; - je pot©eba jednozna‡nˆji definovat nastaven¡ instrukc¡ a F p©i startu, aby
;   se nemusely nastavovat (nap©. ‘e SI=0 pro LODSW nebo ‘e je nastaven CLD)

Code     SEGMENT
         ASSUME    cs:Code,ds:Code

; ------ inicializace registr–

Start:   push      cs
         pop       ds                       ; DS <- segment programu

; ------ detekce typu procesoru

         push      es
         call      DetCPU                   ; detekce typu procesoru
         call      ClckCpu                  ; mˆ©en¡ frekvence hodin
         pop       es

; ------ dek¢dov n¡ parametr–

         call      Dekod                    ; dek¢dov n¡ parametr–
         jnc       Start2                   ; zad n¡ OK

; ------ zobrazen¡ n povˆdy

         mov       dx,offset HelpTxt
         mov       cx,offset(HelpTxt0-HelpTxt)
         mov       bx,1
         mov       ah,40h
         int       21h
         jmp       Start8

; ------ nen¡-li nic zad no, zobraz¡ se jen typ procesoru

Start2:  cmp       byte ptr ds:[TestNum],0  ; je nˆco zad no ?
         jne       Start3                   ; je nˆco zad no
         mov       dx,offset CpuTxt1
         mov       ah,9
         int       21h
         mov       cx,ds:[TypCpu]
         mov       si,offset CPUTxt
         jcxz      Start22
Start21: inc       si
         cmp       byte ptr ds:[si-1],"$"
         jne       Start21
         loop      Start21
Start22: mov       dx,si
         mov       ah,9
         int       21h

         mov       al,"/"
         call      DispChr

         mov       ax,ds:[Hodiny]           ; hodiny procesoru
         call      DispNum                  ; zobrazen¡ frekvence
         mov       al,"."
         call      DispChr
         cmp       byte ptr ds:[HodinyD],10
         jae       Start23
         mov       al,"0"
         call      DispChr
Start23: mov       al,ds:[HodinyD]          ; hodiny - desetiny
         mov       ah,0
         call      DispNum

         mov       dx,offset CpuTxt2
         mov       ah,9
         int       21h
         jmp       Start8

; ------ ur‡en¡ po‡tu cykl– k testu -> CX

Start3:  mov       ax,MAXMEM                ; asi tolik velikost programu
         sub       ax,ds:[InitNum]          ; bez inicializa‡n¡ ‡ sti
         xor       dx,dx
         div       word ptr ds:[TestNum]    ; po‡et cykl–
         mov       ds:[CyklNum],ax          ; po‡et testovac¡ch cykl–
         xchg      ax,cx                    ; CX <- po‡et cykl–

; ------ mˆ©en¡ testovan˜ch instrukc¡

         mov       si,offset TestIns
         call      PrepIns                  ; p©¡prava instrukc¡
         call      Execute                  ; proveden¡ mˆ©en¡

; ------ doba na jednu smy‡ku

         or        ax,ax
         jnz       Start32
         dec       ax
Start32: xor       dx,dx
         div       word ptr ds:[CyklNum]    ; doba na jednu instrukci
         mov       ds:[TestDoba],ax         ; testovan  doba - cel  ‡ st
         xor       ax,ax
         div       word ptr ds:[CyklNum]
         mov       ds:[TestDobD],ax         ; testovan  doba - desetiny

; ------ ur‡en¡ po‡tu cykl– referen‡n¡ho testu -> CX

         cmp       word ptr ds:[RefNum],0   ; je nˆco ?
         je        Start4                   ; nen¡ nic
         mov       ax,MAXMEM                ; asi tolik velikost programu
         sub       ax,ds:[InitNum]          ; bez inicializa‡n¡ ‡ sti
         xor       dx,dx
         div       word ptr ds:[RefNum]     ; po‡et cykl–
         mov       ds:[CyklNum],ax          ; po‡et testovac¡ch cykl–
         xchg      ax,cx                    ; CX <- po‡et cykl–

; ------ mˆ©en¡ testovan˜ch instrukc¡

         mov       si,offset RefIns
         call      PrepIns                  ; p©¡prava instrukc¡
         call      Execute                  ; proveden¡ mˆ©en¡

; ------ doba na jednu smy‡ku

         or        ax,ax
         jnz       Start34
         dec       ax
Start34: xor       dx,dx
         div       word ptr ds:[CyklNum]    ; doba na jednu instrukci
         xchg      ax,bx                    ; BX <- testovan  doba - cel  ‡ st
         xor       ax,ax
         div       word ptr ds:[CyklNum]
         sub       ds:[TestDobD],ax         ; testovan  doba - desetiny
         sbb       ds:[TestDoba],bx
         jnc       Start4
         mov       word ptr ds:[TestDoba],0
         mov       word ptr ds:[TestDobD],0

; ------ zobrazen¡ prvn¡ ‡ sti hl ¨en¡

Start4:  mov       dx,offset Text
         mov       cx,ds:[TextNum]
         mov       ah,40h
         mov       bx,1
         int       21h                      ; z pis £vodu hl ¨en¡

; ------ v˜po‡et doby instrukce
; 1 impuls = 0.83809511 us (=54925 / 64K)
;
         mov       ax,54925                 ; ‡ st doby
         mul       word ptr ds:[TestDobD]   ; p©epo‡et desetin doby
         mov       ds:[TestDobD],dx         ; desetinn  ‡ st doby
         mov       ax,54925                 ; ‡ st doby
         mul       word ptr ds:[TestDoba]   ; p©epo‡et cel‚ ‡ sti
         add       ds:[TestDobD],ax         ; doba instrukce - desetiny
         adc       dx,0
         mov       ds:[TestDoba],dx         ; doba instrukce - cel  ‡ st

; ------ zobrazen¡ doby jedn‚ instrukce

         mov       ax,ds:[TestDoba]
         mov       bx,ds:[TestDobD]
         add       bx,33                    ; zaokrouhlen¡ - p©i‡ten¡ 0.0005
         adc       ax,0
         call      DispNum
         mov       al,"."
         call      DispChr
         mov       cx,3                     ; po‡et ‡¡slic k zobrazen¡
Start5:  mov       ax,10
         mul       bx
         xchg      ax,bx
         xchg      ax,dx
         add       al,"0"
         call      DispChr
         loop      Start5

         mov       dx,offset DobaTxt
         mov       ah,9
         int       21h

; ------ frekvence procesoru - desetinn  ‡ st -> AX

         mov       dh,0
         mov       dl,ds:[HodinyD]          ; hodiny procesoru - setiny
         xor       ax,ax
         mov       cx,100
         div       cx                       ; v˜po‡et ‡ sti rychlosti

; ------ v˜po‡et po‡tu takt–

         push      ax                       ; ‡ st frekvence
         mul       word ptr ds:[TestDobD]   ; ‡ st frekvence * ‡ st doby
         xchg      dx,ds:[TestDobD]         ; p©en ¨¡ se jen HIGH
         xchg      ax,dx                    ; AX <- ‡ st doby
         mul       word ptr ds:[Hodiny]     ; frekvence * ‡ st doby
         add       ds:[TestDobD],ax         ; p©enos LOW
         adc       dx,0
         xchg      dx,ds:[TestDoba]         ; p©enos HIGH, DX <- doba
         push      dx
         xchg      ax,dx
         mul       word ptr ds:[Hodiny]     ; doba * frekvence
         add       ds:[TestDoba],ax         ; p©enos jen LOW
         pop       dx                       ; doba
         pop       ax
         mul       dx                       ; doba * ‡ st frekvence
         add       ds:[TestDobD],ax         ; p©enos LOW
         adc       ds:[TestDoba],dx         ; p©enos HIGH

; ------ zobrazen¡ po‡tu takt–

         mov       ax,ds:[TestDoba]         ; po‡et takt– - cel  ‡ st
         mov       bx,ds:[TestDobD]
         add       bx,32768                 ; zaokrouhlen¡ - p©i‡ten¡ 0.5
         adc       ax,0
         call      DispNum
;         mov       al,"."
;         call      DispChr
;         mov       cx,3                     ; po‡et ‡¡slic k zobrazen¡
;Start6:  mov       ax,10
;         mul       bx
;         xchg      ax,bx
;         xchg      ax,dx
;         add       al,"0"
;         call      DispChr
;         loop      Start6

         mov       dx,offset DobaTxt1
         dec       ax
         jz        Start7
         mov       dx,offset DobaTxt2
         sub       ax,4-1
         jbe       Start7
         mov       dx,offset DobaTxt3
Start7:  mov       ah,9
         int       21h

Start8:  mov       ah,4ch
         mov       al,byte ptr ds:[TypCPU]  ; detekovan˜ procesor
         int       21h

; *****************************************************************************
;
;                             Obsluha zobrazen¡
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        zobrazen¡ ‡¡sla AX
; -----------------------------------------------------------------------------

DispNum  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ p©¡prava registr–

         mov       bx,10                    ; dˆlitel
         xor       cx,cx                    ; ‡¡ta‡ znak–

; ------ vydˆlen¡ ‡¡sla

DispNum1:xor       dx,dx
         div       bx
         push      dx
         inc       cx
         or        ax,ax
         jnz       DispNum1

; ------ zobrazen¡ ‡¡sla

DispNum2:pop       ax
         add       al,"0"
         call      DispChr
         loop      DispNum2

; ------ n vrat registr–

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispNum  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku AL
; -----------------------------------------------------------------------------

DispChr  PROC      NEAR

         push      ax
         push      dx
         xchg      ax,dx
         mov       ah,2
         int       21h
         pop       dx
         pop       ax
         ret

DispChr  ENDP

; *****************************************************************************
;
;                              test instrukc¡
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        proveden¡ jednoho testu instrukc¡ (ni‡¡ registry !) -> AX=doba
; -----------------------------------------------------------------------------

Execute  PROC      NEAR

; ------ £schova z sobn¡ku

         mov       ds:[RegSS],ss            ; £schova registru SS
         mov       ds:[RegSP],sp            ; £schova registru SP

; ------ ‡ek n¡ na hranu hodin INT 08h (aby nep©i¨lo bˆhem testu)

         xor       ax,ax
         mov       es,ax
         sti
         mov       ax,es:[46ch]             ; aktu ln¡ stav ‡¡ta‡e hodin
Execute2:cmp       ax,es:[46ch]
         je        Execute2                 ; ‡ek n¡ na hranu INT 08h

; ------ inicializace z sobn¡ku

         cli
         mov       ax,SEG ProgZ
         mov       ss,ax                    ; segment z sobn¡ku
         mov       sp,0fffeh                ; offset z sobn¡ku

; ------ vypnut¡ CACHE pamˆti pro 80386 a vy¨¨¡

         cmp       byte ptr ds:[TypCPU],8   ; procesor 80386 a vy¨¨¡ ?
         jb        Execute3                 ; je mal˜ typ procesoru
.386p
         mov       eax,cr0
         mov       ds:[RegCR0],eax
         or        eax,40000000h            ; z kaz CACHE
         mov       cr0,eax
.8086
; ------ inicializace registr– (aby to bylo jednozna‡n‚)

Execute3:xor       bx,bx
         xor       cx,cx
         xor       dx,dx
         xor       si,si
         xor       di,di
         xor       bp,bp
         mov       ax,SEG ProgS             ; segment bufferu programu
         mov       ds,ax                    ; DS <- segment bufferu
         mov       es,ax                    ; ES <- segment bufferu

; ------ nastaven¡ dˆli‡ky reproduktoru

         in        al,[61h]
         and       al,not 3                 ; ‡¡ta‡ vypnut
         out       [61h],al                 ; vypnut¡ v˜stupu na reproduktor
         mov       al,0b4h
         out       [43h],al                 ; povel pro nastaven¡ frekvence
         mov       al,0
         out       [42h],al                 ; dˆlic¡ konstanta LOW
         jmp       $+2
         out       [42h],al                 ; dˆlic¡ konstanta HIGH

; ------ start mˆ©en¡ doby

         in        al,[61h]
         or        al,1                     ; zapnut¡ hradla ‡¡ta‡e
         out       [61h],al
         xor       ax,ax                    ; AX <- 0

; ------ skok na obsluhu testu

         jmp       far ptr ExecStrt         ; start mˆ©en¡

; ====== n vrat z obsluhy testu

; ------ vypnut¡ ‡¡ta‡e hodin

ExecRet: in        al,[61h]
         and       al,not 3
         out       [61h],al                 ; vypnut¡ ‡¡ta‡e reproduktoru

; ------ ‡ten¡ hodin

         in        al,[42h]                 ; konstanta LOW
         mov       ah,al                    ; £schova konstanty LOW
         in        al,[42h]                 ; konstanta HIGH
         xchg      al,ah                    ; oprava po©ad¡ bajt–
         neg       ax                       ; ubˆhl˜ po‡et takt– hodin

; ------ n vrat ukazatele z sobn¡ku

         mov       ss,cs:[RegSS]            ; n vrat registru SS
         mov       sp,cs:[RegSP]            ; n vrat registru SP
         push      cs
         pop       ds                       ; DS <- datov˜ segment

; ------ n vrat nastaven¡ ‡¡ta‡e reproduktoru

         push      ax
         mov       al,0b6h                  ; povel
         out       [43h],al
         mov       al,5                     ; konstanta asi tak 920 Hz
         out       [42h],al                 ; konstanta - n¡‘¨¡ bajt
         out       [42h],al                 ; konstanta - vy¨¨¡ bajt

; ------ n vrat nastaven¡ CACHE pamˆti pro 80386 a vy¨¨¡

         cmp       byte ptr ds:[TypCPU],8   ; procesor 80386 a vy¨¨¡ ?
         jb        Execute6                 ; je mal˜ typ procesoru
.386p
         mov       eax,ds:[RegCR0]
         mov       cr0,eax
.8086
Execute6:pop       ax
         sub       ax,ds:[KorDob]           ; korekce namˆ©en‚ doby
         sti                                ; p©eru¨en¡ povoleno
         ret

Execute  ENDP

; -----------------------------------------------------------------------------
;        sestaven¡ CX opakov n¡ instrukc¡ DS:SI
; -----------------------------------------------------------------------------

PrepIns  PROC      NEAR

; ------ £schova registr–

         push      cx
         push      di
         push      es

; ------ p©¡prava registr–

         mov       di,SEG ProgS             ; segment programu
         mov       es,di                    ; segment programu
         xor       di,di                    ; za‡ tek segmentu

; ------ dek¢dov n¡ inicializa‡n¡ ‡ sti

         push      si
         mov       si,offset InitIns        ; inicializa‡n¡ ‡ st programu
         call      StorIns                  ; dek¢dov n¡ instrukc¡
         pop       si

; ------ dek¢dov n¡ zadan˜ch instrukc¡

PrepIns2:call      StorIns                  ; dek¢dov n¡ instrukc¡
         loop      Prepins2                 ; dal¨¡ skupina

; ------ ulo‘en¡ instrukce pro n vrat z testu (zde je CLD)

         mov       al,0eah                  ; instrukce JMP FAR
         stosb
         mov       ax,offset ExecRet        ; offset n vratov‚ adresy
         stosw
         mov       es:[di],cs               ; segment n vratov‚ adresy

; ------ n vrat registr–

         pop       es
         pop       di
         pop       cx
         ret

PrepIns  ENDP

; -----------------------------------------------------------------------------
;        ulo‘en¡ posloupnosti instrukc¡ DS:SI do bufferu ES:DI (-> posouv  DI)
; -----------------------------------------------------------------------------

StorIns  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      si

; ------ na‡ten¡ p©¡znakov‚ho bajtu

         cld
StorIns2:lodsb                              ; na‡ten¡ p©¡znakov‚ho bajtu

; ------ test, zda je konec instrukc¡

         or        al,al                    ; je konec instrukc¡ ?
         js        StorIns9                 ; je konec instrukc¡

; ------ ulo‘en¡ platn‚ho bajtu

         jnz       StorIns3                 ; nen¡ platn˜ bajt
         movsb                              ; p©enos platn‚ho bajtu
         jmp       short StorIns2           ; dal¨¡ data

; ------ ulo‘en¡ relokovan‚ho slova

StorIns3:cmp       al,1                     ; je kladn  relokace ?
         jne       StorIns4
         lodsw                              ; relokovan‚ slovo
         add       ax,di                    ; relokace
         stosw                              ; ulo‘en¡ slova
         jmp       short StorIns2           ; dal¨¡ data

; ------ ulo‘en¡ z porn‚ho relokovan‚ho slova

StorIns4:lodsw                              ; relokovan‚ slovo
         add       ax,di                    ; relokace
         neg       ax                       ; negaxe
         stosw                              ; ulo‘en¡ slova
         jmp       short StorIns2           ; dal¨¡ data

; ------ n vrat registr–

StorIns9:pop       si
         pop       ax
         ret

StorIns  ENDP

; -----------------------------------------------------------------------------
;        detekce typu procesoru
; -----------------------------------------------------------------------------

DetCPU   PROC      NEAR

         call      GetProc                  ; poskytnut¡ typu procesoru
         mov       ds:[TypCpu],ax           ; typ procesoru
         ret

DetCPU   ENDP

; -----------------------------------------------------------------------------
;        detekce procesoru -> AX
; -----------------------------------------------------------------------------
;          0=nezn m˜
;          1=Intel 8088
;          2=Intel 8086
;          3=NEC V20
;          4=NEC V30
;          5=Intel 80188
;          6=Intel 80186
;          7=Intel 80286
;          8=Intel 80386 DX
;          9=Intel 80386 SX
;         10=Intel 80486
; -----------------------------------------------------------------------------

GetProc  PROC      NEAR

         push      ds
         pop       es

; ------ rozli¨en¡ hranice  8088 a‘ V30 / 80186 a v˜¨e

         pushf                              ; £schova registru p©¡znak–
         xor       ax,ax                    ; AX <- 0
         push      ax                       ; 0 -> stack
         popf                               ; F <- 0
         pushf                              ; F -> stack
         pop       ax                       ; AX <- F
         popf                               ; n vrat p©¡znak–
         and       ax,0f000h                ; test bit– 12 a‘ 15
         cmp       ax,0f000h                ; jsou napevno nastaveny na 1 ?
         jne       GetProc2                 ; nejsou nast. - je 80186 nebo vyssi

; ------ je 8088 a‘ V30 - rozli¨en¡ hranice 8088,8086 / V20,V30

         xor       al,al                    ; nastaven¡ p©¡znaku ZY
         mov       al,40h                   ; n soben‚ ‡¡slo
         mul       al                       ; vyn soben¡ 40h*40h
         mov       ax,1                     ; procesor 8088,8086
         jnz       GetProc1                 ; je procesor 8088,8086
         mov       ax,3                     ; nemˆn¡ ZF - je procesor V20, V30

; ------ test 8-bitov‚ sbˆrnice (rozli¨en¡ 8088,V20,80188 / 8086,V30,80186)

GetProc1:push      ax                       ; £schova k¢du procesoru
         EVEN                               ; nastaven¡ na sudou adresu
         mov       di,offset GetProca       ; konec testovac¡ posloupnosti
         std                                ; smˆr dol–
         mov       al,byte ptr cs:[GetProc9]; posledn¡ instrukce STI
         mov       cx,3                     ; po‡et bajt– k testu
         cli                                ; z kaz p©eru¨en¡
         rep       stosb                    ; p©epis isntrukc¡ STI
         cld                                ; n vrat smˆru dol–
         nop
         nop
GetProc8:nop                                ; sem se zap¡¨¡ 3 instrukce STI
         inc       cx                       ; u 8086 tato instrukce z–stane
GetProc9:sti
GetProca:sti
         pop       ax
         add       ax,cx                    ; korekce procesoru podle sbˆrnice
         ret

; ------ je 80186 a vy¨¨¡ - rozli¨en¡ 80188,80186 / 80286 a vy¨¨¡

GetProc2:push      sp                       ; ulo‘en¡ ukazatele z sobn¡ku
         pop       bx                       ; n vrat ‡¡sla, kter‚ se ulo‘ilo
         cmp       bx,sp                    ; ulo‘il se stav SP p©ed operac¡ ?
         mov       ax,5                     ; procesor 80188, 80186
         jne       GetProc1                 ; je procesor 80188, 80186

; ------ je 80286 a vy¨¨¡ - rozli¨en¡ 80286 / 80386 a vy¨¨¡

         pushf                              ; £schova registru p©¡znak–
         mov       ax,0f000h                ; AX <- F000h
         push      ax                       ; F000h -> stack
         popf                               ; F <- F000h
         pushf                              ; F -> stack
         pop       ax                       ; AX <- F
         popf                               ; n vrat registru p©¡znak–
         and       ax,0f000h                ; test bit– 12 a‘ 15
         jnz       GetProc3                 ; nejsou v¨echny 0 - nen¡ 80286
         mov       ax,7                     ; jsou napevno 0 - je procesor 80286
         ret

; ------ je 80386 a vy¨¨¡ - rozli¨en¡ 80386DX,80386SX / 80486

GetProc3:
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
         jnz       GetProc4                 ; nen¡ procesor 80486
         mov       ax,10                    ; procesor 80486
         ret

; ------ rozli¨en¡ 80386DX / 80386SX

GetProc4:
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
         mov       ax,8                     ; procesor 80386 DX
         jnz       GetProc5                 ; nen¡ procesor 80386 SX
         inc       ax                       ; je procesor 80386 SX (=9)
GetProc5:ret

GetProc  ENDP

; -----------------------------------------------------------------------------
;        mˆ©en¡ frekvence procesoru
; -----------------------------------------------------------------------------
;þ
ClckCpu  PROC      NEAR

         mov       al,byte ptr ds:[TypCpu]
         cmp       al,7
         jae       ClckCpu1                 ; je vy¨¨¡ typ procesoru OK
         ret

; ------ vypnut¡ CACHE pamˆti pro 80386 a vy¨¨¡

ClckCpu1:cli
         cmp       byte ptr ds:[TypCPU],8   ; procesor 80386 a vy¨¨¡ ?
         jb        ClckCpu2                 ; je mal˜ typ procesoru
.386p
         mov       eax,cr0
         mov       ds:[RegCR0],eax
         or        eax,40000000h            ; z kaz CACHE
         mov       cr0,eax
.8086
; ------ nastaven¡ dˆli‡ky reproduktoru

ClckCpu2:in        al,[61h]
         and       al,not 3
         mov       bl,al                    ; £schova stavu portu
         out       [61h],al                 ; vypnut¡ v˜stupu na reproduktor
         mov       al,0b4h
         out       [43h],al                 ; povel pro nastaven¡ frekvence
         mov       al,0
         out       [42h],al                 ; dˆlic¡ konstanta LOW
         jmp       $+2
         out       [42h],al                 ; dˆlic¡ konstanta HIGH

; ------ p©¡prava k mˆ©en¡ frekvence procesoru

         mov       di,8000h                 ; pomocn  konstanta
         mov       cx,10                    ; po‡et pr–chod– smy‡kou

; ------ start mˆ©en¡ rychlosti

         mov       ah,0
         mov       al,bl                    ; stav portu 61h
         or        al,1                     ; hradlo ‡¡ta‡e zapnuto
         EVEN                               ; zarovn n¡ na sudou adresu
         out       [61h],al                 ; zapnut¡ ‡¡ta‡e
         mov       al,0

; ------ proveden¡ po‘adovan‚ho mno‘stv¡ instrukc¡ MUL

ClckCpu3:rept      100                      ; 1 smy‡ka celkem asi 12 000 takt–
         mul       di                       ; 1 instrukce asi 120 takt–
         endm
         dec       cx
         jz        ClckCpu4                 ; 10 smy‡ek - asi 120 000 takt–
         jmp       ClckCpu3

; ------ vypnut¡ ‡¡ta‡e reproduktoru

ClckCpu4:mov       al,bl                    ; p–vodn¡ stav portu
         out       [61h],al                 ; vypnut¡ reproduktoru

; ------ ‡ten¡ dosa‘en‚ho stavu ‡¡ta‡e

         in        al,[42h]                 ; konstanta LOW
         mov       ah,al                    ; £schova konstanty LOW
         in        al,[42h]                 ; konstanta HIGH
         xchg      al,ah                    ; oprava po©ad¡ bajt–
         neg       ax                       ; ubˆhl˜ po‡et takt– hodin

; ------ n vrat nastaven¡ ‡¡ta‡e

         push      ax
         mov       al,0b6h                  ; povel
         out       [43h],al
         mov       al,5                     ; konstanta asi tak 920 Hz
         out       [42h],al                 ; konstanta - n¡‘¨¡ bajt
         out       [42h],al                 ; konstanta - vy¨¨¡ bajt
         pop       ax
                                            ; celkem doba asi 1 a‘ 50 ms
; frekvence 1193182 Hz (0.8381 us na impuls)
; - tj. asi 2000 a‘ 60000 impuls–
; v˜po‡et zhruba  f[MHz]= 120000 / (impulsu_hodin * 0.8381us)
;                             ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÙ
;                                   doba mereni v [us]
;
;    f[MHz*10] = 1 430 000 / impulsu_hodin


         cmp       ax,500
         jb        ClckCpu8                 ; je to nemˆ©iteln‚

         mov       bx,ds:[TypCpu]         ; procesor
         shl       bx,1
         shl       bx,1
         mov       cx,ds:[HodProc+bx]      ; dˆlic¡ konstanta pro hodiny
         mov       dx,ds:[HodProc+bx+2]

         xchg      ax,cx                    ; AX <- konstanta LOW

         div       cx                       ; p©epo‡et na kmito‡et

         cmp       ax,3                     ; minim ln¡ frekvence
         jb        ClckCpu8                 ; nemˆ©iteln‚

         mov       ds:[Hodiny],ax           ; frekvence - cel  ‡ st

         xor       ax,ax
         div       cx
         mov       cx,100
         mul       cx
         add       ax,7f60h
         adc       dx,0
ClckCpu6:cmp       dl,100
         jb        ClckCpu7
         sub       dl,100
         inc       word ptr ds:[Hodiny]
         jmp       short ClckCpu6
ClckCpu7:mov       ds:[HodinyD],dl          ; hodiny - desetiny

; ------ n vrat nastaven¡ CACHE pamˆti pro 80386 a vy¨¨¡

ClckCpu8:cmp       byte ptr ds:[TypCPU],8   ; procesor 80386 a vy¨¨¡ ?
         jb        ClckCpu9                 ; je mal˜ typ procesoru
.386p
         mov       eax,ds:[RegCR0]
         mov       cr0,eax
.8086
ClckCpu9:sti
         ret

ClckCpu  ENDP

; *****************************************************************************
;
;                   Dek¢dov n¡ parametr– v p©¡kazov‚m © dku
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        dek¢dov n¡ zadan˜ch parametr– (ES=segment PSP !)
; -----------------------------------------------------------------------------

Dekod    PROC      NEAR

; ------ p©¡prava k dek¢dov n¡ p©¡kazov‚ho © dku (ES=segment PSP)

         mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         mov       bl,es:[si-1]             ; d‚lka p©¡kazov‚ho © dku
         mov       bh,0
         mov       es:[si+bx],bh            ; ozna‡en¡ konce p©¡kazov‚ho © dku

; ------ dek¢dov n¡ inicializa‡n¡ ‡ sti instrukc¡

         mov       di,offset InitIns        ; buffer inicializa‡n¡ ‡ sti
         call      DekIns                   ; dek¢dov n¡ inicializa‡n¡ ‡ sti
         mov       ds:[InitNum],cx          ; po‡et bajt– inicializa‡n¡ ‡ sti

; ------ dek¢dov n¡ testovan‚ ‡ sti instrukc¡

         mov       di,offset TestIns        ; buffer testovan‚ ‡ sti
         call      DekIns                   ; dek¢dov n¡ testovan‚ ‡ sti
         mov       ds:[TestNum],cx          ; po‡et bajt– testovan‚ ‡ sti

; ------ dek¢dov n¡ referen‡n¡ ‡ sti instrukc¡

         mov       di,offset RefIns         ; buffer referen‡n¡ ‡ sti
         call      DekIns                   ; dek¢dov n¡ referen‡n¡ ‡ sti
         mov       ds:[RefNum],cx           ; po‡et bajt– referen‡n¡ ‡ sti

; ------ na‡ten¡ textu

         mov       di,offset Text           ; buffer textu
         call      DekSpc                   ; vypu¨tˆn¡ mezer
         call      DekChr                   ; na‡ten¡ znaku
         jc        Dekod6                   ; nen sleduje text - to nevad¡
         cmp       al,'"'
         jne       Dekod32                  ; nen sleduje text
Dekod2:  mov       al,es:[si]               ; znak z p©¡kazov‚ho © dku
         cmp       al," "
         jb        Dekod9                   ; konec textu
         inc       si                       ; zv˜¨en¡ ukazatele
         cmp       al,'"'
         je        Dekod3                   ; konec textu
         mov       ds:[di],al               ; ulo‘en¡ znaku do bufferu
         inc       di                       ; zv˜¨en¡ ukazatele bufferu
         jmp       short Dekod2             ; dal¨¡ znak

; ------ parametr - frekvence procesoru

Dekod3:  call      DekSpc
         call      DekChr
         jc        Dekod4
Dekod32: cmp       al,"/"
         stc
         jne       Dekod9
         call      DekSpc
         call      DekChr
         jc        Dekod9
         cmp       al,"C"
         stc
         jne       Dekod9
         call      DekNum                   ; na‡ten¡ ‡¡sla
         or        ax,ax
         stc
         jz        Dekod9
         mov       ds:[Hodiny],ax
         mov       byte ptr ds:[HodinyD],0

Dekod4:  sub       di,offset Text           ; po‡et ulo‘en˜ch znak–
         mov       ds:[TextNum],di          ; po‡et znak– v bufferu
         call      DekSpc                   ; n sleduje je¨tˆ nˆco ?
Dekod6:  cmc                                ; nic nesm¡ n sledovat

Dekod9:  ret

Dekod    ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ instrukc¡ ES:SI do bufferu DS:DI -> po‡et CX
; -----------------------------------------------------------------------------

DekIns   PROC      NEAR

         xor       cx,cx

; ------ na‡ten¡ jednoho bajtu HEX

DekIns2: call      DekBHex                  ; na‡ten¡ bajtu HEX
         jc        DekIns3                  ; nen¡ platn˜ znak HEX
         inc       cx                       ; ‡¡ta‡ bajt–
         mov       byte ptr ds:[di],0       ; p©¡znak dat
         inc       di
         mov       ds:[di],al               ; ulo‘en¡ bajtu dat
         inc       di
         jmp       short DekIns2            ; dal¨¡ data

; ------ na‡ten¡ znaku (mezery jsou vypu¨tˆny)

DekIns3: call      DekChr                   ; na‡ten¡ znaku
         jc        DekIns9                  ; nen¡ dal¨¡ znak

; ------ konec posloupnosti instrukc¡

         cmp       al,","
         je        DekIns9

; ------ znak "@" - segment programu

         cmp       al,"@"
         jne       DekIns4
         inc       cx
         inc       cx                       ; ‡¡ta‡ bajt–
         mov       byte ptr ds:[di],0       ; p©¡znak dat
         inc       di
         mov       ax,SEG ProgS             ; segment programu
         mov       ds:[di],al               ; segment programu LOW
         inc       di
         mov       byte ptr ds:[di],0       ; p©¡znak dat
         inc       di
         mov       ds:[di],ah               ; segment programu HIGH
         inc       di
         jmp       short DekIns2            ; dal¨¡ data

; ------ znak "$" - offset

DekIns4: cmp       al,"$"
         jne       DekIns5

         inc       cx
         inc       cx                       ; ‡¡ta‡ bajt–
         mov       byte ptr ds:[di],1       ; p©¡znak relokace
         inc       di
         call      DekWHex                  ; na‡ten¡ slova
         mov       ds:[di],ax               ; reloka‡n¡ offset
         inc       di
         inc       di
         jmp       short DekIns2            ; dal¨¡ data

; ------ znak "-" - z porn˜ offset

DekIns5: cmp       al,"-"
         jne       DekIns8
         call      DekSpc
         call      DekChr
         jc        DekIns9
         cmp       al,"$"
         jne       DekIns8

         inc       cx
         inc       cx                       ; ‡¡ta‡ bajt–
         mov       byte ptr ds:[di],2       ; p©¡znak z porn‚ relokace
         inc       di
         call      DekWHex                  ; na‡ten¡ slova
         mov       ds:[di],ax               ; reloka‡n¡ offset
         inc       di
         inc       di
         jmp       short DekIns2            ; dal¨¡ data

DekIns8: dec       si                       ; n vrat neplatn‚ho znaku
DekIns9: ret

DekIns   ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ slova HEX -> AX
; -----------------------------------------------------------------------------

DekWHex  PROC      NEAR

; ------ £schova registr–

         push      bx
         push      cx

; ------ p©¡prava registr–

         mov       cx,4                     ; maxim ln¡ po‡et ‡¡slic
         xor       bx,bx                    ; st©ada‡
         call      DekSpc                   ; vypu¨tˆn¡ mezer

; ------ na‡ten¡ znaku

DekWHex2:call      DekHx                    ; na‡ten¡ znaku HEX
         jc        DekWHex9                 ; nen¡ platn˜ znak

; ------ p©id n¡ znaku ke st©ada‡i

         shl       bx,1
         shl       bx,1
         shl       bx,1
         shl       bx,1
         or        bl,al                    ; p©id n¡ znaku ke st©ada‡i

; ------ dal¨¡ znak

         loop      DekWHex2                 ; dal¨¡ znak

; ------ n vrat registr–

DekWHex9:xchg      ax,bx                    ; AX <- na‡ten  hodnota
         pop       cx
         pop       bx
         ret

DekWHex  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ bajtu HEX -> AL (CY=nen¡ platn˜ znak)
; -----------------------------------------------------------------------------

DekBHex  PROC      NEAR

; ------ £schova registr–

         push      bx

; ------ vypu¨tˆn¡ mezer

         call      DekSpc                   ; vypu¨tˆn¡ mezer

; ------ na‡ten¡ prvn¡ho znaku

         call      DekHx                    ; na‡ten¡ prvn¡ho znaku
         jc        DekBHex8                 ; nen¡ platn˜ znak
         mov       bl,al                    ; BL <- £schova znaku

; ------ na‡ten¡ druh‚ho znaku

         call      DekHx                    ; na‡ten¡ druh‚ho znaku
         jc        DekBHex6                 ; nen¡ druh˜ znak

; ------ slou‡en¡ znak–

         shl       bl,1
         shl       bl,1
         shl       bl,1
         shl       bl,1                     ; posun prvn¡ho znaku
         or        bl,al                    ; p©id n¡ druh‚ho znaku

DekBHex6:mov       al,bl                    ; na‡ten¡ bajt
         clc                                ; p©¡znak operace OK
DekBHex8:pop       bx
         ret

DekBHex  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ znaku HEX
; -----------------------------------------------------------------------------

DekHx    PROC      NEAR

         call      DekChr                   ; na‡ten¡ znaku
         jc        DekHx9                   ; nen¡ dal¨¡ znak
         cmp       al,"0"
         jb        DekHx8                   ; nen¡ platn˜ znak
         cmp       al,"9"
         jbe       DekHx4                   ; je platn˜ znak
         cmp       al,"A"
         jb        DekHx8                   ; nen¡ platn˜ znak
         cmp       al,"F"
         ja        DekHx8                   ; nen¡ platn˜ znak
         sub       al,7                     ; korekce HEX znaku

DekHx4:  sub       al,"0"                   ; konverze na ‡¡slo
         ret

DekHx8:  dec       si                       ; n vrat znaku
         stc
DekHx9:  ret

DekHx    ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ ‡¡sla -> AX
; -----------------------------------------------------------------------------

DekNum   PROC      NEAR

         push      bx
         xor       bx,bx
         call      DekSpc
DekNum1: call      DekChr
         jc        DekNum8
         sub       al,"0"
         jb        DekNum7
         cmp       al,9
         ja        DekNum7
         mov       ah,0
         xchg      ax,bx
         mov       dx,10
         mul       dx
         add       bx,ax
         jmp       short DekNum1

DekNum7: dec       si
DekNum8: xchg      ax,bx
         pop       bx
         ret

DekNum   ENDP

; -----------------------------------------------------------------------------
;        vypu¨tˆn¡ mezer z p©¡kazov‚ho © dku ES:SI
; -----------------------------------------------------------------------------

DekSpc   PROC      NEAR

         call      DekChr                   ; na‡ten¡ znaku
         jc        DekSpc2                  ; konec
         je        DekSpc                   ; vypu¨tˆn¡ mezery
         dec       si                       ; n vrat platn‚ho znaku
DekSpc2: ret

DekSpc   ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ znaku z p©¡kazov‚ho © dku ES:SI
; -----------------------------------------------------------------------------

DekChr   PROC      NEAR

; ------ na‡ten¡ znaku

         mov       al,es:[si]               ; znak z p©¡kazov‚ho © dku
         inc       si                       ; zv˜¨en¡ ukazatele

; ------ konverze na velk‚ p¡smeno

         cmp       al,"a"
         jb        DekChr2
         cmp       al,"z"
         ja        DekChr2
         sub       al,32                    ; konverze na velk‚ p¡smeno

; ------ test, zda je platn˜ znak

DekChr2: cmp       al," "
         jae       DekChr3                  ; je platn˜ znak
         dec       si                       ; n vrat ukazatele znak–
DekChr3: ret

DekChr   ENDP

; *****************************************************************************
;
;                                   data
;
; *****************************************************************************
;þ
HelpTxt  db        'CPUTEST v1.0 - test rychlosti instrukci; (c) Miroslav Nemecek',13,10
         db        'Syntaxe:  CPUTEST  inicializace , test , [reference] [, "text"] [/Cn]',13,10
         db        '    inicializace ....... inicializacni cast programu (jednorazove',13,10
         db        '                         provedene instrukce pri startu od adresy 0)',13,10
         db        '    test ............... testovana cast programu (instrukce,',13,10
         db        '                         jejichz rychlost se ma detekovat)',13,10
         db        '    reference .......... referencni cast programu (instrukce,',13,10
         db        '                         jejichz rychlost se ma odecist od rychlosti',13,10
         db        '                         instrukci v testovane casti programu - bez',13,10
         db        '                         zadani tohoto parametru se nic neodecita)',13,10
         db        '    "text" ............. text k zobrazeni pred vypisem rychlosti',13,10
         db        '    /Cn ................ zadana rychlost procesoru (n=rychlost v MHz)',13,10
         db        13,10
         db        'Casti programu se zadavaji jako posloupnosti HEX dat (napr. 2A F6 ...).',13,10
         db        'Znak "@" se nahradi slovem - segment programu. Zapis "$offset" se nahradi',13,10
         db        'slovem vzniklym souctem aktualniho ukazatele instrukci a zadaneho offsetu HEX.',13,10
         db        'Zapis "-$offset" se nahradi zapornou hodnotou slova "$offset".',13,10
         db        13,10
         db        'Program navraci navratovy kod typu procesoru:',13,10
         db        '     1 ...... 8088         6 ...... 80186',13,10
         db        '     2 ...... 8086         7 ...... 80286',13,10
         db        '     3 ...... V20          8 ...... 80386 DX',13,10
         db        '     4 ...... V30          9 ...... 80386 SX',13,10
         db        '     5 ...... 80188       10 ...... 80486',13,10
         db        13,10
HelpTxt0 label     byte

CpuTxt1  db        'Detekovan procesor $'
CpuTxt2  db        ' MHz',13,10,'$'

CpuTxt   db        '???$'                   ; 0
         db        '8088$'                  ; 1
         db        '8086$'                  ; 2
         db        'V20$'                   ; 3
         db        'V30$'                   ; 4
         db        '80188$'                 ; 5
         db        '80186$'                 ; 6
         db        '80286$'                 ; 7
         db        '80386DX$'               ; 8
         db        '80386SX$'               ; 9
         db        '80486$'                 ; 10

DobaTxt  db        ' us, $'
DobaTxt1 db        ' takt',13,10,'$'
DobaTxt2 db        ' takty',13,10,'$'
DobaTxt3 db        ' taktu',13,10,'$'

; ------ definice instrukc¡
; 00 = p©¡znak dat, n sleduje 1 bajt platn˜ch dat
; 01 = p©¡znak relokace, n sleduje 1 slovo = offset relokace
; 02 = p©¡znak z porn‚ relokace, n sleduje 1 slovo = offset relokace
; 80 = konec dat

RegSS    dw        0                        ; uschovan˜ registr SS
RegSP    dw        0                        ; uschovan˜ registr SP
RegCR0   dd        0                        ; uschovan˜ registr CR0

TypCPU   dw        0                        ; typ detekovan‚ho procesoru
                                            ;   0=nezn m˜
                                            ;   1=Intel 8088
                                            ;   2=Intel 8086
                                            ;   3=NEC V20
                                            ;   4=NEC V30
                                            ;   5=Intel 80188
                                            ;   6=Intel 80186
                                            ;   7=Intel 80286
                                            ;   8=Intel 80386 DX
                                            ;   9=Intel 80386 SX
                                            ;  10=Intel 80486

HodProc  label     word                   ;* tabulka konstant pro hodiny
         dd        10000                    ;   0=nezn m˜
         dd        10000                    ;   1=Intel 8088
         dd        10000                    ;   2=Intel 8086
         dd        11000                    ;   3=NEC V20
         dd        13000                    ;   4=NEC V30
         dd        13000                    ;   5=Intel 80188
         dd        13000                    ;   6=Intel 80186
         dd        25254                    ;   7=80286 (ovˆ©eno na 12 MHz)
         dd        30110                    ;   8=80386 (ovˆ©eno na 40 MHz)
         dd        30110                    ;   9=80386 SX
         dd        31300                    ;  10=80486 (ovˆ©eno na 50 MHz)

CyklNum  dw        0                        ; po‡et testovac¡ch cykl–

KorDob   dw        0                        ; korekce namˆ©en‚ doby

TestDoba dw        0                        ; doba instrukce - cel  ‡ st
TestDobD dw        0                        ; doba instrukce - desetinn  ‡ st

; Pro 8088 frekvence 4.7727 MHz
Hodiny   dw        4                        ; hodiny procesoru
HodinyD  db        77                       ; hodiny procesoru - setiny

InitIns  db        120 dup(80h)             ; inicializa‡n¡ ‡ st
InitNum  dw        0                        ; po‡et bajt– inicializa‡n¡ ‡ sti

TestIns  db        120 dup(80h)             ; testovan  ‡ st
TestNum  dw        0                        ; po‡et bajt– testovan‚ ‡ sti

RefIns   db        120 dup(80h)             ; referen‡n¡ ‡ st
RefNum   dw        0                        ; po‡et bajt– referen‡n¡ ‡ sti

Text     db        120 dup(" ")             ; text k zobrazen¡
TextNum  dw        0                        ; d‚lka textu k zobrazen¡

Code     ENDS

; *****************************************************************************
;
;                        Segment testovan‚ho programu
;
; *****************************************************************************

ProgS    SEGMENT   PARA
ExecStrt db        0ffffh dup(?)
ProgS    ENDS

; *****************************************************************************
;
;                        Z sobn¡k testovan‚ho programu
;
; *****************************************************************************

ProgZ    SEGMENT   PARA
         db        0ffffh dup(?)
ProgZ    ENDS

; *****************************************************************************
;
;                                 Z sobn¡k
;
; *****************************************************************************

Zasobnik SEGMENT   'STACK' STACK
         dw        400h dup(?)
Zasobnik ENDS
         END       Start
