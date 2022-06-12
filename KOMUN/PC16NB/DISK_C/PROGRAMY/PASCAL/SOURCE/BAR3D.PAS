uses
  Graph;
var
  Gd, Gm : integer;
  y0, y1, y2, x1, x2 : integer;
begin
  Gd := Detect;
  InitGraph(Gd, Gm, '');
  if GraphResult <> grOk then
    Halt(1);
  y0 := 10;
  y1 := 60;
  y2 := 110;
  x1 := 10;
  x2 := 50;
  Bar3D(x1, y0, x2, y1, 10, TopOn);
  Bar3D(x1, y1, x2, y2, 10, TopOff);
  Readln;
  CloseGraph;
end.