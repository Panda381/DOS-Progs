unit Edit;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls, Buttons, Yes;

type
  TEditForm = class(TForm)
    PanelEditSpeed: TPanel;
    PanelEdit: TPanel;
    PanelColor: TPanel;
    ImageColor: TImage;
    BoxPruchod: TCheckBox;
    ButtonEsc: TSpeedButton;
    ButtonNahoru: TSpeedButton;
    ButtonDolu: TSpeedButton;
    ButtonVpravo: TSpeedButton;
    ButtonVlevo: TSpeedButton;
    LabelEditNum: TLabel;
    PanelStatus: TPanel;
    PanelImageEdit: TPanel;
    ImageEdit: TImage;
    ButtonVlevoNahoru: TSpeedButton;
    ButtonVpravoNahoru: TSpeedButton;
    ButtonVlevoDolu: TSpeedButton;
    ButtonVpravoDolu: TSpeedButton;
    ButtonUndo: TSpeedButton;
    Panel1: TPanel;
    Panel2: TPanel;
    ImageEnter: TImage;
    ImageEsc: TImage;
    ButtonRedo: TSpeedButton;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonEscClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Zobraz;
    procedure ZobrazCol;
    procedure FormResize(Sender: TObject);
    procedure ButtonNahoruClick(Sender: TObject);
    procedure ButtonDoluClick(Sender: TObject);
    procedure ButtonVlevoClick(Sender: TObject);
    procedure ButtonVpravoClick(Sender: TObject);
    procedure ImageEditMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ImageColorMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ImageEditMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BoxPruchodClick(Sender: TObject);
    procedure LoadResTxt;
    procedure InitEditSize;
    procedure ButtonVlevoNahoruClick(Sender: TObject);
    procedure ButtonVlevoDoluClick(Sender: TObject);
    procedure ButtonVpravoDoluClick(Sender: TObject);
    procedure ButtonVpravoNahoruClick(Sender: TObject);
    procedure ButtonUndoClick(Sender: TObject);
    procedure ButtonRedoClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  EditForm: TEditForm;
  EditBitmap: TBitmap;      { buffer stránky pro editaci }
  RedoBitmap: TBitmap;      { buffer stránky pro navracení pro REDO }

  EditBod: Integer;         { šíøka bodu editoru }
  EditXNum: Integer;        { poèet bodù editoru horizontálnì }
  EditYNum: Integer;        { poèet bodù editoru vertikálnì }
  EditLeft: Integer;        { poèet bodù editoru na levém okraji }
  EditTop: Integer;         { poèet bodù editoru na horním okraji }

  ColHeight: Integer;       { výška ikony volby barvy (bez mezery) }
  ColWidth: Integer;        { šíøka ikony volby barvy }

  EditBarva: Integer;
  EditTrans: Integer;
{  EditModi: Boolean;}

  EditaceTxt: string;        { text "- editace pøedmìtu" }
  EditaceTxt2: string;        { text "- kopírování a pøesouvání pøedmìtù" }
  EditModiText1: string;
  EditModiText2: string;

  RedoColor:  array [0..149] of Shortint;  { index masky, -1=není }
  RedoPruchod: array [0..149] of Byte;    { 1=prùchodný, 0=není }
  EditColor:  array [0..149] of Shortint;  { index masky, -1=není }
  EditPruchod: array [0..149] of Byte;    { 1=prùchodný, 0=není }
  EditParam: array [0..149] of Byte;  { pøíznaky pøedmìtù }
                                     { 0=nic, 1=UNDO, 2=REDO }

  EditBarvaHint: string;    { text nápovìdy k tlaèítkùm }

implementation

uses Main, Org;
{$R *.DFM}

procedure TEditForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Case Key of
    VK_ESCAPE: begin
                Close;
                Key := 0;
               end;
{    VK_LEFT:  ButtonVlevoClick(Sender);
    VK_RIGHT: ButtonVpravoClick(Sender);
    VK_UP:    ButtonNahoruClick(Sender);
    VK_DOWN:  ButtonDoluClick(Sender); }
  end;
