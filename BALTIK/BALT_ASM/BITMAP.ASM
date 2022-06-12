
INCLUDE         def.inc

.Data

BaltikBMP1      db      'BALTIKBITMAP',0
HBMP1           dw      0

SGPBMP          db      'SGPBITMAP',0
HSGPBMP         dw      0

BANKA000BMP     db      'BANKA000BMP',0
HBANKA000BMP    dw      0
BANKA001BMP     db      'BANKA001BMP',0
HBANKA001BMP    dw      0
BANKA002BMP     db      'BANKA002BMP',0
HBANKA002BMP    dw      0
BANKA003BMP     db      'BANKA003BMP',0
HBANKA003BMP    dw      0
BANKA004BMP     db      'BANKA004BMP',0
HBANKA004BMP    dw      0
BANKA005BMP     db      'BANKA005BMP',0
HBANKA005BMP    dw      0
BANKA100BMP     db      'BANKA100BMP',0
HBANKA100BMP    dw      0
BANKA101BMP     db      'BANKA101BMP',0
HBANKA101BMP    dw      0

.Code

; -----------------------------------------------------------------------------
;               naètení obrázkù z resource
; -----------------------------------------------------------------------------

LoadBMP         PROC

                call    LoadDIBitmap,ds of BaltikBMP1
                mov     HBMP1,ax

                call    LoadDIBitmap,ds of SGPBMP
                mov     HSGPBMP,ax

                call    LoadDIBitmap,ds of BANKA000BMP
                mov     HBANKA000BMP,ax

                call    LoadDIBitmap,ds of BANKA001BMP
                mov     HBANKA001BMP,ax

                call    LoadDIBitmap,ds of BANKA002BMP
                mov     HBANKA002BMP,ax

                call    LoadDIBitmap,ds of BANKA003BMP
                mov     HBANKA003BMP,ax

                call    LoadDIBitmap,ds of BANKA004BMP
                mov     HBANKA004BMP,ax

                call    LoadDIBitmap,ds of BANKA005BMP
                mov     HBANKA005BMP,ax

                call    LoadDIBitmap,ds of BANKA100BMP
                mov     HBANKA100BMP,ax

                call    LoadDIBitmap,ds of BANKA101BMP
                mov     HBANKA101BMP,ax
                ret

LoadBMP         ENDP

; -----------------------------------------------------------------------------
;               naètení DIbitmapy z resource
; -----------------------------------------------------------------------------
; VSTUP: (4) jméno
; VÝSTUP: AX=handle bitmapy (0=není)
; -----------------------------------------------------------------------------
; Struktura BMP:
;  - BITMAPFILEHEADER (nenaèítá se pøi LoadResource)
;  - BITMAPINFOHEADER
;  - RGBQUAD
;  - BYTE
;
;  BITMAPFILEHEADER struc
;      bfType          dw ?         identifikátor typu, 'BM'
;      bfSize          dd ?         celková velikost souboru
;      bfReserved1     dw ?         ... rezerováno, musí být = 0
;      bfReserved2     dw ?         ... rezerováno, musí být = 0
;      bfOffBits       dd ?         offset dat od BITMAPFILEHEADER
;  BITMAPFILEHEADER ends
;
;      BITMAPINFO  struc
;         bmiHeader   db (SIZE BITMAPINFOHEADER) DUP (?)
;         bmiColors   db ?            ; array of RGBQUADs
;      BITMAPINFO  ends
;
;  BITMAPINFOHEADER struc
;      biSize           dd ?        velikost BITMAPINFOHEADER
;      biWidth          dd ?        šíøka bitmapy v bodech
;      biHeight         dd ?        výška bitmapy v bodech
;      biPlanes         dw ?        poèet barevných rovin
;      biBitCount       dw ?        poèet bitù na barevný bod
;
;      biCompression    dd ?        komprese 0=BI_RGB,1=BI_RLE8,2=BI_RLE4
;      biSizeImage      dd ?        velikost dat obrázku v bajtech (0=def.)
;      biXPelsPerMeter  dd ?        horizontálnì bodù na metr
;      biYPelsPerMeter  dd ?        vertikálnì bodù na metr
;      biClrUsed        dd ?        použitých barev z tabulky palet (0=vše)
;                                   (pro biBitCount=24 je velikost tabulky)
;      biClrImportant   dd ?        poèet barev dùležitých k zobrazení (0=vše)
;  BITMAPINFOHEADER ends
;
;  RGBQUAD         struc
;      rgbqBlue        db ?
;      rgbqGreen       db ?
;      rgbqRed         db ?
;      rgbqReserved    db ?
;  RGBQUAD         ends


LoadDIBitmap    PROC    lName:DWORD
                uses    es,si
                local   lhrsrc:WORD,lHGlobal:WORD,lHBitmap:WORD,   \
                        lAdresa:DWORD,lhdc:WORD,lHPalOld:WORD

; --- nalezení bitmapy v resource

                mov     lHBitmap,0              ; pøíznak neplatné bitmapy

                call    FindResource,HInstance,lName,0,RT_BITMAP
                or      ax,ax
                jz      LoadDIBitmap9
                mov     lhrsrc,ax

