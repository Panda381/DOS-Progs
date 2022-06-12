
Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; -----------------------------------------------------------------------------
;        konstanty
; -----------------------------------------------------------------------------

N        EQU       19                       ; velikost pole
EscCh    EQU       27                       ; znak ESC
CtrlC    EQU       3                        ; znak Ctrl-C
Return   EQU       13                       ; znak CR
Space    EQU       32                       ; znak mezery
AttackFactor EQU   4                        ; stupe§ £toánosti (1...16)
True     EQU       -1                       ; p©°znak pravdy
False    EQU       0                        ; p©°znak nepravdy

; ------ barvy

NormalColor EQU    15                       ; norm†ln° barva
BorderColor EQU    14                       ; barva r†mu
BoardColor  EQU    11                       ; barva desky
HeadingColor EQU   6                        ; barva z†hlav°
XColor   EQU       15                       ; barva k©°zku
OColor   EQU       10                       ; barva koleáka

; ------ typy kamenñ

Empty    EQU       -1                       ; p©°znak pr†zdnÇho pol°áka
Cross    EQU       0                        ; p©°znak k©°ëku
Nought   EQU       1                        ; p©°znak koleáka

; ------ smàry

Null     EQU       -1                       ; nen° smàr
Horiz    EQU       0                        ; horizont†ln° smàr
DownLeft EQU       1                        ; smàr vlevo dolñ
DownRight EQU      2                        ; smàr vpravo dolñ
Vert     EQU       3                        ; vertik†ln° smàr

Start:   jmp       Main

; -----------------------------------------------------------------------------
;        ukonáen° programu
; -----------------------------------------------------------------------------

Abort    PROC      NEAR

         call      ClrScr
         xor       dx,dx
         mov       ah,2
         mov       bh,0
         call      Int10P
         int       20h

Abort    ENDP

; -----------------------------------------------------------------------------
;        zobrazen° hrac° plochy
; -----------------------------------------------------------------------------

SetUpScreen PROC   NEAR

         call      WriteBoard
         mov       byte ptr ds:[TextColor],NormalColor ; barva p°smene
         ret

SetUpScreen ENDP

; -----------------------------------------------------------------------------
;        zobrazen° hrac° plochy
; -----------------------------------------------------------------------------

WriteBoard PROC    NEAR

         mov       byte ptr ds:[Pozice],0
         mov       byte ptr ds:[Radek],0
         call      WriteLetters             ; zobrazen° p°smen

         mov       byte ptr ds:[J],N
         mov       byte ptr ds:[S1],"⁄"
         mov       byte ptr ds:[S2],"ƒ"
         mov       byte ptr ds:[S3],"¬"
         mov       byte ptr ds:[S4],"ƒ"
         mov       byte ptr ds:[S5],"ø"
         call      WriteBoardLine

         dec       byte ptr ds:[J]
         mov       byte ptr ds:[S1],"√"
         mov       byte ptr ds:[S2],"ƒ"
         mov       byte ptr ds:[S3],"≈"
         mov       byte ptr ds:[S4],"ƒ"
         mov       byte ptr ds:[S5],"¥"
         mov       cx,N-2
WriteBr2:push      cx
         call      WriteBoardLine
         pop       cx
         dec       byte ptr ds:[J]
         loop      WriteBr2

         mov       byte ptr ds:[S1],"¿"
         mov       byte ptr ds:[S2],"ƒ"
         mov       byte ptr ds:[S3],"¡"
         mov       byte ptr ds:[S4],"ƒ"
         mov       byte ptr ds:[S5],"Ÿ"
         call      WriteBoardLine

         call      WriteLetters
         ret

WriteBoard ENDP

; -----------------------------------------------------------------------------
;        z†pis p°smen na ©†dku
; -----------------------------------------------------------------------------

WriteLetters PROC  NEAR

         mov       byte ptr ds:[TextColor],BorderColor ; barva p°smene
         call      WriteSpc                 ; zobrazen° mezery
         call      WriteSpc

         mov       al,"A"
