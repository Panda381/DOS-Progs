uses
  Graph;
var
  ErrorCode : integer;
  GrDriver, GrMode : integer;
begin
  GrDriver := Detect;
  InitGraph(GrDriver, GrMode, '');
  ErrorCode := GraphResult; { Check for errors }
  if ErrorCode <> grOK then
  begin
    Writeln('Graphics error:');
    Writeln(GraphErrorMsg(ErrorCode));
    Writeln('Program aborted...');
    Halt(1);
  end;
  { Do some graphics... }
  ClearDevice;
  Rectangle(0, 0, GetMaxX, GetMaxY);
  Readln;
  CloseGraph;
end.