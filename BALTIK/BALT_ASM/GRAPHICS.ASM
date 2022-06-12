
INCLUDE         def.inc

.Data
                db      16 dup (0)              ; zarovn·nÌ

;; --- tabulka palet
;
;PaletteTab      PALETTEENTRY <>                 ; z·hlavÌ tabulky palet
;                db      256*4-1 dup(0)          ; buffer pro palety
;
;PALETTEENTRY        struc
;    peRed           db ?
;    peGreen         db ?
;    peBlue          db ?
;    peFlags         db ?
;PALETTEENTRY        ends

;; Logical Palette
;LOGPALETTE          struc
;    palVersion      dw ?
;    palNumEntries   dw ?
;    palPalEntry     db ?  ; array of PALETTEENTRY
;LOGPALETTE          ends

.Code

; -----------------------------------------------------------------------------
;               vykreslenÌ panelu
; -----------------------------------------------------------------------------
; VSTUP:    (2) HDC    kontext za¯ÌzenÌ
;           (2) LEFT   lev˝ okraj panelu
;           (2) TOP    hornÌ okraj panelu
;           (2) WIDTH  öÌ¯ka panelu
;           (2) HEIGHT v˝öka panelu
;           (2) WIDTHLINE öÌ¯ka Ë·ry (0=nenÌ)
;           (2) NAHORU TRUE=nahoru, FALSE=dol˘
; -----------------------------------------------------------------------------

Panel           PROC    lhdc:WORD,lLeft:WORD,lTop:WORD,lWidth:WORD,  \
                        lHeight:WORD,lWidthLine:WORD,lNahoru:WORD

; --- vykreslenÌ r·meËku panelu

                call    Frame3D,lhdc,lLeft,lTop,lWidth,lHeight,lWidthLine,lNahoru

; --- p¯Ìprava ukazatel˘ plochy

                mov     ax,lWidthLine           ; öÌ¯ka Ë·ry
                add     lLeft,ax
                add     lTop,ax
                shl     ax,1
                sub     lWidth,ax
                sub     lHeight,ax

; --- p¯Ìprava barvy plochy

                mov     ax,COLOR_BTNFACE
                call    GetSysColor,ax          ; barva povrchu panelu

; --- vykreslenÌ v˝plnÏ panelu

                call    Plocha,lhdc,lLeft,lTop,lWidth,lHeight,dx,ax
                ret

Panel           ENDP

; -----------------------------------------------------------------------------
;               vykreslenÌ barevnÈ plochy
; -----------------------------------------------------------------------------
; VSTUP:    (2) HDC    kontext za¯ÌzenÌ
;           (2) LEFT   lev˝ okraj
;           (2) TOP    hornÌ okraj
;           (2) WIDTH  öÌ¯ka plochy
;           (2) HEIGHT v˝öka plochy
;           (4) COLOR  barva
; -----------------------------------------------------------------------------

Plocha          PROC    lhdc:WORD,lLeft:WORD,lTop:WORD,lWidth:WORD,  \
                        lHeight:WORD,lColor:DWORD
                LOCAL   lRect:RECT,lhBrush:WORD

; --- p¯Ìprava ukazatele plochy

                mov     ax,lLeft
                mov     lRect.rcLeft,ax
                add     ax,lWidth
                mov     lRect.rcRight,ax
                mov     ax,lTop
                mov     lRect.rcTop,ax
                add     ax,lHeight
                mov     lRect.rcBottom,ax

; --- vytvo¯enÌ ötÏtce

                call    CreateSolidBrush,lColor ; vytvo¯enÌ ötÏtce
                mov     lhBrush,ax              ; HANDLE ötÏtce

; --- vymaz·nÌ plochy

                lea     ax,lRect
                call    FillRect,lhdc,ss,ax,lhBrush ; vymaz·nÌ plochy

; --- zruöenÌ ötÏtce

                mov     ax,lhBrush              ; pouûit˝ ötÏtec
                call    DeleteObject,ax         ; zruöenÌ ötÏtce
                ret

Plocha          ENDP

