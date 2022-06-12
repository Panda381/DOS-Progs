uses
  Graph;
var
  Gd, Gm  : integer;
  Y, Size : integer;
begin
  Gd := Detect;
  InitGraph(Gd, Gm, '');
  if GraphResult <> grOk then
    Halt(1);
  Y := 0;
  for Size := 1 to 5 do
  begin
    SetTextStyle(DefaultFont, HorizDir, Size);
    OutTextXY(0, Y, 'Turbo Graphics');
    Inc(Y, TextHeight('Turbo Graphics'));
  end;
  Readln;
  CloseGraph;
end.
