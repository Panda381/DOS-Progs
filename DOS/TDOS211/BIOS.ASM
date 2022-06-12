
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                 Modul TBIOS.SYS opera‡n¡ho syst‚mu TDOS V2.11
;                      (spou¨t¡ se od adresy 0070:0000)
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

AdrSeg_a EQU       70h
AdrSeg_b EQU       (offset(seg_a_k - seg_a_z)+0fh)/16 + AdrSeg_a

b_0005h  equ       5
b_0009h  equ       9
b_000Bh  equ       0Bh
b_000Dh  equ       0Dh
b_000Fh  equ       0Fh
b_0011h  equ       11h
b_0012h  equ       12h
;b_0F31h  equ       0F31h
;b_0F54h  equ       0F54h

a_00D0h  equ       0D0h
a_00D1h  equ       0D1h
a_3603h  equ       3603h
a_9301h  equ       9301h
a_9D01h  equ       9D01h
a_D401h  equ       0D401h
a_e302h  equ       0E302h

seg_a    segment   para
         assume    cs:seg_a, ds:seg_a
         org       0

seg_a_z  label     near
                                            ; ukazatel na ‡¡slo 1. winch.
start:   jmp       a_0B03                   ; start modulu TBIOS.SYS

         jmp       a_079F

         db        10 dup (0)

a_0010   dw        7                        ; atribut barev

         db        0, 4, 0
         db        0

a_0016   dd        00000h                   ; adresa po‘adavku za©¡zen¡

a_001A   dw        0                        ; ‡¡slo portu COM, LPT

; -----------------------------------------------------------------------------
;         Z hlav¡ standardn¡ch za©¡zen¡
; -----------------------------------------------------------------------------

; N slednosti za©¡zen¡:
;         CON
;         AUX
;         PRN
;         CLOCK$
;         disky
;         COM1
;         COM2
;         LPT1
;         LPT2
;         LPT3

                                          ;* ovlada‡ konzoly CON
a_001c   dw        a_002e                   ; adresa n sleduj¡c¡ho za©¡zen¡
         dw        70h
         dw        8013h                    ; atributy
         dw        a_014d                   ; adresa strategie
         dw        a_0158                   ; adresa p©eru¨en¡
         db        'CON     '               ; jm‚no za©¡zen¡

                                          ;* ovlada‡ p©¡dav. za©¡zen¡ AUX
a_002e   dw        a_0064                   ; adresa n sleduj¡c¡ho za©¡zen¡
         dw        70h
         dw        8000h                    ; atributy
         dw        a_014d                   ; adresa strategie
         dw        a_015d                   ; adresa p©eru¨en¡
         db        'AUX     '               ; jm‚no za©¡zen¡

                                          ;* ovlada‡ komun. za©¡zen¡ COM1
a_0040   dw        a_0052                   ; adresa n sleduj¡c¡ho za©¡zen¡
         dw        70h
a_0044   dw        8000h                    ; atributy
         dw        a_014d                   ; adresa strategie
         dw        a_015d                   ; adresa p©eru¨en¡
         db        'COM1    '               ; jm‚no za©¡zen¡

                                          ;* ovlada‡ komun. za©¡zen¡ COM2
a_0052   dw        a_0076                   ; adresa n sleduj¡c¡ho za©¡zen¡
         dw        70h
         dw        8000h                    ; atributy
         dw        a_014d                   ; adresa strategie
         dw        a_0162                   ; adresa p©eru¨en¡
         db        'COM2    '               ; jm‚no za©¡zen¡

                                          ;* ovlada‡ tiskov. za©¡zen¡ PRN
a_0064   dw        a_00ac                   ; adresa n sleduj¡c¡ho za©¡zen¡
         dw        70h
         dw        8000h                    ; atributy
         dw        a_014d                   ; adresa strategie
         dw        a_0169                   ; adresa p©eru¨en¡
         db        'PRN     '               ; jm‚no za©¡zen¡

                                          ;* ovlada‡ tiskov. za©¡zen¡ LPT1
a_0076   dw        a_0088                   ; adresa n sleduj¡c¡ho za©¡zen¡
         dw        70h
         dw        8000h                    ; atributy
         dw        a_014d                   ; adresa strategie
         dw        a_0169                   ; adresa p©eru¨en¡
         db        'LPT1    '               ; jm‚no za©¡zen¡

                                          ;* ovlada‡ tiskov. za©¡zen¡ LPT2
a_0088   dw        a_009a                   ; adresa n sleduj¡c¡ho za©¡zen¡
         dw        70h
         dw        8000h                    ; atributy
         dw        a_014d                   ; adresa strategie
         dw        a_016e                   ; adresa p©eru¨en¡
         db        'LPT2    '               ; jm‚no za©¡zen¡

                                          ;* ovlada‡ tiskov. za©¡zen¡ LPT3
a_009a   dd        -1                       ; adresa n sleduj¡c¡ho za©¡zen¡
         dw        8000h                    ; atributy
         dw        a_014d                   ; adresa strategie
         dw        a_0173                   ; adresa p©eru¨en¡
         db        'LPT3    '               ; jm‚no za©¡zen¡

                                          ;* ovlada‡ hodin. za©¡zen¡ CLOCK$
a_00ac   dw        a_00be                   ; adresa n sleduj¡c¡ho za©¡zen¡
         dw        70h
         dw        8008h                    ; atributy
         dw        a_014d                   ; adresa strategie
         dw        a_017a                   ; adresa p©eru¨en¡
         db        'CLOCK$  '               ; jm‚no za©¡zen¡

                                          ;* ovlada‡ diskov˜ch jednotek
a_00be   dw        a_0040                   ; adresa n sleduj¡c¡ho za©¡zen¡
         dw        70h
         dw        0000                     ; atributy
         dw        a_014d                   ; adresa strategie
         dw        a_017f                   ; adresa p©eru¨en¡
a_00c8   db        1                        ; celkov˜ po‡et log. disk–
         db        0,0,0,0,0,0,0          

; -----------------------------------------------------------------------------
;         Adresy tabulek obsluh za©¡zen¡
; -----------------------------------------------------------------------------
                                          ;* tabulka popis– za©¡zen¡

                                          ;* za©¡zen¡ CON
a_00d0   db        0bh                      ; max. povel
         dw        a_00df                   ; adresa tabulky obsluh

                                          ;* za©¡zen¡ AUX, COM1, COM2, COM3
a_00d3   db        0bh                      ; max. povel
         dw        a_00f3                   ; adresa tabulky obsluh

                                          ;* za©¡zen¡ CLOCK$
a_00d6   db        0bh                      ; max. povel
         dw        a_0109                   ; adresa tabulky obsluh

                                          ;* za©¡zen¡ PRN, LPT1, LPT2, LPT3
a_00d9   db        0bh                      ; max. povel
         dw        a_011d                   ; adresa tabulky obsluh

                                          ;* diskov‚ za©¡zen¡
a_00dc   db        0bh                      ; max. povel
         dw        a_0135                   ; adresa tabulky obsluh

; -----------------------------------------------------------------------------
;         Tabulky adres obsluh za©¡zen¡
; -----------------------------------------------------------------------------
                                          ;* adresy obsluh CON
a_00df   dw        a_01e3                   ; 0 (inicializace za©¡zen¡)
         dw        a_01e3                   ; 1 (kontrola m‚dia)
         dw        a_01e3                   ; 2 (vystavˆn¡ bloku BPB)
         dw        a_01bf                   ; 3 (vstup z kan lu IOCTL)!
         dw        a_0201                   ; 4 vstup - ‡ten¡ ze za©¡zen¡
         dw        a_0220                   ; 5 nedestruktivn¡ vstup
         dw        a_01e3                   ; 6 (statut vstupu)
         dw        a_0241                   ; 7 vypr zdnˆn¡ vstupu
         dw        a_0270                   ; 8 v˜stup - z pis na za©¡zen¡
         dw        a_0270                   ; 9 v˜stup s verifikac¡

                                          ;* adresy obsluh AUX a COM
a_00f3   dw        a_01e3                   ; 0 (inicializace za©¡zen¡)
         dw        a_01e3                   ; 1 (kontrola m‚aia)
         dw        a_01e3                   ; 2 (vystavˆn¡ bloku BPB)
         dw        a_01bf                   ; 3 (vstup z kan lu IOCTL)!
         dw        a_0293                   ; 4 vstup - ‡ten¡ ze za©¡zen¡
         dw        a_02b0                   ; 5 nedestruktivn¡ vstup
         dw        a_01e3                   ; 6 (statut vstupu)
         dw        a_02e4                   ; 7 vypr zdnˆn¡ vstupu
         dw        a_0308                   ; 8 v˜stup - z pis na za©¡zen¡
         dw        a_0308                   ; 9 v˜stup s verifikac¡
         dw        a_0323                   ; 0ah statut v˜stupu

                                          ;*adresy obsluh CLOCK$
a_0109   dw        a_01e3                   ; 0 (inicializace za©¡zen¡)
         dw        a_01e3                   ; 1 (kontrola m‚aia)
         dw        a_01e3                   ; 2 (vystavˆn¡ bloku BPB)
         dw        a_01bf                   ; 3 (vstup z kan lu IOCTL)!
         dw        a_039d                   ; 4 vstup - ‡ten¡ ze za©¡zen¡
         dw        a_01d0                   ; 5 nedestruktivn¡ vstup
         dw        a_01e3                   ; 6 (statut vstupu)
         dw        a_01e3                   ; 7 (vypr zdnˆn¡ vstupu)
         dw        a_03d8                   ; 8 v˜stup - z pis na za©¡zen¡
         dw        a_03d8                   ; 9 v˜stup s verifikac¡

                                          ;* adresy obsluh PRN a LPT
a_011d   dw        a_01e3                   ; 0 (inicializace za©¡zen¡)
         dw        a_01e3                   ; 1 (kontrola m‚aia)
         dw        a_01e3                   ; 2 (vystavˆn¡ bloku BPB)
         dw        a_01bf                   ; 3 (vstup z kan lu IOCTL)!
         dw        a_01d4                   ; 4 vstup - ‡ten¡ ze za©¡zen¡
         dw        a_01d0                   ; 5 nedestruktivn¡ vstup
         dw        a_01e3                   ; 6 (statut vstupu)
         dw        a_01e3                   ; 7 (vypr zdnˆn¡ vstupu)
         dw        a_0336                   ; 8 v˜stup - z pis na za©¡zen¡
         dw        a_0336                   ; 9 v˜stup s verifikac¡
         dw        a_035a                   ; 0ah statut v˜stupu
         dw        a_01e3                   ; 0bh (vypr zdnˆn¡ v˜stupu)

                                          ;* adresy obsluh disk. jednotek
a_0135   dw        a_0726                   ; 0 inicializace za©¡zen¡
         dw        a_073a                   ; 1 kontrola m‚dia
         dw        a_07cc                   ; 2 vystavˆn¡ bloku BPB
         dw        a_01bf                   ; 3 (vstup z kan lu IOCTL)!
         dw        a_083e                   ; 4 vstup - ‡ten¡ ze za©¡zen¡
         dw        a_01d0                   ; 5 nedestruktivn¡ vstup
         dw        a_01e3                   ; 6 (statut vstupu)
         dw        a_01e3                   ; 7 (vypr zdnˆn¡ vstupu)
         dw        a_084e                   ; 8 v˜stup - z pis na za©¡zen¡
         dw        a_0853                   ; 9 v˜stup s verifikac¡
         dw        a_01e3                   ; 0ah (statut v˜stupu)
         dw        a_01e3                   ; 0bh (vypr zdnˆn¡ v˜stupu)

; -----------------------------------------------------------------------------
;         Obsluha strategie za©¡zen¡
; -----------------------------------------------------------------------------
                                          ;* obsluha strategie za©¡zen¡
a_014d   PROC      FAR

         mov       word ptr cs:[a_0016],bx  ; adresa po‘adavku za©¡zen¡ LOW
         mov       word ptr cs:[a_0016+2],es ; adresa po‘adavku za©¡zen¡ HIGH
         retf

a_014d   ENDP

; -----------------------------------------------------------------------------
;         Obsluha p©eru¨en¡ za©¡zen¡
; -----------------------------------------------------------------------------
                                          ;* obsluha za©¡zen¡ CON
a_0158:  push      ax
         mov       al,0                     ; offset v tabulce adres
         jmp       short a_0182             ; obsluha za©¡zen¡

                                          ;* obsluha za©¡zen¡ AUX a COM1
a_015d:  push      ax
         mov       ah,0                     ; ‡¡slo portu COM1
         jmp       short a_0165

                                          ;* obsluha za©¡zen¡ COM2
a_0162:  push      ax
         mov       ah,1
a_0165:  mov       al,3                     ; offset v tabulce adres
         jmp       short a_0182             ; obsluha za©¡zen¡

                                          ;* obsluha za©¡zen¡ PRN a LPT1
a_0169:  push      ax
         mov       ah,0                     ; ‡¡slo portu LPT1
         jmp       short a_0176

                                          ;* obsluha za©¡zen¡ LPT2
a_016e:  push      ax
         mov       ah,1                     ; ‡¡slo portu LPT2
         jmp       short a_0176

                                          ;* obsluha za©¡zen¡ LPT3
a_0173:  push      ax
         mov       ah,2                     ; ‡¡slo portu LPT3
a_0176:  mov       al,9                     ; offset v tabulce adres
         jmp       short a_0182             ; obsluha za©¡zen¡

                                          ;* obsluha za©¡zen¡ CLOCK$
a_017a:  push      ax
         mov       al,6                     ; offset v tabulce adres
         jmp       short a_0182             ; obsluha za©¡zen¡

                                          ;* obsluha diskov‚ho za©¡zen¡
a_017f:  push      ax
         mov       al,0ch                   ; offset v tabulce adres


a_0182:  mov       byte ptr cs:[a_001A],ah  ; ‡¡slo portu LPT, COM
         cbw                                ; identifik tor za©¡zen¡
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es
         mov       si,ax                    ; identifik tor za©¡zen¡
         lds       bx,cs:[a_0016]           ; adresa po‘adavku za©¡zen¡
         mov       al,ds:[bx+2]             ; k¢d povelu
         cmp       al,cs:[a_00D0h+si]       ; max. povel
         ja        a_01BF                   ; chybn˜ povel
         cbw                                ; AX <- povel
         mov       bp,ax                    ; k¢d povelu
         mov       al,ds:[bx+1]             ; ‡¡slo disk. jednotky
         mov       ah,ds:[bx+0Dh]           ; popisova‡ m‚dia ...
         mov       cx,ds:[bx+12h]           ; po‡et bajt– nebo sektor–
         mov       dx,ds:[bx+14h]           ; ‡¡slo po‡ te‡n¡ho sektoru
         les       di,dword ptr ds:[bx+0Eh] ; adresa bufferu pro p©enos dat
         cld                                ; smˆr dol–
         push      cs                       
         pop       ds                       ; DS <- CS
         mov       si,ds:[a_00D1h+si]       ; adresa tabulky adres obsluh
         shl       bp,1                     ; k¢d povelu * 2
         jmp       word ptr ds:[bp+si]      ; skok na obsluhu za©¡zen¡

                                          ;* chyba - nezn m˜ povel
a_01BF:  mov       al,3                     ; chyba - nezn m˜ povel
         jmp       short a_01CC

                                          ;* chyba ‡ten¡ ze za©¡zen¡
a_01C3:  mov       al,0Bh
         jmp       short a_01C9              ; nastav. po‡tu zpracov. sektor–

                                          ;* chyba z pisu na za©¡zen¡
a_01C7:  mov       al,0Ah
a_01C9:  call      a_01F7                   ; nastav. po‡tu zpracov. sektor–

a_01CC:  mov       ah,81h                   ; p©¡znak chyby, akce provedena
         jmp       short a_01E5

                                          ;* za©¡zen¡ nep©ipraveno
