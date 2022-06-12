uses
  Crt, Graph;
var
  Gd, Gm : integer;

begin
  Gd := Detect;
  InitGraph(Gd, Gm, '');
  if GraphResult <> grOk then
    Halt(1);
  Randomize;
  repeat
    Line(Random(200), Random(200),
         Random(200), Random(200));
  until KeyPressed;
  Readln;
  CloseGraph;
end.