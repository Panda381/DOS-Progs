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
    Circle(100, 100, Radius*10);
  Readln;
  CloseGraph;
end.