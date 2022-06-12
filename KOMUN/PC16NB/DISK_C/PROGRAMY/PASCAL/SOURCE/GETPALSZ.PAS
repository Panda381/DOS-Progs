{ example for GetPaletteSize }

uses
  Graph;
var
  Driver, Mode : Integer;

begin
  Driver := Detect;                                { Put in graphics mode }
  InitGraph(Driver, Mode, '');
  if GraphResult < 0 then
    Halt(1);

  SetColor(1);
  OutText('Color = 1, ');
  SetColor(GetPaletteSize - 1);
  OutText('Color = Max');

  Readln;
  Closegraph;
end.
