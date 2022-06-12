
INCLUDE         def.inc

.Data
                db      16 dup (0)              ; zarovnání

NNewBitmap      db      'NEWBITMAP',0
NLoadBitmap     db      'LOADBITMAP',0
NSaveBitmap     db      'SAVEBITMAP',0
NExitBitmap     db      'EXITBITMAP',0
NStartBitmap    db      'STARTBITMAP',0
NPauseBitmap    db      'PAUSEBITMAP',0
NSelectBitmap   db      'SELECTBITMAP',0
NEditBitmap     db      'EDITBITMAP',0

SButtonNew      SButtonClass <>                 ; tlaèítko NEW
SButtonLoad     SButtonClass <>                 ; tlaèítko LOAD
SButtonSave     SButtonClass <>                 ; tlaèítko SAVE
SButtonExit     SButtonClass <>                 ; tlaèítko EXIT
SButtonStart    SButtonClass <>                 ; tlaèítko START
SButtonPause    SButtonClass <>                 ; tlaèítko Pause
SButtonSelect   SButtonClass <>                 ; tlaèítko Select
SButtonEdit     SButtonClass <>                 ; tlaèítko Edit

.Code

; -----------------------------------------------------------------------------
;               naètení tlaèítek
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
;               deinicializace tlaèítek
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
;               zobrazení SPEED tlaèítek hlavního panelu
; -----------------------------------------------------------------------------

MButtonDisp     PROC    lhdc: WORD

; --- inicializace pozice tlaèítek

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

; --- zobrazení tlaèítek

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
;               zobrazení Speed tlaèítka
; -----------------------------------------------------------------------------
; VSTUP:   (2) kontext zaøízení
;          (4) adresa tlaèítka
; -----------------------------------------------------------------------------

SButtonDisp     PROC    lhdc:WORD,lAdresa:DWORD
                USES    es,si,di
                local   lcdc:WORD,lHOldBitmap:WORD,lBarva:DWORD,lmdc:WORD, \
                        lhPalOld:WORD,lMonoDC:WORD,lHMonoBitmap:WORD

; --- vykreslení podkladové plochy

                les     si,lAdresa
                mov     ax,TRUE                 ; tlaèítko není zatlaèeno
                cmp     es:[si].sbStatus,2      ; je tlaèítko stisknuto ?
                jb      SButtonDisp2            ; není stisknuto
                mov     ax,FALSE                ; tlaèítko zatlaèeno
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
                cmp     es:[si].sbStatus,1      ; zakázáno ?
                je      SButtonDisp3            ; zakázáno
                mov     di,0
                jb      SButtonDisp3            ; povoleno, volné
                inc     ax
                inc     dx
                dec     bx
                dec     cx

SButtonDisp3:   call    DispBitmap,lhdc,es:[si].sbHBitmap,     \
                        ax,dx,                                \ ; left a top
                        bx,cx,                                \ ; rozmìry
                        di,0                                  \ ; zdrojový X,Y

                ret









; --- vytvoøení kompatibilní DC

                call    CreateCompatibleDC,lhdc ; vytvoøení kompatibilní DC
                mov     lcdc,ax

; --- výbìr palet plochy

                call    SelectPalette,lcdc,HDefPalette,TRUE ; výbìr palet
                mov     lHPalOld,ax             ; pùvodní palety
                call    RealizePalette,lcdc     ; použití palet

; --- výbìr objektu bitmapy

                les     si,lAdresa              ; bitmapa
                call    SelectObject,lcdc,es:[si].sbHBitmap ; výbìr bitmapy
                mov     lHOldBitmap,ax          ; pùvodní bitmapa
                or      ax,ax
                jz      SButtonDisp8            ; chyba

; --- naètení barvy pozadí

;                call    GetPixel,lcdc,0,ICONHEIGHT-1 ; bod vlevo dole
;                mov     wrd lBarva,ax
;                mov     wrd lBarva+2,dx

; --- vytvoøení plochy pro mono

;                call    CreateCompatibleDC,lcdc
;                mov     lMonoDC,ax

; --- vytvoøení mono bitmapy

;                call    CreateBitmap,ICONWIDTH,ICONHEIGHT,1,1,0,0
;                mov     lHMonoBitmap,ax

; --- pøidìlení mono bitmapy kontextu zaøízení

;                call    SelectObject,lMonoDC,lHMonoBitmap

; --- nastavení barvy pozadí

;                call    SetBkColor,lMonoDC,lBarva

; --- konverze na mono obrázek

;                call    BitBlt,lMonoDC,0,0,ICONWIDTH,ICONHEIGHT,  \
;                          lcdc,0,0,SRCCOPY_H,SRCCOPY_L

; --- pøenos obrázku

                les     si,lAdresa              ; bitmapa
                mov     ax,es:[si].sbBounds.bnLeft
                add     ax,(SBUTTONWIDTH-ICONWIDTH)/2
                mov     dx,es:[si].sbBounds.bnTop
                add     dx,(SBUTTONHEIGHT-ICONHEIGHT)/2

                call    BitBlt,lhdc,                          \ ; cílový DC
                        ax,dx,                                \ ; left a top
                        ICONWIDTH,ICONHEIGHT,                 \ ; rozmìry
                        lcdc,                                 \ ; zdrojový DC
                        0,0,                                  \ ; zdrojový X,Y
                        SRCCOPY_H,SRCCOPY_L                     ; parametry

; --- nastavení barvy popøedí a pozadí

;                call    SetTextColor,lhdc,0,0
;                call    SetBkColor,lhdc,0ffh,0ffffh

; --- pøenos obrázku 2

;                les     si,lAdresa              ; bitmapa
;                mov     ax,es:[si].sbBounds.bnLeft
;                add     ax,(SBUTTONWIDTH-ICONWIDTH)/2
;                mov     dx,es:[si].sbBounds.bnTop
;                add     dx,(SBUTTONHEIGHT-ICONHEIGHT)/2
;
;                call    BitBlt,lhdc,                          \ ; cílový DC
;                        ax,dx,                                \ ; left a top
;                        ICONWIDTH,ICONHEIGHT,                 \ ; rozmìry
;                        lMonoDC,                              \ ; zdrojový DC
;                        0,0,                                  \ ; zdrojový X,Y
;                        SRCCOPY_H,SRCCOPY_L                     ; parametry
;                        00e2h,0746h                             ; parametry

; --- zrušení mono bitmapy

;                call    DeleteObject,lHMonoBitmap

; --- zrušení mono plochy

;                call    DeleteDC,lMonoDC

; --- návrat pùvodního objektu bitmapy

                call    SelectObject,lcdc,lHOldBitmap

; --- navrácení pùvodních palet

SButtonDisp8:   call    SelectPalette,lcdc,lHPalOld,TRUE

; --- zrušení pracovního DC

                call    DeleteDC,lcdc           ; zrušení DC
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