end;

procedure TEditForm.FormCreate(Sender: TObject);
var Bitmap: TBitmap;
begin
  Tag := 1;
  EditBarva := 15;
  EditTrans := -1;
  ColWidth := 25;
  ColHeight := 20;

  LoadResTxt;

  ImageEdit.Cursor := ID_TUZKACURSOR;
  ImageEnter.Cursor := ID_LUPAMINSCURSOR;
  ImageEsc.Cursor := ID_LUPAMINSCURSOR;

{ pøíprava editaèního bufferu }
  EditBitmap := TBitmap.Create;
  EditBitmap.Width := IconXNum*IconWidth;
  EditBitmap.Height := IconYNum*IconHeight;
  EditBitmap.Palette := MainForm.InitPal;

  RedoBitmap := TBitmap.Create;
  RedoBitmap.Width := IconXNum*IconWidth;
  RedoBitmap.Height := IconYNum*IconHeight;
  RedoBitmap.Palette := MainForm.InitPal;

{ pøíprava menu barev }
  Bitmap := TBitmap.Create;
  Bitmap.Width := ColWidth;
  Bitmap.Height := ColHeight*16+15;
  ImageColor.Picture.Graphic := Bitmap;
  ImageColor.Picture.Bitmap.Palette := MainForm.InitPal;

  EditForm.ButtonVlevo.Glyph.Palette := MainForm.InitPal;
  EditForm.ButtonVlevoNahoru.Glyph.Palette := MainForm.InitPal;
  EditForm.ButtonVlevoDolu.Glyph.Palette := MainForm.InitPal;
  EditForm.ButtonVpravo.Glyph.Palette := MainForm.InitPal;
  EditForm.ButtonVpravoNahoru.Glyph.Palette := MainForm.InitPal;
  EditForm.ButtonVpravoDolu.Glyph.Palette := MainForm.InitPal;
  EditForm.ButtonNahoru.Glyph.Palette := MainForm.InitPal;
  EditForm.ButtonDolu.Glyph.Palette := MainForm.InitPal;
  EditForm.ButtonUndo.Glyph.Palette := MainForm.InitPal;
  EditForm.ButtonRedo.Glyph.Palette := MainForm.InitPal;
  EditForm.ButtonEsc.Glyph.Palette := MainForm.InitPal;

{ pøíprava okna editoru }
  Bitmap := TBitmap.Create;
  Bitmap.Width := PanelImageEdit.Width;
  Bitmap.Height := PanelImageEdit.Height;
  ImageEdit.Picture.Graphic := Bitmap;
  ImageEdit.Picture.Bitmap.Palette := MainForm.InitPal;

  Bitmap := TBitmap.Create;
  Bitmap.Width := 2*IconWidth;
  Bitmap.Height := 2*IconHeight;
  ImageEnter.Picture.Graphic := Bitmap;
  ImageEnter.Picture.Bitmap.Palette := MainForm.InitPal;

  Bitmap := TBitmap.Create;
  Bitmap.Width := 2*IconWidth;
  Bitmap.Height := 2*IconHeight;
  ImageEsc.Picture.Graphic := Bitmap;
  ImageEsc.Picture.Bitmap.Palette := MainForm.InitPal;

  Height := 430;
  Width := 620;
end;

