
INCLUDE         def.inc

.Data
                db      16 dup (0)              ; zarovn�n�

;; --- tabulka palet
;
;PaletteTab      PALETTEENTRY <>                 ; z�hlav� tabulky palet
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
;               vykreslen� panelu
; -----------------------------------------------------------------------------
; VSTUP:    (2) HDC    kontext za��zen�
;           (2) LEFT   lev� okraj panelu
;           (2) TOP    horn� okraj panelu
;           (2) WIDTH  ���ka panelu
;           (2) HEIGHT v��ka panelu
;           (2) WIDTHLINE ���ka ��ry (0=nen�)
;           (2) NAHORU TRUE=nahoru, FALSE=dol�
; -----------------------------------------------------------------------------

Panel           PROC    lhdc:WORD,lLeft:WORD,lTop:WORD,lWidth:WORD,  \
                        lHeight:WORD,lWidthLine:WORD,lNahoru:WORD

; --- vykreslen� r�me�ku panelu

                call    Frame3D,lhdc,lLeft,lTop,lWidth,lHeight,lWidthLine,lNahoru

; --- p��prava ukazatel� plochy

                mov     ax,lWidthLine           ; ���ka ��ry
                add     lLeft,ax
                add     lTop,ax
                shl     ax,1
                sub     lWidth,ax
                sub     lHeight,ax

; --- p��prava barvy plochy

                mov     ax,COLOR_BTNFACE
                call    GetSysColor,ax          ; barva povrchu panelu

; --- vykreslen� v�pln� panelu

                call    Plocha,lhdc,lLeft,lTop,lWidth,lHeight,dx,ax
                ret

Panel           ENDP

; -----------------------------------------------------------------------------
;               vykreslen� barevn� plochy
; -----------------------------------------------------------------------------
; VSTUP:    (2) HDC    kontext za��zen�
;           (2) LEFT   lev� okraj
;           (2) TOP    horn� okraj
;           (2) WIDTH  ���ka plochy
;           (2) HEIGHT v��ka plochy
;           (4) COLOR  barva
; -----------------------------------------------------------------------------

Plocha          PROC    lhdc:WORD,lLeft:WORD,lTop:WORD,lWidth:WORD,  \
                        lHeight:WORD,lColor:DWORD
                LOCAL   lRect:RECT,lhBrush:WORD

; --- p��prava ukazatele plochy

                mov     ax,lLeft
                mov     lRect.rcLeft,ax
                add     ax,lWidth
                mov     lRect.rcRight,ax
                mov     ax,lTop
                mov     lRect.rcTop,ax
                add     ax,lHeight
                mov     lRect.rcBottom,ax

; --- vytvo�en� �t�tce

                call    CreateSolidBrush,lColor ; vytvo�en� �t�tce
                mov     lhBrush,ax              ; HANDLE �t�tce

; --- vymaz�n� plochy

                lea     ax,lRect
                call    FillRect,lhdc,ss,ax,lhBrush ; vymaz�n� plochy

; --- zru�en� �t�tce

                mov     ax,lhBrush              ; pou�it� �t�tec
                call    DeleteObject,ax         ; zru�en� �t�tce
                ret

Plocha          ENDP

; -----------------------------------------------------------------------------
;               vykreslen� 3D r�me�ku
; -----------------------------------------------------------------------------
; VSTUP:    (2) HDC    kontext za��zen�
;           (2) LEFT   lev� okraj
;           (2) TOP    horn� okraj
;           (2) WIDTH  ���ka r�me�ku
;           (2) HEIGHT v��ka r�me�ku
;           (2) WIDTHLINE ���ka ��ry (0=nen�)
;           (2) NAHORU TRUE=nahoru, FALSE=dol�
; -----------------------------------------------------------------------------

Frame3D         PROC    lhdc:WORD,lLeft:WORD,lTop:WORD,lWidth:WORD,  \
                        lHeight:WORD,lWidthLine:WORD,lNahoru:WORD
                local   lP1:POINT,lP2:POINT,lP3:POINT,lhPenOld:WORD,  \
                        lOldROP:WORD

; --- test, zda je r�me�ek

                cmp     lWidthLine,0            ; je r�me�ek ?
                je      Frame3D9                ; nen� r�me�ek

; --- nastaven� stylu pera

                call    SetROP2,lhdc,R2_COPYPEN ; b�n� re�im - barva pera
                mov     lOldROP,ax              ; p�vodn� re�im ROP2

; --- vytvo�en� a v�b�r pera - sv�tl� barva

Frame3D2:       mov     ax,COLOR_BTNHILIGHT
                cmp     lNahoru,TRUE
                je      Frame3D3
                mov     ax,COLOR_BTNSHADOW
Frame3D3:       call    GetSysColor,ax
                call    CreatePen,PS_SOLID,1,dx ax ; vytvo�en� sv�tl�ho pera
                call    SelectObject,lhdc,ax    ; v�b�r sv�tl�ho pera
                mov     lhPenOld,ax             ; �schova p�vodn�ho pera

; --- lev� a horn� okraj - sou�adnice X

                mov     ax,lLeft
                mov     lP1.ptX,ax
                mov     lP2.ptX,ax
                add     ax,lWidth
                mov     lP3.ptX,ax

; --- lev� a horn� okraj - sou�adnice Y

                mov     ax,lTop
                mov     lP2.ptY,ax
                mov     lP3.ptY,ax
                add     ax,lHeight
                dec     ax
                dec     ax
                mov     lP1.ptY,ax

; --- vykreslen� lev�ho a horn�ho okraje

                lea     ax,lP1
                call    PolyLine,lhdc,ss,ax,3

; --- zm�na na tmav� pero

                mov     ax,COLOR_BTNSHADOW
                cmp     lNahoru,TRUE
                je      Frame3D5
                mov     ax,COLOR_BTNHILIGHT
Frame3D5:       call    GetSysColor,ax
                call    CreatePen,PS_SOLID,1,dx ax ; vytvo�en� tmav�ho pera
                call    SelectObject,lhdc,ax    ; v�b�r tmav�ho pera
                call    DeleteObject,ax         ; zry�en� sv�tl�ho pera

; --- prav� a doln� okraj - sou�adnice X

                mov     ax,lLeft
                mov     lP1.ptX,ax
                add     ax,lWidth
                dec     ax
                mov     lP2.ptX,ax
                mov     lP3.ptX,ax

; --- prav� a doln� okraj - sou�adnice Y

                mov     ax,lTop
                mov     lP3.ptY,ax
                add     ax,lHeight
                dec     ax
                mov     lP1.ptY,ax
                mov     lP2.ptY,ax

; --- vykreslen� prav�ho a doln�ho okraje

                lea     ax,lP1
                call    PolyLine,lhdc,ss,ax,3

; --- n�vrat p�vodn�ho pera

                mov     ax,lhPenOld             ; p�vodn� pero
                call    SelectObject,lhdc,ax    ; navr�cen� p�vodn�ho pera
                call    DeleteObject,ax         ; zru�en� tmav�ho pera

; --- ��ta� tlou��ky ��ry

                inc     lLeft
                inc     lTop
                sub     lWidth,2
                sub     lHeight,2
                dec     lWidthLine
                jnz     Frame3D2                ; dal�� ��ra

; --- navr�cen� stylu pera

                call    SetROP2,lhdc,lOldROP    ; p�vodn� re�im pera
Frame3D9:       ret

Frame3D         ENDP

                ENDS
                END