; --- naètení bitmapy do pamìti

                call    LoadResource,HInstance,lhrsrc
                or      ax,ax
                jz      LoadDIBitmap9
                mov     lHGlobal,ax

; --- uzamèení bitmapy (a naètení do pamìti)

                call    LockResource,lHGlobal
                mov     wrd lAdresa,ax
                mov     wrd lAdresa+2,cx

; --- pøíprava kontextu zaøízení

                call    GetDC,0
                mov     lhdc,ax

; --- použití palet

                call    SelectPalette,lhdc,HDefPalette,TRUE ; výbìr palet
                mov     lHPalOld,ax             ; pùvodní palety
                call    RealizePalette,lhdc     ; použití palet

; --- konverze bitmapy

                les     si,lAdresa              ; adresa bitmapy
                mov     bx,wrd es:[si].biClrUsed ; poèet barev
                or      bx,bx                   ; jsou všechny barvy ?
                jnz     LoadDIBitmap3
                mov     cx,es:[si].biBitCount   ; bitù na barevný bod
                dec     cx
                inc     bx
                shl     bx,cl
LoadDIBitmap3:  shl     bx,1
                shl     bx,1                    ; velikost tabulky barev
                add     bx,wrd es:[si].biSize   ; offset zaèátku dat
                add     bx,si                   ; adresa zaèátku dat

                call    CreateDIBitmap,       \
                        lhdc,                 \ ; kontext zaøízení
                        lAdresa,              \ ; adresa BITMAPINFOHEADER
                        0 CBM_INIT,           \ ; pøíznak inicializace
                        es bx,                \ ; adresa zaèátku dat
                        lAdresa,              \ ; adresa BITMAPINFO
                        DIB_RGB_COLORS          ; pøíznak použití palet

                mov     lHBitmap,ax

; --- navrácení pùvodních palet

                call    SelectPalette,lhdc,lHPalOld,TRUE

; --- uvolnìní kontextu zaøízení

                call    ReleaseDC,0,lhdc

; --- odemknutí bitmapy

LoadDIBitmap7:  call    GlobalUnlock,lHGlobal

; --- uvolnìní bitmapy z pamìti

LoadDIBitmap8:  call    FreeResource,lHGlobal
LoadDIBitmap9:  mov     ax,lHBitmap
                ret

LoadDIBitmap    ENDP

; -----------------------------------------------------------------------------
;               zobrazení bitmapy (bez maskování)
; -----------------------------------------------------------------------------
; VSTUP:   (2) kontext zaøízení
;          (2) handle bitmapy
;          (2)  LEFT
;          (2)  TOP
;          (2)  WIDTH
;          (2)  HEIGHT
;          (2)  SLEFT zdroje
;          (2)  STOP zdroje
; -----------------------------------------------------------------------------

DispBitmap      PROC    lhdc:WORD,lHBitmap:WORD,lLeft:WORD,lTop:WORD,     \
                        lWidth:WORD,lHeight:WORD,lSLeft:WORD,lSTop:WORD
                local   lcdc:WORD,lHOldBitmap:WORD,lhPalOld:WORD

; --- vytvoøení kompatibilní DC

                call    CreateCompatibleDC,lhdc ; vytvoøení kompatibilní DC
                mov     lcdc,ax

; --- výbìr palet plochy

                call    SelectPalette,lcdc,HDefPalette,TRUE ; výbìr palet
                mov     lHPalOld,ax             ; pùvodní palety
                call    RealizePalette,lcdc     ; použití palet

; --- výbìr objektu bitmapy

                call    SelectObject,lcdc,lHBitmap ; výbìr bitmapy
                or      ax,ax
                jz      DispBitmap8             ; chyba
                mov     lHOldBitmap,ax          ; pùvodní bitmapa

; --- pøenos obrázku

                call    BitBlt,lhdc,                          \ ; cílový DC
                        lLeft,lTop,                           \ ; left a top
                        lWidth,lHeight,                       \ ; rozmìry
                        lcdc,                                 \ ; zdrojový DC
                        lSLeft,lSTop,                         \ ; zdrojový X,Y
                        SRCCOPY_H,SRCCOPY_L                     ; parametry

; --- návrat pùvodního objektu bitmapy

                call    SelectObject,lcdc,lHOldBitmap

; --- navrácení pùvodních palet

DispBitmap8:    call    SelectPalette,lcdc,lHPalOld,TRUE

; --- zrušení pracovního DC

                call    DeleteDC,lcdc           ; zrušení DC
                ret

DispBitmap      ENDP

; -----------------------------------------------------------------------------
;               uvolnìní obrázkù
; -----------------------------------------------------------------------------

DeleteBMP       PROC

                call    DeleteObject,HBMP1
                call    DeleteObject,HSGPBMP
                call    DeleteObject,HBANKA000BMP
                call    DeleteObject,HBANKA001BMP
                call    DeleteObject,HBANKA002BMP
                call    DeleteObject,HBANKA003BMP
                call    DeleteObject,HBANKA004BMP
                call    DeleteObject,HBANKA005BMP
                call    DeleteObject,HBANKA100BMP
                call    DeleteObject,HBANKA101BMP
                ret

DeleteBMP       ENDP


                ENDS
                END
