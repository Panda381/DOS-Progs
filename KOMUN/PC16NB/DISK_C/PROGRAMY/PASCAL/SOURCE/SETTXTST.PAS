uses
  Graph;
var
  Gd, Gm : integer;
  Y, Size : integer;
begin
  Gd := Detect;
  InitGraph(Gd, Gm, '');
  if GraphResult <> grOk then
    Halt(1);
  Y := 0;
  for Size := 1 to 4 do
  begin
    SetTextStyle(DefaultFont, HorizDir, Size);
    OutTextXY(0, Y, 'Size = ' + Chr(Size+48));
    Inc(Y, TextHeight('H') + 1);
  end;
  Readln;
  CloseGraph;
end.
