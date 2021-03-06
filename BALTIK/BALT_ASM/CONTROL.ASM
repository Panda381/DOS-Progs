
INCLUDE         def.inc

.Data
                db      16 dup (0)              ; zarovn�n�

NNewBitmap      db      'NEWBITMAP',0
NLoadBitmap     db      'LOADBITMAP',0
NSaveBitmap     db      'SAVEBITMAP',0
NExitBitmap     db      'EXITBITMAP',0
NStartBitmap    db      'STARTBITMAP',0
NPauseBitmap    db      'PAUSEBITMAP',0
NSelectBitmap   db      'SELECTBITMAP',0
NEditBitmap     db      'EDITBITMAP',0

SButtonNew      SButtonClass <>                 ; tla��tko NEW
SButtonLoad     SButtonClass <>                 ; tla��tko LOAD
SButtonSave     SButtonClass <>                 ; tla��tko SAVE
SButtonExit     SButtonClass <>                 ; tla��tko EXIT
SButtonStart    SButtonClass <>                 ; tla��tko START
SButtonPause    SButtonClass <>                 ; tla��tko Pause
SButtonSelect   SButtonClass <>                 ; tla��tko Select
SButtonEdit     SButtonClass <>                 ; tla��tko Edit

.Code

; -----------------------------------------------------------------------------
;               na�ten� tla��tek
; -----------------------------------------------------------------------------

ButtonLoad      PROC

                call    LoadDIBitmap,ds of NNewBitmap
                mov     SButtonNew.sbHBitmap,ax

                call    LoadDIBitmap,ds of NLoadBitmap
                mov     SButtonLoad.sbHBitmap,ax

                call    LoadDIBitmap,ds of NSaveBitmap
                mov     SButtonSave.sbHBitmap,ax
                mov     SButtonSave.sbStatus,1

                call    LoadDIBitmap,ds of NExitBitmap
                mov     SButtonExit.sbHBitmap,ax

                call    LoadDIBitmap,ds of NStartBitmap
                mov     SButtonStart.sbHBitmap,ax

                call    LoadDIBitmap,ds of NPauseBitmap
                mov     SButtonPause.sbHBitmap,ax
                mov     SButtonPause.sbStatus,3

                call    LoadDIBitmap,ds of NSelectBitmap
                mov     SButtonSelect.sbHBitmap,ax

                call    LoadDIBitmap,ds of NEditBitmap
                mov     SButtonEdit.sbHBitmap,ax
                ret

ButtonLoad      ENDP

; -----------------------------------------------------------------------------
;               deinicializace tla��tek
; -----------------------------------------------------------------------------

ButtonDelete    PROC

                call    DeleteObject,SButtonNew.sbHBitmap
                call    DeleteObject,SButtonLoad.sbHBitmap
                call    DeleteObject,SButtonSave.sbHBitmap
                call    DeleteObject,SButtonExit.sbHBitmap
                call    DeleteObject,SButtonStart.sbHBitmap
                call    DeleteObject,SButtonPause.sbHBitmap
                call    DeleteObject,SButtonSelect.sbHBitmap
                call    DeleteObject,SButtonEdit.sbHBitmap
                ret

ButtonDelete    ENDP

; -----------------------------------------------------------------------------
;               zobrazen� SPEED tla��tek hlavn�ho panelu
; -----------------------------------------------------------------------------

MButtonDisp     PROC    lhdc: WORD

; --- inicializace pozice tla��tek

                mov     SButtonNew.sbBounds.bnLeft,10
                mov     SButtonLoad.sbBounds.bnLeft,10+52
                mov     SButtonSave.sbBounds.bnLeft,10+52+52
                mov     SButtonExit.sbBounds.bnLeft,10+52+52+52

                mov     ax,MainForm.FormCBounds.bnWidth
                sub     ax,54
                mov     SButtonEdit.sbBounds.bnLeft,ax
                sub     ax,52
                mov     SButtonSelect.sbBounds.bnLeft,ax
                sub     ax,52
                mov     SButtonPause.sbBounds.bnLeft,ax
                sub     ax,52
                mov     SButtonStart.sbBounds.bnLeft,ax