procedure TEditForm.LoadResTxt;
begin
  EditaceTxt := LoadResString(IDS_CAPTION+11);
  EditaceTxt2 := LoadResString(IDS_CAPTION+10);
  ImageColor.Hint := LoadResString(IDS_EDIT+0);
  BoxPruchod.Caption := LoadResString(IDS_EDIT+1);
  BoxPruchod.Hint := LoadResString(IDS_EDIT+2);

  ButtonNahoru.Hint := LoadResString(IDS_EDIT+3);
  ButtonVpravoNahoru.Hint := LoadResString(IDS_EDIT+4);
  ButtonVpravo.Hint := LoadResString(IDS_EDIT+5);
  ButtonVpravoDolu.Hint := LoadResString(IDS_EDIT+6);
  ButtonDolu.Hint := LoadResString(IDS_EDIT+7);
  ButtonVlevoDolu.Hint := LoadResString(IDS_EDIT+8);
  ButtonVlevo.Hint := LoadResString(IDS_EDIT+9);
  ButtonVlevoNahoru.Hint := LoadResString(IDS_EDIT+10);

  ImageEnter.Hint := LoadResString(IDS_EDIT+11);
  ButtonUndo.Hint := LoadResString(IDS_EDIT+12);
  ButtonRedo.Hint := LoadResString(IDS_EDIT+13);
  ImageEsc.Hint := LoadResString(IDS_EDIT+14);
  ButtonEsc.Hint := LoadResString(IDS_EDIT+15);
  EditModiText1 := LoadResString(IDS_EDIT+18);
  EditModiText2 := LoadResString(IDS_EDIT+19);

  EditBarvaHint := LoadResString(IDS_EDIT+28);
end;

procedure TEditForm.FormDestroy(Sender: TObject);
begin
  EditBitmap.Free;
  RedoBitmap.Free;
end;

procedure TEditForm.ButtonEscClick(Sender: TObject);
begin
  Close;
end;

procedure TEditForm.FormShow(Sender: TObject);
begin
  if EditName = '' then EditName := DefName;
{  Caption := EditName + EditaceTxt;}
  Caption := EditaceTxt;
  FormResize(Sender);

  Left := MainForm.Left + (MainForm.Width - Width) div 2;
  Top := MainForm.Top + (MainForm.Height - Height) div 2;
end;

procedure TEditForm.FormResize(Sender: TObject);
var I: Integer;
begin
  EditBod := PanelImageEdit.Width div (IconWidth * 3) +
      PanelImageEdit.Height div (IconHeight * 3);

  if EditBod > 13 then EditBod := 13;

  InitEditSize;

  for I := 0 to 2 do
    if (EditXNum*EditBod + 10 < PanelImageEdit.Width) or
       (EditYNum*EditBod + 10 < PanelImageEdit.Height) then
    begin
      Inc(EditBod);
      InitEditSize;
    end;

  for I := 0 to 10 do
    if ((IconWidth+4)*EditBod > PanelImageEdit.Width) or
       ((IconHeight+4)*EditBod > PanelImageEdit.Height) then
    begin
      Dec(EditBod);
      InitEditSize;
    end;

  ImageEdit.Picture.Bitmap.Width := EditXNum*EditBod;
  ImageEdit.Picture.Bitmap.Height := EditYNum*EditBod;
  ImageEdit.Left := (PanelImageEdit.Width - EditXNum*EditBod) div 2;
  ImageEdit.Top := (PanelImageEdit.Height - EditYNum*EditBod) div 2;

  ColHeight := (PanelEditSpeed.Height - 10) div 16 - 1;
  if ColHeight < 4 then ColHeight := 4;
  ImageColor.Picture.Bitmap.Height := (ColHeight+1)*16-1;
  ImageColor.Picture.Bitmap.Width := ColWidth;
  ImageColor.Top := 3;
  ImageColor.Left := 3;
  PanelColor.Height := ImageColor.Height + 6;
  PanelColor.Width := ImageColor.Width + 6;
  PanelColor.Top := (PanelEditSpeed.Height - PanelColor.Height) div 2;

  Zobraz;
end;

procedure TEditForm.InitEditSize;
begin
  if EditBod < 2 then EditBod := 2;

  EditXNum := PanelImageEdit.Width div EditBod;
  if EditXNum < IconWidth then EditXNum := IconWidth;
  if EditXNum > 2*IconWidth then EditXNum := 2*IconWidth;

  EditYNum := PanelImageEdit.Height div EditBod;
  if EditYNum < IconHeight then EditYNum := IconHeight;
  if EditYNum > 2*IconHeight then EditYNum := 2*IconHeight;

  EditLeft := (EditXNum - IconWidth) div 2;
  EditTop := (EditYNum - IconHeight) div 2;
end;

procedure TEditForm.Zobraz;
var I,J,K,L: Integer;
    Ikona: Integer;
    SRect,DRect,LRect,BRect,B2Rect: TRect;
