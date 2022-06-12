uses
  Graph;
var
  Gd, Gm : integer;
  P      : pointer;
  Size   : word;
begin
  Gd := Detect;
  InitGraph(Gd, Gm, '');
  if GraphResult <> grOk then
    Halt(1);
  Bar(0, 0, GetMaxX, GetMaxY);
  Size := ImageSize(10,20,30,40);
  GetMem(P, Size); { Allocate memory on heap }
  GetImage(10,20,30,40,P^);
  Readln;
  ClearDevice;
  PutImage(100, 100, P^, NormalPut);
  Readln;
  CloseGraph;
end.

