
INCLUDE         def.inc

.Data
                db      16 dup (0)              ; musí být zarovnání kvùli
                                                ; Windows Task Managment

PSP             dw      ?                       ; adresa PSP programu
PSPCmd          dw      ?                       ; offset pøík. øádku ASCIIZ v PSP
HPrevInst       dw      ?                       ; identifikátor pøedchozího
                                                ;  spuštìní (0=není)
HInstance       dw      ?                       ; identifikátor tohoto programu
CmdShow         dw      ?                       ; typ zobrazení okna

Msg             MsgStruct  <0>                  ; buffer pro pøíjem zprávy WINDOWS

;lHDC            dw      ?                       ; pracovní handle DC

; --- implicitní tabulka palet

HDefPalette     dw      0                       ; handle palet

DefPalette      label   byte
  dpalVersion   dw      300h                    ; požadovaná verze WINDOWS
  dpalNumEntr   dw      16                      ; poèet barev
  dpalPalEntr   label   byte                    ; položky palet
                PALETTEENTRY <  0,  0,  0,  0>  ;  0: èerná
                PALETTEENTRY <  0,170,  0,  0>  ;  1: zelená
                PALETTEENTRY <  0,  0,255,  0>  ;  2: svìtle modrá
                PALETTEENTRY <  0,  0,170,  0>  ;  3: modrá
                PALETTEENTRY < 85,  0,170,  0>  ;  4: fialová
                PALETTEENTRY <170,  0,  0,  0>  ;  5: èervená
                PALETTEENTRY <170,170, 85,  0>  ;  6: hnìdá
                PALETTEENTRY <170,170,170,  0>  ;  7: šedá
                PALETTEENTRY < 85, 85, 85,  0>  ;  8: tmavì šedá
                PALETTEENTRY <  0,255,  0,  0>  ;  9: svìtle zelená
                PALETTEENTRY <  0,255,255,  0>  ; 10: svìtle modrozelená
                PALETTEENTRY <170, 85,255,  0>  ; 11: svìtle fialová
                PALETTEENTRY <255, 85, 85,  0>  ; 12: svìtle èervená
                PALETTEENTRY <255,170,  0,  0>  ; 13: oranžová
                PALETTEENTRY <255,255,  0,  0>  ; 14: žlutá
                PALETTEENTRY <255,255,255,  0>  ; 15: bílá
DefPalette0     label   byte

;PALETTEENTRY        struc
;    peRed           db ?
;    peGreen         db ?
;    peBlue          db ?
;    peFlags         db ?
;PALETTEENTRY        ends

; *****************************************************************************
;
;                         Hlavní start programu
;
; *****************************************************************************

.Code
; -----------------------------------------------------------------------------
;            startovací inicializace programu, inicializace WINDOWS
; -----------------------------------------------------------------------------
; Pøi startu nenastavovat DS pomocí MOV AX,@Data - pøi vícenásobném spuštìní
; se zøejmì použije stejný DS a proto pøi ukonèení první spuštìné kopie
; ostatní kopie havarují. DS je pøi startu nastaven automaticky.

; --- inicializace úlohy WINDOWS

Start:          call    InitTask                ; inicializace úlohy WINDOWS
                or      ax,ax                   ; je inicializace OK ?
                jz      StartErr                ; chyba inicializace

; --- úschova navrácených registrù

                mov     PSP,es                  ; segment PSP
                mov     PSPCmd,bx               ; offset pøíkazového øádku
                mov     HPrevInst,si            ; identifikátor pøedchozího spuštìní
                mov     HInstance,di            ; identifikátor tohoto programu
                mov     CmdShow,dx              ; typ zobrazení okna

; --- inicializace aplikace WINDOWS

                call    WaitEvent,0             ; 0 = povel pro inicializaci
                call    InitApp,HInstance       ; inicializace úlohy
                or      ax,ax                   ; je inicializace OK ?
                jnz     WinMain                 ; inicializace probìhla OK

; --- pøerušení programu pøi chybì inicializace

StartErr:       mov     ax,4CFFh
                int     21h

; -----------------------------------------------------------------------------
;               registrace a vytvoøení oken
; -----------------------------------------------------------------------------

; --- pøíprava tabulky palet

WinMain:        call    CreatePalette,ds of DefPalette ; vytvoøení tabulky palet
                mov     HDefPalette,ax

; --- naètení obrázkù z resource

                call    LoadBMP                 ; naètení obrázkù z resource
                call    ButtonLoad              ; inicializace tlaèítek

; --- registrace tøíd oken

                call    MainFormReg             ; registrace hlavního okna

; --- vytvoøení oken

                call    MainFormCreate          ; vytvoøení hlavního okna

; -----------------------------------------------------------------------------
;               hlavní obslužná smyèka
; -----------------------------------------------------------------------------

; --- pøíjem zprávy od WINDOWS

Msg_Loop:       call    GETMESSAGE,ds of Msg,0 0 0 ; pøíjem zprávy WINDOWS
                or      ax,ax                   ; je konec programu ?
                je      End_Loop                ; je konec programu

; --- konverze kódu z klávesnice

                call    TRANSLATEMESSAGE,ds of Msg ; konverze kódu klávesnice

; --- pøedání zprávy dále (obsluze okna)

                call    DISPATCHMESSAGE,ds of Msg ; pøedání zprávy dále
                jmp     Msg_Loop                ; èekání ve smyèce

; --- uvolnìní obrázkù

End_Loop:       call    DeleteBMP               ; uvolnìní obrázkù
                call    ButtonDelete            ; uvolnìní tlaèítek
                call    DeleteObject,HDefPalette ; uvolnìní palet

; --- konec programu

                mov     ax,Msg.msWPARAM         ; návratový kód programu
                mov     ah,4Ch
                int     21h

                ENDS
                END       Start