begin
  LabelEditNum.Caption := IntToStr(Tag);
  Ikona := (Tag-1) mod 1000;

  Case EditParam[Ikona] of
    1: begin
         ButtonUndo.Enabled := True;
         ButtonRedo.Enabled := False;
       end;
    2: begin
         ButtonUndo.Enabled := False;
         ButtonRedo.Enabled := True;
       end;
  else begin
         ButtonUndo.Enabled := False;
         ButtonRedo.Enabled := False;
       end;
  end;

  with ImageEdit.Canvas do
  begin
    I := (Ikona mod IconXNum)*IconWidth - IconWidth div 2;
    J := (Ikona div IconXNum)*IconHeight - IconHeight div 2;
    K := I + 2*IconWidth;
    L := J + 2*IconHeight;

    BRect := Bounds(0,0,2*IconWidth,2*IconHeight);
    B2Rect := Bounds((IconWidth div 2 - EditLeft),
                   (IconHeight div 2 - EditTop),
                    EditXNum,EditYNum);
    LRect := BRect;

    if I < 0 then
    begin
      I := 0;
      LRect.Left := IconWidth div 2;
    end;

    if J < 0 then
    begin
      J := 0;
      LRect.Top := IconHeight div 2;
    end;

    if K > IconWidth*IconXNum then
    begin
      K := IconWidth*IconXNum;
      LRect.Right := IconWidth div 2 + IconWidth;
    end;

    if L > IconHeight*IconYNum then
    begin
      L := IconHeight*IconYNum;
      LRect.Bottom := IconHeight div 2 + IconHeight;
    end;

    SRect := Rect(I,J,K,L);
    DRect := Rect(0,0,EditXNum*EditBod,EditYNum*EditBod);

    with ImageEnter.Picture.Bitmap.Canvas do
    begin
      Brush.Color := clBlack;
      Brush.Style := bsSolid;
      FillRect(BRect);
    end;

    ImageEnter.Picture.Bitmap.Canvas.CopyRect(
                LRect,EditBitmap.Canvas,SRect);

    with ImageEsc.Canvas do
    begin
      Brush.Color := clBlack;
      Brush.Style := bsSolid;
      FillRect(BRect);
    end;

    if Assigned(SelBanks^[(Tag-1) div 1000]^.bnBitmap) then
      ImageEsc.Picture.Bitmap.Canvas.CopyRect(LRect,
        SelBanks^[(Tag-1) div 1000]^.bnBitmap.Canvas,SRect);

    CopyRect(DRect,ImageEnter.Picture.Bitmap.Canvas,B2Rect);

    Pen.Color := clGray;
    Pen.Style := psSolid;
    Pen.Width := 1;
    for I := 1 to EditXNum-1 do
    begin
      MoveTo(I*EditBod-1,0);
      LineTo(I*EditBod-1,EditYNum*EditBod);
    end;

    for I := 1 to EditYNum-1 do
    begin
      MoveTo(0,I*EditBod-1);
      LineTo(EditXNum*EditBod,I*EditBod-1);
    end;

    Pen.Color := clWhite;

    MoveTo(EditLeft*EditBod-1,0);
    LineTo(EditLeft*EditBod-1,EditYNum*EditBod);
    MoveTo((EditLeft + IconWidth)*EditBod-1,0);
    LineTo((EditLeft + IconWidth)*EditBod-1,EditYNum*EditBod);

    MoveTo(0,EditTop*EditBod-1);
    LineTo(EditXNum*EditBod,EditTop*EditBod-1);
    MoveTo(0,(EditTop + IconHeight)*EditBod-1);
    LineTo(EditXNum*EditBod,(EditTop + IconHeight)*EditBod-1);
  end;