WriteLe1:call      WriteSpc
         call      Write
         inc       ax
         cmp       al,"A"+N
         jne       WriteLe1

         call      WriteLN
         ret

WriteLetters ENDP

; -----------------------------------------------------------------------------
;        z†pis ©†dku hrac° plochy
; -----------------------------------------------------------------------------

WriteBoardLine PROC NEAR

         mov       byte ptr ds:[TextColor],BorderColor ; barva p°smene

         mov       ah,0
         mov       al,ds:[J]
         mov       cl,2                     ; poáet pozic
         call      WriteNum                 ; zobrazen° á°sla ©†dku

         call      WriteSpc

         mov       byte ptr ds:[TextColor],BoardColor ; barva pole

         mov       al,ds:[s1]               ; levò okraj
         call      Write

         mov       cx,N-2
WriteBl2:mov       al,ds:[s2]
         call      Write
         mov       al,ds:[s3]
         call      Write
         loop      WriteBl2

         mov       al,ds:[s4]
         call      Write
         mov       al,ds:[s5]
         call      Write

         mov       byte ptr ds:[TextColor],BorderColor ; barva p°smene

         call      WriteSpc
         mov       ah,0
         mov       al,ds:[J]
         mov       cl,2
         call      WriteNum

         call      WriteLN
         ret

WriteBoardLine ENDP

; -----------------------------------------------------------------------------
;        zobrazen° tahu (AH=k†men, DL=index pozice, DH=index ©†dku)
; -----------------------------------------------------------------------------

PrintMove PROC     NEAR

         mov       al,OColor
         cmp       ah,Nought
         je        PrintMv1
         mov       al,XColor
PrintMv1:mov       ds:[TextColor],al

         mov       byte ptr ds:[Pozice],48
         mov       byte ptr ds:[Radek],8

         mov       al,"O"
         cmp       ah,Nought
         je        PrintMv2
         mov       al,"X"
PrintMv2:call      Write

         call      WriteSpc
         mov       ah,0
         mov       al,dl                    ; pozice X
         add       al,"A"-1
         call      Write

         mov       al,dh
         mov       cl,2
         call      WriteNum

         call      CLREol




         ret

PrintMove ENDP

; -----------------------------------------------------------------------------
;        vymaz†n° zobrazenÇho tahu
; -----------------------------------------------------------------------------

ClearMove PROC     NEAR

         mov       byte ptr ds:[Pozice],48
         mov       byte ptr ds:[Radek],8
         mov       cx,80-48
ClearMo1:call      WriteSpc
         loop      ClearMo1
         ret

ClearMove ENDP

; -----------------------------------------------------------------------------
;        vymaz†n° hl†®en°
; -----------------------------------------------------------------------------

ClearMsg PROC      NEAR

         mov       byte ptr ds:[Radek],22
         mov       byte ptr ds:[Pozice],0
         mov       cx,80
ClearMs1:call      WriteSpc
         loop      ClearMs1
         ret

ClearMsg ENDP

; -----------------------------------------------------------------------------
;        zobrazen° povelu SI
; -----------------------------------------------------------------------------

WriteCommand PROC  NEAR

         mov       byte ptr ds:[TextColor],NormalColor
         cld
         lodsb
         call      Write
         mov       byte ptr ds:[TextColor],NormalColor-8
         call      WriteTxt
         ret

WriteCommand ENDP

; -----------------------------------------------------------------------------
;        resetov†n° hry (VSTUP: AL=p©°znak prvn°ho resetov†n°)
; -----------------------------------------------------------------------------

