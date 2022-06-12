uses
  Graph;
var
  Gd, Gm : integer;

begin
  Gd := Detect;
  InitGraph(Gd, Gm, '');
  if GraphResult <> grOk then
    Halt(1);
  { Center text on screen: }
  SetTextJustify(CenterText, CenterText);
  OutTextXY(Succ(GetMaxX) div 2,
            Succ(GetMaxY) div 2,
            'Easily Centered');
  Readln;
  CloseGraph;
end.