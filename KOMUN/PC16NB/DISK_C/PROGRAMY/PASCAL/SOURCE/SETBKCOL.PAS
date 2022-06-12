uses
  Crt, Graph;
var
  GraphDriver, GraphMode : integer;
  Palette : PaletteType;
begin
  GraphDriver := Detect;
  InitGraph(GraphDriver,GraphMode,'');
  Randomize;
  if GraphResult <> grOk then
    Halt(1);
  GetPalette(Palette);
  repeat
    if Palette.Size <> 1 then
      SetBkColor(Random(Palette.Size));
    LineTo(Random(GetMaxX),Random(GetMaxY));
  until KeyPressed;
  CloseGraph;
end.


