uses
  Graph;

const
  Triangle : array[1..3] of PointType =
   ((x:  50; y: 100),
    (x: 100; y: 100),
    (x: 150; y: 150));

var
  Gd, Gm : integer;

begin
  Gd := Detect;
  InitGraph(Gd, Gm, '');
  if GraphResult <> grOk then
    Halt(1);
  FillPoly(SizeOf(Triangle) div SizeOf(PointType), { 3 }
           Triangle);
  Readln;
  CloseGraph;
end.

