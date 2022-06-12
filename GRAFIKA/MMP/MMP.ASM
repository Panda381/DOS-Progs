
; N vratov‚ k¢dy programu:
;           0 = v¨e OK, p©¡padn˜ BAT pokra‡uje
;           1 = ukon‡en¡ BAT kl vesou ESC nebo Ctrl-Break
;           2... = chyba...

bit0     EQU       1
bit1     EQU       2
bit2     EQU       4
bit3     EQU       8
bit4     EQU       10h
bit5     EQU       20h
bit6     EQU       40h
bit7     EQU       80h


Code     SEGMENT   PARA
         ASSUME    cs:Code,ds:Data,ss:Zasob

; ------ inicializace registr–

Start:   mov       ax,SEG Data
         mov       ds,ax
         mov       ds:[SegPSP],es           ; segment PSP programu

; ------ £schova aktivn¡ho videom¢du

         call      GetVMod                  ; poskytnut¡ aktu ln¡ho videom¢du
         mov       ds:[OldVMod],al          ; £schova aktivn¡ho videom¢du

; ------ detekce procesoru

         call      DetCPU                   ; detekce typu procesoru

; ------ p©¡prava p©¡kazov‚ho © dku

         mov       si,80h                   ; za‡ tek p©¡kazov‚ho © dku - 1
         mov       es,ds:[SegPSP]           ; segment PSP programu
         mov       bl,es:[si]               ; d‚lka p©¡kazov‚ho © dku
         mov       bh,0
         mov       es:[si+bx+1],bh          ; ozna‡en¡ konce p©¡kazov‚ho © dku

; ------ nalezen¡ za‡ tku jm‚na souboru

Start1:  inc       si                       ; zv˜¨en¡ ukazatele textu
         mov       al,es:[si]               ; znak z p©¡kazov‚ho © dku
         cmp       al,9
         je        Start1                   ; je tabul tor
         cmp       al," "
         je        Start1                   ; je mezera
         ja        Start2                   ; je platn˜ znak OK

; ------ zobrazen¡ textu chyby DS:SI

         mov       si,offset HelpTxt        ; text n povˆdy (nen¡ nic zad no)
Chyba:   mov       ax,SEG Data
         mov       ds,ax
         push      si
         call      RetVMod                  ; n vrat videom¢du
         call      DIniPort                 ; n vrat port–
         mov       si,offset UvTxt
         call      DispTxt                  ; zobrazen¡ £vodn¡ho textu
         pop       si
         call      DispTxt                  ; zobrazen¡ textu chyby

; ------ konec programu

         call      ClosFile                 ; uzav©en¡ vstupn¡ho souboru
         mov       ax,4c02h
         int       21h

; ------ nalezen¡ konce jm‚na souboru

Start2:  mov       dx,si                    ; DX <- za‡ tek jm‚na
Start3:  inc       si                       ; zv˜¨en¡ ukazatele textu
         cmp       byte ptr es:[si]," "
         ja        Start3                   ; nalezen¡ konce jm‚na souboru
         mov       byte ptr es:[si],0       ; ozna‡en¡ konce jm‚na souboru

; ------ nalezen¡ za‡ tku p©¡pony jm‚na souboru

         xor       cx,cx
         mov       di,offset Extens
Start31: cmp       cl,4
         jae       Start34
         dec       si
         inc       cx
         cmp       si,dx
         jb        Start34
         cmp       byte ptr es:[si],"\"
         je        Start34
         cmp       byte ptr es:[si],"."
         jne       Start31

; ------ £schova p©¡pony jm‚na souboru

Start32: inc       si
         mov       al,es:[si]
         cmp       al,"a"
         jb        Start33
         cmp       al,"z"
         ja        Start33
         sub       al,32
Start33: mov       ds:[di],al
         inc       di
         loop      Start32

; ------ otev©en¡ souboru pro ‡ten¡

