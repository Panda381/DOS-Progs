{ example for InstallUserDriver }
uses
  Graph;
var
  Driver, Mode,
  TestDriver,
  ErrCode  : Integer;

{$F+}
function TestDetect : Integer;
{ Autodetect function: assume hardware is always present;
  return value = recommended default mode }
begin
  TestDetect := 1;                       { default mode = 1 }
end;
{$F-}

begin
  { Install the driver }
  TestDriver := InstallUserDriver('TEST', @TestDetect);
  if GraphResult <> grOk then
  begin
    Writeln('Error installing TestDriver');
    Halt(1);
  end;
  Driver := Detect;                      { Put in graphics mode }
  InitGraph(Driver, Mode, '');
  ErrCode := GraphResult;
  if ErrCode <> grOk then
  begin
    Writeln('Error during Init: ', ErrCode);
    Halt(1);
  end;
  OutText('Installable drivers supported...');
  Readln;
  Closegraph;
end.
