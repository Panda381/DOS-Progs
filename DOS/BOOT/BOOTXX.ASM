
code     segment
         assume    cs:code,ds:code

         org       100h

start:
         mov       ah,0dh
         int       21h
         xor       ah,ah
         xor       dl,dl
         int       13h

; ------ zji¨tˆn¡ ‡¡sla zadan‚ho disku

         mov       dx,offset zadtxt
         cmp       byte ptr ds:[80h],2
         jb        chyba
         mov       al,ds:[82h]              ; ‡¡slo mechaniky
         and       al,not 20h               ; korekce na velk‚ p¡smeno
         sub       al,"A"
         jc        chyba                    ; chyba zad n¡
         cmp       al,26
         jae       chyba                    ; chyba zad n¡
         mov       ds:[disk],al             ; ‡¡slo disku

; ------ test, zda je disk v˜mˆnn˜

         mov       bl,al                    ; ‡¡slo disku
         inc       bl
         mov       ax,4408h
         int       21h                      ; test, zda je m‚dium v˜mˆnn‚
         mov       dx,offset zadtxt
         jc        chyba                    ; chyba
         or        ax,ax                    ; je v˜mˆnn‚ ?
         jnz       chyba                    ; nen¡ v˜mˆnn‚

; ------ na‡ten¡ p–vodn¡ho zavadˆ‡e z disku

         mov       bx,offset buffer         ; buffer k na‡ten¡ sektoru
         mov       al,ds:[disk]
         mov       cx,1
         xor       dx,dx
         mov       ds:[zasob],sp
         int       25h
         mov       sp,ds:[zasob]
         mov       dx,offset writtxt
         jc        chyba

; ------ modifikace zavadˆ‡e

         cld
         mov       si,offset bootbeg
         mov       di,offset buffer
         mov       cx,3+8
         rep       movsb
         mov       si,offset boot1
         mov       di,offset boot1-bootbeg+buffer
         mov       cx,offset(bootend-boot1)
         rep       movsb

; ------ z pis zavadˆ‡e zpˆt na disk

         mov       bx,offset buffer         ; buffer k na‡ten¡ sektoru
         mov       al,ds:[disk]
         mov       cx,1
         xor       dx,dx
         mov       ds:[zasob],sp
         int       26h
         mov       sp,ds:[zasob]
         jnc       konec


chyba2:  mov       dx,offset writtxt

chyba:   mov       ah,9
         int       21h

konec:
         int       20h


zadtxt   db        'Zadejte oznaceni disketove mechaniky !',13,10,'$'
writtxt  db        'Chyba zapisu BOOT sektoru !',13,10,'$'

disk     db        0
zasob    dw        0                        ; £schova z sobn¡ku

; =============================================================================
;
; =============================================================================

bootbeg  label     byte

         jmp       boot1                    ; start zavadˆ‡e syst‚mu

Identif  db        'XXXXX1.0'               ; identifikace zavadˆ‡e

SektSize dw        200h                     ; (7C0B) velikost sektoru
SektBlok db        2                        ; (7C0D) po‡et sektor– na alok. blok
RezSekt  dw        1                        ; (7C0E) po‡et rezervovan˜ch sektor–
NumFAT   db        2                        ; (7C10) po‡et tabulek FAT
MaxRoot  dw        70h                      ; (7C11) max. po‡et polo‘ek ROOT
MaxSekt  dw        2d0h                     ; (7C13) max. po‡et sektor– disku
IdentMed db        0fdh                     ; (7C15) popisova‡ m‚dia
SektFAT  dw        2                        ; (7C16) po‡et sektor– na FAT
SektTrck dw        9                        ; (7C18) po‡et sektor– na stopu
NumHead  dw        2                        ; (7C1A) po‡et hlav disku
HidSekt  dd        0                        ; (7C1C) po‡et skryt˜ch sektor–
MaxSektH dd        0                        ; (7C20) po‡et sektor– na disku

BootDisk db        0                        ; (7C24) aktivn¡ disk
BootHead db        0                        ; (7C25) aktivn¡ hlava

