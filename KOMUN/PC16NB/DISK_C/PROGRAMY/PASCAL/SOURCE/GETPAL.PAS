uses
  Graph;
var
  Gd, Gm  : integer;
  Color   : word;
  Palette : PaletteType;
begin
  Gd := Detect;
  InitGraph(Gd, Gm, '');
  if GraphResult <> grOk then
    Halt(1);
  GetPalette(Palette);
  if Palette.Size <> 1 then
    for Color := 0 to Pred(Palette.Size) do
    begin
      SetColor(Color);
      Line(0, Color*5, 100, Color*5);
    end
  else
    Line(0, 0, 100, 0);
  Readln;
  CloseGraph;
end.
