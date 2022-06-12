uses
  Graph;
var
  grDriver : integer;
  grMode   : integer;
  ErrCode  : integer;
begin
  grDriver := Detect;
  InitGraph(grDriver,grMode,'');
  ErrCode := GraphResult;
  if ErrCode = grOk then
    begin
      { Do graphics }
      Line(0, 0, GetMaxX, GetMaxY);
      Readln;
      CloseGraph;
    end
  else
    Writeln('Graphics error:', GraphErrorMsg(ErrCode));
end.