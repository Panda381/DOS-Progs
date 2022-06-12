uses
  Graph;
var
  Gd, Gm : integer;

begin
  Gd := Detect;
  InitGraph(Gd, Gm, '');
  if GraphResult <> grOk then
    Halt(1);
  MoveTo(1,2);
  LineRel(100, 100);  { Draw to the point (101,102) }
  Readln;
  CloseGraph;
end.