a_01D0:  mov       ah,3                     ; chyba - za©¡zen¡ nep©ipraveno
         jmp       short a_01E5

                                          ;* disk. operace probˆhla OK
a_01d4:  lds       bx,cs:[a_0016]           ; adresa po‘adavku za©¡zen¡
         mov       word ptr ds:[bx+12h],0   ; nezbyl ‘ dn˜ sektor
         jmp       short a_01E3

                                          ;* operace probˆhla OK
a_01e0:  call      a_01f7                   ; nastav. po‡tu zpracov. sektor–

a_01E3:  mov       ah,1                     ; p©¡znak - akce provedena
a_01E5:  lds       bx,cs:[a_0016]           ; adresa po‘adavku za©¡zen¡
         mov       ds:[bx+3],ax             ; ulo‘en¡ n vratov‚ho slova
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         retf      

;==========================================================================
;        nastaven¡ po‡tu zpracovan˜ch sektor–
;==========================================================================

a_01F7   PROC      near

         lds       bx,cs:[a_0016]           ; adresa po‘adavku za©¡zen¡
         sub       [bx+12h],cx
         ret

a_01F7   ENDP

; -----------------------------------------------------------------------------
;         Obsluha za©¡zen¡ CON
; -----------------------------------------------------------------------------

a_0200   db        0                        ; uschovan  kl vesa z CON

                                          ;* 4:vstup - ‡ten¡ z CON
a_0201:  jcxz      a_021c                   ; nen¡ po‘adov n ‘ dn˜ znak
a_0203:  call      a_024D                   ; vyjmut¡ znaku z bufferu znak–
         jnz       a_0219                   ; byl uschov n nˆjak˜ znak
                                          ;* vstup znaku z kl vesnice BIOS
         mov       ah,0                   
         int       16h                      ; vstup znaku z kl vesnice
         call      a_0256                   ; test, zda je kl vesa PrtScr
         jnz       a_0219                   ; je kl vesa Print Screen
         or        ah,ah                    ; byla nˆjak  kl vesa ?
         jz        a_0203                   ; nebyla ‘ dn  kl vesa
         mov       ds:[a_0200],ah           ; uschov n¡ kl vesa
                                          ;* ulo‘en¡ p©ijat‚ho znaku
a_0219:  stosb                              ; ulo‘en¡ p©ijat‚ho znaku
         loop      a_0203                   ; vstup dal¨¡ho znaku
a_021c:  jmp       short a_01E3             ; n vrat z obsluhy OK
; -----------------------------------------------------------------------------
a_021E:  int       16h                      ; zru¨en¡ znaku Ctrl-Break

                                          ;* 5: nedestruktivn¡ vstup z CON
a_0220:  call      a_024D                   ; vyjmut¡ znaku z bufferu znak–
         mov       ds:[a_0200],al           ; £schova znaku zpˆt do bufferu
         jnz       a_0235                   ; je p©ipraven nˆjak˜ znak
         mov       ah,1                   
         int       16h                      ; test stavu kl vesnice
         jz        a_023F                   ; nen¡ p©ipraven znak
         call      a_0256                   ; test, zda je kl vesa PrtScr
         or        ax,ax                    ; je kl vesa Ctrl-Break ?
         jz        a_021E                   ; je Ctrl-Break: zru¨en¡, znovu
                                          ;* ulo‘en¡ p©ipraven‚ho znaku
a_0235:  lds       bx,cs:[a_0016]           ; adresa po‘adavku za©¡zen¡
         mov       ds:[bx+0Dh],al           ; ulo‘en¡ p©ipraven‚ho znaku
         jmp       short a_01E3             ; n vrat OK

a_023F:  jmp       short a_01D0             ; n vrat - za©¡z. nep©ipraveno
; -----------------------------------------------------------------------------
                                          ;* 7: vypr zdnˆn¡ vstupu
a_0241:  call      a_0260                   ; vypr zdnˆn¡ buff. kl vesnice
         jmp       short a_01E3             ; n vrat OK
; -----------------------------------------------------------------------------
                                          ;* obsluha INT 1bh (Ctrl-Break)
a_0246:  mov       cs:[a_0200],3            ; kl vesa Ctrl-C
                                          ;* obsluha INT 01h, 02h, 03h
a_024c:  iret

;==========================================================================
;        vyjmut¡ znaku z bufferu znak–
;==========================================================================

a_024D   PROC      near

         xor       al,al                    ; nulovac¡ bajt
         xchg      al,ds:[a_0200]           ; vyjmut¡ znaku z bufferu
         or        al,al                    ; byl nˆjak˜ znak ?
         ret

a_024D   ENDP

;==========================================================================
;        test, zda je kl vesa Print-Screen
;==========================================================================

a_0256   PROC      near

         cmp       ax,7200h                 ; je kl vesa Print Screen ?
         jne       a_025D                   ; nen¡ Print Screen
         mov       al,10h                   ; n hrada ^P
a_025D:  or        al,al                    ; p©¡znak ZY=nen¡ Print Screen
         ret

a_0256   ENDP

;==========================================================================
;        vypr zdnˆn¡ bufferu kl vesnice
;==========================================================================

a_0260   PROC      near

         call      a_024D                   ; vyjmut¡ znaku z bufferu znak–
a_0263:  mov       ah,1                     
         int       16h                      ; je p©ipraven znak ?
         jnz       a_026A                   ; je p©ipraven znak
         ret                                
                                            
a_026A:  mov       ah,0
         int       16h                      ; zru¨en¡ znaku z bufferu
         jmp       short a_0263             ; dal¨¡ znak

a_0260   ENDP

; -----------------------------------------------------------------------------
;        8,9: z pis na za©¡zen¡ CON
; -----------------------------------------------------------------------------

a_0270:  jcxz      a_0280                   ; nen¡ ‘ dn˜ znak k z pisu
         mov       si,di                    ; ukazatel bufferu
a_0274:  lods      byte ptr es:[si]         ; znak k zobrazen¡
         mov       ah,0Eh                   
         mov       bx,ds:[a_0010]           ; atribut barev
         int       10h                      ; zobrazen¡ znaku na CON
         loop      a_0274                   ; dal¨¡ znak k zobrazen¡
a_0280:  jmp       a_01E3                   ; n vrat OK

; -----------------------------------------------------------------------------
;        obsluha p©eru¨en¡ INT 29h
; -----------------------------------------------------------------------------

a_0283   PROC      FAR

         push      ax
         push      bx
         mov       ah,0Eh
         mov       bx,cs:[a_0010]           ; atribut barev
         int       10h                      ; zobrazen¡ znaku
         pop       bx
         pop       ax
         iret      

a_0283   ENDP

; -----------------------------------------------------------------------------
;         Obsluha za©¡zen¡ AUX a COM
; -----------------------------------------------------------------------------

a_0291   db        0                        ; £schova bajtu z COM1
         db        0                        ; £schova bajtu z COM2
                                          ;* 4: vstup ze za©¡zen¡ AUX,COM
a_0293:  jcxz      a_02aa
a_0295:  mov       dx,ds:[a_001A]           ; ‡¡slo portu COM, LPT
         call      a_02F0                   ; vyjmut¡ bajtu z bufferu COM
         jnz       a_02A7                   ; byl p©ipraven bajt
         mov       ah,2                   
         int       14h                      ; p©¡jem znaku z portu COM
         call      a_02FB                   ; test navr cen‚ho stavu z COM
         jnz       a_02AD                   ; byla nˆjak  chyba
a_02A7:  stosb                              ; ulo‘en¡ p©ijat‚ho znaku
         loop      a_0295                   ; p©¡jem dal¨¡ho bajtu
a_02aa:  jmp       a_01E3                   ; n vrat OK

a_02AD:  jmp       a_01C3                   ; chyba ‡ten¡ ze za©¡zen¡ COM
; -----------------------------------------------------------------------------
                                          ;* 5: nedestruktivn¡ vstup z COM
a_02b0:  mov       dx,ds:[a_001A]           ; ‡¡slo portu COM, LPT
         call      a_02F0                   ; vyjmut¡ bajtu z bufferu COM
         jnz       a_02D3                   ; byl uschov n znak
         mov       ah,3                   
         int       14h                      ; dotaz na stav portu
         call      a_02FB                   ; test navr cen‚ho stavu z COM
         jnz       a_02DC                   ; je nˆjak  chyba
         and       ax,120h                  ; maska - data p©ipravena
         cmp       ax,120h                  ; jsou data p©ipravena ?
         jne       a_02E1                   ; nejsou p©ipravena data
         mov       ah,2                   
         int       14h                      ; ‡ten¡ znaku z portu COM
         call      a_02FB                   ; test navr cen‚ho stavu z COM
         jnz       a_02DC                   ; je nˆjak  chyba
a_02D3:  mov       bx,dx                    ; ‡¡slo portu COM
         mov       ds:[a_0291+bx],al        ; £schova p©ijat‚ho znaku
         jmp       a_0235                   ; ulo‘en¡ p©ipraven‚ho znaku
                                          ;* chyba ‡ten¡ ze za©¡zen¡ COM
a_02DC:  mov       al,0Bh                   ; chyba ‡ten¡
         jmp       a_01CC                   ; chybov˜ n vrat
                                          ;* za©¡zen¡ nep©ipraveno
a_02E1:  jmp       a_01D0                   ; za©¡zen¡ nep©ipraveno
; -----------------------------------------------------------------------------
                                          ;* 7: vypr zdnˆn¡ vstupu
a_02e4:  mov       bx,ds:[a_001A]           ; ‡¡slo portu COM, LPT
         mov       byte ptr ds:[a_0291+bx],0 ; vynulov n¡ bufferu
         jmp       a_01E3                   ; n vrat OK

;==========================================================================
;        vyjmut¡ bajtu z bufferu COM
;==========================================================================

a_02F0   PROC      near

         mov       bx,dx                    ; ‡¡slo portu COM, LPT
         xor       al,al                    ; AL <- 0
         xchg      al,ds:[a_0291+bx]        ; vyjmut¡ bajtu z bufferu
         or        al,al                    ; byl ulo‘en znak ?
         ret

a_02F0   ENDP

;==========================================================================
;        test navr cen‚ho stavu z COM
;==========================================================================

a_02FB   PROC      near

         test      ah,10h                   ; bylo p©eru¨en¡ ?
         jz        a_0304                   ; nebylo p©eru¨en¡
         mov       al,3                     ; n hradn¡ znak p©eru¨en¡ ^C
         mov       ah,0                     
a_0304:  test      ah,0Eh                   ; byla jin  chyba ?
         ret

a_02FB   ENDP

; -----------------------------------------------------------------------------
                                          ;* 8,9: v˜stup na za©¡zen¡ COM
a_0308:  jcxz      a_031D                   ; nen¡ ‘ dn˜ znak k z pisu
         mov       dx,ds:[a_001A]           ; ‡¡slo portu COM, LPT
         mov       si,di                    ; adresa bufferu
a_0310:  lods      byte ptr es:[si]         ; znak k z pisu
         mov       ah,1                     
         int       14h                      ; vysl n¡ znaku na port COM
         test      ah,80h                   ; byla chyba TIME-OUT v˜stupu ?
         jnz       a_0320                   ; chyba TIME-OUT p©i z pisu
         loop      a_0310                   ; z pis dal¨¡ho znaku
a_031D:  jmp       a_01E3                   ; n vrat OK

a_0320:  jmp       a_01C7                   ; chyba z pisu na za©¡zen¡ COM
; -----------------------------------------------------------------------------
                                          ;* 0ah: statut v˜stupu na COM
a_0323:  mov       dx,ds:[a_001A]           ; ‡¡slo portu COM, LPT
         mov       ah,3                   
         int       14h                      ; dotaz na stav portu
         and       ax,2020h                 ; maska p©ipravenosti
         cmp       ax,2020h                 ; je vys¡la‡ p©ipraven ?
         jne       a_02E1                   ; za©¡zen¡ nen¡ p©ipraveno
         jmp       a_01E3                   ; n vrat OK

; -----------------------------------------------------------------------------
;         Obsluha za©¡zen¡ PRN, LPT
; -----------------------------------------------------------------------------
                                          ;* 8,9: v˜stup na za©¡z. LPT, PRN
a_0336:  jcxz      a_0354                   ; nen¡ ‘ dn˜ znak k v˜stupu
         mov       dx,ds:[a_001A]           ; ‡¡slo portu COM, LPT
         mov       ah,2                     
         int       17h                      ; dotaz na stav tisk rny
         call      a_0375                   ; test navr c. stavu z tisk rny
         jnz       a_0357                   ; chyba tisk rny
         mov       si,di                    ; adresa bufferu k v˜stupu
a_0347:  lods      byte ptr es:[si]         ; na‡ten¡ znaku k v˜stupu
         mov       ah,0                     
         int       17h                      ; v˜stup znaku na tisk rnu
         call      a_0375                   ; test navr c. stavu z tisk rny
         jnz       a_0357                   ; byla chyba v˜stupu na tisk.
         loop      a_0347                   ; v˜stup dal¨¡ho znaku

a_0354:  jmp       a_01E3                   ; n vrat OK

a_0357:  jmp       a_01C9                   ; chyba v˜stupu na tisk rnu

; -----------------------------------------------------------------------------
                                          ;* 0ah: statut v˜stupu na LPT,PRN
a_035a:  mov       dx,ds:[a_001A]           ; ‡¡slo portu COM, LPT
         mov       ah,2                     
         int       17h                      ; dotaz na stav LPT, PRN
         call      a_0375                   ; test navr c. stavu z tisk rny
         jnz       a_036F                   ; chyba v˜stupn¡ho za©¡zen¡
         test      ah,80h                   ; je tisk rna zanepr zdnˆna ?
         jz        a_0372                   ; tisk rna je zanepr zdnˆna
         jmp       a_01E3                   ; n vrat OK

a_036F:  jmp       a_01CC                   ; chyba v˜stupn¡ho za©¡zen¡

a_0372:  jmp       a_01D0                   ; za©¡zen¡ nep©ipraveno

;==========================================================================
;        test navr c. stavu z tisk rny
;==========================================================================

a_0375   PROC      near

         mov       al,2                     ; chyba - tisk rna nep©ipravena
         test      ah,10h                   ; je tisk rna v ON-LINE ?
         jz        a_038C                   ; tisk rna nen¡ v ON-LINE
         mov       al,9                     ; chyba - v tisk rnˆ nen¡ pap¡r
         test      ah,20h                   ; je v tisk rnˆ pap¡r ?
         jnz       a_038C                   ; v tisk rnˆ nen¡ pap¡r
         mov       al,0Ah                   ; chyba v˜stupu na tisk rnu
         test      ah,9                     ; je jin  chyba (TIME-OUT) ?
         jnz       a_038C                   ; je chyba TIME-OUT nebo I/O
         xor       al,al                    ; p©¡znak - ‘ dn  chyba
a_038C:  or        al,al                    ; nastaven¡ p©¡znaku ZF
         ret

a_0375   ENDP

; -----------------------------------------------------------------------------
;         Obsluha za©¡zen¡ CLOCK$
; -----------------------------------------------------------------------------

a_038F   dw        890h                     ; po‡et dn– od 1.1.1980

                                          ;* tabulka po‡tu dn– mˆs¡c–
a_0391   db        31                       ; po‡et dn– v lednu
a_0392   db        28                       ; po‡et dn– v £noru
         db        31                       ; po‡et dn– v b©eznu
         db        30                       ; po‡et dn– v dubnu
         db        31                       ; po‡et dn– v kvˆtnu
         db        30                       ; po‡et dn– v ‡ervnu
         db        31                       ; po‡et dn– v ‡ervenci
         db        31                       ; po‡et dn– v sprnu
         db        30                       ; po‡et dn– v z ©¡
         db        31                       ; po‡et dn– v ©¡jnu
         db        30                       ; po‡et dn– v listopadu
         db        31                       ; po‡et dn– v prosinci

                                          ;* 4: ‡ten¡ ze za©¡zen¡ CLOCK
