unit Help;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

type
  THelpForm = class(TForm)
    MemoHelp: TMemo;
    procedure MemoHelpKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LoadResTxt;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  HelpForm: THelpForm;
  HelpFile: string;

implementation

uses Main;

{$R *.DFM}

procedure THelpForm.MemoHelpKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then
    begin
      Key := 0;
      Close;
    end;
end;

procedure THelpForm.FormShow(Sender: TObject);
begin
  Left := MainForm.Left + (MainForm.Width - Width) div 2;
  Top := MainForm.Top + (MainForm.Height - Height) div 2;

  MemoHelp.Lines.Clear;
  try
    MemoHelp.Lines.LoadFromFile(HomeDir+HelpFile);
  except end;
end;

procedure THelpForm.FormCreate(Sender: TObject);
begin
  LoadResTxt;
end;

procedure THelpForm.LoadResTxt;
begin
  HelpFile := LoadResString(IDS_CAPTION+0);
  Caption := HelpFile;
end;

end.
