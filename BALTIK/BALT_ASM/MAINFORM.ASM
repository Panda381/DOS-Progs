
INCLUDE         def.inc

.Data
                db      16 dup (0)              ; zarovn�n�

MainForm        FormClass <>                    ; popisova� hlavn�ho okna
MainFormName    db      'Balt�k',0
MainMenuName    db      'MAINMENU',0

;PAINTSTRUCT STRUC
;    PShdc         DW ?
;    PSfErase      DW ?
;    PSrcPaint     DB size RECT dup(?)
;    PSfRestore    DW ?
;    PSfIncUpdate  DW ?
;    PSrgbReserved DB 16 dup(?)
;PAINTSTRUCT ENDS

;lpRect          RECT <>
;RECT    struc
;        rcLeft          dw      ?
;        rcTop           dw      ?
;        rcRight         dw      ?
;        rcBottom        dw      ?
;RECT    ends

.Code

; -----------------------------------------------------------------------------
;               registrace hlavn�ho okna
; -----------------------------------------------------------------------------

MainFormReg     PROC

                mov     wrd MainForm.WClass.clsHbrBackground,0 ; pr�hledn�
                mov     wrd MainForm.WClass.clsLpszMenuName,of MainMenuName
                mov     wrd MainForm.WClass.clsLpszMenuName+2,ds
                mov     wrd MainForm.WClass.clsLpfnWndProc, of MainFormEvents
                mov     wrd MainForm.WClass.clsLpfnWndProc+2, seg MainFormEvents
                call    FormReg,ds of MainForm
                ret

MainFormReg     ENDP

; -----------------------------------------------------------------------------
;               vytvo�en� hlavn�ho okna
; -----------------------------------------------------------------------------

MainFormCreate  PROC

; --- vytvo�en� hlavn�ho okna

                mov     wrd MainForm.FormName,of MainFormName
                mov     wrd MainForm.FormName+2,ds
                call    FormCreate, ds of MainForm

; --- prvn� zobrazen� okna

                call    SHOWWINDOW,MainForm.FormHandle,CmdShow ; prvn� zobrazen� okna

; --- vykreslen� obsahu okna

                call    UPDATEWINDOW,MainForm.FormHandle ; vykreslen� obsahu okna
                ret

MainFormCreate  ENDP

; -----------------------------------------------------------------------------
;               obsluha ud�lost� hlavn�ho okna
; -----------------------------------------------------------------------------

MainFormEvents  PROC    hwnd:WORD,wmsg:WORD,wparam:WORD,lparam:DWORD

                call    FormEvents,hwnd,wmsg,wparam,lparam,cs of MainFormEvntTab
                ret

MainFormEvents  ENDP

MainFormEvntAdr dd      MainFormEvntTab

MainFormEvntTab label   word

                dw      WM_CREATE               ; vytvo�en� okna
                dd      MFormWMCreate

                dw      WM_DESTROY              ; zru�en� okna
                dd      MFormWMDestroy

                dw      WM_PAINT                ; vykreslen� okna
                dd      MFormWMPaint

                dw      WM_ACTIVATE             ; aktivace okna
                dd      MFormWMActivate

                dw      0

; --- vytvo�en� okna

MFormWMCreate   PROC    hwnd:WORD,wmsg:WORD,wparam:WORD,lparam:DWORD

                xor     ax,ax
                ret

MFormWMCreate   ENDP

; --- uzav�en� okna

MFormWMDestroy  PROC    hwnd:WORD,wmsg:WORD,wparam:WORD,lparam:DWORD

                call    POSTQUITMESSAGE,0       ; zpr�va o ukon�en� programu
                xor     ax,ax
                ret

MFormWMDestroy  ENDP

; --- aktivace okna

MFormWMActivate PROC    hwnd:WORD,wmsg:WORD,wparam:WORD,lparam:DWORD

                call    InvalidateRgn,hwnd,0,FALSE
                xor     ax,ax
                ret

MFormWMActivate ENDP

; -----------------------------------------------------------------------------
;               vykreslen� hlavn�ho okna
; -----------------------------------------------------------------------------