a_039d:  call      a_0425                   ; ‡ten¡ syst‚mov‚ho ‡asova‡e
         mov       ax,ds:[a_038f]           ; po‡et dn– od 1.1.1980
         stosw                              ; ulo‘en¡ po‡tu dn– od 1.1.1980

         push      dx                       ; £schova ni‘¨¡ho slova ‡¡ta‡e
         xchg      dh,dl                    ;
         mov       dh,cl                    ; DX = ‡¡ta‡ / 256
         mov       ax,1878                  ; 1878
         mul       dx                       ; (‡¡ta‡ / 256) * 1878
         pop       ax                       ; n vrat ni‘¨¡ho slova ‡¡ta‡e
         sub       ax,dx                    ;
         sbb       cx,0                   
         push      cx                       ; £schova hodiny
         mov       cx,5625                  ; 5625
         mul       cx                     
         mov       cx,10                    ; po‡et rotac¡
a_03BD:  shr       dx,1                     ; DX >> CF >> AX (10x)
         rcr       ax,1                     
         loop      a_03BD                   ; dal¨¡ rotace
                                          ;* v DX:AX je po‡et setin sekund
         mov       cx,6000                  ; dˆlitel 6000
         div       cx                       ; v˜po‡et minuty 0-59
         pop       cx                       ; n vrat hodiny
         mov       ah,cl                    ; hodina 0-23
         stosw                              ; ulo‘en¡ hodiny a minuty
         mov       ax,dx                    ; po‡et setin sekund
         mov       cl,100                   ; dˆlitel 100
         div       cl                       ; v˜po‡et sekund a setin sekund
         xchg      ah,al                  
         stosw                              ; ulo‘en¡ sekund a setin sekund
         jmp       a_01E3                   ; n vrat OK

; -----------------------------------------------------------------------------
                                          ;* 8,9: z pis na za©¡zen¡ CLOCK$
a_03d8:  mov       si,di                    ; adresa bufferu
         lods      word ptr es:[si]         ; na‡ten¡ po‡tu dn– od 1.1.1980
         mov       ds:[a_038F],ax           ; po‡et dn– od 1.1.1980
         call      a_044E
         call      a_0431
         mov       ah,5
         int       1Ah
         lods      word ptr es:[si]
         mov       cx,ax
         lods      word ptr es:[si]
         mov       dx,ax
         mov       dl,0
         push      dx
         push      cx
         call      a_0431
         mov       ah,3
         int       1Ah                      ; nastaven¡ hodin re l. ‡asu
         xor       bx,bx
         pop       ax
         mov       bl,ah
         mov       cl,60
         mul       cl
         pop       dx
         xchg      dh,dl
         add       dx,ax
         xor       ax,ax
         mov       cx,3600
         div       cx
         mov       dx,ax
         mov       cx,bx
         mov       al,7
         mul       cl
         add       dx,ax
         adc       cx,0
         mov       ah,1
         int       1Ah
         jmp       a_01E3

;==========================================================================
;        ‡ten¡ syst‚mov‚ho ‡asova‡e
;==========================================================================

a_0425   PROC      near

         xor       ax,ax
         int       1Ah                      ; ‡ten¡ syst‚mov‚ho ‡asova‡e
         xor       ah,ah                    ; AX = p©¡znak p©elomu dne
         add       cs:[a_038F],ax           ; zv˜¨en¡ ‡¡ta‡e dn–
         ret

a_0425   ENDP

;==========================================================================
;                  SUBROUTINE
;==========================================================================

a_0431   PROC      near

         push      cx
         push      dx
         mov       bp,sp
         mov       cx,4
a_0438:  push      cx
         mov       al,ss:[bp]
         aam       
         mov       cl,4
         shl       ah,cl
         or        al,ah
         mov       ss:[bp],al
         inc       bp
         pop       cx
         loop      a_0438
         pop       dx
         pop       cx
         ret

a_0431   ENDP

;==========================================================================
;
;==========================================================================

a_044E   PROC      near

         mov       dx,ax
         mov       cx,50h
a_0453:  call      a_0480
         xor       bx,bx
a_0458:  mov       al,ds:[a_0391+bx]        ; tabulka po‡tu dn– mˆs¡c–
         cbw       
         sub       dx,ax
         jc        a_046B
         inc       bl
         cmp       bl,0Ch
         jb        a_0458
         inc       cx
         jmp       short a_0453

a_046B:  add       dx,ax
         inc       dl
         inc       bl
         mov       dh,bl
         mov       ch,13h
         cmp       cl,100
         jb        a_047F
         inc       ch
         sub       cl,100
a_047F:  ret

a_044E   ENDP

;==========================================================================
;        stanoven¡ po‡tu dn– v £noru
;==========================================================================

a_0480   PROC      near

         mov       al,28                    ; 28
         test      cx,3                     ; je stolet¡ dˆliteln‚ 4 ?
         jnz       a_048A                   ; stolet¡ nen¡ dˆliteln‚ 4
         inc       al                       ; £nor se 29 dny
a_048A:  mov       ds:[a_0392],al           ; po‡et dn– v £noru
         ret

a_0480   ENDP

; -----------------------------------------------------------------------------
;         Obsluha diskov‚ho za©¡zen¡
; -----------------------------------------------------------------------------

a_048E   db        4                        ; po‡et logick˜ch disket. jedn.

a_048F   db        2                        ; funkce (2=‡ten¡ / 3=z pis)

a_0490   db        0                        ; aktivn¡ logick˜ disk
a_0491   db        0                        ; aktivn¡ fyzick˜ disk
a_0492   db        0                        ; po‡et disketov˜ch mechanik-1
                                            ;  bit 7: p©¡znak verifikace

a_0493   dd        0                        ; ‡as posledn¡ diskov‚ operace

a_0497   db        0                        ; po‡et zb˜vaj¡c¡ch sektor–
a_0498   db        0                        ; po‡et sektor– pro operaci

a_0499   dw        0                        ; ‡¡slo stopy pro disk. operaci
a_049B   db        0                        ; ‡¡slo sektoru pro disk. oper.

a_049C   db        4 dup(0)                 ; bit 0: p©¡znak mo‘n‚ indikace
                                            ;        v˜mˆny m‚dia
                                            ; bit 1: m‚dium bylo vymˆnˆno

a_04a0   dw        0

a_04A2   db        0Fh                      ; ‡as pro p©¡tlak hlavy

a_04A3   dw        0                        ; £schova SP p©i disk. operaci

a_04A5   db        5                        ; ‡¡ta‡ pokus– o operaci

                                          ;* adresy def. tabulek disk–
a_04A6   dw        a_04C5                   ; A
a_04A8   dw        a_04C5                   ; B
a_04aa   dw        a_04c5                   ; C
a_04ac   dw        a_04c5                   ; D
a_04ae   dw        a_0aac                   ; E
a_04b0   dw        a_0abf                   ; F

; -----------------------------------------------------------------------------
;         Tabulky popisova‡– disketov˜ch jednotek
; -----------------------------------------------------------------------------
                                          ;* 0f9h: 5 1/4" DS HD 1.2MB
a_04b2   dw        200h                     ; [SI+00h] velikost sektoru
         db        1                        ; [SI+02h] sektor– na blok
         dw        1                        ; [SI+03h] rezervovan‚ sektory
         db        2                        ; [SI+05h] po‡et tabulek FAT
         dw        0e0h                     ; [SI+06h] po‡et adr. polo‘ek
         dw        960h                     ; [SI+08h] celkem sektor–
         db        0f9h                     ; [SI+0ah] popisova‡ m‚dia
         dw        7                        ; [SI+0bh] sektor– na FAT
         dw        0fh                      ; [SI+0dh] sektor– na stopu
         dw        2                        ; [SI+0fh] po‡et hlav
         dw        0                        ; [SI+11h] po‡ t. rel. sektor

                                          ;* 0fah: 5 1/4" DS DD 720KB
a_04c5   dw        200h                     ; [SI+00h] velikost sektoru
         db        2                        ; [SI+02h] sektor– na blok
         dw        1                        ; [SI+03h] rezervovan‚ sektory
         db        2                        ; [SI+05h] po‡et tabulek FAT
         dw        70h                      ; [SI+06h] po‡et adr. polo‘ek
         dw        5a0h                     ; [SI+08h] celkem sektor–
         db        0fah                     ; [SI+0ah] popisova‡ m‚dia
         dw        3                        ; [SI+0bh] sektor– na FAT
         dw        9                        ; [SI+0dh] sektor– na stopu
         dw        2                        ; [SI+0fh] po‡et hlav
         dw        0                        ; [SI+11h] po‡ t. rel. sektor

                                          ;* 0fch: 5 1/4" SS DD 180KB
a_04d8   dw        200h                     ; [SI+00h] velikost sektoru
         db        1                        ; [SI+02h] sektor– na blok
         dw        1                        ; [SI+03h] rezervovan‚ sektory
         db        2                        ; [SI+05h] po‡et tabulek FAT
         dw        40h                      ; [SI+06h] po‡et adr. polo‘ek
         dw        168h                     ; [SI+08h] celkem sektor–
         db        0fch                     ; [SI+0ah] popisova‡ m‚dia
         dw        2                        ; [SI+0bh] sektor– na FAT
         dw        9                        ; [SI+0dh] sektor– na stopu
         dw        1                        ; [SI+0fh] po‡et hlav
         dw        0                        ; [SI+11h] po‡ t. rel. sektor

                                          ;* 0fdh: 5 1/4" DS DD 360KB
a_04eb   dw        200h                     ; [SI+00h] velikost sektoru
         db        2                        ; [SI+02h] sektor– na blok
         dw        1                        ; [SI+03h] rezervovan‚ sektory
         db        2                        ; [SI+05h] po‡et tabulek FAT
         dw        70h                      ; [SI+06h] po‡et adr. polo‘ek
         dw        2d0h                     ; [SI+08h] celkem sektor–
         db        0fdh                     ; [SI+0ah] popisova‡ m‚dia
         dw        2                        ; [SI+0bh] sektor– na FAT
         dw        9                        ; [SI+0dh] sektor– na stopu
         dw        2                        ; [SI+0fh] po‡et hlav
         dw        0                        ; [SI+11h] po‡ t. rel. sektor

                                          ;* 0feh: 5 1/4" SS DD 160KB
a_04fe   dw        200h                     ; [SI+00h] velikost sektoru
         db        1                        ; [SI+02h] sektor– na blok
         dw        1                        ; [SI+03h] rezervovan‚ sektory
         db        2                        ; [SI+05h] po‡et tabulek FAT
         dw        40h                      ; [SI+06h] po‡et adr. polo‘ek
         dw        140h                     ; [SI+08h] celkem sektor–
         db        0feh                     ; [SI+0ah] popisova‡ m‚dia
         dw        1                        ; [SI+0bh] sektor– na FAT
         dw        8                        ; [SI+0dh] sektor– na stopu
         dw        1                        ; [SI+0fh] po‡et hlav
         dw        0                        ; [SI+11h] po‡ t. rel. sektor

                                          ;* 0ffh: 5 1/4" DS DD 320KB
a_0511   dw        200h                     ; [SI+00h] velikost sektoru
         db        2                        ; [SI+02h] sektor– na blok
         dw        1                        ; [SI+03h] rezervovan‚ sektory
         db        2                        ; [SI+05h] po‡et tabulek FAT
         dw        70h                      ; [SI+06h] po‡et adr. polo‘ek
         dw        280h                     ; [SI+08h] celkem sektor–
         db        0ffh                     ; [SI+0ah] popisova‡ m‚dia
         dw        1                        ; [SI+0bh] sektor– na FAT
         dw        8                        ; [SI+0dh] sektor– na stopu
         dw        2                        ; [SI+0fh] po‡et hlav
a_0522   dw        0                        ; [SI+11h] po‡ t. rel. sektor


a_0524   db        13h                      ; d‚lka tabulky disk. parametr–
         db        90h                      ; zarovn n¡ na sudou adresu

a_0526   db        200h dup (0)             ; sektorov˜ buffer

; -----------------------------------------------------------------------------
                                          ;* 0: inicializace za©¡zen¡
a_0726:  mov       al,ds:[a_00c8]           ; celkov˜ po‡et log. disk–
         mov       si,offset a_04a6         ; adresy def. tabulek disk–
a_072C:  lds       bx,cs:[a_0016]           ; adresa po‘adavku za©¡zen¡
         mov       ds:[bx+0Dh],al           ; po‡et diskov˜ch jednotek
         mov       ds:[bx+12h],si           ; tabulka adres parametr– BPB
         mov       ds:[bx+14h],cs           ; segment adres parametr– BPB
         jmp       a_01E3                   ; n vrat OK
; -----------------------------------------------------------------------------
                                          ;* 1: kontrola v˜mˆny m‚dia
a_073a:  xor       bx,bx                    ; BX <- 0
         mov       bl,al                    ; disk
         test      byte ptr ds:[a_049C+bx],06
         jnz       a_078E                   ; nen¡ zn m  v˜mˆna m‚dia
         cmp       al,ds:[a_048E]           ; po‡et logick˜ch disket. jedn.
         jae       a_0792                   ; je pevn˜ disk - nevymˆnˆn
         xchg      al,ds:[a_0490]           ; aktivn¡ logick˜ disk
         cmp       al,ds:[a_0490]           ; aktivn¡ logick˜ disk
         jne       a_076C                   ; aktivn¡ disk byl vymˆnˆn-test
         call      a_0425                   ; ‡ten¡ syst‚mov‚ho ‡asova‡e
         cmp       cx,word ptr ds:[a_0493]  ; byla zmˆna ‡asu ?
         jne       a_0773                   ; byla zmˆna ‡asu HIGH-test
         sub       dx,word ptr ds:[a_0493+2]; rozd¡l ‡asu LOW
         cmp       dx,24h                   ; je rozd¡l ‡asu > 2 sekundy ?
         jb        a_0792                   ; kr tk  doba - nevymˆnˆno
         jmp       short a_0773             ; test vymˆny m‚dia
                                          ;* test v˜mˆny m‚dia
a_076C:  test      byte ptr ds:[a_0492],3   ; po‡et disket. mechanik-1
         jz        a_078E                   ; je 1 disket.mechanika-nezn mo
a_0773:  xor       bx,bx                    ; BX <- 0
         mov       bl,ds:[a_0490]           ; aktivn¡ logick˜ disk
         test      byte ptr ds:[a_049C+bx],1; je mo‘n  indik. v˜mˆny ?
         jz        a_078E                   ; nen¡ mo‘n  indikace v˜mˆny
         call      a_07AC                   ; p©evod log. disku na fyzick˜
         mov       dl,al                    ; disk pro operaci
         mov       ah,16h                 
         int       13h                      ; test stavu v˜mˆny diskety
         cmp       ah,0                     ; je m‚dium vymˆnˆno ?
         je        a_0792                   ; m‚dium nen¡ vymˆnˆno
                                          ;* nen¡ zn m  v˜mˆna m‚dia
a_078E:  mov       ah,0                     ; p©¡znak - nen¡ zn m  v˜mˆna
         jmp       short a_0794           
                                          ;* m‚dium nevymˆnˆno
a_0792:  mov       ah,1                     ; p©¡znak - m‚dium nevymˆnˆno
a_0794:  lds       bx,cs:[a_0016]
         mov       ds:[bx+0Eh],ah           ; adresa po‘adavku za©¡zen¡
         jmp       a_01E3                   ; stav v˜mˆny m‚dia
                                            ; n vrat OK
; -----------------------------------------------------------------------------

a_079F:  push      bx
         xor       bx,bx
         mov       bl,dl
         or        byte ptr cs:[a_049C+bx],4
         pop       bx
         retf      

;==========================================================================
;        p©evod log. disku na fyzick˜
;==========================================================================