Start34: push      ds
         mov       ds,ds:[SegPSP]           ; DS <- PSP
         mov       ax,3d00h
         int       21h                      ; otev©en¡ souboru pro ‡ten¡
         pop       ds
         mov       si,offset FndTxt         ; text - soubor nenalezen
         jc        Chyba0                   ; chyba - soubor nenalezen
         mov       ds:[SoubIdnt],ax         ; identifik tor souboru

; ------ zji¨tˆn¡ velikosti souboru

         xchg      ax,bx
         xor       cx,cx
         xor       dx,dx
         mov       ax,4202h
         int       21h                      ; nastaven¡ ukazatele na konec
         mov       word ptr ds:[SoubSize],ax ; velikost souboru
         mov       word ptr ds:[SoubSize+2],dx
         xor       cx,cx
         xor       dx,dx
         mov       ax,4200h
         int       21h                      ; resetov n¡ ukazatele souboru

; ------ zmen¨en¡ pamˆti programu na minimum (ES=segment PSP)

         mov       es,ds:[SegPSP]           ; segment PSP programu
         mov       bx,SEG KonSegm           ; segment konce programu
         sub       bx,ds:[SegPSP]           ; velikost segmentu programu
         mov       ah,4ah
         int       21h                      ; zmen¨en¡ bloku pamˆti (chyba nevad¡)

; ------ vytvo©en¡ maxim ln¡ho aloka‡n¡ho bloku

         mov       bx,-1
         mov       ah,48h
         int       21h                      ; poskytnut¡ maxim ln¡ho bloku
         mov       ah,48h
         int       21h                      ; p©idˆlen¡ aloka‡n¡ho bloku
         mov       si,offset MemTxt         ; text - chyba pamˆti
         jc        Chyba0                   ; chyba pamˆti

; ------ ulo‘en¡ parametr– bloku

         cmp       bx,1100h                 ; minim lnˆ asi 70 KB pamˆti
         jb        Chyba0                   ; chyba - nedostatek pamˆti
         mov       ds:[BuffAdr],ax          ; adresa segmentu
         mov       ds:[BuffSize],bx         ; velikost segmentu
         add       ax,bx
         mov       ds:[BuffEnd],ax          ; adresa konce segmentu

; ------ skok na obsluhu souboru

         mov       ax,word ptr ds:[Extens]  ; 1. a 2. znak jm‚na souboru
         mov       dh,ds:[Extens+2]         ; 3. znak jm‚na souboru
         mov       bx,offset TabSkok        ; tabulka skok– na obsluhu souboru

Start5:  cmp       ax,ds:[bx]               ; souhlas¡ 1. a 2. znak ?
         jne       Start6                   ; nesouhlas¡
         cmp       dh,ds:[bx+2]             ; souhlas¡ 3. znak ?
         jne       Start6                   ; nesouhlas¡
         jmp       word ptr ds:[bx+3]       ; skok na obsluhu souboru

Start6:  add       bx,5                     ; adresa dal¨¡ polo‘ky
         cmp       byte ptr ds:[bx],0       ; je konec tabulky ?
         jne       Start5                   ; nen¡ konec - dal¨¡ typ souboru
         mov       si,offset ZnamyTxt       ; text - nezn m˜ form t
Chyba0:  jmp       Chyba                    ; chybov‚ hl ¨en¡




; ------ ‡ek n¡ na zad n¡ znaku z kl vesnice

KonecCek:mov       ah,0
         int       16h
         or        ax,ax                    ; je Ctrl-Break ?
         jz        Konec1                   ; je Ctrl-Break
         cmp       al,27                    ; je ESC ?
         jne       Konec0                   ; nen¡ ESC

Konec1:  mov       al,1                     ; p©¡znak p©eru¨en¡ programu

; ------ ukon‡en¡ programu

Konec:   push      ax
         mov       ax,SEG Data
         mov       ds,ax
         call      ClosFile                 ; uzav©en¡ souboru
         call      RetVMod                  ; n vrat videom¢du
         call      DIniPort                 ; n vrat port–
         pop       ax

         mov       ah,4ch
         int       21h