ResetGame PROC     NEAR

         call      SetUpScreen              ; inicializace obrazovky

         cmp       byte ptr ds:[FirstGame],TRUE
         jne       ResetGa4

         mov       byte ptr ds:[TextColor],HeadingColor ; barva
         mov       byte ptr ds:[Pozice],48
         mov       byte ptr ds:[Radek],0
         mov       si,offset Nadpis
         call      WriteTxt                 ; zobrazen° nadpisu

         mov       byte ptr ds:[Pozice],48
         mov       byte ptr ds:[Radek],2
         mov       si,offset CommNeu
         call      WriteCommand
         mov       si,offset CommEnd
         call      WriteCommand
         mov       si,offset CommAut
         call      WriteCommand
         mov       si,offset CommSpi
         call      WriteCommand
         mov       si,offset CommTip
         call      WriteCommand

         mov       byte ptr ds:[Pozice],48
         mov       byte ptr ds:[Radek],4
         mov       si,offset NadpInf
         call      WriteCommand
;         call      WriteHelp

         mov       byte ptr ds:[FirstGame],FALSE
         jmp       short ResetGa5

ResetGa4:call      ClearMsg
         call      ClearMove

ResetGa5:
         mov       di,offset Board
         mov       cx,N*N
         mov       al,EMPTY
         cld
         rep       stosb                    ; vymaz†n° hrac°ho pole

         xor       ax,ax
         mov       di,offset Value
         mov       cx,N*N*2
         rep       stosb                    ; vymaz†n° tabulky hodnot

         mov       cx,N*N*2*4
         mov       di,offset Line
         rep       stosb                    ; vymaz†n° poátu kamenñ

         mov       byte ptr ds:[Player],CROSS ; aktivn° hr†á - k©°ëek

         mov       word ptr ds:[TotalLines],2*2*(N*(N-4)+(N-4)*(N-4))
         mov       byte ptr ds:[GameWon],FALSE ; nen° vòhra
         ret

ResetGame ENDP



; -----------------------------------------------------------------------------
;        inicializace programu
; -----------------------------------------------------------------------------

Initialize PROC    NEAR

; ------ £schova aktivn°ho videom¢du

         mov       ah,0fh
         call      Int10P
         mov       ds:[OldVMod],al          ; pñvodn° videom¢d

; ------ inicializace videom¢du

         cmp       al,7
         je        Initial1
         mov       byte ptr ds:[AdrVRAM+1],0b8h
         cmp       al,2
         je        Initial1
         cmp       al,3
         je        Initial1
         mov       ax,3
         call      Int10P                   ; inicializace videom¢du
         jmp       short Initial2

; ------ vymaz†n° obrazovky

Initial1:call      ClrScr                   ; vymaz†n° obrazovky
         mov       ax,500h
         call      Int10P                   ; nastaven° str†nky 0

; ------ inicializace gener†toru n†hody

Initial2:call      Randomize                ; inicializace gener†toru n†hody

; ------ inicializace p©°znakñ

         mov       byte ptr ds:[AutoPlay],FALSE ; nen° automatick† hra
         mov       byte ptr ds:[FileRead],FALSE ; nen° n†povàda
         ret

Initialize ENDP

; -----------------------------------------------------------------------------
;        vymaz†n° obrazovky
; -----------------------------------------------------------------------------

ClrScr   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      di
         push      es

; ------ vymaz†n° obrazovky

         mov       es,ds:[AdrVRAM]
         xor       di,di
         mov       cx,80*55
         mov       ax,720h
         cld
         rep       stosw

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       cx
         pop       ax
         ret

ClrScr   ENDP

; -----------------------------------------------------------------------------
;        proveden° tahu
; -----------------------------------------------------------------------------

MakeMove PROC      NEAR

         mov       byte ptr ds:[WinningLine],NULL

         mov       byte ptr ds:[D],Horiz

         mov       byte ptr ds:[K],0
MakeMov1:mov       al,ds:[X]
         sub       al,ds:[K]
         jbe       MakeMv13
         cmp       al,N-4
         ja        MakeMv13
         mov       ds:[X1],al
         mov       al,ds:[Y]
         mov       ds:[Y],al

         call      Add0

         mov       cx,5



MakeMv13:inc       byte ptr ds:[K]
         cmp       byte ptr ds:[K],4
         jbe       MakeMov1






         ret

MakeMove ENDP

; -----------------------------------------------------------------------------
;        p©id†n° kamene (X1, Y1, Player, D smàr) -> BX=adresa v tabulce poátñ
; -----------------------------------------------------------------------------

