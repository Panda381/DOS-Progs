uses
  Graph;
var
  Gd, Gm : integer;

begin
  Gd := Detect;
  InitGraph(Gd, Gm, '');
  if GraphResult <> grOk then
    Halt(1);
  MoveTo(0,0); { Upper-left corner of viewport }
  LineTo(GetMaxX, GetMaxY);
  Readln;
  CloseGraph;
end.