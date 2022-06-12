unit Registr;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, Yes;

type
  TRegForm = class(TForm)
    LabelNadpis: TLabel;
    ButtonYes: TBitBtn;
    ButtonCancel: TBitBtn;
    EditRegistr: TEdit;
    EditJmeno: TEdit;
    EditFirma: TEdit;
    EditMesto: TEdit;
    EditStat: TEdit;
    LabelJmeno: TLabel;
    LabelFirma: TLabel;
    LabelMesto: TLabel;
    LabelStat: TLabel;
    LabelRegistr: TLabel;
    LabelSerial: TLabel;
    LabelSerial2: TLabel;
    EditSerial: TEdit;
    ButtonCopy: TBitBtn;
    ButtonPaste: TBitBtn;
    MemoTemp: TMemo;
    LabelNadpis1: TLabel;
    LabelNadpis3: TLabel;
    LabelNadpis4: TLabel;
    LabelNadpis5: TLabel;
    LabelNadpis2: TLabel;
    LabelNadpis6: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure ButtonCancelClick(Sender: TObject);
    procedure ButtonYesClick(Sender: TObject);
    procedure AddSum(var Suma: Longint; Txt: string);
    procedure LabelCrackMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure LoadResTxt;
    function GetKod: Integer;
    procedure EditJmenoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditFirmaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditMestoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditStatKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditRegistrKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditSerialKeyPress(Sender: TObject; var Key: Char);
    procedure EditRegistrKeyPress(Sender: TObject; var Key: Char);
    procedure EditSerialKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ButtonCopyClick(Sender: TObject);
    procedure ButtonPasteClick(Sender: TObject);
    procedure Uschova;
    procedure EditRegistrChange(Sender: TObject);
    procedure EditJmenoChange(Sender: TObject);
    procedure ButtonYesOdregistrClick(Sender: TObject);
  private
    HlasNadpis: array [0..256] of Char;
    HlasText: array [0..256] of Char;
    CrackMode: Boolean;
    SerialText: string;
{    JeRegNadpis: string;
    NeniRegNadpis: string;}
    NezaregTxt: string;

    ButRegTxt: string;
    ButRegHint: string;
    ButOdregTxt: string;
    ButOdregHint: string;
  public
    { Public declarations }
  end;

var
  RegForm: TRegForm;

implementation

uses Main;
{$R *.DFM}

procedure TRegForm.FormCreate(Sender: TObject);
begin
  LoadResTxt;

  ButtonYes.GLyph.Palette := MainForm.InitPal;
  ButtonCancel.GLyph.Palette := MainForm.InitPal;
end;

procedure TRegForm.LoadResTxt;
begin
  Caption := LoadResString(IDS_CAPTION+14);
{  NeniRegNadpis := LoadResString(IDS_REGISTR+0);}
  LabelNadpis.Caption := LoadResString(IDS_REGISTR+1);

  LabelJmeno.Caption := LoadResString(IDS_REGISTR+2);
  EditJmeno.Hint := LoadResString(IDS_REGISTR+3);

  LabelFirma.Caption := LoadResString(IDS_REGISTR+4);
  EditFirma.Hint := LoadResString(IDS_REGISTR+5);

  LabelMesto.Caption := LoadResString(IDS_REGISTR+6);
  EditMesto.Hint := LoadResString(IDS_REGISTR+7);

  LabelStat.Caption := LoadResString(IDS_REGISTR+8);
  EditStat.Hint := LoadResString(IDS_REGISTR+9);

  LabelRegistr.Caption := LoadResString(IDS_REGISTR+10);
  EditRegistr.Hint := LoadResString(IDS_REGISTR+11);

  LabelSerial.Caption := LoadResString(IDS_REGISTR+12);
  NezaregTxt := LoadResString(IDS_REGISTR+13);

  ButRegTxt := LoadResString(IDS_REGISTR+14);
  ButRegHint := LoadResString(IDS_REGISTR+15);
  ButOdregTxt := LoadResString(IDS_REGISTR+24);
  ButOdregHint := LoadResString(IDS_REGISTR+25);

  ButtonCopy.Caption := LoadResString(IDS_REGISTR+16);
  ButtonCopy.Hint := LoadResString(IDS_REGISTR+17);

  ButtonPaste.Caption := LoadResString(IDS_REGISTR+18);
  ButtonPaste.Hint := LoadResString(IDS_REGISTR+19);

  ButtonCancel.Caption := LoadResString(IDS_REGISTR+20);
  ButtonCancel.Hint := LoadResString(IDS_REGISTR+21);

  StrPCopy(HlasNadpis,LoadResString(IDS_REGISTR+22));
  StrPCopy(HlasText,LoadResString(IDS_REGISTR+23));

  LabelNadpis1.Caption := LoadResString(IDS_REGISTR+28);
  LabelNadpis2.Caption := LoadResString(IDS_REGISTR+29);
  LabelNadpis3.Caption := LoadResString(IDS_REGISTR+30);
  LabelNadpis4.Caption := LoadResString(IDS_REGISTR+31);
  LabelNadpis5.Caption := LoadResString(IDS_REGISTR+32);
  LabelNadpis6.Caption := LoadResString(IDS_REGISTR+33);