Add0     PROC      NEAR

         mov       al,ds:[Y1]
         mov       ah,N
         mul       ah
         xchg      ax,bx
         mov       al,ds:[X1]
         mov       ah,0
         add       bx,ax
         shl       bx,1
         shl       bx,1
         or        bl,ds:[D]                ; smàr
         add       bx,offset Line

         cmp       byte ptr ds:[Player],Cross
         je        Add00
         add       bx,4*N*N

Add00:   mov       al,ds:[bx]

         inc       ax
         cmp       al,1
         jne       Add01
         dec       word ptr ds:[TotalLines]

Add01:   cmp       al,5
         jb        Add02
         mov       byte ptr ds:[GameWon],TRUE

         cmp       byte ptr ds:[WinningLine],NULL
         jne       Add02

         mov       ah,ds:[D]
         mov       ds:[WinningLine],ah

Add02:   mov       ds:[bx],al
         ret

Add0     ENDP

; -----------------------------------------------------------------------------
;        aktualizace pole
; -----------------------------------------------------------------------------

UpDate   PROC      NEAR




         ret

UpDate   ENDP

; -----------------------------------------------------------------------------
;        vstup povelu
; -----------------------------------------------------------------------------

ReadCommand PROC   NEAR

ReadCom1:call      GoToSquare               ; zobrazen° kurzoru

         mov       ah,0
         int       16h

         cmp       al,"a"
         jb        ReadCom2
         cmp       al,"z"
         ja        ReadCom2
         sub       al,32
ReadCom2:mov       ds:[Command],al

         cmp       al,"?"
         jne       ReadCom3
;         call      Help
         jmp       short ReadCom1

ReadCom3:or        ax,ax
         jz        ReadCm32
         cmp       al,27
         je        ReadCm32
         cmp       al,CtrlC
         jne       ReadCom4
ReadCm32:mov       byte ptr ds:[Command],"E"
         jmp       short ReadCom9

ReadCom4:cmp       al,13
         je        ReadCm42
         cmp       al," "
         jne       ReadCom5
ReadCm42:mov       byte ptr ds:[Command],"P"
         jmp       short ReadCom9

ReadCom5:cmp       al,0
         jne       ReadCom6

         mov       al,"L"
         cmp       ah,"K"
         je        ReadCm52                 ; vlevo
         mov       al,"R"
         cmp       ah,"M"
         je        ReadCm52                 ; vpravo
         mov       al,"D"
         cmp       ah,"P"
         je        ReadCm52                 ; dolñ
         mov       al,"U"
         cmp       ah,"H"
         je        ReadCm52                 ; nahoru
;         mov       al,"7"
;         cmp       ah,"G"
;         je        ReadCm52                 ; Home
;         mov       al,"9"
;         cmp       ah,"I"
;         je        ReadCm52                 ; PgUp
;         mov       al,"1"
;         cmp       ah,"O"
;         je        ReadCm52                 ; End
;         mov       al,"3"
;         cmp       ah,"Q"
;         je        ReadCm52                 ; PgDn
         call      ClearBuff
ReadCm11:jmp       short ReadCom1
ReadCm52:mov       byte ptr ds:[Command],al
         jmp       short ReadCom9

ReadCom6:cmp       al,"N"
         je        ReadCom9
         cmp       al,"E"
         je        ReadCom9
         cmp       al,"A"
         je        ReadCom9
         cmp       al,"S"
         je        ReadCom9
         cmp       al,"T"
         je        ReadCom9

         call      ClearBuff                ; nulov†n° bufferu
         jmp       short ReadCm11

ReadCom9:ret

ReadCommand ENDP

; -----------------------------------------------------------------------------
;        nulov†n° bufferu kl†vesnice
; -----------------------------------------------------------------------------

ClearBuff PROC     NEAR

         mov       ah,1
         int       16h
         jz        ClearBf2
         mov       ah,0
         int       16h
         jmp       short ClearBuff
ClearBf2:ret

ClearBuff ENDP

