
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
;               na�ten� obr�zk� z resource
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
;               na�ten� DIbitmapy z resource
; -----------------------------------------------------------------------------
; VSTUP: (4) jm�no
; V�STUP: AX=handle bitmapy (0=nen�)
; -----------------------------------------------------------------------------
; Struktura BMP:
;  - BITMAPFILEHEADER (nena��t� se p�i LoadResource)
;  - BITMAPINFOHEADER
;  - RGBQUAD
;  - BYTE
;
;  BITMAPFILEHEADER struc
;      bfType          dw ?         identifik�tor typu, 'BM'
;      bfSize          dd ?         celkov� velikost souboru
;      bfReserved1     dw ?         ... rezerov�no, mus� b�t = 0
;      bfReserved2     dw ?         ... rezerov�no, mus� b�t = 0
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
;      biWidth          dd ?        ���ka bitmapy v bodech
;      biHeight         dd ?        v��ka bitmapy v bodech
;      biPlanes         dw ?        po�et barevn�ch rovin
;      biBitCount       dw ?        po�et bit� na barevn� bod
;
;      biCompression    dd ?        komprese 0=BI_RGB,1=BI_RLE8,2=BI_RLE4
;      biSizeImage      dd ?        velikost dat obr�zku v bajtech (0=def.)
;      biXPelsPerMeter  dd ?        horizont�ln� bod� na metr
;      biYPelsPerMeter  dd ?        vertik�ln� bod� na metr
;      biClrUsed        dd ?        pou�it�ch barev z tabulky palet (0=v�e)
;                                   (pro biBitCount=24 je velikost tabulky)
;      biClrImportant   dd ?        po�et barev d�le�it�ch k zobrazen� (0=v�e)
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

; --- nalezen� bitmapy v resource

                mov     lHBitmap,0              ; p��znak neplatn� bitmapy

                call    FindResource,HInstance,lName,0,RT_BITMAP
                or      ax,ax
                jz      LoadDIBitmap9
                mov     lhrsrc,ax

; --- na�ten� bitmapy do pam�ti

                call    LoadResource,HInstance,lhrsrc
                or      ax,ax
                jz      LoadDIBitmap9
                mov     lHGlobal,ax

; --- uzam�en� bitmapy (a na�ten� do pam�ti)

                call    LockResource,lHGlobal
                mov     wrd lAdresa,ax
                mov     wrd lAdresa+2,cx

; --- p��prava kontextu za��zen�

                call    GetDC,0
                mov     lhdc,ax

; --- pou�it� palet

                call    SelectPalette,lhdc,HDefPalette,TRUE ; v�b�r palet
                mov     lHPalOld,ax             ; p�vodn� palety
                call    RealizePalette,lhdc     ; pou�it� palet

; --- konverze bitmapy

                les     si,lAdresa              ; adresa bitmapy
                mov     bx,wrd es:[si].biClrUsed ; po�et barev
                or      bx,bx                   ; jsou v�echny barvy ?
                jnz     LoadDIBitmap3
                mov     cx,es:[si].biBitCount   ; bit� na barevn� bod
                dec     cx
                inc     bx
                shl     bx,cl
LoadDIBitmap3:  shl     bx,1
                shl     bx,1                    ; velikost tabulky barev
                add     bx,wrd es:[si].biSize   ; offset za��tku dat
                add     bx,si                   ; adresa za��tku dat

                call    CreateDIBitmap,       \
                        lhdc,                 \ ; kontext za��zen�
                        lAdresa,              \ ; adresa BITMAPINFOHEADER
                        0 CBM_INIT,           \ ; p��znak inicializace
                        es bx,                \ ; adresa za��tku dat
                        lAdresa,              \ ; adresa BITMAPINFO
                        DIB_RGB_COLORS          ; p��znak pou�it� palet

                mov     lHBitmap,ax

; --- navr�cen� p�vodn�ch palet

                call    SelectPalette,lhdc,lHPalOld,TRUE

; --- uvoln�n� kontextu za��zen�

                call    ReleaseDC,0,lhdc

; --- odemknut� bitmapy

LoadDIBitmap7:  call    GlobalUnlock,lHGlobal

; --- uvoln�n� bitmapy z pam�ti

LoadDIBitmap8:  call    FreeResource,lHGlobal
LoadDIBitmap9:  mov     ax,lHBitmap
                ret

LoadDIBitmap    ENDP

; -----------------------------------------------------------------------------
;               zobrazen� bitmapy (bez maskov�n�)
; -----------------------------------------------------------------------------
; VSTUP:   (2) kontext za��zen�
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

; --- vytvo�en� kompatibiln� DC

                call    CreateCompatibleDC,lhdc ; vytvo�en� kompatibiln� DC
                mov     lcdc,ax

; --- v�b�r palet plochy

                call    SelectPalette,lcdc,HDefPalette,TRUE ; v�b�r palet
                mov     lHPalOld,ax             ; p�vodn� palety
                call    RealizePalette,lcdc     ; pou�it� palet

; --- v�b�r objektu bitmapy

                call    SelectObject,lcdc,lHBitmap ; v�b�r bitmapy
                or      ax,ax
                jz      DispBitmap8             ; chyba
                mov     lHOldBitmap,ax          ; p�vodn� bitmapa

; --- p�enos obr�zku

                call    BitBlt,lhdc,                          \ ; c�lov� DC
                        lLeft,lTop,                           \ ; left a top
                        lWidth,lHeight,                       \ ; rozm�ry
                        lcdc,                                 \ ; zdrojov� DC
                        lSLeft,lSTop,                         \ ; zdrojov� X,Y
                        SRCCOPY_H,SRCCOPY_L                     ; parametry

; --- n�vrat p�vodn�ho objektu bitmapy

                call    SelectObject,lcdc,lHOldBitmap

; --- navr�cen� p�vodn�ch palet

DispBitmap8:    call    SelectPalette,lcdc,lHPalOld,TRUE

; --- zru�en� pracovn�ho DC

                call    DeleteDC,lcdc           ; zru�en� DC
                ret

DispBitmap      ENDP

; -----------------------------------------------------------------------------
;               uvoln�n� obr�zk�
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