unit Select;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls, Buttons, Tabs, Ikona;

type
  TSelForm = class(TForm)
    TabSet: TTabSet;
    PanelSpeed: TPanel;
    ButtonExit: TSpeedButton;
    ButtonLeft: TSpeedButton;
    ButtonRight: TSpeedButton;
    PanelStatus: TPanel;
    Image: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DispForm;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure ButtonExitClick(Sender: TObject);
    procedure TabSetClick(Sender: TObject);
    procedure ButtonLeftClick(Sender: TObject);
    procedure ButtonRightClick(Sender: TObject);
    procedure ImageMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ImageMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LoadResTxt;
    procedure DispKurz(Kurzor: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SelForm: TSelForm;
  SelectTxt: string;
  OldIkon: Integer;

implementation

uses Main, Org;

{$R *.DFM}

procedure TSelForm.FormCreate(Sender: TObject);
var Bitmap: TBitmap;
begin
  LoadResTxt;
  OldIkon := -1;

  Width := 591;
  Height := 400;

{ pøíprava plochy k volbì }
  Bitmap := TBitmap.Create;
  Bitmap.Width := IconXNum*IconWidth+IconXNum-1;
  Bitmap.Height := IconYNum*IconHeight+IconYNum-1;
  Image.Picture.Graphic := Bitmap;
  Image.Picture.Bitmap.Palette := MainForm.InitPal;

  SelForm.ButtonLeft.Glyph.Palette := MainForm.InitPal;
  SelForm.ButtonRight.Glyph.Palette := MainForm.InitPal;
  SelForm.ButtonExit.Glyph.Palette := MainForm.InitPal;
end;

procedure TSelForm.LoadResTxt;
begin
  SelectTxt := LoadResString(IDS_CAPTION+12);
  TabSet.Hint := LoadResString(IDS_SELECT+0);
  ButtonLeft.Hint := LoadResString(IDS_SELECT+1);
  ButtonRight.Hint := LoadResString(IDS_SELECT+2);
  ButtonExit.Hint := LoadResString(IDS_SELECT+3);
end;

procedure TSelForm.FormShow(Sender: TObject);
var I: Integer;
begin
  if EditName = '' then EditName := DefName;
  Caption := EditName + SelectTxt;
  with TabSet do
  begin
    Tabs.Clear;
    for I := 0 to MaxBank-1 do
      if Assigned(SelBanks^[I]^.bnBitmap) then Tabs.Add(IntToStr(I));
    if Tabs.Count = 0 then Tabs.Add('0');
    if SelIndex > Tabs.Count-1 then SelIndex := Tabs.Count-1;
    TabIndex := SelIndex;
  end;
  Tag := -1;
  TabSetClick(Sender);
end;

procedure TSelForm.TabSetClick(Sender: TObject);
begin
  SelIndex := TabSet.TabIndex;
  ActiveControl := PanelSpeed;
  DispForm;
end;

procedure TSelForm.DispForm;
var I,J: Integer;
    Cislo: Integer;
    Banka: TBitmap;
begin
  with Image.Canvas do
  begin
    Cislo := StrToInt(TabSet.Tabs[TabSet.TabIndex]);
    Banka := SelBanks^[Cislo]^.bnBitmap;
    Brush.Style := bsSolid;
    Brush.Color := clBlack;
    if Assigned(Banka) then
      CopyRect(Rect(0,0,IconWidth*IconXNum,IconHeight*IconYNum),
               Banka.Canvas,
               Rect(0,0,IconWidth*IconXNum,IconHeight*IconYNum))
    else
      FillRect(Rect(0,0,IconWidth*IconXNum,IconHeight*IconYNum));
  end;
  OldIkon := -1;
end;

procedure TSelForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  Case Key of
    #27: begin
           Key := #0;
           Close;
         end;
  end;
end;

procedure TSelForm.ButtonExitClick(Sender: TObject);
begin
  Close;
end;

procedure TSelForm.ButtonLeftClick(Sender: TObject);
begin
  TabSet.SelectNext(False);
end;

procedure TSelForm.ButtonRightClick(Sender: TObject);
begin
  TabSet.SelectNext(True);
end;

procedure TSelForm.ImageMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var Predmet: Longint;
    Ikona: Integer;
begin
  if (X >= 0) and (X < IconXNum*IconWidth) and
     (Y >= 0) and (Y < IconYNum*IconHeight) then
  begin
    Ikona := X div IconWidth + (Y div IconHeight)*IconXNum;
    Predmet := StrToInt(TabSet.Tabs[TabSet.TabIndex])* 1000
                + Ikona + 1;
    with Image do
    begin
      Hint := TextPredmet + IntToStr(Predmet);
      if SelBanks^[(Predmet-1) div 1000]^.bnPruchod[(Predmet-1) mod 1000] <> 1 then
        Hint := Hint + TextNepruch;
    end;

    if Ikona <> OldIkon then
    begin
      DispForm;
      DispKurz(Ikona);
      OldIkon := Ikona;
    end;

  end
  else
    Hint := '';
end;

procedure TSelForm.DispKurz(Kurzor: Integer);
var X,Y: Integer;
begin
  if Kurzor = -1 then Exit;
  X := (Kurzor mod IconXNum)*IconWidth;
  Y := (Kurzor div IconXNum)*IconHeight;
  with Image.Canvas do
  begin
    Pen.Mode := pmCopy;
    Pen.Color := clLime;
    Pen.Width := 1;
    MoveTo(X,Y);
    LineTo(X+IconWidth-1,Y);
    LineTo(X+IconWidth-1,Y+IconHeight-1);
    LineTo(X,Y+IconHeight-1);
    LineTo(X,Y+1);
    LineTo(X+IconWidth-2,Y+1);
    LineTo(X+IconWidth-2,Y+IconHeight-2);
    LineTo(X+1,Y+IconHeight-2);
    LineTo(X+1,Y+1);
  end;
end;

procedure TSelForm.ImageMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var Bod: TPoint;
begin
  with Image do
    if (X >= 0) and (X < IconXNum*IconWidth) and
       (Y >= 0) and (Y < IconYNum*IconHeight) then
    begin
      SelForm.Tag := 1 + X div IconWidth
            + (Y div IconHeight)*IconXNum
            + 1000*StrToInt(TabSet.Tabs[TabSet.TabIndex]);
      Bod.X := X;
      Bod.Y := Y;
      if OrgForm.Visible then
        Bod := OrgForm.ScreenToClient(Image.ClientToScreen(Bod))
      else
        Bod := MainForm.Tabbed.ScreenToClient(Image.ClientToScreen(Bod));
      IkonForm.Left := Bod.X - IkonForm.Width div 2;
      IkonForm.Top := Bod.Y - IkonForm.Height div 2;
      Close;
    end;
end;

end.