; -----------------------------------------------------------------------------
;        zobrazen° kurzoru
; -----------------------------------------------------------------------------

GoToSquare PROC    NEAR

         mov       al,ds:[X]
         shl       al,1
         inc       ax
         mov       dl,al

         mov       al,N
         inc       ax
         sub       al,ds:[Y]
         mov       dh,al

         mov       ah,2
         mov       bh,0
         call      Int10P
         ret

GoToSquare ENDP

; -----------------------------------------------------------------------------
;        interpretace povelu
; -----------------------------------------------------------------------------

InterpretCommand PROC NEAR

         mov       al,ds:[Command]

; ------ "N" nov† hra

         cmp       al,"N"
         jne       InterCm2
         mov       byte ptr ds:[FirstGame],FALSE
         call      ResetGame
         mov       byte ptr ds:[X],(N+1)/2
         mov       byte ptr ds:[Y],(N+1)/2
         jmp       short InterCm9

; ------ "T" typ

InterCm2:cmp       al,"T"
         jne       InterCm3
;         call      FindMove
         jmp       short InterCm9

; ------ "L" vlevo

InterCm3:cmp       al,"L"
         jne       InterC32
         mov       ah,0
         mov       al,ds:[X]
         add       ax,N-2
         mov       cl,N
         div       cl
         inc       ah
         mov       ds:[X],ah
         jmp       short InterCm9

; ------ "R" vpravo

InterC32:cmp       al,"R"
         jne       InterC34
         mov       ah,0
         mov       al,ds:[X]
         mov       cl,N
         div       cl
         inc       ah
         mov       ds:[X],ah
         jmp       short InterCm9

; ------ "D" dolñ

InterC34:cmp       al,"D"
         jne       InterC36
         mov       ah,0
         mov       al,ds:[Y]
         add       ax,N-2
         mov       cl,N
         div       cl
         inc       ah
         mov       ds:[Y],ah
         jmp       short InterCm9

; ------ "U" nahoru

InterC36:cmp       al,"U"
         jne       InterCm4
         mov       ah,0
         mov       al,ds:[Y]
         mov       cl,N
         div       cl
         inc       ah
         mov       ds:[Y],ah
         jmp       short InterCm9

; ------ "A" automat

InterCm4:cmp       al,"A"
         jne       InterCm5
         mov       byte ptr ds:[AutoPlay],TRUE
         jmp       short InterCm9

InterCm5:


InterCm9:
         ret

InterpretCommand ENDP

; -----------------------------------------------------------------------------
;        tah hr†áe
; -----------------------------------------------------------------------------

PlayerMove PROC    NEAR

         mov       al,ds:[Y]
         mov       ah,N
         mul       ah
         mov       cl,ds:[X]
         mov       ch,0
         add       ax,cx
         xchg      ax,di
         cmp       byte ptr ds:[di+Board],EMPTY
         jne       PlayerM9

         call      MakeMove




PlayerM9:
         ret

PlayerMove ENDP

; -----------------------------------------------------------------------------
;        tah poá°taáe
; -----------------------------------------------------------------------------

ProgramMove PROC   NEAR


         ret

ProgramMove ENDP

; -----------------------------------------------------------------------------
;        hlavn° procedura
; -----------------------------------------------------------------------------
;˛
Main     PROC      NEAR

         call      Initialize               ; inicializace programu
         mov       byte ptr ds:[FirstGame],TRUE ; p©°znak prvn°ho resetov†n°
         call      ResetGame                ; resetov†n° hry

         mov       byte ptr ds:[X],(N+1)/2
         mov       byte ptr ds:[Y],(N+1)/2

Main1:   call      ReadCommand
         cmp       byte ptr ds:[GameOver],TRUE
         jne       Main12
         cmp       byte ptr ds:[Command],"E"
         je        Main12
         mov       byte ptr ds:[Command],"N"

Main12:  call      InterpretCommand

         cmp       byte ptr ds:[Command],"P"
         jne       Main2

         call      PlayerMove               ; tah hr†áe

