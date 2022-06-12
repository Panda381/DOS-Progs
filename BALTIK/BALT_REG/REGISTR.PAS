unit Registr;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, Spin;

const
  RegInit = 711432;                      { výchozí hodnota CRC }

type
  TRegForm = class(TForm)
    LabelNadpis: TLabel;
    ButtonYes: TBitBtn;
    ButtonCancel: TBitBtn;
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
    EditSerial: TEdit;
    ButtonCopy: TBitBtn;
    ButtonPaste: TBitBtn;
    MemoTemp: TMemo;
    MemoReg: TMemo;
    EditRegistr: TLabel;
    SpinButton1: TSpinButton;
    procedure FormShow(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure ButtonCancelClick(Sender: TObject);
    procedure AddSum(var Suma: Longint; Txt: string);
    procedure EditJmenoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditFirmaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditMestoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditStatKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditSerialKeyPress(Sender: TObject; var Key: Char);
    procedure EditSerialKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ButtonCopyClick(Sender: TObject);
    procedure ButtonPasteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ButtonYesClick(Sender: TObject);
    procedure EditJmenoKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditFirmaKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditMestoKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditStatKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditSerialMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure EditSerialExit(Sender: TObject);
    procedure SpinButton1UpClick(Sender: TObject);
    procedure SpinButton1DownClick(Sender: TObject);
    procedure EditJmenoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure EditFirmaMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure EditMestoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure EditStatMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    HlasNadpis: array [0..256] of Char;
    HlasText: array [0..256] of Char;
{    CrackMode: Boolean;}
    SerialText: string;
    JeRegNadpis: string;
    NeniRegNadpis: string;
    NezaregTxt: string;
  public
    { Public declarations }
  end;

var
  RegForm: TRegForm;

implementation

{$R *.DFM}

procedure TRegForm.FormCreate(Sender: TObject);
var I: Integer;
begin
  MemoReg.Lines.Clear;
  try
    if FileExists('BALTIK.REG') then
      MemoReg.Lines.LoadFromFile('BALTIK.REG');
  except MemoReg.Lines.Clear; end;
end;

procedure TRegForm.FormShow(Sender: TObject);
var I: Integer;
begin
  EditSerial.Text := MemoReg.Lines.Strings[1];
  EditJmeno.Text := MemoReg.Lines.Strings[2];
  EditFirma.Text := MemoReg.Lines.Strings[3];
  EditMesto.Text := MemoReg.Lines.Strings[4];
  EditStat.Text := MemoReg.Lines.Strings[5];
  ButtonYesClick(Sender);
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
                          ActiveControl := EditSerial;
                          Key := 0;
                        end;
    VK_UP: begin
             ActiveControl := EditMesto;
             Key := 0;
           end;
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
  end;
end;

procedure TRegForm.EditSerialKeyPress(Sender: TObject; var Key: Char);
var K: Integer;
begin
  K := Ord(Key);
  if (K > 32) and (K < Ord('0')) or (K > Ord('9')) then Key := #0;
end;

procedure TRegForm.ButtonCopyClick(Sender: TObject);
begin
  ButtonYesClick(Sender);
  with MemoTemp.Lines do
  begin
    Clear;
    Add(EditJmeno.Text);
    Add(EditFirma.Text);
    Add(EditMesto.Text);
    Add(EditStat.Text);
    Add(EditRegistr.Caption);
    Add(EditSerial.Text);
  end;
  MemoTemp.SelectAll;
  MemoTemp.CopyToClipboard;
end;

procedure TRegForm.ButtonPasteClick(Sender: TObject);
begin
  with MemoTemp.Lines do
  begin
    Clear;
    MemoTemp.PasteFromClipboard;
    EditJmeno.Text := MemoTemp.Lines.Strings[0];
    EditFirma.Text := MemoTemp.Lines.Strings[1];
    EditMesto.Text := Strings[2];
    EditStat.Text := Strings[3];
  end;
  ButtonYesClick(Sender);
end;

procedure TRegForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  with MemoReg.Lines do
  begin
    Clear;
    Add('0');
    Add(EditSerial.Text);
    Add(EditJmeno.Text);
    Add(EditFirma.Text);
    Add(EditMesto.Text);
    Add(EditStat.Text);
    try
      SaveToFile('BALTIK.REG');
    except end;
  end
end;

procedure TRegForm.ButtonYesClick(Sender: TObject);
var I,J,K: Integer;
    Sum: Longint;
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

  EditRegistr.Caption := '';

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

    EditRegistr.Caption := EditRegistr.Caption + Chr(K) + Chr(J);
  end;
end;

procedure TRegForm.EditJmenoKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  ButtonYesClick(Sender);
end;

procedure TRegForm.EditFirmaKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  ButtonYesClick(Sender);
end;

procedure TRegForm.EditMestoKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  ButtonYesClick(Sender);
end;

procedure TRegForm.EditStatKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  ButtonYesClick(Sender);
end;

procedure TRegForm.EditSerialMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  EditSerial.SelectAll;
end;

procedure TRegForm.EditSerialExit(Sender: TObject);
begin
  ButtonYesClick(Sender);
end;

procedure TRegForm.SpinButton1UpClick(Sender: TObject);
var N: Longint;
begin
  N := StrToIntDef(EditSerial.Text,-1);
  if N >= 0 then
    EditSerial.Text := IntToStr(N+1);
  ButtonYesClick(Sender);
  EditSerial.SelectAll;
end;

procedure TRegForm.SpinButton1DownClick(Sender: TObject);
var N: Longint;
begin
  N := StrToIntDef(EditSerial.Text,-1);
  if N > 0 then
    EditSerial.Text := IntToStr(N-1);
  ButtonYesClick(Sender);
  EditSerial.SelectAll;
end;

procedure TRegForm.EditJmenoMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  EditJmeno.SelectAll;
end;

procedure TRegForm.EditFirmaMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  EditFirma.SelectAll;
end;

procedure TRegForm.EditMestoMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  EditMesto.SelectAll;
end;

procedure TRegForm.EditStatMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  EditStat.SelectAll;
end;

end.

