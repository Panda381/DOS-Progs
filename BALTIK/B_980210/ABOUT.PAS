unit About;

interface

uses Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
  TAboutBox = class(TForm)
    Panel1: TPanel;
    ProgramIcon: TImage;
    ProductName: TLabel;
    Version: TLabel;
    Copyright: TLabel;
    Internet: TLabel;
    ProductName2: TLabel;
    Comment1: TLabel;
    Comment2: TLabel;
    Comment3: TLabel;
    Comment4: TLabel;
    LabelReg: TLabel;
    LabelRegJmeno: TLabel;
    LabelRegFirma: TLabel;
    LabelRegMesto: TLabel;
    LabelRegStat: TLabel;
    LabelRegSerial: TLabel;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure LoadResTxt;
  private
    TextReg: string;

    TextCom1Reg: string;
    TextCom2Reg: string;
    TextCom3Reg: string;
    TextCom4Reg: string;

    TextCom1NReg: string;
    TextCom2NReg: string;
    TextCom3NReg: string;
    TextCom4NReg: string;

    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

implementation

uses Main;

{$R *.DFM}

procedure TAboutBox.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Key := 0;
  Close;
end;

procedure TAboutBox.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Close;
end;

procedure TAboutBox.Panel1Click(Sender: TObject);
begin
  Close;
end;

procedure TAboutBox.FormShow(Sender: TObject);
begin
  Height := 337;

  Left := MainForm.Left + (MainForm.Width - Width) div 2;
  Top := MainForm.Top + (MainForm.Height - Height) div 2;

  if DemoMode then
  begin
    LabelReg.Caption := '';
    LabelRegJmeno.Caption := '';
    LabelRegFirma.Caption := '';
    LabelRegMesto.Caption := '';
    LabelRegStat.Caption := '';
    LabelRegSerial.Caption := '';

    LabelReg.Visible := False;
    LabelRegJmeno.Visible := False;
    LabelRegFirma.Visible := False;
    LabelRegMesto.Visible := False;
    LabelRegStat.Visible := False;
    LabelRegSerial.Visible := False;

    ProgramIcon.Center := True;

    Comment1.Caption := TextCom1NReg;
    Comment2.Caption := TextCom2NReg;
    Comment3.Caption := TextCom3NReg;
    Comment4.Caption := TextCom4NReg;
  end
  else
  begin
    ProgramIcon.Center := False;

    Comment1.Caption := TextCom1Reg;
    Comment2.Caption := TextCom2Reg;
    Comment3.Caption := TextCom3Reg;
    Comment4.Caption := TextCom4Reg;

    LabelReg.Visible := True;
    LabelRegJmeno.Visible := True;
    LabelRegFirma.Visible := True;
    LabelRegMesto.Visible := True;
    LabelRegStat.Visible := True;
    LabelRegSerial.Visible := True;

    LabelReg.Caption := TextReg;
    LabelRegJmeno.Caption := MainForm.MemoReg.Lines.Strings[2];
    LabelRegFirma.Caption := MainForm.MemoReg.Lines.Strings[3];
    LabelRegMesto.Caption := MainForm.MemoReg.Lines.Strings[4];
    LabelRegStat.Caption := MainForm.MemoReg.Lines.Strings[5];
    LabelRegSerial.Caption := SerialPrefix + MainForm.MemoReg.Lines.Strings[1];
  end;
end;

procedure TAboutBox.FormKeyPress(Sender: TObject; var Key: Char);
begin
  Key := #0;
  Close;
end;

procedure TAboutBox.FormCreate(Sender: TObject);
begin
  LoadResTxt;
end;

procedure TAboutBox.LoadResTxt;
begin
  Caption := LoadResString(IDS_CAPTION+9);            { O programu }
  ProductName.Caption := LoadResString(IDS_ABOUT+0);  { SGP Baltík }
  ProductName2.Caption := ProductName.Caption;
{$IFDEF WIN32}
  Version.Caption := LoadResString(IDS_ABOUT+2);
{$ELSE}
  Version.Caption := LoadResString(IDS_ABOUT+1);
{$ENDIF}
  Copyright.Caption := LoadResString(IDS_ABOUT+3);
  Internet.Caption := LoadResString(IDS_ABOUT+4);

  TextReg := LoadResString(IDS_ABOUT+5);

  TextCom1NReg := LoadResString(IDS_ABOUT+6);
  TextCom2NReg := LoadResString(IDS_ABOUT+7);
  TextCom3NReg := LoadResString(IDS_ABOUT+8);
  TextCom4NReg := LoadResString(IDS_ABOUT+9);

  TextCom1Reg := LoadResString(IDS_ABOUT+10);
  TextCom2Reg := LoadResString(IDS_ABOUT+11);
  TextCom3Reg := LoadResString(IDS_ABOUT+12);
  TextCom4Reg := LoadResString(IDS_ABOUT+13);
end;


end.