Main2:   cmp       byte ptr ds:[Command],"S"
         je        Main23
         cmp       byte ptr ds:[Command],"A"
         jne       Main3
Main23:  call      ProgramMove

Main3:
         cmp       byte ptr ds:[Command],"E"
         jne       Main1

         call      Abort
         ret

Main     ENDP

; *****************************************************************************
;
;                             Intern° procedury
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;                               Randomize
;                  inicializace gener†toru n†hody
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------

Randomize PROC     NEAR

         push      ax
         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[46ch]             ; á°taá systÇmovÇho áasovaáe
         pop       ds
         mov       word ptr ds:[RandomR],ax ; inicializaán° konstanta
         pop       ax
         ret

Randomize ENDP

; -----------------------------------------------------------------------------
;                                 Random
;                       gener†tor n†hodnÇho á°sla
; -----------------------------------------------------------------------------
; VSTUP: AX=max. hodnota
;        DS=datovò segment
; VùSTUP: AX=á°slo 0 aë (max. hodnota - 1)
; -----------------------------------------------------------------------------

Random   PROC      NEAR

         push      bx
         push      dx
         or        ax,ax
         jz        Random1
         mov       bx,ax                    ; poëadovanò rozsah
         call      Random0                  ; generov†n° n†hodnÇho á°sla DX:AX
         xchg      ax,dx                    ; AX <- n†hodnÇ á°slo
         xor       dx,dx
         div       bx
         xchg      ax,dx
Random1: pop       dx
         pop       bx
         ret

Random   ENDP

; -----------------------------------------------------------------------------

Random0  PROC      NEAR

         push      bx
         push      cx
         mov       ax,word ptr ds:[RandomR]
         mov       bx,word ptr ds:[RandomR+2]
         mov       cx,ax
         mul       word ptr cs:[RandomD]
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
         pop       cx
         pop       bx
         ret

Random0  ENDP

; -----------------------------------------------------------------------------
;        vymaz†n° po zbytek ©†dku
; -----------------------------------------------------------------------------

CLREol   PROC      NEAR

CLREol1: cmp       byte ptr ds:[Pozice],80
         jae       CLREol2
         call      WriteSpc
         jmp       short CLREol1
CLREol2: ret

CLREol   ENDP

; -----------------------------------------------------------------------------
;        zobrazen° á°sla AX / CL pozic
; -----------------------------------------------------------------------------

WriteNum PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

         xor       si,si
         mov       ch,0
         jcxz      WriteNm7
         mov       bx,10
WriteNm1:xor       dx,dx
         div       bx
         add       dl,"0"
         push      dx
         inc       si
         dec       cx
         jz        WriteNm6
         or        ax,ax
         jnz       WriteNm1

WriteNm4:call      WriteSpc
         loop      WriteNm4

WriteNm6:pop       ax
         call      Write
         dec       si
         jnz       WriteNm6

WriteNm7:pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

WriteNum ENDP

; -----------------------------------------------------------------------------
;        p©echod na novò ©†dek
; -----------------------------------------------------------------------------

WriteLN  PROC      NEAR

         inc       byte ptr ds:[Radek]
         mov       byte ptr ds:[Pozice],0
         ret

WriteLN  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° mezery
; -----------------------------------------------------------------------------

WriteSpc PROC      NEAR

         push      ax
         mov       al," "
         call      Write
         pop       ax
         ret

WriteSpc ENDP

; -----------------------------------------------------------------------------
;        zobrazen° textu SI (ASCIIZ)
; -----------------------------------------------------------------------------

WriteTxt PROC      NEAR

WriteTx2:mov       al,ds:[si]
         inc       si
         cmp       al,0
         je        WriteTx3
         call      Write
         jmp       short WriteTx2

WriteTx3:ret

WriteTxt ENDP

; -----------------------------------------------------------------------------
;        zobrazen° znaku AL na pozici kurzoru
; -----------------------------------------------------------------------------

