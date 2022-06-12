uses
  Graph;
var
  GraphDriver : integer;
  GraphMode   : integer;
  LowMode     : integer;
  HighMode    : integer;

begin
  GraphDriver := Detect;
  InitGraph(GraphDriver, GraphMode, '');
  if GraphResult <> grOk then
    Halt(1);
  GetModeRange(GraphDriver, LowMode, HighMode);
  SetGraphMode(LowMode);    { Select low-res mode }
  Line(0, 0, GetMaxX, GetMaxY);
  Readln;
  CloseGraph;
end.
