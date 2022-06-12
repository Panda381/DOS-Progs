uses
  Graph;
var
  Gd, Gm   : integer;
  I, Width : integer;
begin
  Gd := Detect;
  InitGraph(Gd, Gm, '..');
  writeln(graphresult);
  readln;
  if GraphResult <> grOk then
    Halt(1);
  Width := 10;
  for I := 1 to 5 do
    Bar(I*Width, I*10, Succ(I)*Width, 200);
  Readln;
  CloseGraph;
end.