a_07AC   PROC      near

         mov       al,ds:[a_0490]           ; aktivn¡ logick˜ disk
         cmp       al,ds:[a_048E]           ; po‡et logick˜ch disket. jedn.
         jae       a_07C0
         test      byte ptr ds:[a_0492],3   ; po‡et disketov˜ch mechanik-1
         jnz       a_07C8                   ; je v¡ce ne‘ 1 mechanika
         mov       al,0                     ; je 1. disket. mechanika
         jmp       short a_07C8             
a_07C0:  sub       al,ds:[a_048E]           ; po‡et logick˜ch disket. jedn.
         add       al,ds:[a_0AAB]           ; ‡¡slo prvn¡ho pevn‚ho disku
a_07C8:  mov       ds:[a_0491],al           ; aktivn¡ fyzick˜ disk
         ret

a_07AC   ENDP

; -----------------------------------------------------------------------------
;        3: vystavˆn¡ bloku param. BPB
; -----------------------------------------------------------------------------

a_07cc:  mov       ds:[a_0490],al           ; aktivn¡ logick˜ disk
         call      a_07AC                   ; p©evod log. disku na fyzick˜
         mov       ah,es:[di]               ; popisova‡ m‚dia
         cmp       ah,0F9h                  ; je disketa 5 1/4" HD ?
         jne       a_07DD                   ; nen¡ disketa 5 1/4" HD
         call      a_07F1                   ; test disku HD
a_07DD:  call      a_0816                   ; tabulka parametr– akt. disku
         xor       bx,bx                    ; BX <- 0
         mov       bl,ds:[a_0490]           ; aktivn¡ logick˜ disk
         and       byte ptr ds:[a_049C+bx],0F1h ; p©¡znak ur‡en¡ m‚dia
         mov       al,ds:[si+0Ah]           ; popisova‡ m‚dia
         jmp       a_072C                   ; nastaven¡ ukazatel– disku

;==========================================================================
;        test diskety HD
;==========================================================================

a_07F1   PROC      near

         mov       byte ptr ds:[a_04A5],3   ; ‡¡ta‡ pokus– o operaci
         push      ds                       
         pop       es                       
a_07F8:  mov       ax,401h                  ; verifikace 1 sektoru
         mov       bx,offset a_0526         ; sektorov˜ buffer
         mov       cx,0Fh                   ; sektor 15 na stopˆ 0
         xor       dx,dx                    ; hlava 0
         mov       dl,byte ptr ds:[a_0491]  ; aktivn¡ fyzick˜ disk
         int       13h                      ; test, zda je sektor 15
         mov       ah,0F9h                  ; typ disku 5 1/4" HD 1.2M
         jnc       a_0815                   ; je disk 5 1/4" HD 1.2M
         dec       byte ptr ds:[a_04A5]     ; ‡¡ta‡ pokus– o operaci
         jg        a_07F8                   
         mov       ah,0FAh                  ; disk 3 1/4" HD 1.44M
a_0815:  ret

a_07F1   ENDP

;==========================================================================
;        Poskytnut¡ adresy tabulky parametr– aktivn¡ diskov‚ jednotky
;==========================================================================

a_0816   PROC      near

         mov       al,ds:[a_0490]           ; aktivn¡ logick˜ disk
         cmp       al,ds:[a_048E]           ; po‡et logick˜ch disket. jedn.
         jae       a_0835                   ; je pevn˜ disk
         mov       al,ah                    ; popisova‡ m‚dia
         cmp       al,0FCh                  ; je vˆt¨¡ ne‘ 0FBh ?
         jb        a_0827                   ; je 0FBh nebo ni‘¨¡
         dec       al                       ; vypu¨tˆn¡ k¢du 0fbh
a_0827:  mov       si,offset a_04B2         ; tabulky parametr– disket
         sub       al,0F9h                  ; je k¢d men¨¡ ne‘ 0f9h ?
         jc        a_0834                   ; je men¨¡ ne‘ 0f9h - chyba
         mul       byte ptr ds:[a_0524]     ; popisova‡ * d‚lka tabulky
         add       si,ax                    ; adresa v tabulce
a_0834:  ret                              
                                          ;* ur‡en¡ pro pevn˜ disk
a_0835:  mov       si,offset a_0AAC         ; 1. pevn˜ disk
         jz        a_083D                 
         mov       si,offset a_0ABF         ; 2. pevn˜ disk
a_083D:  ret

a_0816   ENDP

; -----------------------------------------------------------------------------
                                          ;* 4: ‡ten¡ z diskov‚ho za©¡zen¡
a_083e:  push      es
         xor       bx,bx
         mov       es,bx                    ; ES <- 0
         mov       byte ptr es:[52Bh],1     ; ust len¡ hlavy = 1 ms
         pop       es
         mov       bl,2                     ; povel pro ‡ten¡
         jmp       short a_0856

                                          ;* 8: z pis na diskov‚ za©¡zen¡
a_084e:  mov       bx,3                     ; povel pro z pis
         jmp       short a_0856

                                          ;* 9: z pis na za©¡z. s verifik.
a_0853:  mov       bx,8003h                 ; povel pro z pis s verifikac¡

a_0856:  mov       ds:[a_0490],al           ; aktivn¡ logick˜ disk
         mov       ds:[a_048F],bl           ; funkce (2=‡ten¡ / 3=z pis)
         and       byte ptr ds:[a_0492],0Fh ; po‡et disketov˜ch mechanik-1
         or        byte ptr ds:[a_0492],bh  ; nastaven¡ p©¡znaku verifikace
         call      a_07AC                   ; p©evod log. disku na fyzick˜
         call      a_0816                   ; tabulka parametr– akt. disku
         mov       bx,di                    ; adresa bufferu
         call      a_0894                   ; proveden¡ operace R/W/V
         mov       bx,0                     ; BX <- 0
         mov       es,bx                    ; ES <- 0
         mov       bl,ds:[a_04A2]           ; ‡as pro p©¡tlak hlavy
         mov       es:[52Bh],bl             ; n vrat ‡asu pro p©¡tlak hlavy
         jc        a_088F                   ; chyba operace
         call      a_0425                   ; ‡ten¡ syst‚mov‚ho ‡asova‡e
         mov       word ptr ds:[a_0493],cx  ; £schova ‡asu posledn¡ operace
         mov       word ptr ds:[a_0493+2],dx
         jmp       a_01E3                   ; n vrat OK

a_088F:  xor       ch,ch                    ; po‡et p©enesen˜ch bajt– = 0
         jmp       a_01C9

;==========================================================================
;        €ten¡/z pis/z pis s verifikac¡
;==========================================================================

a_0894   PROC      near

                                          ;* VSTUP: DX=po‡ te‡n¡ sektor
                                          ;*        ES:BX=adresa ke ‡ten¡
                                          ;*        CX=po‡et sektor–
                                          ;*        SI=tabulka m‚dia
         mov       ds:[a_04A3],sp           ; £schova SP
         mov       ds:[a_0497],cl           ; po‡et sektor–
         jcxz      a_0919                   ; nen¡ ‘ dn˜ sektor
         mov       ax,cx                    ; po‡et sektor–
         add       ax,dx                    ; kone‡n˜ sektor
         cmp       ax,ds:[si+8]             ; celkem sektor– na disku
         ja        a_091B                   ; chyba - p©ete‡en¡ sektor–

         add       dx,ds:[si+11h]           ; p©i‡ten¡ po‡ t. sektoru
         mov       ax,dx                    ; po‡ te‡n¡ abs. sektor
         xor       dx,dx                  
         div       word ptr ds:[si+0Dh]     ; v˜po‡et ‡¡sla stopy
         mov       ds:[a_0499],ax           ; ‡¡slo stopy
         inc       dl                       ; ‡¡slo sektoru
         mov       ds:[a_049B],dl           ; ‡¡slo sektoru
                                          ;* po‘adavek v˜mˆny m‚dia
         test      word ptr ds:[a_0491],380h ; je 1 disketa ?
         jnz       a_08C7                   ; v¡ce disket nebo pevn˜ disk
         push      es                     
         call      a_0A33                   ; v˜zva k v˜mˆnˆ m‚dia
         pop       es                     
                                          ;* kontrola adresy DMA
a_08C7:  mov       ax,es                    ; segment adresy bufferu
         mov       cl,4                   
         shl       ax,cl                    ; p©epo‡et na bajty
         add       ax,bx                    ; ni‘¨¡ slovo adresy
         mov       cl,ds:[a_0497]           ; po‡et zb˜vaj¡c¡ch sektor–
         add       ax,1FFh
         jc        a_08E7
         shr       ax,1
         mov       ch,80h
         sub       ch,ah
         cmp       ch,cl
         jae       a_0914
         call      a_0937
         sub       cl,ch
a_08E7:  push      es
         push      bx
         test      byte ptr ds:[a_048F],1   ; je z pis ?
         jz        a_08F7                   ; bude operace ‡ten¡
         push      ds                       
         push      si                       
         call      a_091F                   ; p©enos sektoru do bufferu
         pop       si                       
         pop       ds                       
a_08F7:  push      ds                       
         pop       es                       
         mov       bx,offset a_0526         ; sektorov˜ buffer
         mov       ch,1
         call      a_0937
         dec       cl
         pop       bx
         pop       es
         test      byte ptr [a_048F],1      ; byl to z pis ?
         jnz       a_0911                   ; byla to operace z pisu
         push      si                     
         call      a_092A                   ; p©enos sektoru z bufferu
         pop       si                     
a_0911:  add       bh,2                   
a_0914:  mov       ch,cl                  
         call      a_0937                 
a_0919:  clc                              
         ret                              

                                          ;* chyba - sektor nenalezen
a_091B:  mov       al,8                     ; chyba - sektor nenalezen
         stc                                ; p©¡znak chyby
         ret

a_0894   ENDP

;==========================================================================
;        p©enos sektoru do bufferu
;==========================================================================

a_091F   PROC      near

         push      es                     
         push      ds                     
         pop       es                       ; ES <- DS
         pop       ds                       ; DS <- ES
         mov       si,bx                    ; adresa bufferu
         mov       di,offset a_0526         ; sektorov˜ buffer
         jmp       short a_092F             ; p©enos sektoru
                                          ;* p©enos sektoru z bufferu
a_092A:  mov       si,offset a_0526         ; sektorov˜ buffer
         mov       di,bx                    ; c¡lov˜ sektor

a_092F:  push      cx                     
         mov       cx,100h                  ; d‚lka sektoru
         rep       movsw                    ; p©enos sektoru z/do bufferu
         pop       cx
         ret

a_091F   ENDP

;==========================================================================
;        ‡ten¡/z pis na jedn‚ stopˆ
;==========================================================================

a_0937   PROC      near

         push      cx                     
         mov       ds:[a_0498],ch           ; po‡et sektor– pro operaci
         mov       byte ptr ds:[a_04A5],5   ; ‡¡ta‡ pokus– o operaci
a_0941:  mov       al,ds:[a_0498]           ; po‡et sektor– pro operaci
         or        al,al                    ; je nˆjak˜ sektor ?
         jnz       a_094B                   ; je nˆjak˜ sektor ?
         pop       cx                     
         clc                              
         ret                              

                                          ;* v˜po‡et parametr–
a_094B:  mov       cx,ds:[si+0Dh]           ; po‡et sektor– na stopu
         mov       ah,ds:[a_049B]           ; ‡¡slo sektoru pro disk. oper.
         sub       cl,ah                    ; sektor– do konce stopy - 1
         inc       cl                       ; sektor– do konce stopy
         cmp       al,cl                    ; po‘adov n vy¨¨¡ po‡et sekt. ?
         jbe       a_095C                   ; po‡et sektor– OK
         mov       al,cl                    ; omezen¡ na max. po‡et sekt.

a_095C:  push      ax                     
         mov       ax,ds:[a_0499]           ; ‡¡slo stopy pro disk. operaci
         xor       dx,dx                    ; DX <- 0
         div       word ptr ds:[si+0Fh]     ; v˜po‡et ‡¡sla v lce
         mov       ch,al                    ; ‡¡slo v lce
         mov       cl,6                   
         shl       ah,cl                    ; horn¡ 2 bity ‡¡sla v lce
         mov       cl,ah                    ; horn¡ 2 bity ‡¡sla v lce
         or        cl,ds:[a_049B]           ; ‡¡slo sektoru pro disk. oper.
         mov       dh,dl                    ; ‡¡slo hlavy
         mov       dl,byte ptr ds:[a_0491]  ; aktivn¡ fyzick˜ disk
         pop       ax                     
                                          ;* operace ‡ten¡/z pis
         push      ax                     
         mov       ah,ds:[a_048F]           ; funkce (2=‡ten¡ / 3=z pis)
         int       13h                      ; proveden¡ operace ‡ten¡/z pis
         jnc       a_0984                   ; operace OK
         call      a_09BA                   ; obsluha chybov‚ho stavu
                                          ;* verifikace dat
a_0984:  test      byte ptr ds:[a_0492],80h ; je verifikace ?
         jz        a_0996                   ; nen¡ verifikace
         pop       ax                     
         push      ax                       ; po‡et sektor–
         mov       ah,4                   
         int       13h                      ; verifikace sektor–
         jnc       a_0996                   ; operace OK
         call      a_09BA                   ; obsluha chybov‚ho stavu
                                          ;* zv˜¨en¡ ukazatel–
a_0996:  pop       ax                     
         sub       ds:[a_0497],al           ; po‡et zb˜vaj¡c¡ch sektor–
         sub       ds:[a_0498],al           ; sn¡‘en¡ po‡tu sektor–
         add       ds:[a_049B],al           ; zv˜¨en¡ ‡¡sla sektoru
         shl       al,1                     ; po‡et sektor– * 2
         add       bh,al                    ; zv˜¨en¡ adresy v pamˆti
         mov       al,ds:[a_049B]           ; ‡¡slo sektoru pro disk. oper.
         cmp       al,ds:[si+0Dh]           ; je konec stopy ?
         jbe       a_09B8                   ; nen¡ konec stopy
         mov       byte ptr ds:[a_049B],1   ; ‡¡slo sektoru = 1
         inc       word ptr ds:[a_0499]     ; zv˜¨en¡ ‡¡sla stopy
a_09B8:  jmp       short a_0941

a_0937   ENDP

;==========================================================================
;        obsluha chybov‚ho stavu
;==========================================================================

a_09BA   PROC      near

         cld
         mov       ds:[a_0A31],ah           ; chybov˜ k¢d disk. operace
         cmp       ah,11h                   ; je korekce dat ECC ?
         jne       a_09C5                   ; nen¡ korekce ECC
         ret

a_09C5:  cmp       ah,6                     ; byla v˜mˆna diskety ?
         jne       a_09D9                   ; nebyla v˜mˆna diskety
         xor       cx,cx                    
         mov       cl,ds:[a_0490]           ; aktivn¡ logick˜ disk
         mov       di,cx                    
         or        ds:[a_049C+di],2         ; p©¡znak-m‚dium vymˆnˆno
         jmp       short a_09EA
                                          ;* reset disku a test opakov n¡
a_09D9:  mov       ah,0
         int       13h                      ; resetov n¡ disku
         test      byte ptr ds:[a_0A31],80h ; chybov˜ k¢d disk. operace
         jnz       a_09FC                   ; operace se nebude opakova
         dec       byte ptr ds:[a_04A5]     ; ‡¡ta‡ pokus– o operaci
         jl        a_09FC                   ; dal¨¡ pokus o operaci
                                          ;* operace se bude opakovat
a_09EA:  push      es
         xor       ax,ax
         mov       es,ax                    ; ES <- 0
         mov       al,ds:[a_04A2]           ; ‡as pro p©¡tlak hlavy
         mov       es:[52Bh],al             ; n vrat ‡asu pro p©¡tlak
         pop       es                       ; n vrat ES
         pop       ax                       ; zru¨en¡ n vratv‚ adresy
         pop       ax                       ; n vrat po‡tu sektor–
         jmp       a_095C                   ; opakov n¡ operace
                                          ;* operace se nebude opakovat