; --- zobrazen� tla��tek

                call    SButtonDisp,lhdc,ds of SButtonNew
                call    SButtonDisp,lhdc,ds of SButtonLoad
                call    SButtonDisp,lhdc,ds of SButtonSave
                call    SButtonDisp,lhdc,ds of SButtonExit

                call    SButtonDisp,lhdc,ds of SButtonStart
                call    SButtonDisp,lhdc,ds of SButtonPause
                call    SButtonDisp,lhdc,ds of SButtonSelect
                call    SButtonDisp,lhdc,ds of SButtonEdit
                ret

MButtonDisp     ENDP

; -----------------------------------------------------------------------------
;               zobrazen� Speed tla��tka
; -----------------------------------------------------------------------------
; VSTUP:   (2) kontext za��zen�
;          (4) adresa tla��tka
; -----------------------------------------------------------------------------

SButtonDisp     PROC    lhdc:WORD,lAdresa:DWORD
                USES    es,si,di
                local   lcdc:WORD,lHOldBitmap:WORD,lBarva:DWORD,lmdc:WORD, \
                        lhPalOld:WORD,lMonoDC:WORD,lHMonoBitmap:WORD

; --- vykreslen� podkladov� plochy

                les     si,lAdresa
                mov     ax,TRUE                 ; tla��tko nen� zatla�eno
                cmp     es:[si].sbStatus,2      ; je tla��tko stisknuto ?
                jb      SButtonDisp2            ; nen� stisknuto
                mov     ax,FALSE                ; tla��tko zatla�eno
SButtonDisp2:   call    Panel,lhdc,es:[si].sbBounds.bnLeft,  \
                        es:[si].sbBounds.bnTop,               \
                        es:[si].sbBounds.bnWidth,             \
                        es:[si].sbBounds.bnHeight,2,ax


                les     si,lAdresa              ; bitmapa
                mov     ax,es:[si].sbBounds.bnLeft
                add     ax,(SBUTTONWIDTH-ICONWIDTH)/2
                mov     dx,es:[si].sbBounds.bnTop
                add     dx,(SBUTTONHEIGHT-ICONHEIGHT)/2

                mov     bx,ICONWIDTH
                mov     cx,ICONHEIGHT
                mov     di,ICONWIDTH
                cmp     es:[si].sbStatus,1      ; zak�z�no ?
                je      SButtonDisp3            ; zak�z�no
                mov     di,0
                jb      SButtonDisp3            ; povoleno, voln�
                inc     ax
                inc     dx
                dec     bx
                dec     cx

SButtonDisp3:   call    DispBitmap,lhdc,es:[si].sbHBitmap,     \
                        ax,dx,                                \ ; left a top
                        bx,cx,                                \ ; rozm�ry
                        di,0                                  \ ; zdrojov� X,Y

                ret









; --- vytvo�en� kompatibiln� DC

                call    CreateCompatibleDC,lhdc ; vytvo�en� kompatibiln� DC
                mov     lcdc,ax

; --- v�b�r palet plochy

                call    SelectPalette,lcdc,HDefPalette,TRUE ; v�b�r palet
                mov     lHPalOld,ax             ; p�vodn� palety
                call    RealizePalette,lcdc     ; pou�it� palet

; --- v�b�r objektu bitmapy

                les     si,lAdresa              ; bitmapa
                call    SelectObject,lcdc,es:[si].sbHBitmap ; v�b�r bitmapy
                mov     lHOldBitmap,ax          ; p�vodn� bitmapa
                or      ax,ax
                jz      SButtonDisp8            ; chyba

; --- na�ten� barvy pozad�

;                call    GetPixel,lcdc,0,ICONHEIGHT-1 ; bod vlevo dole
;                mov     wrd lBarva,ax
;                mov     wrd lBarva+2,dx

; --- vytvo�en� plochy pro mono

;                call    CreateCompatibleDC,lcdc
;                mov     lMonoDC,ax

; --- vytvo�en� mono bitmapy

;                call    CreateBitmap,ICONWIDTH,ICONHEIGHT,1,1,0,0
;                mov     lHMonoBitmap,ax

; --- p�id�len� mono bitmapy kontextu za��zen�

;                call    SelectObject,lMonoDC,lHMonoBitmap

; --- nastaven� barvy pozad�

;                call    SetBkColor,lMonoDC,lBarva

; --- konverze na mono obr�zek

;                call    BitBlt,lMonoDC,0,0,ICONWIDTH,ICONHEIGHT,  \
;                          lcdc,0,0,SRCCOPY_H,SRCCOPY_L