Konec0:  mov       al,0                     ; n vratov˜ k¢d OK
         jmp       short Konec

; -----------------------------------------------------------------------------
;        detekce typu procesoru
; -----------------------------------------------------------------------------

DetCPU   PROC      NEAR

         and       byte ptr ds:[ParamPC],not bit0+bit1 ; p©ednastaven¡ - je 8086

; ------ test, zda je procesor 80286 a vy¨¨¡

         xor       ax,ax                    ; AX <- 0
         push      ax                       ; 0
         popf                               ; registr p©¡znak– <- 0
         pushf                              ; ‡ten¡ registru p©¡znak–
         pop       ax                       ; AX <- registr p©¡znak–
         cmp       ax,0f000h                ; jsou bity natvrdo 1 ?
         je        DetCPU9                  ; je procesor 8086/80186
         or        byte ptr ds:[ParamPC],bit0 ; p©¡znak procesoru 80286 a vy¨¨¡
         mov       word ptr cs:[FliPaltK],9090h ; vysl n¡ palet FLI - REP OUTSB

; ------ test, zda je procesor 80386 a vy¨¨¡

         mov       ah,0f0h                  ; AX = 0f000h
         push      ax                       ; 0f000h
         popf                               ; registr p©¡znak– <- 0f000h
         pushf                              ; ‡ten¡ registru p©¡znak–
         pop       ax                       ; AX <- registr p©¡znak–
         and       ah,0f0h                  ; jsou bity natvrdo 0 ?
         jz        DetCPU9                  ; je procesor 80286
         or        byte ptr ds:[ParamPC],bit1 ; p©¡znak procesoru 80386 a vy¨¨¡
DetCPU9: ret

DetCPU   ENDP

; -----------------------------------------------------------------------------
;        uzav©en¡ vstupn¡ho souboru
; -----------------------------------------------------------------------------

ClosFile PROC      NEAR

         mov       bx,ds:[SoubIdnt]         ; identifik tor souboru
         or        bx,bx                    ; je soubor otev©en ?
         jz        ClosFil9                 ; soubor nen¡ otev©en
         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru
         mov       word ptr ds:[SoubIdnt],0 ; p©¡znak uzav©en¡ souboru
ClosFil9:ret

ClosFile ENDP

; -----------------------------------------------------------------------------
;          na‡ten¡ ur‡en˜ch CX bajt– na ukl dac¡ adresu bufferu
;       nesm¡ p©et‚ct p©es konec bufferu ani p©es konec souboru !
; -----------------------------------------------------------------------------

ReadBuff PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      di
         push      es

; ------ adresa bufferu

         mov       ax,cx                    ; AX <- £schova po‡tu bajt– ke ‡ten¡
         les       di,ds:[BuffWrit]         ; ukl dac¡ adresa do bufferu
         call      ReadFile                 ; na‡ten¡ dat do bufferu
         cmp       ax,cx                    ; souhlas¡ po‡et bajt– ?
         jne       ReadFil1                 ; chyba ‡ten¡

; ------ posun adresy bufferu

         add       word ptr ds:[BuffNact],cx ; zv˜¨en¡ ukazatele na‡ten˜ch dat
         adc       word ptr ds:[BuffNact+2],0
         add       word ptr ds:[BuffWrit],cx ; zv˜¨en¡ adresy v bufferu
         mov       ax,word ptr ds:[BuffWrit] ; offset adresy
         and       word ptr ds:[BuffWrit],0fh ; normalizace offsetu adresy
         mov       cl,4
         shr       ax,cl                    ; p©evod na segment
         add       word ptr ds:[BuffWrit+2],ax ; p©enos do segmentu

; ------ n vrat registr–

         pop       es
         pop       di
         pop       cx
         pop       ax
         ret

ReadBuff ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ dat ze vstupn¡ho souboru do bufferu ES:DI, CX bajt– -> CX
; -----------------------------------------------------------------------------

