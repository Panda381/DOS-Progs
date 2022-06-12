
locals                                          ; povolena lokální návìští @@
jumps                                           ; optimalizace podmínìných skokù
.model large,WINDOWS PASCAL
INCLUDE         windows.inc
.386

; --- konstanty

of              EQU     offset
hi              EQU     256
wrd             EQU     word ptr

CW_USECENTER    EQU     CW_USEDEFAULT+1         ; pøíznak vystøedìnéno okna

; --- rozmìry panelu

SPANELHEIGHT    EQU     37                      ; výška SPEEDBAR panelu
SBUTTONWIDTH    EQU     43                      ; šíøka SPEED BUTTON
SBUTTONHEIGHT   EQU     33                      ; výška SPEED BUTTON

ICONWIDTH       EQU     39                      ; šíøka ikon
ICONHEIGHT      EQU     29                      ; výška ikon

; --- funkce API

GLOBAL          ARC:PROC
GLOBAL          BEGINPAINT:PROC
GLOBAL          BITBLT:PROC
GLOBAL          CREATEBITMAP:PROC
GLOBAL          CREATECOMPATIBLEBITMAP:PROC
GLOBAL          CREATECOMPATIBLEDC:PROC
GLOBAL          CREATEDIBITMAP:PROC
GLOBAL          CREATEPALETTE:PROC
GLOBAL          CREATEPEN:PROC
GLOBAL          CREATESOLIDBRUSH:PROC
GLOBAL          CREATEWINDOW:PROC
GLOBAL          DEFWINDOWPROC:PROC
GLOBAL          DELETEDC:PROC
GLOBAL          DELETEOBJECT:PROC
GLOBAL          DIALOGBOX:PROC
GLOBAL          DISPATCHMESSAGE:PROC
GLOBAL          ELLIPSE:PROC
GLOBAL          ENDDIALOG:PROC
GLOBAL          ENDPAINT:PROC
GLOBAL          FILLRECT:PROC
GLOBAL          FINDRESOURCE:PROC
GLOBAL          FREEPROCINSTANCE:PROC
GLOBAL          FREERESOURCE:PROC
GLOBAL          GETCLIENTRECT:PROC
GLOBAL          GETDC:PROC
GLOBAL          GETMESSAGE:PROC
GLOBAL          GETPIXEL:PROC
GLOBAL          GETSTOCKOBJECT:PROC
GLOBAL          GETSYSCOLOR:PROC
GLOBAL          GLOBALUNLOCK:PROC
GLOBAL          INITAPP:PROC
GLOBAL          INITTASK:PROC
GLOBAL          INVALIDATERECT:PROC
GLOBAL          INVALIDATERGN:PROC
GLOBAL          KILLTIMER:PROC
GLOBAL          LINETO:PROC
GLOBAL          LOADBITMAP:PROC
GLOBAL          LOADCURSOR:PROC
GLOBAL          LOADRESOURCE:PROC
GLOBAL          LOCKRESOURCE:PROC
GLOBAL          MAKEPROCINSTANCE:PROC
GLOBAL          MESSAGEBEEP:PROC
GLOBAL          MESSAGEBOX:PROC
GLOBAL          MOVETO:PROC
GLOBAL          PIE:PROC
GLOBAL          POLYLINE:PROC
GLOBAL          POSTQUITMESSAGE:PROC
GLOBAL          REALIZEPALETTE:PROC
GLOBAL          RECTANGLE:PROC
GLOBAL          REGISTERCLASS:PROC
GLOBAL          RELEASEDC:PROC
GLOBAL          SELECTOBJECT:PROC
GLOBAL          SELECTPALETTE:PROC
GLOBAL          SETBKCOLOR:PROC
GLOBAL          SETTEXTCOLOR:PROC
GLOBAL          SETROP2:PROC
GLOBAL          SETTIMER:PROC
GLOBAL          SHOWWINDOW:PROC
GLOBAL          TEXTOUT:PROC
GLOBAL          TRANSLATEMESSAGE:PROC
GLOBAL          UPDATEWINDOW:PROC
GLOBAL          WAITEVENT:PROC

; --- struktury

DIBSECTION      STRUC
dsBm            BITMAP <>                       ; parametry bitmapy
dsBmih          BITMAPINFOHEADER <>             ; informaèní záhlaví
dsBitfields     dd ?,?,?                        ; barevná maska
dshSection      dw ?
dsOffset        dd ?
DIBSECTION      ENDS

