uses
  Graph;
var
  Gd, Gm : integer;

begin
  Gd := Detect;
  InitGraph(Gd, Gm, '');
  if GraphResult <> grOk then
    Halt(1);
  Rectangle(19, 19, GetMaxX-19, GetMaxY-19);
  SetViewPort(20, 20, GetMaxX-20, GetMaxY-20, ClipOn);
  OutTextXY(0, 0, '<RETURN> clears viewport:');
  Readln;
  ClearViewPort;
  OutTextXY(0, 0, '<RETURN> to quit:');
  Readln;
  CloseGraph;
end.