IdentExt db        29h                      ; (7C26) identif. roz¨¡©. informac¡
SerNum   dw        1bc9h,425bh              ; (7C27) s‚riov‚ ‡¡slo

Jmeno    db        'NO NAME    '            ; jm‚no disku
Fat      db        'FAT12   '               ; jm‚no tabulky FAT




boot1:   cld

         sti

         xor       ax,ax
         mov       ds,ax



error:   mov       si,offset(errtxt-bootbeg+7c00h)
         mov       cx,offset(errtxt0-errtxt)
error1:  lodsb
         mov       ah,0eh
         mov       bx,7
         int       10h
         loop      error1

         xor       ax,ax
         int       16h

         int       19h

;0000:7C3E FA             CLI                     ; z kaz p©eru¨en¡
;0000:7C3F 33C0           XOR    AX,AX            ; AX <- 0
;0000:7C41 8ED0           MOV    SS,AX            ; SS <- 0 tento segment
;0000:7C43 BC007C         MOV    SP,7C00          ; ukazatel z sobn¡ku
;0000:7C46 16             PUSH   SS
;0000:7C47 07             POP    ES               ; ES <- 0
;0000:7C48 BB7800         MOV    BX,0078          ; ukazatel tabulky INT 1eh
;0000:7C4B 36C537         LDS    SI,SS:[BX]       ; adresa tabulky disk. param.
;
;0000:7C4E 1E             PUSH   DS               ; £schova adresy INT 1eh
;0000:7C4F 56             PUSH   SI               ; £schova adresy INT 1eh
;0000:7C50 16             PUSH   SS               ; £schova ukazatele na INT 1eh
;0000:7C51 53             PUSH   BX               ; £schova ukazatele na INT 1eh
;0000:7C52 BF3E7C         MOV    DI,7C3E          ; vlastn¡ tabulka parametr–
;0000:7C55 B90B00         MOV    CX,000B          ; d‚lka tabulky INT 1eh
;0000:7C58 FC             CLD                     ; smˆr nahoru
;0000:7C59 F3A4           REPZ   MOVSB            ; £schova tabulky INT 1eh
;0000:7C5B 06             PUSH   ES
;0000:7C5C 1F             POP    DS               ; DS <- 0
;0000:7C5D C645FE0F       MOV    Byte Ptr [DI-02],0F ; +9 ‡as p©¡tlaku hlavy
;0000:7C61 8B0E187C       MOV    CX,[7C18]        ; po‡et sektor– na stopu
;0000:7C65 884DF9         MOV    [DI-07],CL       ; +4 po‡et sektor– na stopu
;0000:7C68 894702         MOV    [BX+02],AX       ; segment INT 1eh <- 0
;0000:7C6B C7073E7C       MOV    Word Ptr [BX],7C3E ; ukazatel na vlastn¡ INT 1eh
;0000:7C6F FB             STI                     ; povolen¡ p©eru¨en¡
;0000:7C70 CD13           INT    13               ; reset diskov‚ho syst‚mu
;0000:7C72 7279           JC     7CED             ; chyba disku
;
;0000:7C74 33C0           XOR    AX,AX            ; AX <- 0
;0000:7C76 3906137C       CMP    [7C13],AX        ; po‡et sektor– je 4 bajty ?
;0000:7C7A 7408           JZ     7C84             ; po‡et sektor– 4 bajty
;0000:7C7C 8B0E137C       MOV    CX,[7C13]        ; po‡et sektor– (2 bajty)
;0000:7C80 890E207C       MOV    [7C20],CX        ; pracovn¡ po‡et sektor–
;0000:7C84 A0107C       * MOV    AL,[7C10]        ; po‡et tabulek FAT
;0000:7C87 F726167C       MUL    Word Ptr [7C16]  ; v˜po‡et sektor– FAT celkem
;0000:7C8B 03061C7C       ADD    AX,[7C1C]        ; p©i‡ten¡ skryt˜ch sektor–
;0000:7C8F 13161E7C       ADC    DX,[7C1E]        ; p©enos do vy¨¨¡ho slova
;0000:7C93 03060E7C       ADD    AX,[7C0E]        ; p©i‡ten¡ rezervovan˜ch sekt.
;0000:7C97 83D200         ADC    DX,+00           ; p©enos do vy¨¨¡ho slova
;0000:7C9A A3507C         MOV    [7C50],AX        ; po‡ te‡n¡ sektor adres ©e LOW
;0000:7C9D 8916527C       MOV    [7C52],DX        ; po‡ t. sektor adres ©e HIGH
;0000:7CA1 A3497C         MOV    [7C49],AX        ; po‡ te‡n¡ datov˜ sektor LOW
;0000:7CA4 89164B7C       MOV    [7C4B],DX        ; po‡ te‡n¡ datov˜ sektor HIGH
;0000:7CA8 B82000         MOV    AX,0020          ; po‡et bajt– na polo‘ku adres.
;0000:7CAB F726117C       MUL    Word Ptr [7C11]  ; v˜po‡et d‚lky adres ©e ROOT
;0000:7CAF 8B1E0B7C       MOV    BX,[7C0B]        ; d‚lka sektoru (v bajtech)
;0000:7CB3 03C3           ADD    AX,BX            ; zaokrouhlen¡ na sektor
;0000:7CB5 48             DEC    AX               ; - 1
;0000:7CB6 F7F3           DIV    BX               ; v˜po‡et sektor– ROOT adres ©e
;0000:7CB8 0106497C       ADD    [7C49],AX        ; v˜po‡et 1. datov‚ho sektoru
;0000:7CBC 83164B7C00     ADC    Word Ptr [7C4B],+00 ; p©enos do vy¨¨¡ho slova
;0000:7CC1 BB0005         MOV    BX,0500          ; adresa k na‡ten¡ ROOT adres.
;0000:7CC4 8B16527C       MOV    DX,[7C52]        ; sektor adres ©e HIGH
;0000:7CC8 A1507C         MOV    AX,[7C50]        ; sektor adres ©e LOW
;0000:7CCB E89200         CALL   7D60             ; nastaven¡ parametr–
;0000:7CCE 721D           JB     7CED             ; chyba p©ete‡en¡
;0000:7CD0 B001           MOV    AL,01            ; 1 sektor ke ‡ten¡
;0000:7CD2 E8AC00         CALL   7D81             ; na‡ten¡ sektoru adres ©e
;0000:7CD5 7216           JB     7CED             ; chyba ‡ten¡ sektoru
;0000:7CD7 8BFB           MOV    DI,BX            ; adresa s adres ©em
;0000:7CD9 B90B00         MOV    CX,000B          ; d‚lka jm‚na IO.SYS
;0000:7CDC BEE67D         MOV    SI,7DE6          ; jm‚no souboru IO.SYS
;0000:7CDF F3A6           REPZ   CMPSB            ; kontrola, zda je IO.SYS
;0000:7CE1 750A           JNZ    7CED             ; chyba - nen¡ IO.SYS
;0000:7CE3 8D7F20         LEA    DI,[BX+20]       ; adresa 2. polo‘ky adres ©e
;0000:7CE6 B90B00         MOV    CX,000B          ; d‚lka jm‚na MSDOS.SYS
;0000:7CE9 F3A6           REPZ   CMPSB            ; kontrola, zda je MSDOS.SYS
;0000:7CEB 7418           JZ     7D05             ; je MSDOS.SYS - d le
;
;                                                 ; chyba zav dˆn¡ syst‚mu
;0000:7CED BE9E7D       * MOV    SI,7D9E          ; text chyby syst‚mu
;0000:7CF0 E85F00         CALL   7D52             ; zobrazen¡ chybov‚ho textu
;0000:7CF3 33C0           XOR    AX,AX            ; AX <- 0 funkce vstupu znaku
;0000:7CF5 CD16           INT    16               ; ‡ek n¡ na stisk kl vesy
;0000:7CF7 5E             POP    SI               ; n vrat ukazatele na INT 1eh
;0000:7CF8 1F             POP    DS               ; n vrat ukazatele na INT 1eh
;0000:7CF9 8F04           POP    [SI]             ; n vrat p–vodn¡ adresy INT 1eh
;0000:7CFB 8F4402         POP    [SI+02]          ; n vrat p–vodn¡ adresy INT 1eh
;0000:7CFE CD19           INT    19               ; opakov n¡ zav dˆn¡ syst‚mu
;
;
;0000:7D00 58           * POP    AX               ; zru¨en¡ ‡¡ta‡e sektor–
;0000:7D01 58             POP    AX               ; zru¨en¡ ‡¡sla sektor– HIGH
;0000:7D02 58             POP    AX               ; zru¨en¡ ‡¡sla sektor– LOW
;0000:7D03 EBE8           JMP    7CED             ; chyba operace
;
;                                                 ; na‡ten¡ zavadˆ‡e IO.SYS
;                                                 ; VSTUP: DS:BX=adr. pol. IO.SYS
;
;0000:7D05 8B471A         MOV    AX,[BX+1A]       ; po‡ te‡n¡ alok. blok IO.SYS
;0000:7D08 48             DEC    AX
;0000:7D09 48             DEC    AX               ; ‡¡slo bloku relativnˆ
;0000:7D0A 8A1E0D7C       MOV    BL,[7C0D]        ; po‡et sektor– na alok. blok
;0000:7D0E 32FF           XOR    BH,BH            ; BX = po‡et sektor– na blok
;0000:7D10 F7E3           MUL    BX               ; v˜po‡et datov‚ho sektoru
;0000:7D12 0306497C       ADD    AX,[7C49]        ; prvn¡ sektor IO.SYS - LOW
;0000:7D16 13164B7C       ADC    DX,[7C4B]        ; prvn¡ sektor IO.SYS - HIGH
;
;0000:7D1A BB0007         MOV    BX,0700          ; BX=adresa k na‡ten¡ IO.SYS
;0000:7D1D B90300         MOV    CX,0003          ; po‡et sektor– ke ‡ten¡ IO.SYS
;0000:7D20 50           * PUSH   AX               ; £schova ‡¡sla sektoru LOW
;0000:7D21 52             PUSH   DX               ; £schova ‡¡sla sektoru HIGH
;0000:7D22 51             PUSH   CX               ; £schova ‡¡ta‡e sektor–
;0000:7D23 E83A00         CALL   7D60             ; v˜po‡et sekt., v lce a hlavy
;0000:7D26 72D8           JB     7D00             ; chyba - p©ete‡en¡
;0000:7D28 B001           MOV    AL,01            ; po‡et sektor– ke ‡ten¡
;0000:7D2A E85400         CALL   7D81             ; na‡ten¡ 1 sektoru do pamˆti
;0000:7D2D 59             POP    CX               ; n vrat ‡¡ta‡e sektor–
;0000:7D2E 5A             POP    DX               ; n vrat ‡¡sla sektoru HIGH
;0000:7D2F 58             POP    AX               ; n vrat ‡¡sla sektoru LOW
;0000:7D30 72BB           JB     7CED             ; chyba ‡ten¡ sektoru
;0000:7D32 050100         ADD    AX,0001          ; zv˜¨en¡ ‡¡sla sektoru LOW
;0000:7D35 83D200         ADC    DX,+00           ; p©enos do vy¨¨¡ho slova
;0000:7D38 031E0B7C       ADD    BX,[7C0B]        ; zv˜¨en¡ adresy ke ‡ten¡
;0000:7D3C E2E2           LOOP   7D20             ; ‡ten¡ dal¨¡ho sektoru
;0000:7D3E 8A2E157C       MOV    CH,[7C15]        ; popisova‡ m‚dia
;0000:7D42 8A16247C       MOV    DL,[7C24]        ; ‡¡slo disku
;0000:7D46 8B1E497C       MOV    BX,[7C49]        ; ‡¡slo dal¨¡ho sektoru LOW
;0000:7D4A A14B7C         MOV    AX,[7C4B]        ; ‡¡slo dal¨¡ho sektoru HIGH
;0000:7D4D EA00007000     JMP    0070:0000        ; start na‡ten‚ho modulu IO.SYS
;
;                                                 ; zobrazen¡ textu DS:SI
;
;0000:7D52 AC           * LODSB                   ; znak k zobrazen¡
;0000:7D53 0AC0           OR     AL,AL            ; je ji‘ konec textu ?
;0000:7D55 7429           JZ     7D80             ; je ji‘ konec textu
;0000:7D57 B40E           MOV    AH,0E            ; funkce zobrazen¡ znaku
;0000:7D59 BB0700         MOV    BX,0007          ; str nka 0, barva 7
;0000:7D5C CD10           INT    10               ; zobrazen¡ znaku
;0000:7D5E EBF2           JMP    7D52             ; zobrazen¡ dal¨¡ho znaku
;
;
;                                                 ; v˜po‡et sekt., v lce a hlavy
;                                                 ; VSTUP: DX:AX=‡¡slo sektoru
;
;0000:7D60 3B16187C       CMP    DX,[7C18]        ; vzniklo by p©ete‡en¡ dˆlen¡ ?
;0000:7D64 7319           JAE    7D7F             ; bylo by p©ete‡en¡
;0000:7D66 F736187C       DIV    Word Ptr [7C18]  ; v˜po‡et stopy a ‡¡sla sektoru
;0000:7D6A FEC2           INC    DL               ; ‡¡slo sektoru ke ‡ten¡
;0000:7D6C 88164F7C       MOV    [7C4F],DL        ; ‡¡slo sektoru ke ‡ten¡
;0000:7D70 33D2           XOR    DX,DX            ; DX <- 0
;0000:7D72 F7361A7C       DIV    Word Ptr [7C1A]  ; v˜po‡et hlavy a v lce
;0000:7D76 8816257C       MOV    [7C25],DL        ; ‡¡slo hlavy
;0000:7D7A A34D7C         MOV    [7C4D],AX        ; ‡¡slo v lce ke ‡ten¡
;0000:7D7D F8             CLC                     ; p©¡znak operace OK
;0000:7D7E C3             RET
;
;0000:7D7F F9           * STC                     ; chyba operace - p©ete‡en¡
;0000:7D80 C3           * RET
;
;
;                                                 ; na‡ten¡ sektor– do pamˆti
;                                                 ; VSTUP: AL=po‡et sektor–
;                                                 ;        ES:BX=adresa v pamˆti
;
;
;0000:7D81 B402           MOV    AH,02            ; funkce ‡ten¡ sektor–
;0000:7D83 8B164D7C       MOV    DX,[7C4D]        ; ‡¡slo v lce ke ‡ten¡
;0000:7D87 B106           MOV    CL,06            ; po‡et rotac¡
;0000:7D89 D2E6           SHL    DH,CL            ; vy¨¨¡ 2 bity ‡¡sla v lce
;0000:7D8B 0A364F7C       OR     DH,[7C4F]        ; p©idan¡ ‡¡sla sektoru
;0000:7D8F 8BCA           MOV    CX,DX            ; ‡¡slo v lce a sektoru
;0000:7D91 86E9           XCHG   CH,CL            ; ‡¡slo v lce a sektoru
;0000:7D93 8A16247C       MOV    DL,[7C24]        ; ‡¡slo disku
;0000:7D97 8A36257C       MOV    DH,[7C25]        ; ‡¡slo hlavy
;0000:7D9B CD13           INT    13               ; na‡ten¡ sektor– do pamˆti
;0000:7D9D C3             RET
;
;
;0000:7D9E                db     13,10,'Non-System disk or disk error'
;                         db     13,10,'Replace and press any key when ready'
;                         db     13,10,0
;
;0000:7DE6                db     'IO      SYS'
;0000:7DF1                db     'MSDOS   SYS'
;
;                         db     0,0
;
;                         db     55h,0aah


errtxt   db        'Chyba zavadeni systemu !',13,10
errtxt0  label     byte

         db        510 - (errtxt0-bootbeg) dup(0)


         db        55h,0aah                 ; identifik tor zav dˆc¡ho sektoru


bootend  label     byte


buffer   label     byte                     ; buffer pro na‡ten¡ sektoru


code     ends
         end       start