ReadFile PROC      NEAR

         push      ax
         push      bx
         push      dx
         push      ds

         mov       dx,di
         mov       bx,ds:[SoubIdnt]         ; identifik tor souboru
         push      es
         pop       ds                       ; DS <- segment bufferu
         mov       ah,3fh
         int       21h                      ; na‡ten¡ souboru
         xchg      ax,cx                    ; CX <- po‡et na‡ten˜ch bajt–

         pop       ds
         pop       dx
         pop       bx
         pop       ax

         jnc       ReadFil2                 ; operace OK
ReadFil1:mov       si,offset ReadTxt
         jmp       Chyba                    ; chyba ‡ten¡ dat

ReadFil2:add       word ptr ds:[SoubUkaz],cx ; zv˜¨en¡ ukazatele ‡tec¡ho offsetu
         adc       word ptr ds:[SoubUkaz+2],0
         ret

ReadFile ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ ukazatele v ‡tec¡m souboru na DX:AX
; -----------------------------------------------------------------------------

UkazFile PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

         mov       word ptr ds:[SoubUkaz],ax
         mov       word ptr ds:[SoubUkaz+2],dx

         xchg      cx,dx                    ; CX <- ukazatel HIGH
         xchg      ax,dx                    ; DX <- ukazatel LOW
         mov       ax,4200h
         mov       bx,ds:[SoubIdnt]         ; identifik tor souboru
         int       21h                      ; nastaven¡ ukazatele v souboru
         jc        ReadFil1                 ; chyba

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

UkazFile ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ textu DS:SI (v datov‚m segmentu)
; -----------------------------------------------------------------------------

DispTxt  PROC      NEAR

         push      ax
         push      dx

         mov       dx,si                    ; DX <- adresa textu
         mov       ah,9
         int       21h                      ; zobrazen¡ textu

         pop       dx
         pop       ax
         ret

DispTxt  ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ videom¢du (CY=nenastaven)
; -----------------------------------------------------------------------------

SetVMod  PROC      NEAR

         mov       ax,13h
         call      Int10
         or        byte ptr ds:[ParamV],bit0 ; p©¡znak zmˆny videom¢du
         call      GetVMod                  ; zji¨tˆn¡ aktu ln¡ho videom¢du
         cmp       al,13h
         je        SetVMod9
         stc
SetVMod9:ret

SetVMod  ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ aktu ln¡ho videom¢du -> AL
; -----------------------------------------------------------------------------

GetVMod  PROC      NEAR

         mov       ah,0fh
         call      Int10                    ; poskytnut¡ videom¢du
         mov       ds:[VMod],al             ; aktu ln¡ videom¢d
         ret

GetVMod  ENDP

; -----------------------------------------------------------------------------
;        n vrat videom¢du
; -----------------------------------------------------------------------------

RetVMod  PROC      NEAR

         test      byte ptr ds:[ParamV],bit0 ; byl videom¢d zmˆnˆn ?
         jz        RetVMod9                 ; videom¢d nebyl zmˆnˆn
         mov       al,ds:[OldVMod]          ; p–vodn¡ videom¢d
         mov       ah,0
         call      Int10                    ; n vrat videom¢du
         call      GetVMod                  ; test videom¢du
         and       byte ptr ds:[ParamV],not bit0 ; p©¡znak - nen¡ zmˆna videom¢du
RetVMod9:ret

RetVMod  ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 10h s £schovou registr–
; -----------------------------------------------------------------------------

Int10    PROC      NEAR

         pushf
         push      si
         push      di
         push      ds
         push      es

         int       10h

         pop       es
         pop       ds
         pop       di
         pop       si
         popf
         ret

Int10    ENDP

; -----------------------------------------------------------------------------
;        zah jen¡ mˆ©en¡ ‡asu pro animaci
; -----------------------------------------------------------------------------

StrtWait PROC      NEAR

         push      ax
         jmp       short TimeWai4

StrtWait ENDP

; -----------------------------------------------------------------------------
;        ‡ek n¡ na dosa‘en¡ ‡asu jednoho kroku p©i animaci
; -----------------------------------------------------------------------------