a_09FC:  mov       al,ds:[a_0A31]           ; chybov˜ k¢d disk. operace
         push      ds                     
         pop       es                       ; ES <- DS
         mov       di,offset a_0A2C         ; tabulka chybov˜ch k¢d–
         mov       cx,6                   
         repne     scasb                  
         sub       di,offset a_0A2c + 1     ; nalezen¡ k¢du v tabulce
         mov       ax,di                    ; offset v tabulce
         shl       al,1                     ; offset k¢du v tabulce
         mov       ah,ds:[a_048F]           ; k¢d * 2
         cmp       ax,20Ah                  ; funkce (2=‡ten¡ / 3=z pis)
         jne       a_0A1C                   ; chyba ‡ten¡ ?
         inc       al                       ; nen¡ chyba ‡ten¡
a_0A1C:  mov       ah,ds:[a_0A31]           ; oprava na k¢d chyby ‡ten¡
         xor       ch,ch                    ; chybov˜ k¢d disk. operace
         mov       cl,ds:[a_0497]         
         mov       sp,ds:[a_04A3]           ; po‡et zb˜vaj¡c¡ch sektor–
         stc                                ; n vrat SP
         ret

a_09BA   ENDP


                                          ;* tabulka chybov˜ch k¢d–
a_0A2C   db        3                        ; chyba 0: chyb ochrany z pisu
         db        80h                      ; chyba 2: disk nep©ipraven
         db        10h                      ; chyba 4: chyba kontrol.sou‡tu
         db        40h                      ; chyba 6: chyba vystaven¡
         db        4                        ; chyba 8: sektor nenalezen

a_0A31   db        0                        ; chybov˜ k¢d disk. operace

         retf
;         db        0CBh

; ******************* konec TBIOS.SYS p©i v¡ce disket. mechanik a ‘ dn‚m winch.

;==========================================================================
;        v˜zva k v˜mˆnˆ media
;==========================================================================

a_0A33   PROC      near

         mov       cl,ds:[a_0490]           ; aktivn¡ logick˜ disk
         mov       ch,"A"                   ; "A"
         add       ch,cl                    ; ozna‡en¡ logick‚ho disku
         mov       ds:[a_0A88],ch           ; ozna‡en¡ disku
         xor       ax,ax                    
         mov       es,ax                    
         xchg      cl,es:[504h]             ; nov˜ logick˜ disk
         cmp       cl,ds:[a_0490]           ; aktivn¡ logick˜ disk
         je        a_0A6B                   ; disk nebyl vymˆnˆn
         push      si                       
         mov       si,offset a_0A6C         ; text "Vymˆ¤te disketu"
         mov       cx,offset(a_0a6c0-a_0a6c); d‚lka textu
         nop                                
a_0A56:  lodsb                              
         int       29h                      ; zobrazen¡ znaku textu
         loop      a_0A56                   ; dal¨¡ znak
         call      a_0260                   ; vypr zdnˆn¡ buff. kl vesnice
         xor       ah,ah                    
         int       16h                      ; ‡ek n¡ na stisk kl vesy
         mov       al,0Dh                   
         int       29h                      ; zobrazen¡ CR
         mov       al,0Ah                   
         int       29h                      ; zobrazen¡ LF
         pop       si
a_0A6B:  ret

a_0A33   ENDP

a_0A6C   db        13,10,'Insert diskette for drive '
a_0a88   db        'A:',13,10,'and press any key when ready  '
a_0a6c0  label     byte

; -----------------------------------------------------------------------------
;         Tabulky popisova‡– pevn˜ch disk–
; -----------------------------------------------------------------------------

a_0aaa   db        0                        ; po‡et fyzick˜ch pevn˜ch disk–

; ******************* konec TBIOS.SYS p©i 1 disket. mechanice a ‘ dn‚m winch.

a_0AAB   db        80h                      ; ‡¡slo prvn¡ho pevn‚ho disku

                                          ;* tabulka param. 1.pevn‚ho disku
a_0aac   dw        200h                     ; 00h: velikost sektoru
         db        0                        ; 02h: sektor– na blok
         dw        1                        ; 03h: rezervovan‚ sektory
         db        2                        ; 05h: po‡et tabulek FAT
         dw        0                        ; 06h: po‡et adr. polo‘ek
         dw        0                        ; 08h: celkem sektor–
         db        0f8h                     ; 0ah: popisova‡ m‚dia
         dw        0                        ; 0bh: sektor– na FAT
         dw        0                        ; 0dh: sektor– na stopu
         dw        0                        ; 0fh: po‡et hlav
         dw        0                        ; 11h: po‡ t. rel. sektor

; ******************* zde je konec TBIOS.SYS, pokud je 1 pevn˜ disk

                                          ;* tabulka param. 2.pevn‚ho disku
a_0abf   dw        200h                     ; [SI+00h] velikost sektoru
         db        0                        ; [SI+02h] sektor– na blok
         dw        1                        ; [SI+03h] rezervovan‚ sektory
         db        2                        ; [SI+05h] po‡et tabulek FAT
         dw        0                        ; [SI+06h] po‡et adr. polo‘ek
         dw        0                        ; [SI+08h] celkem sektor–
         db        0f8h                     ; [SI+0ah] popisova‡ m‚dia
         dw        0                        ; [SI+0bh] sektor– na FAT
         dw        0                        ; [SI+0dh] sektor– na stopu
         dw        0                        ; [SI+0fh] po‡et hlav
         dw        0                        ; [SI+11h] po‡ t. rel. sektor

; ******************* zde je konec TBIOS.SYS, pokud jsou 2 pevn‚ disky

a_0AD2   db        0                        ; popisova‡ m‚dia BOOT
a_0AD3   dw        0                        ; po‡ te‡n¡ rel. sektor ROOT
a_0AD5   dw        0                        ; po‡ te‡n¡ alok. blok TDOS.SYS

                                          ;* tabulka param. pro disk typu 0

a_0ad7   dw        1feah                    ; pevn˜ disk 4 MB
         db        1                        ; © d velikosti bloku v sekt.
         db        2                        ; po‡et sektor– na alok. blok
         dw        70h                      ; po‡et adr. polo‘ek

a_0add   dw        3fd4h                    ; pevn˜ disk 8 MB
         db        2                        ; © d velikosti bloku v sekt.
         db        4                        ; po‡et sektor– na alok. blok
         dw        100h                     ; po‡et adr. polo‘ek

                                          ;* pevn˜ disk typu 1
a_0ae3   dw        7fa8h                    ; pevn˜ disk 16 MB
         db        3                        ; © d velikosti bloku v sekt.
         db        8                        ; po‡et sektor– na alok. blok
         dw        200h                     ; po‡et adr. polo‘ek

a_0ae9   dw        0ffffh                   ; konec tabulky

a_0aeb   dw        1004h
a_0aed   dw        400h

a_0AEF   db        0                        ; k¢d tabulky FAT pevn‚ho disku

                                          ;* tabulka definic p©eru¨en¡
a_0AF0   db        1                        ; obsluha INT 01h
         dw        a_024c
         db        3                        ; obsluha INT 03h
         dw        a_024c
         db        4                        ; obsluha INT 04h
         dw        a_024c
         db        1bh                      ; obsluha INT 1bh
         dw        a_0246
         db        1eh                      ; tabulka INT 1eh
         dw        a_0522
         db        29h                      ; obsluha INT 29h
         dw        a_0283
         db        0ffh                     ; konec tabulky

; -----------------------------------------------------------------------------
;         Start modulu TBIOS.SYS
; -----------------------------------------------------------------------------
                                          ;* inicializace registr–
a_0B03:  cld                                ; smˆt nahoru
         cli                                ; z kaz p©eru¨en¡
         xor       ax,ax                    ; AX <- 0
         mov       es,ax                    ; ES <- 0
         mov       ss,ax                    ; SS <- 0
         mov       sp,7C00h                 ; vlastn¡ z sobn¡k 0:7C00h
         push      cs                     
         pop       ds                       ; DS <- CS (=70h)
         mov       ds:[a_0AD3],bx           ; po‡ te‡n¡ sektor ROOT

                                          ;* vynulov n¡ syst. oblasti dat
         mov       ax,es:[53Ah]             ; po‡ te‡n¡ alok. blok TDOS.SYS
         mov       ds:[a_0AD5],ax           ; po‡ te‡n¡ alok. blok TDOS.SYS
         xor       ax,ax                  
         mov       di,500h                  ; oblast syst‚m. dat
         mov       cx,20h                   ; d‚lka syst‚m. dat
         rep       stosw                    ; vymaz n¡ syst‚m. dat

                                          ;* £schova tab. disket. parametr–
         push      ds                     
         lds       si,dword ptr es:[78h]    ; ukazatel disketov˜ch param.
         mov       di,522h                  ; tabulka disketov˜ch paramtr–
         mov       cx,0Bh                   ; d‚lka tabulky parametr–
         rep       movsb                  
         pop       ds                       ; £schova tabulky disk. param.

         mov       al,es:[52Bh]             ; ‡as pro p©¡tlak hlavy
         mov       ds:[a_04A2],al           ; ‡as pro p©¡tlak hlavy

                                          ;* nastaven¡ obsluh p©eru¨en¡
         mov       si,offset a_0AF0         ; defini‡n¡ tabulka p©eru¨en¡
a_0B3E:  lodsb                              ; na‡ten¡ ‡¡sla p©eru¨en¡
         cmp       al,0FFh                  ; konec tabulky ?
         je        a_0B51                   ; konec tabulky
         cbw                                ; AX <- AL ‡¡slo p©eru¨en¡
         mov       di,ax                    ; ‡¡slo p©eru¨en¡
         shl       di,1                   
         shl       di,1                     ; offset adresy vektoru p©eru¨.
         lodsw                            
         stosw                              ; nastaven¡ offsetu p©eru¨en¡
         mov       ax,cs                  
         stosw                              ; nastaven¡ segmentu p©eru¨en¡
         jmp       short a_0B3E             ; dal¨¡ p©eru¨en¡

                                          ;* dokon‡en¡ instalace INT 1eh
a_0B51:  mov       di,78h+2                 ; segment adresy INT 1eh
         xor       ax,ax                    ; AX <- 0
         stosw                              ; segment adresy INT 1eh <- 0

         sti                                ; povolen¡ p©eru¨en¡
         call      a_0E30                   ; zobrazen¡ licen‡n¡ho textu

         mov       al,20h
         out       [20h],al                 ; uvolnˆn¡ ©adi‡e p©eru¨en¡

                                          ;* inicializace port– COM
         mov       cx,2                     ; po‡et port– = 2
a_0B62:  mov       dx,cx                    ; ‡¡slo portu + 1
         dec       dx                       ; ‡¡slo portu COM
         mov       ax,0A3h                  ; 2400 Baud, 8 bit– bez parity
         int       14h                      ; nastaven¡ parametr– COM
         loop      a_0B62                   ; dal¨¡ port COM

                                          ;* inicializace port– LPT
         mov       cx,3                     ; po‡et port– = 3
a_0B6F:  mov       dx,cx                    ; ‡¡slo portu + 1
         dec       dx                       ; ‡¡slo portu LPT
         mov       ax,100h                  ; povel pro inicializaci
         int       17h                      ; inicializace tisk rny LPT
         loop      a_0B6F                   ; dal¨¡ port LPT

                                          ;* inicializace data podle CMOS
         mov       cx,0FFFFh                ; p©ednastaven¡ n vrat. k¢du
         mov       ah,4                   
         int       1Ah                      ; ‡ten¡ data hodin re l. ‡asu
         cmp       cx,0FFFFh                ; je slu‘ba obsluhovan  ?
         je        a_0B8E                   ; slu‘ba nen¡ obsluhovan 
         call      a_0D10                   ; p©evod CX a DX na bin. tvar
         call      a_0CD0                   ; v˜po‡et po‡tu dn– od 1.1.1980
         mov       ds:[a_038F],ax           ; po‡et dn– od 1.1.1980

                                          ;* stanoven¡ popisova‡e m‚dia
a_0B8E:  mov       al,es:[7C15h]            ; popisova‡ m‚dia (z BOOT)
         cmp       al,0F9h                  ; je disketa 5 1/4" HD ?
         jne       a_0BA0                   ; nen¡ disketa 5 1/4" HD
         cmp       word ptr es:[7C18h],15   ; je 15 sektor–/stopu ?
         je        a_0BA0                   ; je 15 sektor– na stopu
         inc       al                       ; typ 0fah - 5 1/4" DD (720KB)
a_0BA0:  mov       ds:[a_0AD2],al           ; popisova‡ m‚dia BOOT

         mov       al,es:07DFDh             ; disk se zav dˆn˜m syst‚mem
         mov       byte ptr a_0491,al       ; aktivn¡ fyzick˜ disk

                                          ;* stanoven¡ po‡tu disket. jedn.
         int       11h                      ; ‡ten¡ tabulky vybaven¡
         mov       cl,6                     ; po‡et rotac¡
         shr       al,cl                    ; po‡et disketov˜ch mechanik-1
         mov       byte ptr ds:[a_0492],al  ; po‡et disketov˜ch mechanik-1
         jnz       a_0BB7                   ; je v¡ce mechanik ne‘ 1
         inc       al                       ; po‡et disketov˜ch mechanik
a_0BB7:  inc       al                       ; po‡et logick˜ch disket. jedn.
         mov       ds:[a_048E],al           ; po‡et logick˜ch disket. jedn.

                                          ;* mo‘nost indikace v˜mˆny m‚di¡
         push      es                       ; £schova ES
         push      ds                     
         pop       es                       ; ES <- DS
         mov       di,offset a_049C         ; tabulka typ– disket. jednotek
         xor       dx,dx                    ; disketov  jednotka 0
a_0BC4:  mov       ah,15h                 
         int       13h                      ; ‡ten¡ typu DASD disku 0
         mov       al,0                     ; p©¡znak - nen¡ indik. vymˆny
         cmp       ah,2                     ; je mo‘n  indikace v˜mˆny ?
         jne       a_0BD1                   ; nen¡ mo‘n  indikace v˜mˆny
         mov       al,1                     ; p©¡znak mo‘n‚ indikace v˜mˆny
a_0BD1:  stosb                              ; ulo‘en¡ p©¡znaku indik.v˜mˆny
         inc       dl                       ; zv˜¨en¡ ‡¡sla disku
         cmp       dl,byte ptr ds:[a_0492]  ; po‡et disketov˜ch mechanik-1
         jbe       a_0BC4                   ; je je¨tˆ dal¨¡ disket. mechan.
         test      byte ptr ds:[a_0492],3   ; po‡et disket. mechanik-1
         jnz       a_0BE2                   ; je v¡ce ne‘ 1 mechanika
         stosb                              ; plat¡ tak‚ pro logick˜ disk
a_0BE2:  pop       es

                                          ;* inicializace pevn˜ch disk–
         mov       dl,80h                   ; ‡¡slo pevn‚ho disku 0
         mov       ah,8                   
         int       13h                      ; z¡sk n¡ param. pevn‚ho disku
         jc        a_0C34                   ; nen¡ ‘ dn˜ pevn˜ disk
         or        dl,dl                    ; je nˆjak˜ pevn˜ disk ?
         jz        a_0C34                   ; nen¡ ‘ dn˜ pevn˜ disk
         mov       byte ptr ds:[a_0Aaa],dl  ; po‡et pevn˜ch disk–
         mov       dl,80h                   ; ‡¡slo pevn‚ho disku 0
                                          ;* 1. pevn˜ disk
         mov       si,offset a_0AAC         ; tabulka pevn‚ho disku 0
         call      a_0D2F                   ; parametry pevn‚ho disku 0
         mov       al,byte ptr ds:[a_0Aaa]  ; po‡et pevn˜ch disk–
         jnc       a_0C08                   ; disk OK
         dec       byte ptr ds:[a_0Aaa]     ; sn¡‘en¡ po‡tu pevn˜ch disk–
         inc       byte ptr ds:[a_0AAB]     ; zv˜¨en¡ ‡¡sla 1.pevn‚ho disku
                                          ;* 2. pevn˜ disk
