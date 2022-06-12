uses
  Graph;
var
  GraphDriver, GraphMode : integer;

begin
  DetectGraph(GraphDriver, GraphMode);
  if (GraphDriver = EGA) or
     (GraphDriver = EGA64) then
  begin
    GraphDriver := CGA;
    GraphMode := CGAHi;
  end;
  InitGraph(GraphDriver,GraphMode,'');
  if GraphResult <> grOk then
    Halt(1);
  Line(0, 0, GetMaxX, GetMaxY);
  Readln;
  CloseGraph;
end.
