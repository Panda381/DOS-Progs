unit Main;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, TabNotBk, Menus, Tabs, StdCtrls, Buttons, Grids,
  Spin;

type
  TMainForm = class(TForm)
    Tabbed: TTabbedNotebook;
    PanelSpeed: TPanel;
    PanelStatus: TPanel;
    GridRoom: TDrawGrid;
    GridObject: TDrawGrid;
    GridPicture: TDrawGrid;
    GridProgram: TDrawGrid;
    ListProgram: TListBox;
    ListObject: TListBox;
    ListRoom: TListBox;
    ListPicture: TListBox;
    SpeedButton1: TSpeedButton;
    SpeedButton3: TSpeedButton;
    MainMenu: TMainMenu;
    PopupMenu: TPopupMenu;
    Soubor1: TMenuItem;
    Otevt1: TMenuItem;
    Uloit1: TMenuItem;
    Nov1: TMenuItem;
    N1: TMenuItem;
    Konec1: TMenuItem;
    Npovda1: TMenuItem;
    Tmata1: TMenuItem;
    Oprogramu1: TMenuItem;
    SpeedButton2: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    BitBtn1: TBitBtn;
    SpeedButton8: TSpeedButton;
    SpeedButton9: TSpeedButton;
    Panel1: TPanel;
    DrawGrid1: TDrawGrid;
    SpeedButton10: TSpeedButton;
    SpeedButton11: TSpeedButton;
    SpeedButton12: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure TabbedClick(Sender: TObject);
    procedure ShowHint(Sender: TObject);
    procedure SpeedButton8Click(Sender: TObject);
    procedure Konec1Click(Sender: TObject);
  private
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

  HomeDir: String;

implementation

{$R *.DFM}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  HomeDir := ExtractFilePath(ParamStr(0));
  Application.HelpFile := HomeDir + 'Peter.hlp';
  Application.OnHint := ShowHint;
  Application.Title := 'Petøík';

  Width := 640;
  Height := 450;
  Left := (Screen.Width - Width) div 2;
  Top := (Screen.Height - Height - 20) div 2;

  ListProgram.Clear;
  ListProgram.Items.Add(' - prázdný -');
  ListProgram.Items.Add('Petøík');
  ListProgram.Items.Add('Petøík 2');
  ListProgram.Items.Add('Pokus 1');
  ListProgram.Items.Add('Pokus 2');
  ListProgram.Items.Add('Pokus 3');
  ListProgram.Items.Add('Pokus 4');
  ListProgram.Items.Add('Pokus 5');
  ListProgram.Items.Add('Pokus 6');
  ListProgram.Items.Add('Pokus 7');
  ListProgram.Items.Add('Pokus 8');
  ListProgram.Items.Add('Pokus 9');
  ListProgram.Items.Add('Pokus 10');
  ListProgram.Items.Add('Pokus 11');
  ListProgram.Items.Add('Pokus 12');
  ListProgram.Items.Add('Pokus 13');
  ListProgram.Items.Add('Pokus 14');
  ListProgram.Items.Add('Pokus 15');
  ListProgram.Items.Add('Pokus 16');
  ListProgram.Items.Add('Pokus 17');
  ListProgram.Items.Add('Pokus 18');
  ListProgram.Items.Add('Pokus 19');
  ListProgram.Items.Add('Pokus 20');
  ListProgram.Items.Add('Pokus 21');
  ListProgram.Items.Add('Pokus 22');

  ListProgram.ItemIndex := 0;
  ListObject.Clear;
  ListObject.Items.Add(' - start -');
  ListObject.Items.Add('Jdi ke zdi');
  ListObject.Items.Add('Opatrný krok');
  ListObject.ItemIndex := 0;
  ListRoom.Clear;
  ListRoom.Items.Add(' - úvodní -');
  ListRoom.Items.Add('Bludištì');
  ListRoom.Items.Add('Bludištì 2');
  ListRoom.ItemIndex := 0;
  ListPicture.Clear;
  ListPicture.Items.Add(' - základní -');
  ListPicture.Items.Add('Pøíkazy');
  ListPicture.Items.Add('Doplòkové');
  ListPicture.ItemIndex := 0;

  Tabbed.PageIndex := 0;
  TabbedClick(Sender);
end;

procedure TMainForm.ShowHint(Sender: TObject);
begin
  PanelStatus.Caption := Application.Hint;
end;

procedure TMainForm.TabbedClick(Sender: TObject);
begin
  Case Tabbed.PageIndex of
    0: ActiveControl := GridProgram;
    1: ActiveControl := GridObject;
    2: ActiveControl := GridRoom;
    3: ActiveControl := GridPicture;
  end;
end;

procedure TMainForm.SpeedButton8Click(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.Konec1Click(Sender: TObject);
begin
  Close;
end;

end.