; -----------------------------------------------------------------------------
;               vykreslenÌ 3D r·meËku
; -----------------------------------------------------------------------------
; VSTUP:    (2) HDC    kontext za¯ÌzenÌ
;           (2) LEFT   lev˝ okraj
;           (2) TOP    hornÌ okraj
;           (2) WIDTH  öÌ¯ka r·meËku
;           (2) HEIGHT v˝öka r·meËku
;           (2) WIDTHLINE öÌ¯ka Ë·ry (0=nenÌ)
;           (2) NAHORU TRUE=nahoru, FALSE=dol˘
; -----------------------------------------------------------------------------

Frame3D         PROC    lhdc:WORD,lLeft:WORD,lTop:WORD,lWidth:WORD,  \
                        lHeight:WORD,lWidthLine:WORD,lNahoru:WORD
                local   lP1:POINT,lP2:POINT,lP3:POINT,lhPenOld:WORD,  \
                        lOldROP:WORD

; --- test, zda je r·meËek

                cmp     lWidthLine,0            ; je r·meËek ?
                je      Frame3D9                ; nenÌ r·meËek

; --- nastavenÌ stylu pera

                call    SetROP2,lhdc,R2_COPYPEN ; bÏûn˝ reûim - barva pera
                mov     lOldROP,ax              ; p˘vodnÌ reûim ROP2

; --- vytvo¯enÌ a v˝bÏr pera - svÏtl· barva

Frame3D2:       mov     ax,COLOR_BTNHILIGHT
                cmp     lNahoru,TRUE
                je      Frame3D3
                mov     ax,COLOR_BTNSHADOW
Frame3D3:       call    GetSysColor,ax
                call    CreatePen,PS_SOLID,1,dx ax ; vytvo¯enÌ svÏtlÈho pera
                call    SelectObject,lhdc,ax    ; v˝bÏr svÏtlÈho pera
                mov     lhPenOld,ax             ; ˙schova p˘vodnÌho pera

; --- lev˝ a hornÌ okraj - sou¯adnice X

                mov     ax,lLeft
                mov     lP1.ptX,ax
                mov     lP2.ptX,ax
                add     ax,lWidth
                mov     lP3.ptX,ax

; --- lev˝ a hornÌ okraj - sou¯adnice Y

                mov     ax,lTop
                mov     lP2.ptY,ax
                mov     lP3.ptY,ax
                add     ax,lHeight
                dec     ax
                dec     ax
                mov     lP1.ptY,ax

; --- vykreslenÌ levÈho a hornÌho okraje

                lea     ax,lP1
                call    PolyLine,lhdc,ss,ax,3

; --- zmÏna na tmavÈ pero

                mov     ax,COLOR_BTNSHADOW
                cmp     lNahoru,TRUE
                je      Frame3D5
                mov     ax,COLOR_BTNHILIGHT
Frame3D5:       call    GetSysColor,ax
                call    CreatePen,PS_SOLID,1,dx ax ; vytvo¯enÌ tmavÈho pera
                call    SelectObject,lhdc,ax    ; v˝bÏr tmavÈho pera
                call    DeleteObject,ax         ; zryöenÌ svÏtlÈho pera

; --- prav˝ a dolnÌ okraj - sou¯adnice X

                mov     ax,lLeft
                mov     lP1.ptX,ax
                add     ax,lWidth
                dec     ax
                mov     lP2.ptX,ax
                mov     lP3.ptX,ax

; --- prav˝ a dolnÌ okraj - sou¯adnice Y

                mov     ax,lTop
                mov     lP3.ptY,ax
                add     ax,lHeight
                dec     ax
                mov     lP1.ptY,ax
                mov     lP2.ptY,ax

; --- vykreslenÌ pravÈho a dolnÌho okraje

                lea     ax,lP1
                call    PolyLine,lhdc,ss,ax,3

; --- n·vrat p˘vodnÌho pera

                mov     ax,lhPenOld             ; p˘vodnÌ pero
                call    SelectObject,lhdc,ax    ; navr·cenÌ p˘vodnÌho pera
                call    DeleteObject,ax         ; zruöenÌ tmavÈho pera

; --- ËÌtaË tlouöùky Ë·ry

                inc     lLeft
                inc     lTop
                sub     lWidth,2
                sub     lHeight,2
                dec     lWidthLine
                jnz     Frame3D2                ; dalöÌ Ë·ra

; --- navr·cenÌ stylu pera

                call    SetROP2,lhdc,lOldROP    ; p˘vodnÌ reûim pera
Frame3D9:       ret

Frame3D         ENDP

                ENDS
                END
