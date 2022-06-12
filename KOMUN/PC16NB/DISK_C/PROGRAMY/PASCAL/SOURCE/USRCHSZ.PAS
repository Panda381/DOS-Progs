{ Example for SetUserCharSize }

uses
  Graph;
var
  Driver, Mode : Integer;
begin
  Driver := Detect;
  InitGraph(Driver, Mode, '');
  if GraphResult <> grOk then
    Halt(1);
  { Showoff }
  SetTextStyle(TriplexFont, Horizdir, 4);
  OutText('Norm');
  SetUserCharSize(1, 3, 1, 2);
  OutText('Short');
  SetUserCharSize(3, 1, 1, 1);
  OutText('Wide');
  Readln;
  CloseGraph;
end.