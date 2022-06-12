unit Yes;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls;

type
  TYesForm = class(TForm)
    Text1Hlaseni: TLabel;
    ButtonYes: TBitBtn;
    ButtonNo: TBitBtn;
    ButtonCancel: TBitBtn;
    Text2Hlaseni: TLabel;
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
    procedure LoadResTxt;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function Hlaseni(Text1,Text2: string): Integer;

var
  YesForm: TYesForm;

implementation

uses Main;

{$R *.DFM}

function Hlaseni(Text1,Text2: string): Integer;
begin
  YesForm.Text1Hlaseni.Caption := Text1;
  YesForm.Text2Hlaseni.Caption := Text2;
  YesForm.ShowModal;
  Result := YesForm.ModalResult;
end;

procedure TYesForm.FormCreate(Sender: TObject);
begin
  LoadResTxt;

  ButtonYes.GLyph.Palette := MainForm.InitPal;
  ButtonNo.GLyph.Palette := MainForm.InitPal;
  ButtonCancel.GLyph.Palette := MainForm.InitPal;
end;

procedure TYesForm.LoadResTxt;
begin
  Caption := LoadResString(IDS_CAPTION+13);
  ButtonYes.Caption := LoadResString(IDS_HLAS+0);
  ButtonYes.Hint := LoadResString(IDS_HLAS+1);
  ButtonNo.Caption := LoadResString(IDS_HLAS+2);
  ButtonNo.Hint := LoadResString(IDS_HLAS+3);
  ButtonCancel.Caption := LoadResString(IDS_HLAS+4);
  ButtonCancel.Hint := LoadResString(IDS_HLAS+5);
end;

procedure TYesForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Key := 0;
    Close;
  end;
end;

procedure TYesForm.FormShow(Sender: TObject);
begin
  Left := MainForm.Left + (MainForm.Width - Width) div 2;
  Top := MainForm.Top + (MainForm.Height - Height) div 2;
  ActiveControl := ButtonYes;
end;

end.