a_0C08:  cmp       al,2                     ; je je¨tˆ 2.pevn˜ disk ?
         jb        a_0C20                   ; nen¡ ji‘ 2. pevn˜ disk
         mov       dl,81h                   ; ‡¡slo pevn‚ho disku 1
         cmp       dl,ds:[a_0AAB]           ; byla chyba disku 0 ?
         je        a_0C17                   ; byla chyba-tabulka se nemˆn¡
         mov       si,offset a_0ABF         ; tabulka param. pro disk 1
a_0C17:  call      a_0D2F                   ; parametry pevn‚ho disku 1
         jnc       a_0C20                   ; disk OK
         dec       byte ptr a_0A6C+3Eh      ; sn¡‘en¡ po‡tu pevn˜ch disk–
                                          ;* ukazatele na tabulky disk–
a_0C20:  mov       bl,ds:[a_048E]           ; po‡et logick˜ch disket. jedn.
         xor       bh,bh                  
         shl       bx,1                     ; ‡¡slo 1. pevn‚ho disku * 2
         mov       word ptr ds:[a_04A6+bx],offset a_0AAC ; adresa 1. pevn. disku
         mov       word ptr ds:[a_04A8+bx],offset a_0ABF ; adresa 2. pevn. disku
                                          ;* po‡et log. diskov˜ch jednotek
a_0C34:  mov       al,ds:[a_048E]           ; po‡et logick˜ch disket. jedn.
         add       al,byte ptr ds:[a_0Aaa]  ; po‡et pevn˜ch disk–
         mov       ds:[a_00C8],al           ; celkov˜ po‡et log. disk–

                                          ;* nastaven¡ aktivn¡ho log. disku
         mov       bx,offset a_0AAB         ; ‡¡slo prvn¡ho pevn‚ho disku
         mov       word ptr ds:[0],bx       ; ukazatel na ‡¡slo 1. winch.
         mov       al,byte ptr ds:[a_0491]  ; aktivn¡ fyzick˜ disk
         test      al,80h                   ; je syst‚m z pevn‚ho disku ?
         jz        a_0C54                   ; syst‚m je z diskety
         sub       al,ds:[a_0AAB]           ; ‡¡slo prvn¡ho pevn‚ho disku
         add       al,ds:[a_048E]           ; po‡et logick˜ch disket. jedn.
a_0C54:  mov       ds:[a_0490],al           ; aktivn¡ logick˜ disk

                                          ;* na‡ten¡ tabulky FAT disku
         mov       ah,ds:[a_0AD2]           ; popisova‡ m‚dia BOOT
         call      a_0816                   ; tabulka parametr– akt. disku
         mov       bx,8000h                 ; adresa k na‡ten¡ FAT
         mov       dx,1                     ; po‡ te‡n¡ sektor FAT
         mov       cx,ds:[si+0Bh]           ; po‡et sektor– na FAT
         call      a_0894                   ; na‡ten¡ tabulky FAT
         jc        a_0CCB                   ; chyba zav dˆn¡ syst‚mu

                                          ;* na‡ten¡ TDOS.SYS do pamˆti
         mov       ax,1000h                 ; segment k na‡ten¡ TDOS.SYS
         mov       es,ax                    ; segment k na‡ten¡ TDOS.SYS
         xor       bx,bx                    ; offset k na‡ten¡ TDOS.SYS
         call      a_0DE0                   ; na‡ten¡ souboru TDOS.SYS
         jc        a_0CCB                   ; chyba zaveden¡ syst‚mu

                                          ;* segment s 2. modulem TBIOS.SYS
         mov       ax,AdrSeg_b              ; nov˜ segment k ulo‘en¡ TDOS
         mov       ds,ax                    ; segment k ulo‘en¡ TDOS.SYS
                                            ; (odpov¡d  0070:0f60h)

                                          ;* v˜po‡et konce TBIOS.SYS
         mov       ds:[b_0005h],es          ; segment s TDOS.SYS = 1000h
         mov       ax,0AEh                  ; d‚lka TBIOS.SYS - 2 winch.
         cmp       byte ptr cs:[a_0Aaa],1   ; po‡et pevn˜ch disk–
         ja        a_0C9F
         mov       ax,0ACh                  ; d‚lka TBIOS.SYS - 1 winch.
         jz        a_0C9F
         mov       ax,0ABh                  ; d‚lka TBIOS.SYS - 1 mechanika
         test      byte ptr cs:[a_0492],3   ; po‡et disket. mechanik-1
         jz        a_0C9F                   ; je jen 1 mechanika
         mov       ax,0A4h                  ; d‚lka TBIOS.SYS - v¡ce ne‘ 1
a_0C9F:  add       ax,70h                   ; p©i‡ten¡ tohoto segmentu
         mov       ds:[b_0009h],ax          ; segment k ulo‘en¡ TDOS.SYS

                                          ;* £schova adresy 1. za©¡zen¡
         mov       ax,offset a_001C         ; offset z hlav¡ za©¡zen¡ CON
         mov       ds:[b_000Bh],ax          ; offset adresy za©¡zen¡ CON
         mov       ds:[b_000Dh],cs          ; adresa z hlav¡ 1. za©¡zen¡

                                          ;* zji¨tˆn¡ velikosti pamˆti
         int       12h                      ; poskytnut¡ voln‚ pamˆti
         mov       cl,6                     ; po‡et rotac¡ pro p©evod
         shl       ax,cl                    ; p©evod KB na odstavce
         mov       ds:[b_000Fh],ax          ; voln  pamˆŸ v odstavc¡ch

         mov       byte ptr ds:[b_0012h],3  ; po‡et diskov˜ch buffer–

         mov       al,cs:[a_0490]           ; aktivn¡ logick˜ disk
         inc       al                       ; aktivn¡ logick˜ disk + 1
         mov       ds:[b_0011h],al          ; aktivn¡ logick˜ disk + 1

;*       jmp       far ptr l_0166_0000      ; start 2. ‡ sti TBIOS.SYS
         db        0EAh, 00h, 00h
         dw        AdrSeg_b

                                          ;* chyba zaveden¡ syst‚mu
a_0CCB:  call      a_0E3B                   ; chyba zaveden¡ syst‚mu
a_0CCE:  jmp       short a_0CCE             ; zablokov n¡ syst‚mu

;==========================================================================
;        V˜po‡et po‡tu dn– od 1.1.1980
;==========================================================================

a_0CD0   PROC      near

         cmp       ch,20                    ; je stolet 20 nebo vy¨¨¡ ?
         jb        a_0CD8                   ; je stolet¡ 19
         add       cl,100                   ; p©i‡ten¡ 100 k roku
a_0CD8:  dec       dh                       ; mˆs¡c 0 a‘ 11
         cmp       dh,0Ch                   ; povolen‚ ‡¡slo mˆs¡ce ?
         jb        a_0CE1                   ; spr vn‚ ‡¡slo mˆs¡ce
         xor       dh,dh                    ; ‡¡slo mˆs¡ce = 0 (leden)
a_0CE1:  mov       ch,dh                    ; ‡¡slo mˆs¡ce
         push      cx                       ; £schova mˆs¡ce a roku
         mov       bp,sp                    ; ukazatel dat v z sobn¡ku
         xor       dh,dh                    ; DH <- 0
         dec       dx                       ; DX = den (0...)
         mov       cx,80                    ; rok 1980
a_0CEC:  call      a_0480                   ; nastaven¡ po‡tu dn– v £noru
         xor       bx,bx                    ; ukazatel mˆs¡c–
a_0CF1:  cmp       cl,[bp]                  ; je ji‘ dosa‘eno roku ?
         jb        a_0CFB                   ; nen¡ je¨tˆ dosa‘eno roku
         cmp       bl,[bp+1]                ; je dosa‘eno mˆs¡ce ?
         jae       a_0D0C                   ; je ji‘ dosa‘eno mˆs¡ce
a_0CFB:  mov       al,ds:[a_0391+bx]        ; po‡et dn– v mˆs¡ci BX
         cbw                                ; po‡et dn– v mˆs¡ci BX
         add       dx,ax                    ; zv˜¨en¡ po‡tu dn–
         inc       bl                       ; zv˜¨en¡ ukazatele mˆs¡c–
         cmp       bl,0Ch                   ; byly ji‘ v¨echny mˆs¡ce ?
         jb        a_0CF1                   ; nebyly - dal¨¡ mˆs¡c v roce
         inc       cx                       ; zv˜¨en¡ ukazatele rok–
         jmp       short a_0CEC             ; p©evod pro dal¨¡ rok
a_0D0C:  pop       ax                       
         mov       ax,dx                    ; po‡et dn– od 1.1.1980
         ret

a_0CD0   ENDP

;==========================================================================
;        P©evod CX a DX z BCD na bin rn¡ tvar
;==========================================================================

a_0D10   PROC      near

         push      cx
         push      dx
         mov       bp,sp                    ; kazatel na data
         mov       cx,4                     ; po‡et parametr–
a_0D17:  push      cx                       ; ‡¡ta‡ parametr–
         mov       al,ss:[bp]               ; parametr v k¢du BCD
         mov       ah,al                    ; parametr v k¢du BCD
         mov       cl,4                     ; po‡et rotac¡
         shr       ah,cl                    ; vy¨¨¡ ‡¡slice BCD
         and       al,0Fh                   ; ni‘¨¡ ‡¡slice BCD
         aad                                ; korekce ‡¡sla BCD na bin rn¡
         mov       ss:[bp],al               ; parametr v bin rn¡m tvaru
         inc       bp                       ; ukazatel na dal¨¡ parametr
         pop       cx                       ; ‡¡ta‡ parametr–
         loop      a_0D17                   ; dal¨¡ parametr
         pop       dx
         pop       cx
         ret

a_0D10   ENDP

;==========================================================================
;        Zji¨tˆn¡ parametr– pevn‚ho disku
;==========================================================================
                                            ; [SI+00h] velikost sektoru
                                            ; [SI+02h] sektor– na blok
                                            ; [SI+03h] rezervovan‚ sektory
                                            ; [SI+05h] po‡et tabulek FAT
                                            ; [SI+06h] po‡et adr. polo‘ek
                                            ; [SI+08h] celkem sektor–
                                            ; [SI+0ah] popisova‡ m‚dia
                                            ; [SI+0bh] sektor– na FAT
                                            ; [SI+0dh] sektor– na stopu
                                            ; [SI+0fh] po‡et hlav
                                            ; [SI+11h] po‡ t. rel. sektor

a_0D2F   PROC      near

         push      dx
         mov       ah,8
         int       13h                      ; poskyt. param. pevn‚ho disku
         jnc       a_0D39                   ; disk definov n OK
         pop       dx                       
         stc                                ; chyba
         ret

a_0D39:  mov       byte ptr ds:[a_0AEF],0   ; k¢d tab.FAT 1.pevn‚ho disku
         and       cl,3Fh                   ; po‡et sektor–
         mov       ds:[si+0Dh],cl           ; po‡et sektor–
         inc       dh                       ; po‡et hlav
         mov       ds:[si+0Fh],dh           ; po‡et hlav disku
         pop       dx                       ; ‡¡slo disku
         push      dx                       ; ‡¡slo disku
         mov       ah,15h
         int       13h                      ; ‡ten¡ typu DASD disku
         cmp       ah,70h                   ; je typ disku "p" ?
         mov       ax,dx                    ; po‡et sektor– - LOW
         pop       dx                       ; ‡¡slo disku
         jz        a_0D9C                   ; je pevn˜ disk "p"
                                          ;* pevn˜ disk ‡lenˆn˜ na odd¡ly
         xor       dh,dh                    ; hlava 0
         mov       cx,1                     ; zav dˆc¡ sektor
         mov       bx,07C00h                ; adresa k na‡ten¡ sektoru
         mov       ax,201h                  ; funkce ‡ten¡ 1 sektoru
         int       13h                      ; ‡ten¡ zav dˆc¡ho sektoru
         jc        a_0D84                   ; chyba
         cmp       word ptr es:[7c00h+1FEh],0AA55h ; je zav dˆc¡ sektor ?
         jne       a_0D84                   ; nen¡ zav dˆc¡ sektor
         mov       cx,4                     ; po‡et odd¡l– disku
         mov       bx,1BEh                  ; tabulka odd¡l– disku
a_0D75:  mov       dh,es:[7C00h+4+bx]       ; k¢d syst‚mu
         cmp       dh,1                     ; je FAT 12b ?
         je        a_0D86                   ; je tabulka FAT 12b
         add       bx,10h                   ; dal¨¡ odd¡l
         loop      a_0D75                   ; dal¨¡ odd¡l disku
a_0D84:  stc                                ; chyba - nen¡ ‘ dn˜ odd¡l
         ret                              
                                          ;* £schova velikosti disku
a_0D86:  mov       ds:[a_0AEF],dh           ; k¢d tabulky FAT pevn‚ho disku
         mov       ax,es:[7C00h+8+bx]       ; po‡ te‡n¡ rel. sektor
         mov       [si+11h],ax              ; po‡ te‡n¡ rel. sektor
         mov       ax,es:[7C00h+0Ch+bx]     ; velikost odd¡lu LOW
         mov       cx,es:[7C00h+0Eh+bx]     ; velikost odd¡lu HIGH
a_0D9C:  cmp       ax,0C8h                  ; je men¨¡ ne‘ 200 sektor– ?
         jb        a_0D84                   ; je men¨¡ - chyba
         or        cx,cx                    ; je vˆt¨¡ ne‘ 65 535 ?
         jnz       a_0D84                   ; je vˆt¨¡ - chyba
         mov       ds:[si+8],ax             ; velikost disku v sektorech
                                          ;* nalezen¡ parametr– pevn. disku
         cld                                ; smˆr nahoru
         mov       di,offset a_0AD7         ; tabulka pro typ disku 0
         cmp       byte ptr ds:[a_0AEF],0   ; k¢d tab. FAT pevn‚ho disku
         je        a_0DB6                   ; typ disku nezn m˜
         mov       di,offset a_0AE3         ; typ disku 1 - pevn˜ disk 16MB
a_0DB6:  cmp       ax,ds:[di]               
         jbe       a_0DBF                   ; nalezen nebo konec tabulky
         add       di,6                     
         jmp       short a_0DB6             ; dal¨¡ disk
a_0DBF:  mov       cx,ds:[di+4]             ; po‡et adres ©ov˜ch polo‘ek
         mov       ds:[si+6],cx             ; po‡et adres ©ov˜ch polo‘ek
         mov       cx,ds:[di+2]             ; sektor– na blok a © d bloku
         mov       ds:[si+2],ch             ; po‡et sektor– na alok. blok
         shr       ax,cl                    ; v˜po‡et po‡tu blok–
         mov       bx,ax                    ; celkov˜ po‡et alok. blok–
         inc       ax                       ; zaokrouhlen¡ na slovo
         shr       ax,1                     ; po‡et blok– / 2
         add       ax,bx                    ; po‡et blok– * 1.5
         add       ax,1FFh                  ; zaokrouhlen¡ na sektor
         mov       cl,9                     ; rotac¡ pro p©evod na sektor
         shr       ax,cl                    ; p©evod na sektory
         mov       ds:[si+0Bh],ax           ; po‡et sektor– jedn‚ FAT
         clc                                ; p©¡znak operace OK
         ret

a_0D2F   ENDP

;==========================================================================
;        Na‡ten¡ souboru do pamˆti od adresy ES:BX
;==========================================================================

a_0DE0   PROC      near
                                          ;* test, zda je ji‘ konec souboru
         xor       ch,ch                    ; CH <- 0
         mov       di,ds:[a_0AD5]           ; ‡¡slo alok. bloku ke ‡ten¡
         cmp       di,0FF8h                 ; je ji‘ konec souboru ?
         jae       a_0E2E                   ; je konec souboru
                                          ;* nalezen¡ spojit‚ oblasti blok–
         push      es                       ; £schova segmentu adresy
         push      bx                       ; £schova offsetu adresy
         xor       ax,ax                    ; AX <- 0
         mov       es,ax                    ; ES <- 0