{  if Ikona >= IconXNum then
    ButtonNahoru.Enabled := True
  else
    ButtonNahoru.Enabled := False;

  if Ikona < IconPageNum-IconXNum then
    ButtonDolu.Enabled := True
  else
    ButtonDolu.Enabled := False;

  if Ikona mod IconXNum > 0 then
    ButtonVlevo.Enabled := True
  else
    ButtonVlevo.Enabled := False;

  if Ikona mod IconXNum < IconXNum-1 then
    ButtonVpravo.Enabled := True
  else
    ButtonVpravo.Enabled := False;

  ButtonVlevoNahoru.Enabled := ButtonVlevo.Enabled and ButtonNahoru.Enabled;
  ButtonVlevoDolu.Enabled := ButtonVlevo.Enabled and ButtonDolu.Enabled;
  ButtonVpravoNahoru.Enabled := ButtonVpravo.Enabled and ButtonNahoru.Enabled;
  ButtonVpravoDolu.Enabled := ButtonVpravo.Enabled and ButtonDolu.Enabled; }

  ZobrazCol;
end;

procedure TEditForm.ZobrazCol;
var I: Integer;
    LRect: TRect;
begin
  EditTrans := EditColor[(Tag-1) mod 1000];
  BoxPruchod.Checked := EditPruchod[(Tag-1) mod 1000] <> 1;

{ vykreslení menu barev }
  with ImageColor.Picture.Bitmap.Canvas do
  begin
    Brush.Style := bsSolid;
    Brush.Color := clBtnFace;
    Pen.Width := 1;
    Pen.Style := psSolid;
    Pen.Mode := pmCopy;
    FillRect(Rect(0,0,Width,Height));
    for I := 0 to 15 do
    begin
      LRect := Rect(1,I*(ColHeight+1)+1,ColWidth-1,I*(ColHeight+1)+ColHeight-1);

      Pen.Color := clBtnShadow;
      MoveTo(0,LRect.Bottom-1);
      LineTo(0,LRect.Top-1);
      LineTo(LRect.Right,LRect.Top-1);

      Pen.Color := clBtnHighlight;
      MoveTo(1,LRect.Bottom);
      LineTo(LRect.Right,LRect.Bottom);
      LineTo(LRect.Right,LRect.Top-1);

      Brush.Color := $1000000+I;
      FillRect(LRect);

      if I = EditBarva then
      begin
        Case EditBarva of
          0,8: Pen.Color := clWhite
        else Pen.Color := clBlack;
        end;
        MoveTo(LRect.Left,LRect.Top);
        LineTo(LRect.Right-1,LRect.Top);
        LineTo(LRect.Right-1,LRect.Bottom-1);
        LineTo(LRect.Left,LRect.Bottom-1);
        LineTo(LRect.Left,LRect.Top);

        MoveTo(LRect.Left+1,LRect.Top+1);
        LineTo(LRect.Right-2,LRect.Top+1);
        LineTo(LRect.Right-2,LRect.Bottom-2);
        LineTo(LRect.Left+1,LRect.Bottom-2);
        LineTo(LRect.Left+1,LRect.Top+1);
      end;

      if I = EditTrans then with LRect do
      begin
        Case EditTrans of
          0..8: Pen.Color := clWhite
        else Pen.Color := clBlack;
        end;

        MoveTo(Left,Top);
        LineTo(Right,Bottom-1);
        MoveTo(Left,Top+1);
        LineTo(Right,Bottom);

        MoveTo(Left,Bottom-1);
        LineTo(Right,Top);
        MoveTo(Left,Bottom-2);
        LineTo(Right,Top-1);
      end;
    end;
  end;
end;

procedure TEditForm.ButtonNahoruClick(Sender: TObject);
begin
  if (Tag-1) mod 1000 >= IconXNum then
  begin
    Tag := Tag - IconXNum;
    Zobraz;
  end;
end;

procedure TEditForm.ButtonDoluClick(Sender: TObject);
begin
  if (Tag-1) mod 1000 < (IconPageNum-IconXNum) then
  begin
    Tag := Tag + IconXNum;
    Zobraz;
  end;
end;

procedure TEditForm.ButtonVlevoClick(Sender: TObject);
begin
  if ((Tag-1) mod 1000) mod IconXNum > 0 then
  begin
    Tag := Tag - 1;
    Zobraz;
  end;
end;

