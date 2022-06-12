uses
  Graph;
var
  Gd, Gm : integer;
  ArcCoords : ArcCoordsType;
begin
  Gd := Detect;
  InitGraph(Gd, Gm, '');
  if GraphResult <> grOk then
    Halt(1);
  Arc(100,100,0,270,30);
  GetArcCoords(ArcCoords);
  with ArcCoords do
    Line(Xstart, Ystart, Xend, Yend);
  Readln;
  CloseGraph;
end.
