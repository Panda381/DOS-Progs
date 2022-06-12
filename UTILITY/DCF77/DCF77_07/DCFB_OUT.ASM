
; -----------------------------------------------------------------------------
;        vys¡l n¡ data v Bin rn¡m protokolu
; -----------------------------------------------------------------------------

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ rozbor p©¡kazov‚ho © dku (mus¡ b˜t nic nebo znak "1" a‘ "4")

Start:   mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         mov       cl,ds:[si-1]             ; d‚lka zadan‚ho textu
         mov       ch,0
         cld
Rozbor1: mov       al,0                     ; implicitn¡ port COM 1
         jcxz      Rozbor2                  ; nen¡ dal¨¡ znak
         lodsb                              ; na‡ten¡ znaku z p©¡kazov‚ho © dku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e zbyl˜ch znak–
         cmp       al," "                   ; mezera nebo ©¡dic¡ znak ?
         jbe       Rozbor1                  ; mezera nebo tabul tor se ignoruje
         sub       al,"1"                   ; korekce na ‡¡slo portu
         cmp       al,3                     ; je platn‚ ‡¡slo portu COM ?
         jbe       Rozbor2                  ; je to platn‚ ‡¡slo portu COM

; ------ chyba zad n¡ parametr– - zobrazen¡ n povˆdy

Chyba:   mov       dx,offset ErrTxt        ; text n povˆdy
         mov       ah,9
         int       21h                      ; zobrazen¡ textu n povˆdy
         int       20h

; ------ adresa portu COM (AL=‡¡slo portu COM 0 a‘ 3)

Rozbor2: push      ds
         mov       ah,0                     ; AX = ‡¡slo portu COM 0 a‘ 3
         xchg      ax,bx                    ; BX <- ‡¡slo portu COM 0 a‘ 3
         shl       bx,1                     ; offset v tabulce BIOS
         mov       ax,40h
         mov       ds,ax                    ; DS <- datov˜ segment BIOS
         mov       ax,ds:[bx]               ; adresa portu COM
         or        ax,ax                    ; je port COM platn˜ ?
         pop       ds
         jz        Chyba                    ; port COM nen¡ platn˜
         mov       ds:[AdrPort],ax          ; adresa portu COM

; ------ zobrazen¡ textu

         mov       dx,offset DispTxt
         mov       ah,9
         int       21h

; ------ vysl n¡ oddˆlova‡e zpr vy

Vysilej1:mov       al,60                    ; oddˆlova‡ zpr vy
         call      OutByte                  ; vysl n¡ oddˆlova‡e zpr vy

; ------ na‡ten¡ data

         mov       ah,2ah
         int       21h                      ; poskytnut¡ syst‚mov‚ho data

; ------ vysl n¡ roku

         xchg      ax,cx                    ; AX <- rok
         sub       ax,1980                  ; offset od roku 1980
         call      OutByte                  ; vysl n¡ roku

; ------ vysl n¡ mˆs¡ce

         mov       al,dh                    ; AL <- mˆs¡c
         call      OutByte                  ; vysl n¡ mˆs¡ce

; ------ vysl n¡ dne

         xchg      ax,dx                    ; AL <- den
         call      OutByte                  ; vysl n¡ dne

; ------ na‡ten¡ ‡asu

         mov       ah,2ch
         int       21h                      ; na‡ten¡ syst‚mov‚ho ‡asu

; ------ vysl n¡ hodiny

         mov       al,ch                    ; AL <- hodina
         call      OutByte                  ; vysl n¡ hodiny

; ------ vysl n¡ minuty

         xchg      ax,cx                    ; AL <- minuta
         call      OutByte                  ; vysl n¡ minuty

; ------ vysl n¡ sekundy

         mov       al,dh                    ; AL <- sekunda
         call      OutByte                  ; vysl n¡ sekundy
         jmp       short Vysilej1

; -----------------------------------------------------------------------------
;        vysl n¡ bajtu AL
; -----------------------------------------------------------------------------

OutByte  PROC      NEAR

         push      ax
         push      dx

; ------ obsluha p©eru¨en¡ programu

OutByte2:push      ax

         mov       ah,1
         int       16h                      ; je nˆjak  kl vesa ?
         jz        OutByte3                 ; nen¡ nic stisknuto
         mov       ah,0
         int       16h                      ; na‡ten¡ znaku z kl vesnice
         int       20h                      ; konec programu

; ------ na‡ten¡ stavov‚ho registru

OutByte3:mov       dx,ds:[AdrPort]          ; adresa portu COM
         add       dx,5                     ; stavov˜ registr linky
         in        al,dx                    ; na‡ten¡ stavov‚ho registru linky
         sub       dx,5                     ; datov˜ registr COM

; ------ test, zda byl p©ijat nˆjak˜ znak

         test      al,1                     ; je p©ijat nˆjak˜ znak ?
         jz        OutByte4                 ; nen¡ p©ijat ‘ dn˜ znak

; ------ p©¡jem a zobrazen¡ znaku

         push      ax
         push      dx
         in        al,dx                    ; p©¡jem znaku
         and       al,111111b               ; ponech  pouze platn‚ bity
         or        al,40h                   ; korekce znaku na ASCII
         xchg      ax,dx                    ; DL <- p©ijat˜ znak
         mov       ah,2
         int       21h                      ; zobrazen¡ p©ijat‚ho znaku
         pop       dx
         pop       ax

; ------ test, zda je vys¡lac¡ buffer pr zdn˜


OutByte4:test      al,20h                   ; je vys¡lac¡ registr pr zdn˜ ?

         pop       ax
         jz        OutByte2                 ; vys¡lac¡ registr nen¡ pr zdn˜

; ------ vysl n¡ znaku na port COM

         or        al,40h                   ; transpozice znaku na ‡¡slici
         out       dx,al                    ; vysl n¡ znaku na port COM

         pop       dx
         pop       ax
         ret

OutByte  ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

AdrPort  dw        0                        ; adresa portu COM 1

ErrTxt   db        'Zvolen neplatny port COM !',13,10,'$'

DispTxt  db        'Vysilam datum a cas na port COM1. Preruseni stiskem libovolne klavesy...',13,10,'$'

Code     ENDS
         END       Start