; --- p�enos obr�zku

                les     si,lAdresa              ; bitmapa
                mov     ax,es:[si].sbBounds.bnLeft
                add     ax,(SBUTTONWIDTH-ICONWIDTH)/2
                mov     dx,es:[si].sbBounds.bnTop
                add     dx,(SBUTTONHEIGHT-ICONHEIGHT)/2

                call    BitBlt,lhdc,                          \ ; c�lov� DC
                        ax,dx,                                \ ; left a top
                        ICONWIDTH,ICONHEIGHT,                 \ ; rozm�ry
                        lcdc,                                 \ ; zdrojov� DC
                        0,0,                                  \ ; zdrojov� X,Y
                        SRCCOPY_H,SRCCOPY_L                     ; parametry

; --- nastaven� barvy pop�ed� a pozad�

;                call    SetTextColor,lhdc,0,0
;                call    SetBkColor,lhdc,0ffh,0ffffh

; --- p�enos obr�zku 2

;                les     si,lAdresa              ; bitmapa
;                mov     ax,es:[si].sbBounds.bnLeft
;                add     ax,(SBUTTONWIDTH-ICONWIDTH)/2
;                mov     dx,es:[si].sbBounds.bnTop
;                add     dx,(SBUTTONHEIGHT-ICONHEIGHT)/2
;
;                call    BitBlt,lhdc,                          \ ; c�lov� DC
;                        ax,dx,                                \ ; left a top
;                        ICONWIDTH,ICONHEIGHT,                 \ ; rozm�ry
;                        lMonoDC,                              \ ; zdrojov� DC
;                        0,0,                                  \ ; zdrojov� X,Y
;                        SRCCOPY_H,SRCCOPY_L                     ; parametry
;                        00e2h,0746h                             ; parametry

; --- zru�en� mono bitmapy

;                call    DeleteObject,lHMonoBitmap

; --- zru�en� mono plochy

;                call    DeleteDC,lMonoDC

; --- n�vrat p�vodn�ho objektu bitmapy

                call    SelectObject,lcdc,lHOldBitmap

; --- navr�cen� p�vodn�ch palet

SButtonDisp8:   call    SelectPalette,lcdc,lHPalOld,TRUE

; --- zru�en� pracovn�ho DC

                call    DeleteDC,lcdc           ; zru�en� DC
                ret

SButtonDisp     ENDP


                ENDS
                END

procedure TCanvas.BrushCopy(const Dest: TRect; Bitmap: TBitmap;
  const Source: TRect; Color: TColor);
const
  ROP_DSPDxax = $00E20746;
var
  crBack, crText: TColorRef;
  W, H: Integer;
begin
  if Bitmap = nil then Exit;
  Changing;
  W := Source.Right - Source.Left;
  H := Source.Bottom - Source.Top;
  RequiredState([csHandleValid]);
     { Build a mask and paint through it }
  if not Assigned(MonoBmp) then
  begin
    MonoBmp := TBitmap.Create;
    MonoBmp.Monochrome := True;
  end;
  if W > MonoBmp.Width then MonoBmp.Width := W;
  if H > MonoBmp.Height then MonoBmp.Height := H;

  MonoBmp.Canvas.RequiredState([csHandleValid]);
  Bitmap.Canvas.RequiredState([csHandleValid]);
  crBack := SetBkColor(Bitmap.Canvas.FHandle, ColorToRGB(Color));
  BitBlt(MonoBmp.Canvas.FHandle, 0, 0, W, H,
    Bitmap.Canvas.FHandle, Source.Left, Source.Top, SrcCopy);
  SetBkColor(Bitmap.Canvas.FHandle, crBack);

  RequiredState([csHandleValid, csBrushValid]);
  StretchBlt(FHandle, Dest.Left, Dest.Top, Dest.Right - Dest.Left,
    Dest.Bottom - Dest.Top, Bitmap.Canvas.FHandle, Source.Left, Source.Top,
    W, H, SrcCopy);
  crText := SetTextColor(FHandle, 0);
  crBack := SetBkColor(FHandle, $FFFFFF);
  StretchBlt(FHandle, Dest.Left, Dest.Top, Dest.Right - Dest.Left,
    Dest.Bottom - Dest.Top, MonoBmp.Canvas.FHandle, 0, 0, W, H, ROP_DSPDxax);
  SetTextColor(FHandle, crText);
  SetBkColor(FHandle, crBack);
  Changed;
end;
