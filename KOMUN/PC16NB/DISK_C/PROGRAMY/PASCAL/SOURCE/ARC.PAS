uses
  Graph;
var
  Gd, Gm : integer;
  Radius : integer;
begin
  Gd := Detect;
  InitGraph(Gd, Gm, '');
  if GraphResult <> grOk then
    Halt(1);
  for Radius := 1 to 5 do
    Arc(100, 100, 0, 90, Radius*10);
  Readln;
  CloseGraph;
end.