a_0DF2:  inc       ch                       ; CH + 1 ‡¡ta‡ spojit˜ch blok–
         mov       bx,di                    ; ‡¡slo aloka‡n¡ho bloku
         shr       bx,1                     ; ‡¡slo bloku / 2
         mov       ax,es:[8000h+bx+di]      ; slovo z tabulky FAT
         jnc       a_0E03                   ; byl sud˜ aloka‡n¡ blok
         mov       cl,4                     ; po‡et rotac¡
         shr       ax,cl                    ; korekce pro lich˜ blok
a_0E03:  and       ax,0FFFh                 ; zamaskov n¡ ‡¡sla bloku
         inc       di                       ; zv˜¨en¡ ukazatele blok–
         cmp       ax,di                    ; n sleduje blok spojitˆ ?
         je        a_0DF2                   ; je to tento blok - dal¨¡
                                          
         xchg      ax,ds:[a_0AD5]           ; £schova n sleduj¡c¡ho bloku
         sub       ax,2                     ; ode‡ten¡ korekce
         xor       bx,bx                    ; BX <- 0
         mov       bl,ds:[si+2]             ; po‡et sektor– na blok
         mul       bx                       ; datov˜ sektor absolutnˆ
         add       ax,ds:[a_0AD3]           ; po‡ te‡n¡ sektor ROOT
         mov       dx,ax                    ; po‡ te‡n¡ sektor ke ‡ten¡
         mov       al,ch                    ; po‡et blok–
         mul       bl                       ; p©epo‡et na po‡et sektor–
         mov       cx,ax                    ; po‡et sektor– ke ‡ten¡
         pop       bx                       ; n vrat offsetu adresy
         pop       es                       ; n vrat segmentu adresy
                                          ;* na‡ten¡ £seku blok– souboru
         call      a_0894                   ; proveden¡ operace R/W/V
         jnc       a_0DE0                   ; operace OK - dal¨¡ £sek
         jmp       short a_0E2F             ; n vrat s chybou

a_0E2E:  clc
a_0E2F:  ret

a_0DE0   ENDP

;==========================================================================
;        Zobrazen¡ licen‡n¡ho textu
;==========================================================================

a_0E30   PROC      near
                                          ;* zobrazen¡ licen‡n¡ho textu
         mov       si,offset a_0E87         ; licen‡n¡ text
         mov       cx,offset(a_0e870-a_0e87); d‚lka textu
         nop                              
         call      a_0E53                   ; zobrazen¡ textu DS:SI
         ret

a_0E30   ENDP

;==========================================================================
;        Hl ¨en¡ - chyba zaveden¡ syst‚mu
;==========================================================================

a_0E3B   PROC      near
                                          ;* chyba zaveden¡ syst‚mu
         mov       al,ah                    ; k¢d chyby
         mov       cl,4                     
         shr       al,cl                    
         and       ax,0F0Fh                 ; ‡¡slo chyby
         or        word ptr ds:[a_0F54],ax  ; nastaven¡ chybov‚ho k¢du
         mov       si,offset a_0F31         ; text "Chyba ‡ten¡ syst‚mu"
         mov       cx,offset(a_0f310-a_0f31); d‚lka
         nop                                
         call      a_0E53                   ; zobrazen¡ textu DS:SI
         ret

a_0E3B   ENDP

;==========================================================================
;        Zobrazen¡ textu
;==========================================================================

a_0E53   PROC      near
                                          ;* zobrazen¡ textu DS:SI
         lodsb                              ; znak k zobrazen¡
         int       29h                      ; zobrazen¡ znaku
         loop      a_0E53                   ; dal¨¡ znak k zobrazen¡
         ret

a_0E53   ENDP

a_0E59   db        13,10,'Illegal to use MS-DOS '
         db        'V3.x on this machine',13,10

a_0e87 db  13,10,'Toshiba  Personal Computer  MS-DOS  Version 2.11 / R2A     '
       db  13,10,10,'    (C) Copyright Toshiba   Corporation 1983, 1988'
       db  13,10,'    (C) Copyright Microsoft Corporation 1981, 1984'
       db  13,10,' ',10
a_0e870  label     byte

a_0f31   db        13,10,'Error loading operating system : '
a_0f54   db        '00'
a_0f310  label     byte

         db        10 dup (0)               ; zarovn n¡ na odstavec

seg_a_k  label     byte

seg_a    ends

; *****************************************************************************
;
;
;
; *****************************************************************************
;þ
a_0006   equ       6
a_0008   equ       8
a_0013   equ       13h
a_0015   equ       15h
a_0043   equ       43h
a_072E   equ       72Eh
a_077E   equ       77Eh
a_07EC   equ       7ECh

seg_b    segment   para
         assume    cs:seg_b, ds:seg_b
         org       0
                                            ; tato ‡ st se provozuje jako
                                            ; kopie pod vrcholem pamˆti RAM
                                            ; kam se nejd©¡ve p©enese

Seg_b_z  label     byte

         jmp       short b_0065             ; start 2. modulu TBIOS.SYS
         nop

b_0003   dw        0                        ; defini‡n¡ tabulka DOS
b_0005   dw        0                        ; segment s na‡ten˜m TDOS.SYS
b_0007   dd        0                        ; adresa za‡. modulu TDOS.SYS
b_000B   dd        0                        ; adresa z hlav¡ 1. za©¡zen¡
b_000F   dw        1                        ; voln  pamˆŸ v odstavc¡ch

                                          ;* prvn¡ FCB pro COMMAND.COM
b_0011   db        0                        ; aktivn¡ logick˜ disk + 1
b_0012   db        2                        ; po‡et diskov˜ch buffer–

b_0013   db        8                        ; po‡et instalovan˜ch za©¡zen¡
                                            ; (max. po‡et soubor–)

                                          ;* p©¡kazov˜ © dek COMMAND.COM
b_0014   db        2                        ; d‚lka textu parametr–
b_0015   db        0                        ; oddˆlovac¡ znak parametr–
         db        'P'                      ; parametr - permanentn¡ re‘im
         db        29 dup (0)               ; p©¡kaz. © dek COMMAND.COM

b_0034   db        0                        ; druh˜ FCB pro COMMAND.COM

                                          ;* tabulka parametr– pro COMMAND
b_0035   dw        0                        ; adresa segmentu prost©ed¡
         dw        b_0014                   ; adresa p©¡kazov‚ho © dku
         dw        AdrSeg_B
         dw        b_0011                   ; adresa prvn¡ho FCB
         dw        AdrSeg_B
         dw        b_0034                   ; adresa druh‚ho FCB
         dw        AdrSeg_B

b_0043   dw        0                        ; ‡¡ta‡ znak– CONFIG.SYS

b_0045   dw        0

b_0047   dd        0                        ; adresa konce posled. za©¡zen¡

b_004B   dw        0                        ; adresa za‡ tku bloku dat
b_004D   dw        0                        ; segment bloku pamˆti pro data

         db        16h
         db        12 dup (0)
b_005C   db        0
b_005D   dw        0
b_005F   dw        0
b_0061   dw        0, 0

; -----------------------------------------------------------------------------
;         P©enesen¡ modulu pod vrchol RAM
; -----------------------------------------------------------------------------

b_0065:  cld
         xor       si,si                    ; SI <- 0
         mov       di,si                    ; DI <- 0

                                          ;* ur‡en¡ celkov‚ pamˆti
         mov       cx,cs:[b_000f]           ; voln  pamˆŸ v odstavc¡ch
         cmp       cx,1                     ; byla pamˆŸ ji‘ ur‡ena ?
         jne       b_0091                   ; pamˆŸ ji‘ byla ur‡ena
         mov       cx,800h                  ; po‡ te‡n¡ segment 800h
         xor       bx,bx                    ; offset za‡ tku pamˆti
b_0079:  inc       cx                       ; zv˜¨en¡ adresy segmentu
         jz        b_008C                   ; je ji‘ cel  pamˆŸ
         mov       ds,cx                    ; segment pamˆti
         mov       al,ds:[bx]               ; bajt z m¡sta v pamˆti
         not       al                       ; negace hodnoty
         mov       ds:[bx],al               ; ulo‘en¡ negace
         cmp       al,ds:[bx]               ; je spr vn  hodnota ?
         not       al                       ; p–vodn¡ hodnota bajtu
         mov       ds:[bx],al               ; n vrat bajtu
         jz        b_0079                   ; je je¨tˆ pamˆŸ RAM - dal¨¡
b_008C:  mov       cs:[b_000F],cx           ; celkov  pamˆŸ v odstavc¡ch

                                          ;* p©enesen¡ pod vrchol pamˆti
b_0091:  mov       ax,cs                    ; AX <- 0166h
         mov       ds,ax                    ; DS <- 0166h tento segment
         mov       ax,(offset(Seg_B_K-Seg_B_Z)+0fh) AND not 0fh ; d‚lka 2. modulu TBIOS.SYS
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©epo‡et na odstavce
         sub       cx,ax                    ; adresa pod koncem pamˆti
         mov       es,cx                    ; segment pro ulo‘en¡ modulu
         mov       cx,(offset(Seg_B_K-Seg_B_Z)+1) AND not 1 ; d‚lka modulu
         shr       cx,1                     ; d‚lka ve slovech
         rep       movsw                    ; p©enos pod vrchol RAM
         push      es                       ; segment kopie modulu
         mov       ax,offset b_00b1         ; adresa pokra‡. na konci RAM
         push      ax                       ; offset pro skok do kopie
         retf                               ; skok do kopie v RAM
;þ
b_00b1:  mov       ax,cs:[b_0005]
         mov       ds,ax
         mov       ax,word ptr cs:[b_0007+2]
         mov       es,ax
         xor       si,si
         mov       di,si
         mov       cx,2800h
         rep       movsw
         lds       si,cs:b_000B
         mov       dx,cs:b_000F
         cli       
         mov       ax,cs
         mov       ss,ax
         mov       sp,0D9h
         sti       
         call      ss:b_0007
         mov       ss:b_0005,es
         mov       word ptr ss:b_0003,di
;*       call      far ptr s_0070_0A32              ;*
         db         9Ah, 32h, 0Ah, 70h, 00h
         sti       
         cld       
         mov       bx,cs
         sub       bx,10h
         mov       es,bx
         xor       si,si
         mov       di,si
         mov       cx,80h
         rep       movsw
         mov       ah,50h             ; 'P'
         int       21h
         push      ds
         push      cs
         pop       ds
         mov       dx,offset int_24
         mov       ax,2524h
         int       21h
         pop       ds
         mov       dl,ss:b_0011
         or        dl,dl
         jz        b_011E
         dec       dl
         mov       ah,0Eh
         int       21h
b_011E:            
         call      b_01A6
         push      cs
         pop       ds
         mov       al,b_0013
         cbw       
         mov       cx,ax
         xor       bx,bx
         mov       ah,3Eh             ; '>'
         int       21h
         mov       bx,2

b_0132:            
         mov       ah,3Eh             ; '>'
         int       21h
         inc       bx
         loop      b_0132

         mov       dx,offset b_06FD+9
         mov       al,2
         mov       ah,3Dh             ; '='
         stc       
         int       21h
         jnc       b_014A
         call      b_066C
         jmp       short b_015D
b_014A:            
         push      ax
         mov       bx,1
         mov       ah,3Eh             ; '>'
         int       21h
         pop       ax
         mov       bx,ax
         mov       ah,45h             ; 'E'
         int       21h
         mov       ah,45h             ; 'E'
         int       21h
b_015D:            
         mov       dx,offset b_06FD+12h
         mov       al,2
         call      b_06C7
         mov       dx,offset b_06FD+1Bh
         mov       al,1
         call      b_06C7
         mov       si,offset b_0015
         push      ds
         pop       es
         mov       di,si
         mov       cl,0FFh
b_0176:            
         inc       cl
         lodsb     
         stosb     
         or        al,al
         jnz       b_0176
         dec       di
         mov       al,0Dh
         stosb     
         mov       b_0014,cl
         push      cs
         pop       es
         mov       dx,offset b_06FD+30h
         mov       bx,offset b_0035
         mov       [bx+4],cs
         mov       [bx+8],cs
         mov       [bx+0Ch],cs
         xor       ax,ax
         mov       ah,4Bh             ; 'K'
         stc       
         int       21h
         mov       dx,7D8h
         call      b_066C
b_01A4:            
         jmp       short b_01A4

;==========================================================================
;                  SUBROUTINE
;==========================================================================

b_01A6   PROC      near
         push      cs
         pop       ds
         mov       bx,0FFFFh
         mov       ah,48h             ; 'H'
         int       21h
         mov       ah,48h             ; 'H'
         int       21h
         mov       b_004D,ax
         mov       word ptr b_0047+2,ax
         mov       ax,3700h
         int       21h
         mov       b_0015,dl
         mov       dx,offset b_06FD+24h
         mov       ax,3D00h
         stc       
         int       21h
         jc        b_01D0
         jmp       b_0279
b_01D0:            
         push      cs
         pop       ds
         call      b_05EF
         mov       al,b_0013
         sub       al,5
         jbe       b_0217
         cbw       
         mov       bx,word ptr ds:[b_0047]
         mov       dx,word ptr ds:[b_0047+2]
         lds       di,dword ptr ds:[b_0003]
         lds       di,dword ptr [di+4]
         mov       [di],bx
         mov       [di+2],dx
         push      cs
         pop       ds
         les       di,dword ptr b_0047
         mov       word ptr es:[di],0FFFFh
         mov       es:[di+4],ax
         mov       bl,28h             ; '('
         mul       bl
         mov       cx,ax
         add       word ptr ds:[b_0047],ax
         mov       ax,6
         add       word ptr ds:[b_0047],ax
         add       di,ax
         xor       ax,ax
         rep       stosb
b_0217:            
         call      b_05EF
         dec       b_0012
         jz        b_024F
         push      ds
         les       di,dword ptr b_0047
         lds       bx,dword ptr b_0003
         mov       ax,[bx+13h]
         mov       es:[di],ax
         mov       ax,[bx+15h]
         mov       es:[di+2],ax
         mov       [bx+13h],di
         mov       [bx+15h],es
         mov       word ptr es:[di+4],0FFh
         mov       bx,[bx+11h]
         pop       ds
         add       bx,10h
         add       word ptr ds:[b_0047],bx
         jmp       short b_0217
b_024F:            
         call      b_05EF
         mov       bx,word ptr b_0047+2
         mov       ax,b_004D
         mov       es,ax
         sub       bx,ax
         mov       ah,4Ah             ; 'J'
         int       21h
         push      es
         mov       ax,es
         dec       ax
         mov       es,ax
         mov       word ptr es:[1],8
         pop       es
         retn      
b_0270:            
         mov       dx,a_077E
         call      b_068C
         jmp       b_0306
b_0279:            
         mov       bx,ax
         xor       cx,cx
         xor       dx,dx
         mov       ax,4202h
         int       21h
         mov       ds:a_0043,ax
         xor       dx,dx
         mov       ax,4200h
         int       21h
         mov       dx,cs
         mov       ax,ds:a_0043
         add       ax,0Fh
         mov       cl,4
         shr       ax,cl
         sub       dx,ax
         sub       dx,11h
         mov       ds,dx
         mov       es,dx
         xor       dx,dx
         mov       cx,ss:b_0043
         mov       ah,3Fh             ; '?'
         stc       
         int       21h
         pushf     
         push      cs
         pop       ds
         push      ax
         mov       ah,3Eh             ; '>'
         int       21h
         pop       ax
         popf      
         jc        b_02BF
         cmp       cx,ax
         je        b_02C8
b_02BF:            
         mov       dx,721h
         call      b_066C
b_02C5:            
         jmp       b_01D0
b_02C8:            
         call      b_0532
         call      b_0519