Write    PROC      NEAR

         push      ax
         push      bx
         push      es

         push      ax
         mov       al,160
         mul       byte ptr ds:[Radek]      ; p©epoáet ©†dkñ na offset
         xchg      ax,bx
         mov       al,ds:[Pozice]
         mov       ah,0
         shl       ax,1
         add       bx,ax                    ; offset
         pop       ax
         mov       es,ds:[AdrVRAM]
         mov       ah,ds:[TextColor]
         mov       es:[bx],ax               ; zobrazen° znaku

         inc       byte ptr ds:[Pozice]

         pop       es
         pop       bx
         pop       ax
         ret

Write    ENDP

; -----------------------------------------------------------------------------
;        vypnut° kurzoru
; -----------------------------------------------------------------------------

KurzOff  PROC      NEAR

         push      ax
         push      bx
         push      dx

         mov       ah,2
         mov       dx,25*256
         mov       bh,0
         call      Int10P

         pop       dx
         pop       bx
         pop       ax
         ret

KurzOff  ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 10h s £schovou registrñ
; -----------------------------------------------------------------------------

Int10P   PROC      NEAR

         pushf
         push      si
         push      di
         push      bp
         push      ds
         push      es

         int       10h

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         popf
         ret

Int10P   ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

; ------ gener†tor n†hody

RandomR  dd        21510d31h                ; promànn† pro gener†tor n†hody
RandomD  dw        8405h                    ; pomocn† konstanta

Nadpis   db        'T U R B O - G O M O K U',0
CommNeu  db        'Neu ',0
CommEnd  db        'Ende ',0
CommAut  db        'Auto ',0
CommSpi  db        'Spielen ',0
CommTip  db        'Tip',0
NadpInf  db        '?-fuer Information ',0

Weight   dw        0,0,4,20,100,500,0       ;

AdrVRAM  dw        0b000h                   ; adresa videopamàti



OldVMod  db        ?                        ; pñvodn° videom¢d

Board    db        N*N dup(?)               ; hrac° plocha (pozice * ©†dky)
Player   db        ?                        ; aktivn° hr†á
Oponent  db        ?                        ; protihr†á
TotalLines dw      ?                        ; celkovò poáet pr†zdnòch ©†dkñ
GameWon  db        ?                        ; p©°znak vòhry 1 hr†áe
FileRead db        ?                        ; p©°znak naáten° souboru n†povàdy
FirstGame db       ?                        ; p©°znak prvn° hry
GameOver db        ?                        ; p©°znak konce hry
WinningLine db     ?                        ; vòhern° smàr

Line     label     byte                     ; poáty kamenñ v jednom ©†dku
         dd        N * N dup(?)             ; hr†á 1 (k©°ëek), 4 smàry
         dd        N * N dup(?)             ; hr†á 2 (koleáko), 4 smàry

Value    label     byte                     ; hodnoty (hr†á 1 a hr†á 2)
         db        N * N dup(?)             ; hodnoty hr†áe 1 (k©°ëek)
         db        N * N dup(?)             ; hodnoty hr†áe 2 (koleáko)

X        db        ?,?                      ; sou©adnice X
Y        db        ?,?                      ; sou©adnice Y
Command  db        ?                        ; povel z kl†vesnice
AutoPlay db        ?                        ; p©°znak automatickÇ hry
K        db        ?
X1       db        ?
Y1       db        ?

; ------ lok†ln° promànnÇ - ResetGame

I        db        ?                        ; sou©adnice X
J        db        ?                        ; sou©adnice Y
D        db        ?                        ; smàr
C        db        ?                        ; barva hr†áe


S1       db        ?                        ; levò okraj
S2       db        ?                        ; vnit©n° oddàlovac° á†ra
S3       db        ?                        ; vnit©n° k©iëuj°c° znak
S4       db        ?                        ; prav† oddàlovac° á†ra
S5       db        ?                        ; pravò okraj

; ------ systÇmovÇ promànnÇ

TextColor db       ?                        ; barva textu
Pozice   db        ?                        ; pozice
Radek    db        ?                        ; ©†dek k vòstupu na displej

Code     ENDS
         END       Start
