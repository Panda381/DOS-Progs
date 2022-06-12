uses
  Crt, Graph;
var
  GraphDriver, GraphMode : integer;
  Color : word;
  Palette : PaletteType;
begin
  GraphDriver := Detect;
  InitGraph(GraphDriver, GraphMode, '');
  if GraphResult <> grOk then
    Halt(1);
  GetPalette(Palette);
  if Palette.Size <> 1 then
    begin
      for Color := 0 to Pred(Palette.Size) do
      begin
        SetColor(Color);
        Line(0, Color*5, 100, Color*5);
      end;
      Randomize;
      repeat
        SetPalette(Random(Palette.Size),
                   Random(Palette.Size));
      until KeyPressed;
    end
  else
    Line(0, 0, 100, 0);
  Readln;
  CloseGraph
end.