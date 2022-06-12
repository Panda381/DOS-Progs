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
  Color := GetMaxColor;
  Randomize;
  repeat
    PutPixel(Random(100),Random(100), Color); { Plot "stars" }
    Delay(10);
  until KeyPressed;
  Readln;
  CloseGraph;
end.