MFormWMPaint    PROC    hwnd:WORD,wmsg:WORD,wparam:WORD,lparam:DWORD
                uses    es,si,di
                local   lhdc:WORD,lhpen:WORD,lhpenold:WORD,  \
                        lPaint:PAINTSTRUCT,lRect:RECT,lHPalOld:WORD,  \
                        lhBrushOld:WORD,lHPenOld:WORD

; --- zah�jen� kreslen� okna

                lea     ax,lPaint
                call    BEGINPAINT,hwnd,ss,ax
                mov     lhdc,ax

; --- v�b�r palet plochy

                call    SelectPalette,lhdc,HDefPalette,TRUE ; v�b�r palet
                mov     lHPalOld,ax             ; p�vodn� palety
                call    RealizePalette,lhdc     ; pou�it� palet

; --- na�ten� velikosti okna

                lea     ax,lRect
                call    GetClientRect,hwnd,ss ax

; --- �schova CLIENT plochy

                mov     ax,lRect.rcLeft
                mov     MainForm.FormCBounds.bnLeft,ax
                sub     ax,lRect.rcRight
                neg     ax
                mov     MainForm.FormCBounds.bnWidth,ax
                mov     ax,lRect.rcTop
                mov     MainForm.FormCBounds.bnTop,ax
                sub     ax,lRect.rcBottom
                neg     ax
                mov     MainForm.FormCBounds.bnHeight,ax

; --- vykreslen� panelu pro SPEEDBAR

                call    Panel,lhdc,0,0,lRect.rcRight,SPANELHEIGHT,1,TRUE

; --- vykreslen� tla��tek ve SPEEDBARu

                call    MButtonDisp,lhdc

; --- vykreslen� st�edn�ho obr�zku

                cmp     lRect.rcRight,550
                jb      MFormWMPaint5

                mov     ax,lRect.rcRight
                sub     ax,122
                shr     ax,1
                call    DispBitmap,lhdc,HSGPBMP,              \
                        ax,(SPANELHEIGHT-23)/2,               \ ; left a top
                        122,23,                               \ ; rozm�ry
                        0,0                                   \ ; zdrojov� X,Y

                mov     ax,lRect.rcRight
                sub     ax,122+10
                shr     ax,1
                call    Frame3D,lhdc,                         \
                        ax,(SPANELHEIGHT-23-10)/2,            \
                        122+10,23+10,                         \
                        1,TRUE

                mov     ax,lRect.rcRight
                sub     ax,122+4
                shr     ax,1
                call    Frame3D,lhdc,                         \
                        ax,(SPANELHEIGHT-23-4)/2,             \
                        122+4,23+4,                           \
                        1,FALSE

MFormWMPaint5:

                call    DispBitmap,lhdc,HBANKA101BMP,         \
                        0,SPANELHEIGHT,                       \ ; left a top
                        585,290,                              \ ; rozm�ry
                        0,0                                   \ ; zdrojov� X,Y



;                call    Plocha,lhdc,100,100,200,200,200h,0aaffh

;                call    CreateSolidBrush,0,0aaffh
;                call    SelectObject,lhdc,ax
;                mov     lhBrushOld,ax

;                call    CreatePen,PS_SOLID,10,100h,13 ;0aaffh ; vytvo�en� sv�tl�ho pera
;                call    SelectObject,lhdc,ax    ; v�b�r sv�tl�ho pera
;                mov     lhPenOld,ax             ; �schova p�vodn�ho pera

;                call    Rectangle,lhdc,350,100,550,300

;                call    SelectObject,lhdc,lhPenOld ; navr�cen� p�vodn�ho pera
;                call    DeleteObject,ax         ; zru�en�

;                call    SelectObject,lhdc,lhBrushOld
;                call    DeleteObject,ax




; --- navr�cen� p�vodn�ch palet

                call    SelectPalette,lhdc,lHPalOld,TRUE

; --- ukon�en� kreslen� okna

                lea     ax,lPaint
                call    ENDPAINT,hwnd,ss,ax
                xor     ax,ax
                ret

MFormWMPaint    ENDP


                ENDS
                END