end;

procedure TRegForm.FormShow(Sender: TObject);
begin
  Left := MainForm.Left + (MainForm.Width - Width) div 2;
  Top := MainForm.Top + (MainForm.Height - Height) div 2;

  ActiveControl := ButtonCancel;
  CrackMode := False;
  EditSerial.Color := clBtnFace;
  EditSerial.TabStop := False;

  EditJmeno.ReadOnly := False;
  EditFirma.ReadOnly := False;
  EditMesto.ReadOnly := False;
  EditStat.ReadOnly := False;
  EditRegistr.ReadOnly := False;

  EditJmeno.Text := MainForm.MemoReg.Lines.Strings[2];
  EditFirma.Text := MainForm.MemoReg.Lines.Strings[3];
  EditMesto.Text := MainForm.MemoReg.Lines.Strings[4];
  EditStat.Text := MainForm.MemoReg.Lines.Strings[5];
  EditRegistr.Text := '';

  if DemoMode then
  begin
{    LabelNadpis.Caption := NeniRegNadpis;}
    LabelSerial2.Caption := NezaregTxt;
    EditSerial.Text := '';
    ButtonYes.Caption := ButRegTxt;
    ButtonYes.Hint := ButRegHint;
    ButtonPaste.Enabled := True;

    LabelNadpis.Visible := False;
    LabelNadpis1.Visible := True;
    LabelNadpis2.Visible := True;
    LabelNadpis3.Visible := True;
    LabelNadpis4.Visible := True;
    LabelNadpis5.Visible := True;
    LabelNadpis6.Visible := True;

    LabelSerial.Visible := False;
    LabelSerial2.Visible := False;
    EditSerial.Visible := False;
    LabelRegistr.Visible := True;
    EditRegistr.Visible := True;
  end
  else
  begin
{    LabelNadpis.Caption := JeRegNadpis;}
    LabelSerial2.Caption := SerialPrefix;
    EditSerial.Text := MainForm.MemoReg.Lines.Strings[1];

    EditJmeno.ReadOnly := True;
    EditFirma.ReadOnly := True;
    EditMesto.ReadOnly := True;
    EditStat.ReadOnly := True;
    EditRegistr.ReadOnly := True;

    ButtonYes.Caption := ButOdregTxt;
    ButtonYes.Hint := ButOdregHint;
    ButtonPaste.Enabled := False;

    LabelNadpis.Visible := True;
    LabelNadpis1.Visible := False;
    LabelNadpis2.Visible := False;
    LabelNadpis3.Visible := False;
    LabelNadpis4.Visible := False;
    LabelNadpis5.Visible := False;
    LabelNadpis6.Visible := False;

    LabelSerial.Visible := True;
    LabelSerial2.Visible := True;
    EditSerial.Visible := True;
    LabelRegistr.Visible := False;
    EditRegistr.Visible := False;
  end;

  EditSerial.Left := LabelSerial2.Left + LabelSerial2.Width;

  EditJmenoChange(Sender);
  EditRegistrChange(Sender);
