
INCLUDE         def.inc

.Data
                db      16 dup (0)              ; zarovnání

MainForm        FormClass <>                    ; popisovaè hlavního okna
MainFormName    db      'Baltík',0
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
;               registrace hlavního okna
; -----------------------------------------------------------------------------

MainFormReg     PROC

                mov     wrd MainForm.WClass.clsHbrBackground,0 ; prùhledné
                mov     wrd MainForm.WClass.clsLpszMenuName,of MainMenuName
                mov     wrd MainForm.WClass.clsLpszMenuName+2,ds
                mov     wrd MainForm.WClass.clsLpfnWndProc, of MainFormEvents
                mov     wrd MainForm.WClass.clsLpfnWndProc+2, seg MainFormEvents
                call    FormReg,ds of MainForm
                ret

MainFormReg     ENDP

; -----------------------------------------------------------------------------
;               vytvoøení hlavního okna
; -----------------------------------------------------------------------------

MainFormCreate  PROC

; --- vytvoøení hlavního okna

                mov     wrd MainForm.FormName,of MainFormName
                mov     wrd MainForm.FormName+2,ds
                call    FormCreate, ds of MainForm

; --- první zobrazení okna

                call    SHOWWINDOW,MainForm.FormHandle,CmdShow ; první zobrazení okna

; --- vykreslení obsahu okna

                call    UPDATEWINDOW,MainForm.FormHandle ; vykreslení obsahu okna
                ret

MainFormCreate  ENDP

; -----------------------------------------------------------------------------
;               obsluha událostí hlavního okna
; -----------------------------------------------------------------------------

MainFormEvents  PROC    hwnd:WORD,wmsg:WORD,wparam:WORD,lparam:DWORD

                call    FormEvents,hwnd,wmsg,wparam,lparam,cs of MainFormEvntTab
                ret

MainFormEvents  ENDP

MainFormEvntAdr dd      MainFormEvntTab

MainFormEvntTab label   word

                dw      WM_CREATE               ; vytvoøení okna
                dd      MFormWMCreate

                dw      WM_DESTROY              ; zrušení okna
                dd      MFormWMDestroy

                dw      WM_PAINT                ; vykreslení okna
                dd      MFormWMPaint

                dw      WM_ACTIVATE             ; aktivace okna
                dd      MFormWMActivate

                dw      0

; --- vytvoøení okna

MFormWMCreate   PROC    hwnd:WORD,wmsg:WORD,wparam:WORD,lparam:DWORD

                xor     ax,ax
                ret

MFormWMCreate   ENDP

; --- uzavøení okna

MFormWMDestroy  PROC    hwnd:WORD,wmsg:WORD,wparam:WORD,lparam:DWORD

                call    POSTQUITMESSAGE,0       ; zpráva o ukonèení programu
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
;               vykreslení hlavního okna
; -----------------------------------------------------------------------------

MFormWMPaint    PROC    hwnd:WORD,wmsg:WORD,wparam:WORD,lparam:DWORD
                uses    es,si,di
                local   lhdc:WORD,lhpen:WORD,lhpenold:WORD,  \
                        lPaint:PAINTSTRUCT,lRect:RECT,lHPalOld:WORD,  \
                        lhBrushOld:WORD,lHPenOld:WORD

; --- zahájení kreslení okna

                lea     ax,lPaint
                call    BEGINPAINT,hwnd,ss,ax
                mov     lhdc,ax

; --- výbìr palet plochy

                call    SelectPalette,lhdc,HDefPalette,TRUE ; výbìr palet
                mov     lHPalOld,ax             ; pùvodní palety
                call    RealizePalette,lhdc     ; použití palet

; --- naètení velikosti okna

                lea     ax,lRect
                call    GetClientRect,hwnd,ss ax

; --- úschova CLIENT plochy

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

; --- vykreslení panelu pro SPEEDBAR

                call    Panel,lhdc,0,0,lRect.rcRight,SPANELHEIGHT,1,TRUE

; --- vykreslení tlaèítek ve SPEEDBARu

                call    MButtonDisp,lhdc

; --- vykreslení støedního obrázku

                cmp     lRect.rcRight,550
                jb      MFormWMPaint5

                mov     ax,lRect.rcRight
                sub     ax,122
                shr     ax,1
                call    DispBitmap,lhdc,HSGPBMP,              \
                        ax,(SPANELHEIGHT-23)/2,               \ ; left a top
                        122,23,                               \ ; rozmìry
                        0,0                                   \ ; zdrojový X,Y

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
                        585,290,                              \ ; rozmìry
                        0,0                                   \ ; zdrojový X,Y



;                call    Plocha,lhdc,100,100,200,200,200h,0aaffh

;                call    CreateSolidBrush,0,0aaffh
;                call    SelectObject,lhdc,ax
;                mov     lhBrushOld,ax

;                call    CreatePen,PS_SOLID,10,100h,13 ;0aaffh ; vytvoøení svìtlého pera
;                call    SelectObject,lhdc,ax    ; výbìr svìtlého pera
;                mov     lhPenOld,ax             ; úschova pùvodního pera

;                call    Rectangle,lhdc,350,100,550,300

;                call    SelectObject,lhdc,lhPenOld ; navrácení pùvodního pera
;                call    DeleteObject,ax         ; zrušení

;                call    SelectObject,lhdc,lhBrushOld
;                call    DeleteObject,ax




; --- navrácení pùvodních palet

                call    SelectPalette,lhdc,lHPalOld,TRUE

; --- ukonèení kreslení okna

                lea     ax,lPaint
                call    ENDPAINT,hwnd,ss,ax
                xor     ax,ax
                ret

MFormWMPaint    ENDP


                ENDS
                END
