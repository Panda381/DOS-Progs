unit Ikona;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls;

type
  TIkonForm = class(TForm)
    Image: TImage;
    TimerIkon: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure ImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ImageMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ImageMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Zobraz;
    procedure TimerIkonTimer(Sender: TObject);
  private
    { Private declarations }
  public
    procedure ShowModal2;
  end;

var
  IkonForm: TIkonForm;
  InitX, InitY: Integer;
  Drag: Boolean;
  Zahodit: Boolean;
  IkonAktiv: Boolean;
  EnterButton: TMouseButton;

implementation

uses Main, Org;
{$R *.DFM}

procedure TIkonForm.FormCreate(Sender: TObject);
begin
  Parent := MainForm.Tabbed;
  ClientWidth := IconWidth;
  ClientHeight := IconHeight;
  Cursor := ID_RUKADRZICURSOR;
end;

procedure TIkonForm.FormShow(Sender: TObject);
begin
  Zahodit := False;
  SetCaptureControl(Image);
  InitX := -10000;
  InitY := -10000;
  Drag := False;
  Zobraz;
  IkonAktiv := True;
end;

procedure TIkonForm.ShowModal2;
begin
{  Screen.Cursor := ID_RUKADRZICURSOR;}
  Screen.Cursor := Cursor;
  if OrgForm.Visible then
    Parent := OrgForm
  else
    Parent := MainForm.Tabbed;

  TimerIkon.Enabled := True;
  Show;
  repeat
    Application.HandleMessage;
  until not IkonAktiv;
  Visible := False;
  TimerIkon.Enabled := False;
  Screen.Cursor := crDefault;
end;

procedure TIkonForm.Zobraz;
var Banka: TBitmap;
    I,J: Integer;
begin
  if Tag > 0 then with Image.Canvas do
  begin
    Banka := IkonBanks^[(Tag-1) div 1000]^.bnBitmap;
    I := (Tag-1) mod 1000;
    J := I div IconXNum;
    I := I mod IconXNum;
    Brush.Style := bsSolid;
    Brush.Color := clBlack;
    if Assigned(Banka) then
      CopyRect(
        Rect(0,0,IconWidth,IconHeight),
        Banka.Canvas,
        Rect(I*IconWidth,J*IconHeight,
             (I+1)*IconWidth,(J+1)*IconHeight))
    else
      FillRect(Rect(0,0,IconWidth,IconHeight));

    if Zahodit then
    begin
      Pen.Color := $1000008;
      Pen.Width := 2;
      Pen.Style := psSolid;
      Pen.Mode := pmCopy;
      MoveTo(0,0);
      LineTo(IconWidth,IconHeight);
      MoveTo(0,IconHeight);
      LineTo(IconWidth,0);
    end;
  end;
end;

procedure TIkonForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  IkonAktiv := False;
  SetCaptureControl(nil);
end;

procedure TIkonForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Tag := -1;
    IkonAktiv := False;
    Close;
    SetCaptureControl(nil);
  end;
end;

procedure TIkonForm.ImageMouseMove(Sender: TObject;
   Shift: TShiftState; X,Y: Integer);
var Bod: TPoint;
    Hranice: TRect;
    LZahodit: Boolean;
begin
  if not IkonAktiv then Exit;

  with MainForm do
    Case Tabbed.PageIndex of
      0: with ImageScene do
         begin
           Bod := Point(Left,Top);
           Bod := IkonForm.Parent.ScreenToCLient(ClientToScreen(Bod));
           Hranice := Bounds(Bod.X,Bod.Y,Width,Height);
         end;
      1: with ImageScene2 do
         begin
           Bod := Point(Left,Top);
           Bod := IkonForm.Parent.ScreenToCLient(ClientToScreen(Bod));
           Hranice := Bounds(Bod.X,Bod.Y,Width,Height);
         end;
    else with ImageProgram do
         begin
           Bod := Point(Left,Top);
           Bod := IkonForm.Parent.ScreenToCLient(ClientToScreen(Bod));
           Hranice := Bounds(Bod.X,Bod.Y,Width,Height);
         end;
    end;

  Bod := Parent.ScreenToClient(Image.ClientToScreen(Point(X,Y)));
  Left := Bod.X - Width div 2;
  Top := Bod.Y - Height div 2;

  if (Bod.X < Hranice.Left) or (Bod.X >= Hranice.Right)
    or (Bod.Y < Hranice.Top) or (Bod.Y >= Hranice.Bottom) then
    LZahodit := True
  else
    LZahodit := False;

  if LZahodit <> Zahodit then
  begin
    Zahodit := LZahodit;
    Zobraz;
  end;

  if InitX = -10000 then
  begin
    InitX := Left;
    InitY := Top;
  end;

  if GetCaptureControl <> Image then
    SetCaptureControl(Image);

  if ((Abs(Left-InitX) > 5)
     or (Abs(Top-InitY) > 5)) and ((ssLeft in Shift)
     or (ssRight in Shift)) then Drag := True;
end;

procedure TIkonForm.ImageMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var Bod: TPoint;
begin
  Bod.X := X;
  Bod.Y := Y;
  Bod := Image.ClientToScreen(Bod);
  Close;
  IkonAktiv := False;
  SetCaptureControl(nil);
{  Screen.Cursor := crDefault;}

  if (Shift = [ssRight]+[ssLeft]) or
     (((Shift = [ssRight]) or (Shift = [ssLeft]))
        and (Button <> EnterButton))  then
    Tag := -1
  else
    if OrgForm.Visible then
    begin
      Bod := OrgForm.ImageOrg.ScreenToClient(Bod);
      OrgForm.ImageOrgDrop(Bod.X, Bod.Y);
    end
    else
      Case MainForm.Tabbed.PageIndex of
        0: begin
             Bod := MainForm.ImageScene.ScreenToClient(Bod);
             MainForm.ImageSceneDrop(Bod.X, Bod.Y);
           end;
        2: begin
             Bod := MainForm.ImageProgram.ScreenToClient(Bod);
             MainForm.ImageProgramDrop(Bod.X, Bod.Y);
           end;
      end;
end;

procedure TIkonForm.ImageMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if GetCaptureControl <> Image then
    SetCaptureControl(Image);
  if Drag or (Tag = -2) then
    ImageMouseDown(Sender,Button,Shift,X,Y)
  else
    EnterButton := Button;
end;

procedure TIkonForm.TimerIkonTimer(Sender: TObject);
var Bod: TPoint;
begin
  if not IkonAktiv then Exit;
  GetCursorPos(Bod);
  Bod := ScreenToClient(Bod);
  ImageMouseMove(Sender,[],Bod.X, Bod.Y);
end;

end.
