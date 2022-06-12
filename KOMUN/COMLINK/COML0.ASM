
; *****************************************************************************
;
;                                COMLINK0.SYS
;             Program pro spojen¡ po‡¡ta‡– - nulov˜ syst‚mov˜ ovlada‡
;
; *****************************************************************************

; Soubor COMLINK0.SYS slou‘¡ k nalezen¡ ovlada‡– za©¡zen¡ programem COMLINK.
; Soubor se instaluje jako ovlada‡ za©¡zen¡ do souboru CONFIG.SYS. Podm¡nkou
; je, aby byl nainstalov n jako £plnˆ posledn¡ ovlada‡.


code     segment
         assume    cs:code,ds:code
         org       0

                                          ;* z hlav¡ ovlada‡e za©¡zen¡
         dd        -1                       ; adresa n sleduj¡c¡ho za©¡zen¡
         dw        0c000h                   ; atributy za©¡zen¡ (znak. za©¡zen¡)
         dw        offset strateg           ; offset rutiny strategie
         dw        offset prerus            ; offset rutiny p©eru¨en¡
         db        '$$COML$$'               ; jm‚no za©¡zen¡

; -----------------------------------------------------------------------------

adrzahl  dd        0                        ; adresa z hlav¡ za©¡zen¡

; -----------------------------------------------------------------------------

strateg  proc      far                    ;* obsluha rutiny strategie

         mov       word ptr cs:[adrzahl],bx ; offset adresy z hlav¡ za©¡zen¡
         mov       word ptr cs:[adrzahl+2],es ; segment adresy z hlav¡ za©¡zen¡
         ret

strateg  endp
; -----------------------------------------------------------------------------
prerus   proc      far                    ;* obsluha rutiny p©eru¨en¡

         push      bx
         push      es                       ; £schova ES
         les       bx,cs:[adrzahl]          ; adresa z hlav¡ za©¡zen¡

                                          ;* kontrola ‡¡sla povelu
         mov       word ptr es:[bx+3],8103h ; chyba - nezn m˜ povel
         cmp       byte ptr es:[bx+2],12    ; kontrola max. ‡¡sla povelu
         ja        prerus3                  ; chyba - nezn m˜ povel

                                          ;* kontrola, zda je inicializace
         mov       word ptr es:[bx+3],100h  ; atributy - operace OK
         cmp       byte ptr es:[bx+2],0     ; je inicializace ?
         jne       prerus2                  ; nen¡ inicializace

                                          ;* funkce inicializace za©¡zen¡
         mov       byte ptr es:[bx+0dh],0   ; po‡et instal. disk– = 0
         mov       word ptr es:[bx+0eh],offset konec ; offset konce ovlada‡e
         mov       word ptr es:[bx+10h],cs  ; segment konce ovlada‡e
         jmp       short prerus3            ; n vrat z obsluhy

prerus2: cmp       byte ptr es:[bx+2],4     ; je vstup ze znakov‚ho za©¡zen¡ ?
         jne       prerus3                  ; nen¡ vstup ze znak. za©¡zen¡

                                          ;* funkce vstupu ze znak. za©¡zen¡
         mov       word ptr es:[bx+12h],2   ; vstup 2 bajty
         les       bx,es:[bx+0eh]           ; adresa buffer pro p©enos dat
         mov       es:[bx],cs               ; segment tohoto ovlada‡e
prerus3:
         pop       es                       ; n vrat ES
         pop       bx                       ; n vrat BX
         ret

prerus   endp

konec    label     byte                     ; konec rezidentn¡ ‡ sti ovlada‡e

; -----------------------------------------------------------------------------

code     ends
         end