procedure TEditForm.ButtonVpravoClick(Sender: TObject);
begin
  if ((Tag-1) mod 1000) mod IconXNum < IconXNum-1 then
  begin
    Tag := Tag + 1;
    Zobraz;
  end;
end;

procedure TEditForm.ButtonVlevoNahoruClick(Sender: TObject);
begin
  ButtonVlevoClick(Sender);
  ButtonNahoruClick(Sender);
end;

procedure TEditForm.ButtonVlevoDoluClick(Sender: TObject);
begin
  ButtonVlevoClick(Sender);
  ButtonDoluClick(Sender);
end;

procedure TEditForm.ButtonVpravoDoluClick(Sender: TObject);
begin
  ButtonVpravoClick(Sender);
  ButtonDoluClick(Sender);
end;

procedure TEditForm.ButtonVpravoNahoruClick(Sender: TObject);
begin
  ButtonVpravoClick(Sender);
  ButtonNahoruClick(Sender);
end;

procedure TEditForm.ImageEditMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var I,J: Integer;
begin
  I := X;
  J := Y;
{  if (I >= EditLeft*EditBod) and
     (I < (EditLeft + IconWidth)*EditBod) and
     (J >= EditTop*EditBod) and
     (J < (EditTop + IconHeight)*EditBod) then }
    ImageEdit.Hint :=
        '| X = ' + IntToStr((I div EditBod + IconWidth - EditLeft) mod IconWidth)
      + ',  ' + ' Y = ' + IntToStr((J div EditBod + IconHeight - EditTop) mod IconHeight)
      + '        ' + #9 + EditBarvaHint;
{  else
    ImageEdit.Hint := '';}

  if ssLeft in Shift then
      ImageEditMouseDown(Sender,mbLeft,Shift,X,Y);

  if ssRight in Shift then
    ImageEditMouseDown(Sender,mbRight,Shift,X,Y);
end;

procedure TEditForm.ImageColorMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var I: Integer;
    Ikona: Integer;
begin
  Ikona := (Tag-1) mod 1000;

  if Button = mbLeft then
  begin
    if (Y >= 0) and (Y < (ColHeight+1)*16) then
      EditBarva := Y div (ColHeight+1);
    ZobrazCol;
  end;

  if Button = mbRight then
  begin
    if (Y >= 0) and (Y < (ColHeight+1)*16) then
    begin
      I := Y div (ColHeight+1);
      if I = EditTrans then
        EditTrans := -1
      else
        EditTrans := I;
      EditColor[Ikona] := EditTrans;
{      EditModi := True;}
      EditParam[Ikona] := 1;
      ButtonUndo.Enabled := True;
      ButtonRedo.Enabled := False;
    end;
    ZobrazCol;

  end;
end;

procedure TEditForm.ImageEditMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var I,J,K,L: Integer;
    C, D, D0: Longint;
    R,G,B: Byte;
    Ikona: Integer;