TimeWait PROC      NEAR

         push      ax

TimeWai1:cli
         cmp       word ptr ds:[CitTime],0
         je        TimeWai4

         mov       ah,1
         int       16h
         sti
         jz        TimeWai1

TimeWai4:mov       ax,ds:[DeltTime]
         mov       ds:[CitTime],ax
         sti

         pop       ax
         ret

TimeWait ENDP

; -----------------------------------------------------------------------------
;        inicializace port–
; -----------------------------------------------------------------------------

InitPort PROC      NEAR

; ------ test, zda je ji‘ instalace

         mov       ax,word ptr cs:[Old08]
         or        ax,word ptr cs:[Old08+2]
         jnz       InitPrt6

; ------ £schova adresy INT 08h

         mov       ax,3508h
         int       21h
         mov       word ptr cs:[old08],bx
         mov       word ptr cs:[old08+2],es

; ------ instalace obsluhy INT 08h

         cli
         push      ds
         push      cs
         pop       ds
         mov       dx,offset Int08          ; adresa obsluhy INT 08h
         mov       ax,2508h
         int       21h
         pop       ds

; ------ inicializace port–

InitPrt6:cli
         mov       al,36h
         out       [43h],al
         mov       al,0                     ; dˆlic¡ konstanta hodin 16384
         out       [40h],al
         mov       al,40h
         out       [40h],al
         mov       al,20h
         out       [20h],al                 ; uvolnˆn¡ p©eru¨en¡
         sti
         ret

InitPort ENDP

; -----------------------------------------------------------------------------
;        odinstalov n¡ port–
; -----------------------------------------------------------------------------

DIniPort PROC      NEAR

         mov       ax,word ptr cs:[Old08]
         or        ax,word ptr cs:[Old08]
         jz        DIniPrt6

         cli
         mov       al,36h
         out       [43h],al
         mov       al,0
         out       [40h],al
         out       [40h],al
         mov       al,20h
         out       [20h],al

         push      ds
         lds       dx,cs:[Old08]
         mov       ax,2508h
         int       21h
         pop       ds
         xor       ax,ax
         mov       word ptr cs:[Old08],ax
         mov       word ptr cs:[Old08+2],ax
DIniPrt6:ret

DIniPort ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 08h
; -----------------------------------------------------------------------------

Int08    PROC      FAR

         push      ax
         push      ds

         mov       ax,SEG Data
         mov       ds,ax
         cmp       word ptr ds:[CitTime],0
         je        Int081
         dec       word ptr ds:[CitTime]

Int081:  dec       byte ptr ds:[CitInt08]
         jnz       Int082

         mov       al,ds:[IncInt08]
         mov       ds:[CitInt08],al

         pop       ds
         pop       ax
         jmp       dword ptr cs:[Old08]

Int082:  mov       al,20h
         out       [20h],al

         pop       ds
         pop       ax
         iret

Int08    ENDP

Old08    dd        0                        ; p–vodn¡ adresa INT 08h (0=nen¡)

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                               Obsluhy soubor–
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

INCLUDE  FLI.ASM

Code     ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                             Datov˜ segment
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
Data     SEGMENT   PARA PUBLIC

SegPSP   dw        0                        ; segment PSP programu

ParamV   db        0                        ; parametry videom¢du
                                            ;   bit 0: 1=videom¢d zmˆnˆn

ParamPC  db        0                        ; parametry po‡¡ta‡e
                                            ;   bit 0: 1=procesor 80286 a vy¨¨¡
                                            ;   bit 1: 1=procesor 80386 a vy¨¨¡

ParamBuf db        0                        ; parametry bufferu
                                            ;   bit 0: 1=soubor se nevejde cel˜
                                            ;   bit 1: 1=soubor je ji‘ na‡ten

UvTxt    db        'Multi-Media-Player V 0.11; (c) Miroslav Nemecek',13,10,'$'