end;

procedure TRegForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  Case Key of
    #27: begin
           Key := #0;
           Close;
         end;
  end;
end;

procedure TRegForm.ButtonCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TRegForm.LabelCrackMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
{var I,J,K: Integer;
    Sum: Longint;}
begin
{  if SGPMode then
  begin
    if CrackMode then
    begin
      while Length(EditSerial.Text) < 6 do
        EditSerial.Text := '0' + EditSerial.Text;

      Sum := RegInit;
      AddSum(Sum,EditSerial.Text);
      AddSum(Sum,EditJmeno.Text);
      AddSum(Sum,EditFirma.Text);
      AddSum(Sum,EditMesto.Text);
      AddSum(Sum,EditStat.Text);

      SerialText := IntToStr(Sum);
      while Length(SerialText) < 6 do
        SerialText := '0' + SerialText;

      SerialText := SerialText + EditSerial.Text;

      EditRegistr.Text := '';

      for I := 0 to (12 div 3 - 1) do
      begin
        J := 100*(Ord(SerialText[I*3+1]) - Ord('0')) +
             10*(Ord(SerialText[I*3+2]) - Ord('0')) +
               (Ord(SerialText[I*3+3]) - Ord('0')) + 231;

        K := (J div 36) + Ord('0');
        if K > Ord('9') then
          K := K + Ord('A') - (Ord('9')+1);

        J := (J mod 36) + Ord('0');
        if J > Ord('9') then
          J := J + Ord('A') - (Ord('9')+1);

        EditRegistr.Text := EditRegistr.Text + Chr(K) + Chr(J);
      end;
    end
    else
    begin
      CrackMode := True;
      EditSerial.Color := clWindow;
      EditSerial.TabStop := True;
      ActiveControl := EditSerial;
    end;
  end; }
end;

procedure TRegForm.ButtonYesClick(Sender: TObject);
var I,J,K: Integer;
    Sum: Longint;
    Chyba: Boolean;
begin
  if not DemoMode then
  begin
    ButtonYesOdregistrClick(Sender);
    Exit;
  end;

  Chyba := False;

  if Length(EditRegistr.Text) <> 8 then Chyba := True;

  SerialText := '';
  if not Chyba then
    for I := 0 to (8 div 2 - 1) do
    begin
      J := Ord(EditRegistr.Text[I*2+1]);
      if J > Ord('9') then J := J - Ord('A') + Ord('9') + 1;

      K := Ord(EditRegistr.Text[I*2+2]);
      if K > Ord('9') then K := K - Ord('A') + Ord('9') + 1;

      J := (J - Ord('0')) * 36 + (K - Ord('0')) - 231;
      K := J mod 100;

      if J > 999 then
        Chyba := True
      else
        SerialText := SerialText + Chr(J div 100 + Ord('0'))
           + Chr(K div 10 + Ord('0')) + Chr(K mod 10 + Ord('0'));
    end;

  if not Chyba then
  begin
    Sum := RegInit;
    AddSum(Sum,Copy(SerialText,7,6));
    AddSum(Sum,EditJmeno.Text);
    AddSum(Sum,EditFirma.Text);
    AddSum(Sum,EditMesto.Text);
    AddSum(Sum,EditStat.Text);

    if Sum <> StrToIntDef(Copy(SerialText,1,6),-1) then
      Chyba := True;
  end;

  if not Chyba then
    with MainForm.MemoReg.Lines do
    begin
      Clear;
      Add(IntToStr(Sum+GetKod));
      Add(Copy(SerialText,7,6));
      Add(EditJmeno.Text);
      Add(EditFirma.Text);
      Add(EditMesto.Text);
      Add(EditStat.Text);
      try
        SaveToFile(WindowsDir + DefName + '.REG');
      except end;
      MainForm.SetDemoMode(False);
      MainForm.CaptionInit;
      Close;
    end
  else
    MessageBox(RegForm.Handle,HlasText,HlasNadpis,
            MB_OK + MB_ICONEXCLAMATION);
