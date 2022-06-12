program BaltReg;

uses
  Forms,
  Registr in 'REGISTR.PAS' {RegForm};

{$R *.RES}

begin
  Application.CreateForm(TRegForm, RegForm);
  Application.Run;
end.
