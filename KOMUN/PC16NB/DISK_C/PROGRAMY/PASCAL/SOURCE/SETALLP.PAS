uses
  Graph;
var
  Gd, Gm : integer;
  Palette : PaletteType;
begin
  Gd := Detect;
  InitGraph(Gd, Gm, '');
  if GraphResult <> grOk then
    Halt(1);
  Line(0, 0, GetMaxX, GetMaxY);
  with Palette do
  begin
    Size      := 4;
    Colors[0] := 5;
    Colors[1] := 3;
    Colors[2] := 1;
    Colors[3] := 2;
    SetAllPalette(Palette);
  end;
  Readln;
  CloseGraph;
end.