end;

procedure TRegForm.AddSum(var Suma: Longint; Txt: string);
var I,J,N: Integer;
begin
  Txt := AnsiUpperCase(Txt);
  N := Length(Txt);
  if N > 0 then
    for I := 1 to N do
    begin
      J := Ord(Txt[I]);
      if (J >= Ord('0')) and (J <= Ord('9')) or
         (J >= Ord('A')) and (J <= Ord('Z')) then
        Suma := (Suma + Longint(J) + 235 * (Suma mod 3535)) mod 926237;
    end;
end;

function TRegForm.GetKod: Integer;
var Txt: array[0..1024] of Char;
    I: Integer;
    Src: TSearchRec;
begin
{ Datum a èas systémového adresáøe WINDOWS }
  I := GetSystemDirectory(Txt,SizeOf(Txt));
  if I > 0 then
  begin
    I := FindFirst(StrPas(Txt),faReadOnly+faHidden+faSysFile
          +faDirectory+faArchive,Src);
    Result := Src.Time div 132000;
    if I = 0 then Exit;
  end;

{ Velikost disku }
  Result := DiskSize(Ord(HomeDir[1])-Ord('A')+1) div 132000;
  if Result > 0 then Exit;

{ v havarijním pøípadì pojistka }
  Result := 12345;
end;

procedure TRegForm.EditJmenoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Case Key of
    VK_DOWN, VK_RETURN: begin
                          ActiveControl := EditFirma;
                          Key := 0;
                        end;
    VK_UP: begin
             ActiveControl := ButtonCancel;
             Key := 0;
           end;
  end;
end;

procedure TRegForm.EditFirmaKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Case Key of
    VK_DOWN, VK_RETURN: begin
                          ActiveControl := EditMesto;
                          Key := 0;
                        end;
    VK_UP: begin
             ActiveControl := EditJmeno;
             Key := 0;
           end;
  end;
end;

procedure TRegForm.EditMestoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Case Key of
    VK_DOWN, VK_RETURN: begin
                          ActiveControl := EditStat;
                          Key := 0;
                        end;
    VK_UP: begin
             ActiveControl := EditFirma;
             Key := 0;
           end;
  end;
end;

procedure TRegForm.EditStatKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Case Key of
    VK_DOWN, VK_RETURN: begin
                          if EditRegistr.Visible and
                             EditRegistr.Enabled then
                            ActiveControl := EditRegistr
                          else
                            if ButtonYes.Enabled then
                              ActiveControl := ButtonYes
                            else
                              ActiveControl := ButtonCopy;
                          Key := 0;
                        end;
    VK_UP: begin
             ActiveControl := EditMesto;
             Key := 0;
           end;
  end;
end;

procedure TRegForm.EditRegistrKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Case Key of
    VK_DOWN, VK_RETURN: begin
{                          if CrackMode then
                            ActiveControl := EditSerial
                          else }
                            if ButtonYes.Enabled then
                              ActiveControl := ButtonYes
                            else
                              ActiveControl := ButtonCopy;
                          Key := 0;
                        end;
    VK_UP: begin
             ActiveControl := EditStat;
             Key := 0;
           end;
  end;
end;

procedure TRegForm.EditRegistrKeyPress(Sender: TObject; var Key: Char);
{var K: Integer;}
begin
  Case Key of
       'a'..'z': Key := Chr(Ord(Key)-$20);
       'A'..'Z': ;
       '0'..'9': ;
       #0..#31: ;
       else Key := #0;
  end;
end;

procedure TRegForm.EditSerialKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Case Key of
    VK_DOWN, VK_RETURN: begin
                          ActiveControl := ButtonYes;
                          Key := 0;
                        end;
    VK_UP: begin
             ActiveControl := EditStat;
             Key := 0;
           end;
    VK_DELETE, VK_BACK: if not CrackMode then Key := 0;
  end;
