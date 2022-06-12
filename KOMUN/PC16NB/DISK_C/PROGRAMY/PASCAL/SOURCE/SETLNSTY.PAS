uses
  Graph;
var
  Gd, Gm : integer;
  x1, y1, x2, y2 : integer;
begin
  Gd := Detect;
  InitGraph(Gd, Gm, '');
  if GraphResult <> grOk then
    Halt(1);
  x1 := 10;
  y1 := 10;
  x2 := 200;
  y2 := 150;
  SetLineStyle(DottedLn,0,NormWidth);
  Rectangle(x1, y1, x2, y2);
  SetLineStyle(UserBitLn,$C3,ThickWidth);
  Rectangle(Pred(x1), Pred(y1), Succ(x2), Succ(y2));
  Readln;
  CloseGraph;
end.