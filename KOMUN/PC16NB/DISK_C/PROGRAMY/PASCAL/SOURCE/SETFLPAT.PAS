uses
  Graph;
const
  Gray50 : FillPatternType = ($AA, $55, $AA, $55, $AA, $55, $AA, $55);
var
  Gd, Gm : integer;

begin
  Gd := Detect;
  InitGraph(Gd, Gm, '');
  if GraphResult <> grOk then
    Halt(1);
  SetFillPattern(Gray50, White);
  Bar(0, 0, 100, 100); { Draw a bar in a 50% gray scale }
  Readln;
  CloseGraph;
end.