b_02CE:            
         jc        b_02C5
         mov       ah,al
         call      b_0519
         cmp       ah,42h             ; 'B'
         jne       b_02E9
         call      b_063D
         jz        b_0306
         cmp       ax,64h
         jae       b_0270
         mov       b_0012,al
         jmp       short b_0306
b_02E9:            
         cmp       ah,43h             ; 'C'
         je        b_02F1
         jmp       short b_030D
         db        90h
b_02F1:            
         cmp       al,4Fh             ; 'O'
         jne       b_0306
         call      b_0519
         jc        b_02C5
         cmp       al,4Eh             ; 'N'
         jne       b_0306
         mov       ah,33h             ; '3'
         mov       al,1
         mov       dl,al
         int       21h
b_0306:            
         push      cs
         pop       ds
         call      b_05C7
         jmp       short b_02CE
b_030D:            
         cmp       ah,44h             ; 'D'
         je        b_0315
         jmp       b_049A
b_0315:            
         mov       bx,cs
         mov       ds,bx
         mov       b_0061,si
         mov       word ptr b_0061+2,es
         call      b_05EF
         xor       ax,ax
         mov       word ptr b_0007,ax
         mov       ax,word ptr b_0047+2
         mov       word ptr b_0007+2,ax
         mov       b_004B,ax
         push      es
         pop       ds
         mov       dx,si
         mov       es,bx
         mov       bx,offset b_0047+2
         mov       al,3
         mov       ah,4Bh             ; 'K'
         stc       
         int       21h
         push      ds
         pop       es
         push      cs
         pop       ds
         jnc       b_034D
b_0348:            
         call      b_0670
         jmp       short b_0306
b_034D:            
         push      es
         push      si
         push      cs
         pop       es
         mov       bx,a_0006
         call      b_060A
         mov       bx,a_0008
         call      b_060A
         push      cs
         pop       ds
         mov       ax,b_005F
         cmp       ax,b_000F
         jb        b_036C
         pop       si
         pop       es
         jmp       short b_0348
b_036C:            
         mov       word ptr b_0047+2,ax
         mov       ax,b_005D
         mov       word ptr ds:[b_0047],ax
         lds       dx,b_0007
         mov       si,dx
         add       si,4
         les       di,dword ptr cs:b_0003
         mov       ax,[si]
         test      ax,8000h
         jz        b_03A7
         test      ax,1
         jz        b_0397
         mov       es:[di+0Ch],dx
         mov       es:[di+0Eh],ds
b_0397:            
         test      ax,8
         jz        b_03A4
         mov       es:[di+8],dx
         mov       es:[di+0Ah],ds
b_03A4:            
         jmp       b_044B
b_03A7:            
         mov       al,cs:b_005C
         or        al,al
         jnz       b_03BC
         mov       word ptr cs:[b_0047],0
         mov       ax,0FFFFh
         jmp       b_0470
b_03BC:            
         cbw       
         mov       cx,ax
         mov       dh,ah
         mov       dl,es:[di+10h]
         add       es:[di+10h],al
         lds       bx,dword ptr cs:b_0061

b_03CE:            
         les       bp,dword ptr cs:b_0003
         les       bp,dword ptr es:[bp]
b_03D7:            
         cmp       word ptr es:[bp+18h],0FFFFh
         je        b_03E4
         les       bp,dword ptr es:[bp+18h]
         jmp       short b_03D7
b_03E4:            
         mov       ax,word ptr cs:[b_0047]
         mov       es:[bp+18h],ax
         mov       ax,word ptr cs:b_0047+2
         mov       es:[bp+1Ah],ax
         les       bp,dword ptr cs:b_0047
         add       word ptr cs:[b_0047],5Eh
         mov       word ptr es:[bp+18h],0FFFFh
         mov       byte ptr es:[bp+17h],0FFh
         mov       si,[bx]
         inc       bx
         inc       bx
         mov       es:[bp],dx
         mov       ah,53h             ; 'S'
         int       21h
         mov       ax,es:[bp+2]
         push      es
         les       di,dword ptr cs:b_0003
         cmp       ax,es:[di+11h]
         pop       es
         jbe       b_0435
         pop       si
         pop       es
         mov       dx,7A2h
         mov       bx,7A5h
         call      b_0676
         jmp       b_0306
b_0435:            
         push      ds
         push      dx
         lds       dx,cs:b_0007
         mov       es:[bp+12h],dx
         mov       es:[bp+14h],ds
         pop       dx
         pop       ds
         inc       dx
         inc       dh
         loop      b_03CE

b_044B:            
         les       di,dword ptr cs:b_0003
         mov       cx,es:[di+17h]
         mov       dx,es:[di+19h]
         lds       si,cs:b_0007
         mov       es:[di+17h],si
         mov       es:[di+19h],ds
         mov       ax,[si]
         mov       word ptr cs:b_0007,ax
         mov       [si],cx
         mov       [si+2],dx
b_0470:            
         pop       si
         pop       es
         inc       ax
         jz        b_0478
         jmp       b_034D
b_0478:            
         jmp       b_0306
b_047B:            
         cmp       ah,51h             ; 'Q'
         jne       b_04AE
         call      b_063D
         jz        b_0478
         or        ah,ah
         jnz       b_0478
         mov       ah,38h             ; '8'
         mov       dx,0FFFFh
         int       21h
         jnc       b_0478
         mov       dx,a_07EC
         call      b_068C
         jmp       short b_0478
b_049A:            
         cmp       ah,46h             ; 'F'
         jne       b_047B
         call      b_063D
         jz        b_0478
         cmp       ax,64h
         jae       b_0504
         mov       ds:a_0013,al
         jmp       short b_0478
b_04AE:            
         cmp       ah,57h             ; 'W'
         jne       b_04C1
         mov       dl,al
         mov       ax,3701h
         mov       ds:a_0015,dl
         int       21h
         jmp       b_0306
b_04C1:            
         cmp       ah,41h             ; 'A'
         jne       b_04D4
         cmp       al,46h             ; 'F'
         jne       b_04D1
         mov       ax,3703h
         xor       dl,dl
         int       21h
b_04D1:            
         jmp       b_0306
b_04D4:            
         cmp       ah,53h             ; 'S'
         jne       b_0504
         mov       byte ptr ds:a_0015,0
         mov       di,a_072E
         mov       [di-1],al
b_04E4:            
         call      b_0519
         or        al,al
         jz        b_0507
         cmp       al,20h             ; ' '
         jb        b_04F4
         mov       [di],al
         inc       di
         jmp       short b_04E4
b_04F4:            
         mov       byte ptr [di],0
         call      b_0519
         cmp       al,0Ah
         jne       b_0501
         call      b_0519
b_0501:            
         jmp       b_02CE
b_0504:            
         jmp       b_0270
b_0507:            
         mov       byte ptr [di],0
         mov       di,15h
b_050D:            
         call      b_0519
         cmp       al,20h             ; ' '
         jb        b_04F4
         mov       [di],al
         inc       di
         jmp       short b_050D
b_01A6   ENDP      


;==========================================================================
;                  SUBROUTINE
;==========================================================================

b_0519   PROC      near
         mov       cx,b_0043
         jcxz      b_0530
         mov       si,b_0045
         mov       al,es:[si]
         dec       b_0043
         inc       b_0045
         clc       
         retn      
b_0530:            
         stc       
         retn      
b_0519   ENDP      


;==========================================================================
;                  SUBROUTINE
;==========================================================================

b_0532   PROC      near
         mov       cx,ds:a_0043
         jcxz      b_0530
         call      b_05D4
         xor       si,si
         mov       di,si
b_053F:            
         call      b_059B
         cmp       al,20h             ; ' '
         jb        b_053F
         push      cx
         push      si
         push      di
         mov       bp,si
         dec       bp
         mov       si,offset b_073A
         mov       ch,0
b_0551:            
         mov       di,bp
         mov       cl,[si]
         inc       si
         jcxz      b_0566
         repe      cmpsb
         lahf      
         add       si,cx
         sahf      
         lodsb     
         jnz       b_0551
         pop       di
         pop       si
         pop       cx
         jmp       short b_056B
b_0566:            
         pop       di
         pop       si
         pop       cx
         mov       al,5Ah             ; 'Z'
b_056B:            
         stosb     
b_056C:            
         call      b_0593
         call      b_05A8
         jnz       b_056C
         call      b_059B
         stosb     
b_0578:            
         call      b_0593
         stosb     
         cmp       al,20h             ; ' '
         ja        b_0578
         cmp       al,0Ah
         je        b_053F
         mov       byte ptr es:[di-1],0
b_0589:            
         call      b_0593
         stosb     
         cmp       al,0Ah
         jne       b_0589
         jmp       short b_053F
b_0532   ENDP      


;==========================================================================
;                  SUBROUTINE
;==========================================================================

b_0593   PROC      near
         jcxz      b_05BB
         mov       al,es:[si]
         inc       si
         dec       cx
         retn      

;==== External En==try into Subroutine ====================================

b_059B:            
b_059B:            
         jcxz      b_05BB
         mov       al,es:[si]
         inc       si
         dec       cx
         call      b_05A8
         jz        b_059B

b_05A7:            
         retn      

;==== External En==try into Subroutine ====================================

b_05A8:            
         cmp       al,20h             ; ' '
         je        b_05A7
         cmp       al,9
         je        b_05A7
         cmp       al,3Dh             ; '='
         je        b_05A7
         cmp       al,2Ch             ; ','
         je        b_05A7
         cmp       al,3Bh             ; ';'
         retn      
b_05BB:            
         pop       cx
         mov       b_0043,di
         xor       si,si
         mov       b_0045,si
         retn      
b_0593   ENDP      


;==========================================================================
;                  SUBROUTINE
;==========================================================================

b_05C7   PROC      near
b_05C7:            
         call      b_0519
         jc        b_05D3
         cmp       al,0Ah
         jne       b_05C7
         call      b_0519

b_05D3:            
         retn      
b_05C7   ENDP      


;==========================================================================
;                  SUBROUTINE
;==========================================================================

b_05D4   PROC      near
         push      cx
         push      si
         push      ds
         push      es
         pop       ds
         xor       si,si

b_05DB:            
         lodsb     
         cmp       al,61h             ; 'a'
         jb        b_05E9
         cmp       al,7Ah             ; 'z'
         ja        b_05E9
         sub       al,20h             ; ' '
         mov       [si-1],al
b_05E9:            
         loop      b_05DB

         pop       ds
         pop       si
         pop       cx
         retn      
b_05D4   ENDP      


;==========================================================================
;                  SUBROUTINE
;==========================================================================

b_05EF   PROC      near
         mov       ax,word ptr ss:[b_0047]
         add       ax,0Fh
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1
         add       word ptr ss:[b_0047+2],ax
         xor       ax,ax
         mov       word ptr ss:[b_0047],ax
         retn      
b_05EF   ENDP      


;==========================================================================
;                  SUBROUTINE
;==========================================================================

b_060A   PROC      near
         mov       ds,word ptr cs:b_0007+2
         add       bx,word ptr cs:b_0007
         mov       ax,[bx]
         push      word ptr cs:b_0007
         mov       word ptr cs:b_0007,ax
         mov       bx,4Fh
         call      ss:b_0007
         pop       word ptr cs:b_0007
         retn      
b_060A   ENDP      

b_062D:            
         pop       ax
         jmp       b_0270

;==========================================================================
;                  SUBROUTINE
;==========================================================================

b_0631   PROC      near
         sub       al,30h             ; '0'
         jc        b_063B
         cmp       al,9
         ja        b_063B
         clc       
         retn      
b_063B:            
         stc       
         retn      
b_0631   ENDP      


;==========================================================================
;                  SUBROUTINE
;==========================================================================

b_063D   PROC      near
         xor       bx,bx
b_063F:            
         call      b_0631
         jc        b_062D
         xchg      ax,bx
         push      bx
         mov       bx,0Ah
         mul       bx
         pop       bx
         add       al,bl
         adc       ah,0
         jc        b_062D
         xchg      ax,bx
         call      b_0519
         jc        b_0667
         or        al,al
         jnz       b_063F
         inc       ss:b_0043
         dec       ss:b_0045
b_0667:            
         mov       ax,bx
         or        ax,ax
         retn      
b_063D   ENDP      


;==========================================================================
;                  SUBROUTINE
;==========================================================================

b_066C   PROC      near
         push      cs
         pop       es
         mov       si,dx

;==== External En==try into Subroutine ====================================

b_0670:            
         mov       bx,7A2h
         mov       dx,offset b_0775+51h

;==== External En==try into Subroutine ====================================

b_0676:            
         push      cs
         pop       ds
         mov       ah,9
         int       21h
b_067C:            
         mov       dl,es:[si]
         or        dl,dl
         jz        b_068A
         mov       ah,2
         int       21h
         inc       si
         jmp       short b_067C
b_068A:            
         mov       dx,bx

;==== External En==try into Subroutine ====================================

b_068C:            
         mov       ah,9
         int       21h
         retn      
b_066C   ENDP      

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      ds
         push      bx
         xor       ax,ax
         mov       ah,3Dh             ; '='
         stc       
         int       21h
         pop       dx
         jc        b_06C0
         push      es
         pop       ds
         mov       bx,ax
         mov       cx,0FF00h
         mov       ah,3Fh             ; '?'
         stc       
         int       21h
         jc        b_06C0
         mov       si,dx
         cmp       word ptr [si],5A4Dh
         jne       b_06BB
         stc       
         jmp       short b_06C0
b_06BB:            
         mov       ah,3Eh             ; '>'
         stc       
         int       21h
b_06C0:            
         pop       ds
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         retn      

;==========================================================================
;                  SUBROUTINE
;==========================================================================

b_06C7   PROC      near
         call      b_06E4
         jnc       b_06D3
b_06CC:            
         mov       dx,offset b_06FD
         call      b_06E4

b_06D2:            
         retn      
b_06D3:            
         xor       ax,ax
         mov       ah,44h             ; 'D'
         int       21h
         test      dl,80h
         jnz       b_06D2
         mov       ah,3Eh             ; '>'
         int       21h
         jmp       short b_06CC
b_06C7   ENDP      


;==========================================================================
;                  SUBROUTINE
;==========================================================================

b_06E4   PROC      near
         mov       ah,3Dh             ; '='
         stc       
         int       21h
         retn      
b_06E4   ENDP      


;==========================================================================
;                  
;                  External Entry Point
;                  
;==========================================================================

int_24   proc      far
         add       sp,6
         pop       ax
         pop       bx
         pop       cx
         pop       dx
         pop       si
         pop       di
         pop       bp
         pop       ds
         pop       es
         push      ax
         mov       ah,19h
         int       21h
         pop       ax
         iret      
int_24   endp      

b_06FD   db        '\DEV\NUL', 0
         db        '\DEV\CON', 0
         db        '\DEV\AUX', 0
         db        '\DEV\PRN', 0
         db        '\CONFIG.SYS', 0
         db        '\COMMAND.COM', 0
b_073A   db        7
         db        'BUFFERSB'
         db         05h, 42h, 52h, 45h, 41h, 4Bh
         db         43h, 05h, 53h, 48h, 45h, 4Ch
         db         4Ch, 53h, 06h, 44h, 45h, 56h
         db         49h, 43h, 45h, 44h, 05h
         db        'FILESF', 8, 'SWITCHARW', 8, 'AVA'
         db        'ILDEVA'
         db        7
b_0775   db        'COUNTRYQ', 0
         db        0Dh, 0Ah, 'Unrecognized command i'
         db        'n CONFIG.SYS', 0Dh, 0Ah, '$'
         db        0Dh, 0Ah, 'Sector size too large '
         db        'in file $'
         db        0Dh, 0Ah, 'Bad or missing $'
         db        'Command Interpreter', 0
         db        0Dh, 0Ah, 'Bad Country code', 0Dh
         db        0Ah, '$'

seg_b_k  label     byte

seg_b    ends
         end     start
