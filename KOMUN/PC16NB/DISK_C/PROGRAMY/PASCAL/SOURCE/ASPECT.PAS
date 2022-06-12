uses
  Graph;
var
  Gd, Gm : integer;
  Xasp, Yasp : word;
  XSideLength, YSideLength : integer;

begin
  Gd := Detect;
  InitGraph(Gd, Gm, '');
  if GraphResult <> grOk then
    Halt(1);
  GetAspectRatio(Xasp, Yasp);
  XSideLength := 20;

  { Adjust Y length for aspect ratio }
  YSideLength := Round((Xasp/Yasp)*XSideLength);

  { Draw a "square" rectangle on the screen }
  Rectangle(0, 0, XSideLength, YSideLength);

  Readln;
  CloseGraph;
end.
