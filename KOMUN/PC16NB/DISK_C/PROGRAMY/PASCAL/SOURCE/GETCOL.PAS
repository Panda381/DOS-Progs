uses
  Crt, Graph;
var
  Gd, Gm : integer;
  Color  : word;
begin
  Gd := Detect;
  InitGraph(Gd, Gm, '');
  if GraphResult <> grOk then
    Halt(1);
  Randomize;
  repeat
    Color := Succ(GetColor);
    if Color > GetMaxColor then
      Color := 0;
    SetColor(Color);
    LineTo(Random(GetMaxX), Random(GetMaxY));
  until KeyPressed;
  CloseGraph;
end.
