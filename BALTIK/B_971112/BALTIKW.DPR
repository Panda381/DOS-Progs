program Baltikw;

uses
  Forms,
  Main in 'MAIN.PAS' {MainForm},
  Select in 'SELECT.PAS' {SelForm},
  Ikona in 'IKONA.PAS' {IkonForm},
  Exec in 'EXEC.PAS' {ExecForm},
  About in 'ABOUT.PAS' {AboutBox},
  About0 in 'ABOUT0.PAS' {About0Box},
  Edit in 'EDIT.PAS' {EditForm},
  Org in 'ORG.PAS' {OrgForm},
  Yes in 'YES.PAS' {YesForm},
  Help in 'HELP.PAS' {HelpForm};

{$R *.RES}

{$IFDEF WIN32}
  {$R BALTIK32.RES}
{$ELSE}
  {$R BALTIK16.RES}
{$ENDIF}

begin
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSelForm, SelForm);
  Application.CreateForm(TIkonForm, IkonForm);
  Application.CreateForm(TExecForm, ExecForm);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TAbout0Box, About0Box);
  Application.CreateForm(TEditForm, EditForm);
  Application.CreateForm(TOrgForm, OrgForm);
  Application.CreateForm(TYesForm, YesForm);
  Application.CreateForm(THelpForm, HelpForm);
  Application.Run;
end.
