uses
  Crt, Graph;
var
  GraphDriver, GraphMode : integer;
  x1, y1, x2, y2 : integer;
begin
  GraphDriver := Detect;
  InitGraph(GraphDriver,GraphMode,'');
  if GraphResult<> grOk then
    Halt(1);
  Randomize;
  repeat
    x1 := Random(GetMaxX);
    y1 := Random(GetMaxY);
    x2 := Random(GetMaxX - x1) + x1;
    y2 := Random(GetMaxY - y1) + y1;
    Rectangle(x1, y1, x2, y2);
  until KeyPressed;
  CloseGraph;
end.