HelpTxt  db        'Zadejte jmeno souboru k prehrani. Podporovane formaty:',13,10
         db        '     Animacni soubory:   FLI',13,10
         db        '     Graficke soubory:    -',13,10
         db        '      Zvukove soubory:    -',13,10
         db        '      Popisne soubory:    -',13,10
         db        'Parametry: /N ...... nemazat obrazovku pri ukonceni',13,10
         db        '           /Fxxx ... urceni typu souboru nezavisle na pripone',13,10
         db        '$'

FndTxt   db        'Chyba - zadany soubor nenalezen !',13,10,'$'
MemTxt   db        'Chyba - nedostatek pameti !',13,10,'$'
ZnamyTxt db        'Chyba - neznamy format souboru !',13,10,'$'
FormTxt  db        'Chyba - nepodporovany format souboru !',13,10,'$'
ReadTxt  db        'Chyba cteni dat ze souboru !',13,10,'$'

CardTxt  db        'Chyba - soubor vyzaduje grafickou kartu VGA !',13,10,'$'

; ------ tabulka skok– na obsluhu soubor–

TabSkok  db        'FLI'
         dw        SoubFli

         db        0

; ------ parametry videokarty

TypCard  db        0                        ; typ videokarty
                                            ;    1 ... HGC
                                            ;    2 ... CGA
                                            ;    3 ... EGA
                                            ;    4 ... VGA
                                            ;    5 ... SVGA

; ------ parametry videom¢du

OldVMod  db        3                        ; uschovan˜ p–vodn¡ videom¢d
VMod     db        3                        ; aktu ln¡ nastaven˜ videom¢d
AdrVRAM  dd        0                        ; adresa videopamˆti k v˜stupu
CelkSir  dw        320                      ; celkov  ¨¡©ka obrazovky (bod–)
CelkVys  dw        200                      ; celkov  v˜¨ka obrazovky (linek)
IncVAdr  dw        320                      ; p©¡rustek adresy na videolinku

; ------ parametry p©ehr va‡– - anim tor– (FLI)

Rychlost dw        0                        ; rychlost p©ehr v n¡ souboru
NumObr   dw        0                        ; celkov˜ po‡et obr zk–/krok–
CitObr   dw        0                        ; ukazatel ‡¡sla obr zku 1...

; ------ obsluha ‡asov n¡ obr zku

DeltTime dw        0                        ; p©¡rustek ‡asu kroku animace
CitTime  dw        0                        ; ‡¡ta‡ kroku animace (0=dal¨¡)
CitInt08 db        4                        ; ‡¡ta‡ kroku INT 08h
IncInt08 db        4                        ; modul p©¡rustku INT 08h

; ------ definice datov‚ho bufferu pro grafiku (animace)

BuffAdr  dw        0                        ; adresa datov‚ho bufferu (segment)
BuffSize dw        0                        ; velikost datov‚ho bufferu (odstavce)
BuffEnd  dw        0                        ; adresa konce bufferu (segment)
BuffWrit dd        0                        ; z pisov  adresa do bufferu
BuffBlok dw        0                        ; p©¡rustek bufferu-bajt– k na‡ten¡
BuffRead dd        0                        ; ‡tec¡ adresa z bufferu
BuffNact dd        0                        ; na‡ten  data ke zpracov n¡

; ------ definice vstupn¡ho souboru

SoubIdnt dw        0                        ; identifik tor souboru (0=neotev©en)
SoubSize dd        0                        ; velikost souboru
SoubUkaz dd        0                        ; ukazatel ‡tec¡ho offsetu ze souboru
Extens   db        4 dup(0)                 ; p©¡pona souboru (max. 3 znaky + 0)
Soubor   db        128 dup(?)               ; zadan˜ soubor

HeadBuf  db        256 dup(?)               ; buffer z hlav¡ souboru

Data     ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                                Z sobn¡k
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

Zasob    SEGMENT   stack
         dw        400h dup(?)
Zasob    ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                         Segment konce programu
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

KonSegm  SEGMENT
         db        ?
KonSegm  ENDS
         END       Start
