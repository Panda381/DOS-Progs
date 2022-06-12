uses
  Graph;
var
  Gd, Gm : integer;

begin
  Gd := Detect;
  InitGraph(Gd, Gm, '');
  if GraphResult <> grOk then
    Halt(1);
  Ellipse(100,100,0,360,30,50);
  Ellipse(100,100,0,180,50,30);
  Readln;
  CloseGraph;
end.