begin
  I := X;
  J := Y;

  if (I >= 0) and (I < EditXNum*EditBod) and
     (J >= 0) and (J < EditYNum*EditBod) then
  begin
    I := I div EditBod;
    J := J div EditBod;

    if Button = mbRight then
    begin
      C := ImageEnter.Picture.Bitmap.Canvas.Pixels[I-EditLeft+
          IconWidth div 2,J-EditTop+IconHeight div 2] and $ffffff;
      D := 256*256*256;
      R := C and $ff;
      G := (C div 256) and $ff;
      B := (C div 256 div 256) and $ff;
      for K := 0 to 15 do
      begin
        D0 := Abs(DefPalette[K*4]-R) + Abs(DefPalette[K*4+1]-G)
              + Abs(DefPalette[K*4+2]-B);
        if D > D0 then
        begin
          D := D0;
          EditBarva := K;
        end;
      end;
      ZobrazCol;
    end;

    if (Button = mbLeft) then
    begin
      Ikona := (Tag - 1) mod 1000;
      K := Ikona mod IconXNum;
      L := Ikona div IconXNum;
      if ((K > 0) or (I >= EditLeft)) and
         ((L > 0) or (J >= EditTop)) and
         ((K < IconXNum-1) or (I < EditLeft+IconWidth)) and
         ((L < IconYNum-1) or (J < EditTop+IconHeight)) then
      begin
        EditBitmap.Canvas.Pixels[K*IconWidth + I-EditLeft,
           L*IconHeight + J-EditTop] := EditBarva + $1000000;
{        EditModi := True;}
        ImageEnter.Canvas.Pixels[I-EditLeft+IconWidth div 2,
           J-EditTop+IconHeight div 2] := EditBarva + $1000000;

        if (I >= EditLeft) and (I < EditLeft+IconWidth) and
           (J >= EditTop) and (J < EditTop+IconHeight) then
        begin
          ButtonUndo.Enabled := True;
          ButtonRedo.Enabled := False;
        end;

        if I < EditLeft then Ikona := Ikona - 1;
        if I >= EditLeft+IconWidth then Ikona := Ikona + 1;
        if J < EditTop then Ikona := Ikona - IconXNum;
        if J >= EditTop+IconHeight then Ikona := Ikona + IconXNum;
        EditParam[Ikona] := 1;

        with ImageEdit.Canvas do
        begin
          Brush.Style := bsSolid;
          Brush.Color := EditBarva + $1000000;
          FillRect(Rect(I*EditBod,J*EditBod,
            I*EditBod+EditBod-1,
            J*EditBod+EditBod-1));
        end;
      end;
    end;

  end;
end;

procedure TEditForm.BoxPruchodClick(Sender: TObject);
var Ikona: Integer;
    Pruchod: Integer;
begin
  if BoxPruchod.Checked then
    Pruchod := 0
  else
    Pruchod := 1;

  Ikona := (Tag-1) mod 1000;
  if EditPruchod[Ikona] <> Pruchod then
  begin
    EditPruchod[Ikona] := Pruchod;
{    EditModi := True;}
    EditParam[Ikona] := 1;
    ButtonUndo.Enabled := True;
    ButtonRedo.Enabled := False;
  end;
end;

procedure TEditForm.ButtonUndoClick(Sender: TObject);
var LRect: TRect;
    Ikona, Banka: Integer;
begin
  Ikona := (Tag-1) mod 1000;
  Banka := (Tag-1) div 1000;

  if EditParam[Ikona] <> 1 then Exit;

  LRect := Bounds((Ikona mod IconXNum)*IconWidth,
       (Ikona div IconXNum)*IconHeight,IconWidth,IconHeight);

  RedoBitmap.Canvas.CopyRect(LRect,EditBitmap.Canvas,LRect);
  RedoColor[Ikona] := EditColor[Ikona];
  RedoPruchod[Ikona] := EditPruchod[Ikona];

  with EditBitmap.Canvas do
    if Assigned(SelBanks^[Banka]^.bnBitmap) then
      CopyRect(LRect,SelBanks^[Banka]^.bnBitmap.Canvas,LRect)
    else
    begin
      Brush.Color := clBlack;
      FillRect(LRect);
    end;

  EditColor[Ikona] := SelBanks^[Banka]^.bnColor[Ikona];
  EditPruchod[Ikona] := SelBanks^[Banka]^.bnPruchod[Ikona];
  EditParam[Ikona] := 2;
  Zobraz;
end;

procedure TEditForm.ButtonRedoClick(Sender: TObject);
var LRect: TRect;
    Ikona {, Banka}: Integer;
begin
  Ikona := (Tag-1) mod 1000;
 { Banka := (Tag-1) div 1000;}

  if EditParam[Ikona] <> 2 then Exit;

  LRect := Bounds((Ikona mod IconXNum)*IconWidth,
       (Ikona div IconXNum)*IconHeight,IconWidth,IconHeight);
  EditBitmap.Canvas.CopyRect(LRect,RedoBitmap.Canvas,LRect);
  EditColor[Ikona] := RedoColor[Ikona];
  EditPruchod[Ikona] := RedoPruchod[Ikona];
  EditParam[Ikona] := 1;
  Zobraz;
end;

end.
