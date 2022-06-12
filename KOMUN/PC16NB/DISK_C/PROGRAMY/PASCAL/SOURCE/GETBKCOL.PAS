uses
  Crt, Graph;
var
  Gd, Gm : integer;
  Color  : word;
  OldPal : PaletteType;
begin
  Gd := Detect;
  InitGraph(Gd, Gm, '');
  if GraphResult <> grOk then
    Halt(1);
  Randomize;
  GetPalette(OldPal);
  if OldPal.Size <> 1 then
    begin
      repeat
        Color := Succ(GetBkColor);
        if Color > GetMaxColor then
          Color := 0;
        SetBkColor(Color);
        LineTo(Random(GetMaxX), Random(GetMaxY));
      until KeyPressed;
    end
  else
    Line(0, 0, GetMaxX, GetMaxY);
  Readln;
  CloseGraph;
end.