;BITMAP STRUC
;        bmType         DW ?
;        bmWidth        DW ?
;        bmHeight       DW ?
;        bmWidthBytes   DW ?
;        bmPlanes       DB ?
;        bmBitsPixel    DB ?
;        bmBits         DD ?
;BITMAP ENDS

;BITMAPINFOHEADER struc
;        biSize           dd ?
;        biWidth          dd ?
;        biHeight         dd ?
;        biPlanes         dw ?
;        biBitCount       dw ?
;
;        biCompression    dd ?
;        biSizeImage      dd ?
;        biXPelsPerMeter  dd ?
;        biYPelsPerMeter  dd ?
;        biClrUsed        dd ?
;        biClrImportant   dd ?
;BITMAPINFOHEADER ends

BOUNDS          STRUC
bnLeft          dw      ?
bnTop           dw      ?
bnWidth         dw      ?
bnHeight        dw      ?
BOUNDS          ENDS

;WNDCLASS struc
;        clsStyle        dw      ?       ; class style
;        clsLpfnWndProc  dd      ?
;        clsCbClsExtra   dw      ?
;        clsCbWndExtra   dw      ?
;        clsHInstance    dw      ?       ; instance handle
;        clsHIcon        dw      ?       ; class icon handle
;        clsHCursor      dw      ?       ; class cursor handle
;        clsHbrBackground dw     ?       ; class background brush
;        clsLpszMenuName dd      ?       ; menu name
;        clsLpszClassName dd     ?       ; far ptr to class name
;WNDCLASS ends

FormClass       STRUC
WClass          WNDCLASS <CS_HREDRAW+CS_VREDRAW,0,0,0,0,0,0,-1,0,0>
WClassName      db      'FORMCLASS'             ; jméno tøídy okna
WClassName0     db      '12345678',0
FormHandle      dw      0                       ; handle okna
FormBounds      BOUNDS  <CW_USECENTER,CW_USECENTER,CW_USECENTER,CW_USECENTER>
FormCBounds     BOUNDS  <0,0,630,430>           ; rozmìry CLIENT plochy
FormName        dd      0                       ; jméno/titulek okna
FormStyleL      dw      0                       ; styl LOW
FormStyleH      dw      WS_OVERLAPPEDWINDOW+WS_VISIBLE
FormParent      dw      0                       ; handle rodièe (0=nemá)
FormMenu        dw      0                       ; handle menu (0=menu tøídy)
FormClass       ENDS

SButtonClass    STRUC                           ; SPEED BUTTON
sbHBitmap       dw      0                       ; handle bitmapy (2 obrázky)
sbHBitmapM      dw      0                       ; maska bitmapy
sbBounds        BOUNDS  <0,(SPANELHEIGHT-SBUTTONHEIGHT)/2,    \
                          SBUTTONWIDTH,SBUTTONHEIGHT>  ; pozice a rozmìry
sbStatus        dw      0                       ; status:
                                                ;   0 = volné
                                                ;   1 = zakázáno
                                                ;   2 = stisknuto (drženo)
                                                ;   3 = trvale zapnuto
sbExec          dd      0                       ; adresa obsluhy stisku
SButtonClass    ENDS

; --- WINMAIN

GLOBAL          HInstance:WORD, HPrevInst: WORD, NewHWnd: WORD, CmdShow: WORD
GLOBAL          HDefPalette:WORD,DefPalette:BYTE

; --- MAINFORM

GLOBAL          MainFormReg:PROC,MainForm:FormClass,MainFormCreate:PROC

; --- FORMS

GLOBAL          FormReg:PROC,FormCreate:PROC,FormEvents:PROC

; --- GRAPHICS

GLOBAL          Panel:PROC,Plocha:PROC,Frame3D:PROC
;GLOBAL          PaletteTab:PALETTEENTRY

; --- BITMAP

GLOBAL          HSGPBMP:WORD
GLOBAL          LoadBMP:PROC,DeleteBMP:PROC,DispBitmap:PROC
GLOBAL          LoadDIBitmap:PROC
GLOBAL          HBANKA101BMP:WORD

; --- CONTROL

GLOBAL          ButtonLoad:PROC,ButtonDelete:PROC
GLOBAL          MButtonDisp:PROC,SButtonDisp:PROC
GLOBAL          SButtonNew:SButtonClass,SButtonLoad:SButtonClass
GLOBAL          SButtonSave:SButtonClass,SButtonExit:SButtonClass
GLOBAL          SButtonStart:SButtonClass,SButtonPause:SButtonClass
GLOBAL          SButtonSelect:SButtonClass,SButtonEdit:SButtonClass