end;

procedure TRegForm.EditSerialKeyPress(Sender: TObject; var Key: Char);
var K: Integer;
begin
  K := Ord(Key);
  if ((K > 32) or (K = 8)) and not CrackMode then Key := #0;
  if (K > 32) and (K < Ord('0')) or (K > Ord('9')) then Key := #0;
end;

procedure TRegForm.ButtonCopyClick(Sender: TObject);
begin
  with MemoTemp.Lines do
  begin
    Clear;
    Add(EditJmeno.Text);
    Add(EditFirma.Text);
    Add(EditMesto.Text);
    Add(EditStat.Text);
    if Length(EditRegistr.Text) > 0 then
      Add(EditRegistr.Text);
  end;
  MemoTemp.SelectAll;
  MemoTemp.CopyToClipboard;
  Uschova;
end;

procedure TRegForm.ButtonPasteClick(Sender: TObject);
var Txt: string;
    I: Integer;
begin
  with MemoTemp.Lines do
  begin
    Clear;
    MemoTemp.PasteFromClipboard;

    if MemoTemp.Lines.Count = 2 then
      if MemoTemp.Lines.Strings[1] = '' then
        MemoTemp.Lines.Delete(1);

    if MemoTemp.Lines.Count = 1 then
      Txt := AnsiUpperCase(Strings[0])
    else
    begin
      EditJmeno.Text := MemoTemp.Lines.Strings[0];
      EditFirma.Text := MemoTemp.Lines.Strings[1];
      EditMesto.Text := Strings[2];
      EditStat.Text := Strings[3];
      Txt := AnsiUpperCase(Strings[4]);
    end;

    if Length(Txt) > 0 then
    begin
      EditRegistr.Text := '';
      for I := 1 to Length(Txt) do
      if (Ord(Txt[I]) >= Ord('0')) and
         (Ord(Txt[I]) <= Ord('9')) or
         (Ord(Txt[I]) >= Ord('A')) and
         (Ord(Txt[I]) <= Ord('Z')) then
        EditRegistr.Text := EditRegistr.Text + Txt[I];
    end;
  end;
  EditJmenoChange(Sender);
  EditRegistrChange(Sender);
end;

procedure TRegForm.Uschova;
begin
  if DemoMode then
    with MainForm.MemoReg.Lines do
    begin
      Clear;
      Add('0');
      Add('0');
      Add(EditJmeno.Text);
      Add(EditFirma.Text);
      Add(EditMesto.Text);
      Add(EditStat.Text);
      try
        SaveToFile(WindowsDir + DefName + '.REG');
      except end;
    end
end;

procedure TRegForm.EditRegistrChange(Sender: TObject);
begin
  if (Length(EditRegistr.Text) > 0) or not DemoMode then
    ButtonYes.Enabled := True
  else
    ButtonYes.Enabled := False;
end;

procedure TRegForm.EditJmenoChange(Sender: TObject);
begin
  if (Length(EditJmeno.Text) > 0) and
     (Length(EditMesto.Text) > 0) and
     DemoMode then
    if not EditRegistr.Enabled then
    begin
      EditRegistr.Enabled := True;
      EditRegistr.Color := clWindow;
    end
    else
  else
    if EditRegistr.Enabled then
    begin
      EditRegistr.Enabled := False;
      EditRegistr.Color := clBtnFace;
    end;
end;

procedure TRegForm.ButtonYesOdregistrClick(Sender: TObject);
var I: Integer;
begin
  I := MessageBox(RegForm.Handle,TextOdreg2,TextOdreg1,
            MB_YESNO + MB_ICONEXCLAMATION + MB_APPLMODAL);
  if I = IDYES then
  begin
    MainForm.MemoReg.Lines.Clear;
    try
      SysUtils.DeleteFile(WindowsDir + DefName + '.REG');
    except end;
    MainForm.SetDemoMode(True);
    MainForm.CaptionInit;
    Close;
  end;
end;

end.

