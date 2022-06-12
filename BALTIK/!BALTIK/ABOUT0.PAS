unit About0;

interface

uses Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
  TAbout0Box = class(TForm)
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
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel1Click(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure LoadResTxt;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  About0Box: TAbout0Box;

implementation

uses Main;

{$R *.DFM}

procedure TAbout0Box.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Key := 0;
  Close;
end;

procedure TAbout0Box.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Close;
end;

procedure TAbout0Box.Panel1Click(Sender: TObject);
begin
  Close;
end;

procedure TAbout0Box.FormKeyPress(Sender: TObject; var Key: Char);
begin
  Key := #0;
  Close;
end;

procedure TAbout0Box.FormCreate(Sender: TObject);
begin
  LoadResTxt;
end;

procedure TAbout0Box.LoadResTxt;
begin
  Caption := LoadResString(IDS_CAPTION+8);            { SGP Baltík }
  ProductName.Caption := LoadResString(IDS_ABOUT+0);  { SGP Baltík }
  ProductName2.Caption := ProductName.Caption;
{$IFDEF WIN32}
  Version.Caption := LoadResString(IDS_ABOUT+2);
{$ELSE}
  Version.Caption := LoadResString(IDS_ABOUT+1);
{$ENDIF}
  Copyright.Caption := LoadResString(IDS_ABOUT+3);
  Internet.Caption := LoadResString(IDS_ABOUT+4);
  Comment1.Caption := LoadResString(IDS_ABOUT+6);
  Comment2.Caption := LoadResString(IDS_ABOUT+7);
  Comment3.Caption := LoadResString(IDS_ABOUT+8);
  Comment4.Caption := LoadResString(IDS_ABOUT+9);
end;

procedure TAbout0Box.FormShow(Sender: TObject);
begin
  Left := MainForm.Left + (MainForm.Width - Width) div 2;
  Top := MainForm.Top + (MainForm.Height - Height) div 2;
end;

end.

