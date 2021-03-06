
INCLUDE         def.inc

.Data
                db      16 dup (0)              ; mus� b�t zarovn�n� kv�li
                                                ; Windows Task Managment

PSP             dw      ?                       ; adresa PSP programu
PSPCmd          dw      ?                       ; offset p��k. ��dku ASCIIZ v PSP
HPrevInst       dw      ?                       ; identifik�tor p�edchoz�ho
                                                ;  spu�t�n� (0=nen�)
HInstance       dw      ?                       ; identifik�tor tohoto programu
CmdShow         dw      ?                       ; typ zobrazen� okna

Msg             MsgStruct  <0>                  ; buffer pro p��jem zpr�vy WINDOWS

;lHDC            dw      ?                       ; pracovn� handle DC

; --- implicitn� tabulka palet

HDefPalette     dw      0                       ; handle palet

DefPalette      label   byte
  dpalVersion   dw      300h                    ; po�adovan� verze WINDOWS
  dpalNumEntr   dw      16                      ; po�et barev
  dpalPalEntr   label   byte                    ; polo�ky palet
                PALETTEENTRY <  0,  0,  0,  0>  ;  0: �ern�
                PALETTEENTRY <  0,170,  0,  0>  ;  1: zelen�
                PALETTEENTRY <  0,  0,255,  0>  ;  2: sv�tle modr�
                PALETTEENTRY <  0,  0,170,  0>  ;  3: modr�
                PALETTEENTRY < 85,  0,170,  0>  ;  4: fialov�
                PALETTEENTRY <170,  0,  0,  0>  ;  5: �erven�
                PALETTEENTRY <170,170, 85,  0>  ;  6: hn�d�
                PALETTEENTRY <170,170,170,  0>  ;  7: �ed�
                PALETTEENTRY < 85, 85, 85,  0>  ;  8: tmav� �ed�
                PALETTEENTRY <  0,255,  0,  0>  ;  9: sv�tle zelen�
                PALETTEENTRY <  0,255,255,  0>  ; 10: sv�tle modrozelen�
                PALETTEENTRY <170, 85,255,  0>  ; 11: sv�tle fialov�
                PALETTEENTRY <255, 85, 85,  0>  ; 12: sv�tle �erven�
                PALETTEENTRY <255,170,  0,  0>  ; 13: oran�ov�
                PALETTEENTRY <255,255,  0,  0>  ; 14: �lut�
                PALETTEENTRY <255,255,255,  0>  ; 15: b�l�
DefPalette0     label   byte

;PALETTEENTRY        struc
;    peRed           db ?
;    peGreen         db ?
;    peBlue          db ?
;    peFlags         db ?
;PALETTEENTRY        ends

; *****************************************************************************
;
;                         Hlavn� start programu
;
; *****************************************************************************

.Code
; -----------------------------------------------------------------------------
;            startovac� inicializace programu, inicializace WINDOWS
; -----------------------------------------------------------------------------
; P�i startu nenastavovat DS pomoc� MOV AX,@Data - p�i v�cen�sobn�m spu�t�n�
; se z�ejm� pou�ije stejn� DS a proto p�i ukon�en� prvn� spu�t�n� kopie
; ostatn� kopie havaruj�. DS je p�i startu nastaven automaticky.

; --- inicializace �lohy WINDOWS

Start:          call    InitTask                ; inicializace �lohy WINDOWS
                or      ax,ax                   ; je inicializace OK ?
                jz      StartErr                ; chyba inicializace

; --- �schova navr�cen�ch registr�

                mov     PSP,es                  ; segment PSP
                mov     PSPCmd,bx               ; offset p��kazov�ho ��dku
                mov     HPrevInst,si            ; identifik�tor p�edchoz�ho spu�t�n�
                mov     HInstance,di            ; identifik�tor tohoto programu
                mov     CmdShow,dx              ; typ zobrazen� okna

; --- inicializace aplikace WINDOWS

                call    WaitEvent,0             ; 0 = povel pro inicializaci
                call    InitApp,HInstance       ; inicializace �lohy
                or      ax,ax                   ; je inicializace OK ?
                jnz     WinMain                 ; inicializace prob�hla OK

; --- p�eru�en� programu p�i chyb� inicializace

StartErr:       mov     ax,4CFFh
                int     21h

; -----------------------------------------------------------------------------
;               registrace a vytvo�en� oken
; -----------------------------------------------------------------------------

; --- p��prava tabulky palet

WinMain:        call    CreatePalette,ds of DefPalette ; vytvo�en� tabulky palet
                mov     HDefPalette,ax

; --- na�ten� obr�zk� z resource

                call    LoadBMP                 ; na�ten� obr�zk� z resource
                call    ButtonLoad              ; inicializace tla��tek

; --- registrace t��d oken

                call    MainFormReg             ; registrace hlavn�ho okna

; --- vytvo�en� oken

                call    MainFormCreate          ; vytvo�en� hlavn�ho okna

; -----------------------------------------------------------------------------
;               hlavn� obslu�n� smy�ka
; -----------------------------------------------------------------------------

; --- p��jem zpr�vy od WINDOWS

Msg_Loop:       call    GETMESSAGE,ds of Msg,0 0 0 ; p��jem zpr�vy WINDOWS
                or      ax,ax                   ; je konec programu ?
                je      End_Loop                ; je konec programu

; --- konverze k�du z kl�vesnice

                call    TRANSLATEMESSAGE,ds of Msg ; konverze k�du kl�vesnice

; --- p�ed�n� zpr�vy d�le (obsluze okna)

                call    DISPATCHMESSAGE,ds of Msg ; p�ed�n� zpr�vy d�le
                jmp     Msg_Loop                ; �ek�n� ve smy�ce

; --- uvoln�n� obr�zk�

End_Loop:       call    DeleteBMP               ; uvoln�n� obr�zk�
                call    ButtonDelete            ; uvoln�n� tla��tek
                call    DeleteObject,HDefPalette ; uvoln�n� palet

; --- konec programu

                mov     ax,Msg.msWPARAM         ; n�vratov� k�d programu
                mov     ah,4Ch
                int     21h

                ENDS
                END       Start
