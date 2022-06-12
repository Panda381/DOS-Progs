unit Org;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Edit, StdCtrls, Buttons, ExtCtrls, Ikona, Select, Yes;

type

  TOrgForm = class(TForm)
    ImageOrg: TImage;
    PanelSpeed: TPanel;
    ButtonExit: TSpeedButton;
    ButtonGrid: TSpeedButton;
    ButtonSelect: TSpeedButton;
    PanelStatus: TPanel;
    ButtonLeft: TSpeedButton;
    ButtonRight: TSpeedButton;
    ButtonEdit: TSpeedButton;
    ButtonSave: TSpeedButton;
    Edit: TEdit;
    SaveDialogEdit: TSaveDialog;
    procedure ButtonExitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ImageOrgMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ImageOrgMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ImageOrgDrop(X, Y: Integer);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonSelectClick(Sender: TObject);
    procedure Zobraz;
    procedure NextBank;
    procedure PrevBank;
    procedure ReadBank;
    procedure ButtonLeftClick(Sender: TObject);
    procedure ButtonRightClick(Sender: TObject);
    procedure EditClick(Sender: TObject);
    procedure EditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ImageOrgMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ButtonEditClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditKeyPress(Sender: TObject; var Key: Char);
    procedure ButtonSaveClick(Sender: TObject);
    function EditUloz: Boolean;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    function TestModi: Boolean;
    procedure LoadResTxt;
    procedure ButtonGridClick(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure InitHint(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OrgBitmap: TBitmap;       { buffer pro 1 ikonu pøi pøemisování }
  OrgForm: TOrgForm;
  OrgIkon: Integer;         { poèáteèní ikona táhnutí, -1=není }
  Org1Color: Shortint;      { barva poèáteèní ikony }
  Org1Pruchod: Byte;        { prùchod poèáteèní ikony }
  OrgMrizka: Boolean;       { zapnuta møížka }

  OrgBank: Integer;         { banka aktivní stránky }

implementation

{$R *.DFM}

uses Main;

procedure TOrgForm.ButtonExitClick(Sender: TObject);
begin
  Close;
end;

procedure TOrgForm.FormCreate(Sender: TObject);
var Bitmap: TBitmap;
begin
  LoadResTxt;

  ButtonSave.Enabled := MainForm.ButtonSaveScene.Enabled;
  OrgBank := 0;
  OrgMrizka := True;
  OrgIkon := -1;

  ImageOrg.Cursor := ID_LUPAPLUSCURSOR;
{  ButtonGrid.Cursor := ID_RUKAUKAZCURSOR;}

  Height := 405;
  Width := 593;

  Bitmap := TBitmap.Create;
  Bitmap.Width := IconXNum*IconWidth;
  Bitmap.Height := IconYNum*IconHeight;
  ImageOrg.Picture.Graphic := Bitmap;
  ImageOrg.Picture.Bitmap.Palette := MainForm.InitPal;

  OrgBitmap := TBitmap.Create;
  OrgBitmap.Width := IconWidth;
  OrgBitmap.Height := IconHeight;
  OrgBitmap.Palette := MainForm.InitPal;

  ButtonGrid.Glyph.Palette := MainForm.InitPal;
  ButtonLeft.Glyph.Palette := MainForm.InitPal;
  ButtonRight.Glyph.Palette := MainForm.InitPal;
  ButtonSelect.Glyph.Palette := MainForm.InitPal;
  ButtonEdit.Glyph.Palette := MainForm.InitPal;
  ButtonSave.Glyph.Palette := MainForm.InitPal;
  ButtonExit.Glyph.Palette := MainForm.InitPal;
end;

procedure TOrgForm.LoadResTxt;
begin
  SaveDialogEdit.Title := LoadResString(IDS_EDIT+16);
  SaveDialogEdit.Filter := LoadResString(IDS_EDIT+17);

  ButtonGrid.Hint := LoadResString(IDS_EDIT+20);
  ButtonSelect.Hint := LoadResString(IDS_EDIT+21);
  Edit.Hint := LoadResString(IDS_EDIT+22);
  ButtonLeft.Hint := LoadResString(IDS_EDIT+23);
  ButtonRight.Hint := LoadResString(IDS_EDIT+24);
  ButtonEdit.Hint := LoadResString(IDS_EDIT+25);
  ButtonSave.Hint := LoadResString(IDS_EDIT+26);
  ButtonExit.Hint := LoadResString(IDS_EDIT+27);
end;

procedure TOrgForm.FormDestroy(Sender: TObject);
begin
  OrgBitmap.Free;
end;

procedure TOrgForm.FormShow(Sender: TObject);
{ var I: Integer; }
begin
  Left := MainForm.Left + (MainForm.Width - Width) div 2;
  Top := MainForm.Top + (MainForm.Height - Height) div 2;

  ButtonGrid.Down := OrgMrizka;
  if not Assigned(SelBanks^[OrgBank]^.bnBitmap) then NextBank;
  ReadBank;
end;

procedure TOrgForm.ReadBank;
var I: Integer;
begin
  if EditName = '' then EditName := DefName;
{  Caption := EditName + EditaceTxt2;}
  Caption := EditaceTxt2;

  with EditBitmap do
  begin
    Canvas.Brush.Color := clBlack;
    if Assigned(SelBanks^[OrgBank]^.bnBitmap) then
      Assign(SelBanks^[OrgBank]^.bnBitmap)
    else
      Canvas.FillRect(Rect(0,0,Width,Height));
  end;

  for I := 0 to 149 do
  begin
    EditColor[I] := SelBanks^[OrgBank]^.bnColor[I];
    EditPruchod[I] := SelBanks^[OrgBank]^.bnPruchod[I];
    EditParam[I] := 0;
  end;

  Zobraz;
end;

procedure TOrgForm.NextBank;
var I: Integer;
begin
  I := OrgBank;
  repeat
    Inc(OrgBank);
    if OrgBank > 149 then OrgBank := 0;
  until Assigned(SelBanks^[OrgBank]^.bnBitmap) or (I=OrgBank);
end;

procedure TOrgForm.PrevBank;
var I: Integer;
begin
  I := OrgBank;
  repeat
    Dec(OrgBank);
    if OrgBank < 0 then OrgBank := 149;
  until Assigned(SelBanks^[OrgBank]^.bnBitmap) or (I=OrgBank);
end;

procedure TOrgForm.Zobraz;
var I,J: Integer;
begin
  Edit.Text := IntToStr(OrgBank);
  ImageOrg.Picture.Bitmap.Assign(EditBitmap);

  if OrgMrizka then
  begin
    with ImageOrg.Picture.Bitmap.Canvas do
    begin
      Brush.Style := bsSolid;
      Pen.Color := clWhite;
      Pen.Width := 1;
      Pen.Style := psSolid;
      Pen.Mode := pmCopy;

      for I := 1 to IconXNum-1 do
      begin
        MoveTo(I*IconWidth-1,0);
        LineTo(I*IconWidth-1,IconYNum*IconHeight);
      end;

      for J := 1 to IconYNum-1 do
      begin
        MoveTo(0,J*IconHeight-1);
        LineTo(IconXNum*IconWidth,J*IconHeight-1);
      end;

      for I := 0 to IconXNum-1 do
        for J := 0 to IconYNum-1 do
        begin
          if EditColor[J*IconXNum+I] >= 0 then
          begin
            Brush.Color := EditColor[J*IconXNum+I] + $1000000;
            Rectangle(I*IconWidth-1,J*IconHeight-1,
                      I*IconWidth-1+7,J*IconHeight-1+7);
          end;

          if EditPruchod[J*IconXNum+I] <> 1 then
          begin
            Pen.Color := clRed;
            Brush.Color := clWhite;
            Rectangle(I*IconWidth+IconWidth-8,J*IconHeight,
                      I*IconWidth+IconWidth,J*IconHeight+8);
            MoveTo(I*IconWidth+IconWidth-8,J*IconHeight);
            LineTo(I*IconWidth+IconWidth,J*IconHeight+8);
            MoveTo(I*IconWidth+IconWidth-8,J*IconHeight+7);
            LineTo(I*IconWidth+IconWidth,J*IconHeight-1);
            Pen.Color := clWhite;
          end;

          if EditParam[J*IconXNum+I] <> 0 then
          begin
            if EditParam[J*IconXNum+I] = 1 then
              Brush.Color := clRed
            else
              Brush.Color := clBlue;
            Rectangle(I*IconWidth-1+7,J*IconHeight-1,
                     I*IconWidth-1+14,J*IconHeight-1+7);
          end;

        end;

    end;
  end;

end;

procedure TOrgForm.ImageOrgMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var Poz, Rad: Integer;
   { Bod: TPoint;}
begin
  Poz := X div IconWidth;
  Rad := Y div IconHeight;

  InitHint(Sender, Shift, X, Y);

  OrgIkon := Rad*IconXNum + Poz;
  if (OrgIkon >= 0) and (OrgIkon < 150) then
  begin
    Org1Color := EditColor[OrgIkon];
    Org1Pruchod := EditPruchod[OrgIkon];
  end
  else
    OrgIkon := -1;
end;

procedure TOrgForm.ImageOrgMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var Poz, Rad: Integer;
begin
  InitHint(Sender, Shift, X, Y);

  if (X >=0) and (Y >= 0) and (OrgIkon >= 0) and (Button = mbLeft) then
  begin
    Poz := X div IconWidth;
    Rad := Y div IconHeight;
    if Poz >= IconXNum then Exit;
    if Rad >= IconYNum then Exit;
    if (Poz + Rad*IconXNum) <> OrgIkon then Exit;
    EditForm.Tag := Longint(OrgBank)*1000 + Poz + Rad*IconXNum + 1;
    EditForm.ShowModal;
    Zobraz;
    OrgIkon := -1;
  end;
end;

procedure TOrgForm.ButtonEditClick(Sender: TObject);
begin
  EditForm.Tag := OrgBank*1000 + EditForm.Tag mod 1000;
  EditForm.ShowModal;
  Zobraz;
  OrgIkon := -1;
end;

procedure TOrgForm.ImageOrgMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var Predmet: Longint;
    Poz, Rad: Integer;
    Bod: TPoint;
    Txt: string;
begin
 { Predmet := 0; }

  Poz := X div IconWidth;
  Rad := Y div IconHeight;

  if (X >= 0) and (Poz < IconXNum) and
     (Y >= 0) and (Rad < IconYNum) then
  begin
    Predmet := Longint(OrgBank)*1000 + Rad*IconXNum + Poz + 1;

    InitHint(Sender, Shift, X, Y);

    if (OrgIkon >= 0) then
    begin

      if ((Predmet-1) mod 1000 <> OrgIkon)
         and ((ssLeft in Shift) or (ssRight in Shift))
         and not IkonForm.Visible and not IkonAktiv then
      begin
        IkonBanks := SelBanks;

        OrgBitmap.Canvas.CopyRect(
          Rect(0,0,IconWidth,IconHeight),
          EditBitmap.Canvas,
          Bounds((OrgIkon mod IconXNum)*IconWidth,
                 (OrgIkon div IconXNum)*IconHeight,
                 IconWidth,IconHeight));

        Org1Color := EditColor[OrgIkon];
        Org1Pruchod := EditPruchod[OrgIkon];

        if ssRight in Shift then
        begin
          OrgIkon := -1;
          IkonForm.Cursor := ID_RUKAPLUSCURSOR;
        end
        else
          IkonForm.Cursor := ID_RUKADRZICURSOR;

        IkonForm.Tag := -2;
        IkonForm.Image.Canvas.CopyRect(
            Rect(0,0,IconWidth,IconHeight),
            OrgBitmap.Canvas,
            Rect(0,0,IconWidth,IconHeight));

        Update;
        Bod.X := X;
        Bod.Y := Y;
{        Bod := ImageOrg.ClientToScreen(Bod);}
        IkonForm.Left := Bod.X - IkonForm.Width div 2;
        IkonForm.Top := Bod.Y - IkonForm.Height div 2;
        IkonForm.ShowModal2;
        OrgIkon := -1;
      end;
    end;
  end
  else
    Hint := '';
end;

procedure TOrgForm.InitHint(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var Predmet: Longint;
    Poz, Rad: Integer;
    Txt: string;
{    Curs: Integer;}
begin
  Poz := X div IconWidth;
  Rad := Y div IconHeight;
{  Curs := ID_LUPAPLUSCURSOR;}

  if (X >= 0) and (Poz < IconXNum) and
     (Y >= 0) and (Rad < IconYNum) then
  begin
    Predmet := Longint(OrgBank)*1000 + Rad*IconXNum + Poz + 1;

    Txt := TextPredmet + IntToStr(Predmet);

    if EditPruchod[(Predmet-1) mod 1000] <> 1 then
      Txt := Txt + TextNepruch;

    if ssLeft in Shift then
      Txt := Txt + ' ' + TextPredmet3
    else
      if ssRight in Shift then
        Txt := Txt + ' ' + TextPredmet4
      else
        Txt := Txt + ' ' + TextPredmet2;

    if ImageOrg.Hint <> Txt then
    begin
      ImageOrg.Hint := Txt;
      MainForm.ShowHint(Sender);
    end;

{    if ssRight in Shift then
      Curs := ID_RUKAPLUSCURSOR;

    if ssLeft in Shift then
      Curs := ID_RUKADRZICURSOR;}

  end;

{  ImageOrg.Cursor := Curs;
  ImageOrg.DragCursor := Curs;
  OrgForm.Cursor := Curs;
  OrgForm.DragCursor := Curs;}
end;

procedure TOrgForm.ImageOrgDrop(X, Y: Integer);
var Poz, Rad: Integer;
    OPoz, ORad: Integer;
begin
  if IkonForm.Tag = -1 then
  begin
    OrgIkon := -1;
    Exit;
  end;

  if (X >=0) and (Y >= 0) then
  begin
    Poz := X div IconWidth;
    Rad := Y div IconHeight;
    if Poz >= IconXNum then Exit;
    if Rad >= IconYNum then Exit;

    if (Poz + Rad*IconXNum) <> OrgIkon then
    begin
{      EditModi := True;}

      if OrgIkon >= 0 then
      begin
        OPoz := OrgIkon mod IconXNum;
        ORad := OrgIkon div IconXNum;

        EditBitmap.Canvas.CopyRect(
          Bounds(OPoz*IconWidth,
           ORad*IconHeight,IconWidth,IconHeight),
          EditBitmap.Canvas,
          Bounds(Poz*IconWidth,Rad*IconHeight,IconWidth,IconHeight));

        EditColor[OrgIkon] := EditColor[Rad*IconXNum+Poz];
        EditPruchod[OrgIkon] := EditPruchod[Rad*IconXNum+Poz];
        EditParam[OrgIkon] := 1;
      end;

      EditBitmap.Canvas.CopyRect(
        Bounds(Poz*IconWidth,Rad*IconHeight,IconWidth,IconHeight),
        OrgBitmap.Canvas,
        Rect(0,0,IconWidth,IconHeight));

      EditColor[Rad*IconXNum+Poz] := Org1Color;
      EditPruchod[Rad*IconXNum+Poz] := Org1Pruchod;
      EditParam[Rad*IconXNum+Poz] := 1;

      Zobraz;
    end;
  end;
  OrgIkon := -1;
end;

procedure TOrgForm.ButtonSelectClick(Sender: TObject);
var Banka, Ikona: Integer;
begin
  OrgIkon := -1;
  SelForm.ShowModal;
  if SelForm.Tag <> -1 then
  begin
    Banka := (SelForm.Tag-1) div 1000;
    Ikona := (SelForm.Tag-1) mod 1000;

    Org1Color := SelBanks^[Banka]^.bnColor[Ikona];
    Org1Pruchod := SelBanks^[Banka]^.bnPruchod[Ikona];

    OrgBitmap.Canvas.Brush.Color := clBlack;
    if Assigned(SelBanks^[Banka]^.bnBitmap) then
      OrgBitmap.Canvas.CopyRect(
        Rect(0,0,IconWidth,IconHeight),
        SelBanks^[Banka]^.bnBitmap.Canvas,
        Bounds((Ikona mod IconXNum)*IconWidth,
         (Ikona div IconXNum)*IconHeight, IconWidth, IconHeight))
    else
      OrgBitmap.Canvas.FillRect(Rect(0,0,Width,Height));

    IkonForm.Cursor := ID_RUKAPLUSCURSOR;
    IkonForm.Tag := -2;
    IkonForm.Image.Canvas.CopyRect(
        Rect(0,0,IconWidth,IconHeight),
        OrgBitmap.Canvas,
        Rect(0,0,IconWidth,IconHeight));

    Update;
    IkonForm.ShowModal2;
    OrgIkon := -1;
  end;
end;

procedure TOrgForm.ButtonLeftClick(Sender: TObject);
begin
  if not TestModi then Exit;
  PrevBank;
  ReadBank;
end;

procedure TOrgForm.ButtonRightClick(Sender: TObject);
begin
  if not TestModi then Exit;
  NextBank;
  ReadBank;
end;

procedure TOrgForm.EditClick(Sender: TObject);
begin
  Edit.SelectAll;
end;

procedure TOrgForm.EditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var I: Integer;
begin
  if Key = VK_RETURN then
    if not TestModi then Key := VK_ESCAPE;

  Case Key of
    VK_RETURN: begin
                 Key := 0;
                 I := StrToIntDef(Edit.Text, -1);
                 if (I >=0) and (I < 200) then
                 begin
                   OrgBank := I;
                   ActiveControl := PanelStatus;
                   ReadBank;
                 end;
               end;
    VK_ESCAPE: begin
                 Key := 0;
                 ActiveControl := PanelStatus;
                 Zobraz;
               end;
  end;
end;

procedure StorBank(Banky: PBanks; Jmeno, AktDir: string);
var I: Integer;
begin
  if (AktDir+Jmeno = EditAktDir+EditName)
     or
     (Jmeno = '') and
       ((EditName = DefName) and (SceneName = '') and (ProgramName = '')
        or
        (EditAktDir+EditName = AktDirScene+ProgramName)
        or
        (EditAktDir+EditName = AktDirProgram+SceneName)) then
  begin
    with Banky^[OrgBank]^ do
    begin
      if not Assigned(bnBitmap) then
      begin
        bnBitmap := TBitmap.Create;
        bnBitmap.Width := IconXNum*IconWidth;
        bnBitmap.Height := IconYNum*IconHeight;
        bnBitmap.Palette := MainForm.InitPal;
      end;
      with bnBitmap do
        Canvas.CopyRect(
          Rect(0,0,Width,Height),
          EditBitmap.Canvas,
          Rect(0,0,Width,Height));
      for I := 0 to IconPageNum-1 do
      begin
        bnColor[I] := EditColor[I];
        bnPruchod[I] := EditPruchod[I];
      end;
    end;
  end;
end;

procedure TOrgForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Close;
    Key := 0;
  end;
end;

procedure TOrgForm.EditKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #13) or (Key = #27) then Key := #0;
end;

procedure SaveBanka(Jmeno: string);
var I,J,K,L,M,N: Integer;
    R,G,B: Byte;
    D, D0: Integer;
    StreamOut: TMemoryStream;
    BankBitmap: ^TBankBitmap;
    Barva: TColor;
    Barva0: Byte;
begin
  StreamOut := TMemoryStream.Create;
  New(BankBitmap);
  try { finaly }
      with BankBitmap^.BankIcon[0] do
      begin
        biData[0] := Ord('B');
        biData[1] := Ord('A');
        biData[2] := Ord('N');
        biData[3] := Ord('K');
        for I := 0 to 15 do
        begin
          biData[I*3+4]   := DefPalette[I*4]   div 4;
          biData[I*3+4+1] := DefPalette[I*4+1] div 4;
          biData[I*3+4+2] := DefPalette[I*4+2] div 4;
        end;
      end;
      StreamOut.Clear;
      StreamOut.SetSize(SizeHeadBank+IconPageNum*SizeOf(TBankIcon));
      StreamOut.Position := 0;
      StreamOut.WriteBuffer(BankBitmap^.BankIcon[0].biData,SizeHeadBank);

      for I := 0 to IconYNum-1 do
      begin
        for J := 0 to IconXNum-1 do
        begin
          with BankBitmap^.BankIcon[J] do
          begin
            biLastX := 38;
            biPruchod := EditPruchod[I*IconXNum+J];
            biLastY := 28;
            biMaskCol := EditColor[I*IconXNum+J];
            FillChar(biData,SizeOf(biData),0);
            biRes3 := $d8;
            biRes4 := $d3;
            for K := 0 to IconHeight-1 do
              for L := 0 to IconWidth-1 do
              begin
                Barva := EditBitmap.Canvas.Pixels[
                           L+J*IconWidth,K+I*IconHeight];
                R := Barva and $ff;
                G := (Barva div 256) and $ff;
                B := (Barva div 256 div 256) and $ff;
                D := 256+256+256;

                Barva0 := 0;
                for M := 0 to 15 do
                begin
                  D0 := Abs(DefPalette[M*4]-R)
                       + Abs(DefPalette[M*4+1]-G)
                       + Abs(DefPalette[M*4+2]-B);
                  if D0 < D then
                  begin
                    D := D0;
                    Barva0 := M;
                  end;
                end;

                M := 1 shl (7-L and 7);

                N := K*(IconWidthL div 2) + L div 8;
                if (Barva0 and 8) <> 0 then
                  biData[N] := biData[N] or M;

                N := N + IconWidthL div 8;
                if (Barva0 and 4) <> 0 then
                  biData[N] := biData[N] or M;

                N := N + IconWidthL div 8;
                if (Barva0 and 2) <> 0 then
                  biData[N] := biData[N] or M;

                N := N + IconWidthL div 8;
                if (Barva0 and 1) <> 0 then
                  biData[N] := biData[N] or M;

              end;
          end;
        end;
        StreamOut.WriteBuffer(BankBitmap^, SizeOf(TBankBitmap));
      end;
      StreamOut.SaveToFile(Jmeno);
    finally
      Dispose(BankBitmap);
    end;  { try }
  StreamOut.Free;
end;

procedure TOrgForm.ButtonSaveClick(Sender: TObject);
begin
  EditUloz;
end;

function TOrgForm.EditUloz: Boolean;   { TRUE = pokraèovat }
var Pripona: string;
    I: Integer;
    Cislo: Integer;
begin
  Result := False;
  case OrgBank of
        0..9: SaveDialogEdit.DefaultExt := 'B0' + IntToStr(OrgBank);
      10..99: SaveDialogEdit.DefaultExt := 'B'  + IntToStr(OrgBank);
    100..109: SaveDialogEdit.DefaultExt := 'C0' + IntToStr(OrgBank-100);
    else      SaveDialogEdit.DefaultExt := 'C'  + IntToStr(OrgBank-100);
  end;
  SaveDialogEdit.InitialDir := EditAktDir;
  SaveDialogEdit.FileName := EditName+'.'+SaveDialogEdit.DefaultExt;
  if SaveDialogEdit.Execute then
  begin
    Screen.Cursor := crHourGlass;

    EditAktDir := ExtractFilePath(SaveDialogEdit.FileName);
    EditName := ExtractFileName(SaveDialogEdit.FileName);
    if Pos('.',EditName) > 0 then
      Delete(EditName,Pos('.',EditName),200);

    Pripona := AnsiUpperCase(ExtractFileExt(SaveDialogEdit.FileName));
    if Pos('.',Pripona) > 0 then
      Delete(Pripona,Pos('.',Pripona),1);
    Pripona[1] := Chr(Ord(Pripona[1])-Ord('B')+Ord('0'));
    Cislo := StrToIntDef(Pripona,-1);
    if(Cislo >= 0) and (Cislo < MaxBank) then OrgBank := Cislo;

{    Caption := EditName + EditaceTxt2;}
    Caption := EditaceTxt2;

    SaveBanka(SaveDialogEdit.FileName);
    StorBank(@SceneBank, SceneName, AktDirScene);
    StorBank(@ProgramBank, ProgramName, AktDirProgram);

    for I := 0 to 149 do EditParam[I] := 0;
    Screen.Cursor := crDefault;
{    EditModi := False;}
    Result := True;
    Zobraz;
  end;
end;

procedure TOrgForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := TestModi;
end;

function TOrgForm.TestModi: Boolean;
var I: Integer;
begin
  Result := True;
  if not DemoMode then
    for I := 0 to 149 do
      if EditParam[I] = 1 then Result := False;
  if not Result then
  begin
    I := Hlaseni(EditModiText1,EditModiText2);
    if I = mrNo then Result := True;
    if I = mrYes then Result := EditUloz;
  end;
end;

procedure TOrgForm.ButtonGridClick(Sender: TObject);
begin
  OrgMrizka := not OrgMrizka;
  ButtonGrid.Down := OrgMrizka;
  Zobraz;
end;

procedure TOrgForm.EditExit(Sender: TObject);
var I: Integer;
begin
  I := StrToIntDef(Edit.Text, -1);
  if (I >=0) and (I < 200) then
  begin
    OrgBank := I;
    ActiveControl := PanelStatus;
    ReadBank;
  end;
end;

end.

