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
    Panel2: TPanel;
    Label2: TLabel;
    ProductName2: TLabel;
    Label4: TLabel;
    Comment1: TLabel;
    Comment2: TLabel;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel1Click(Sender: TObject);
    procedure CopyrightMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure LoadResTxt;
  private
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

procedure TAboutBox.CopyrightMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Height := Height xor (378 xor 307);
end;

procedure TAboutBox.FormShow(Sender: TObject);
begin
  Height := 307;
end;

procedure TAboutBox.FormKeyPress(Sender: TObject; var Key: Char);
begin
  Key := #0;
  Close;
end;

procedure TAboutBox.FormCreate(Sender: TObject);
begin
  LoadResTxt;
{$IFDEF WIN32}
{  Version.Caption := 'verze '+Verze+' pro Windows 95 a NT';}
{$ELSE}
{  Version.Caption := 'verze '+Verze+' pro Windows';}
{$ENDIF}
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
  Comment1.Caption := LoadResString(IDS_ABOUT+5);
  Comment2.Caption := LoadResString(IDS_ABOUT+6);
end;


end.

