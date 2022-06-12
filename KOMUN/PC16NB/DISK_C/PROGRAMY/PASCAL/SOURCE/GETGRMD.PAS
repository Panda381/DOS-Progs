uses
  Graph;
var
  Gd, Gm : integer;
  Mode : integer;
begin
  Gd := Detect;
  InitGraph(Gd, Gm, '');
  if GraphResult <> grOk then
    Halt(1);
  OutText('<RETURN> to leave graphics:');
  Readln;
  RestoreCRTMode;
  Writeln('Now in text mode');
  Write('<RETURN> to enter graphics mode:');
  Readln;
  SetGraphMode(GetGraphMode);
  OutTextXY(0, 0, 'Back in graphics mode');
  OutTextXY(0, TextHeight('H'), '<RETURN> to quit:');
  Readln;
  CloseGraph;
end.
