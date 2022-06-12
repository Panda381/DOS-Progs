uses
  Graph;
var
  Gd, Gm : integer;

begin
  Gd := Detect;
  InitGraph(Gd, Gm, '');
  if GraphResult <> grOk then
    Halt(1);
  Rectangle(0,0,GetMaxX,GetMaxY); { Draw a full-screen box }
  Readln;
  CloseGraph;
end.