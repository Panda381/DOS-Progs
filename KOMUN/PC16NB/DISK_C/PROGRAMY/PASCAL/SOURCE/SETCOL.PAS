uses
  Crt, Graph;
var
  GraphDriver, GraphMode : integer;
begin
  GraphDriver := Detect;
  InitGraph(GraphDriver, GraphMode, '');
  if GraphResult <> grOk then
    Halt(1);
  Randomize;
  repeat
    SetColor(Random(GetMaxColor)+1);
    LineTo(Random(GetMaxX), Random(GetMaxY));
  until KeyPressed;
end.