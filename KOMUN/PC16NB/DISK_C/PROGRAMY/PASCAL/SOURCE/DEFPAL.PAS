{ example for GetDefaultPalette }

uses
  Crt, Graph;
var
  Driver, Mode,
  i : Integer;
  MyPal, OldPal : PaletteType;

begin
  DirectVideo := false;
  Randomize;
  Driver := Detect;                   { Put in graphics mode }
  InitGraph(Driver, Mode, '');
  if GraphResult < 0 then
    Halt(1);

  GetDefaultPalette(OldPal);          { preserve old one }
  MyPal := OldPal;                    { duplicate & modify }

  { Display something }
  for i := 0 to MyPal.Size - 1 do
  begin
    SetColor(i);
    OutTextXY(10, i * 10, '...Press any key...');
  end;


  repeat           { Change palette until a key is pressed }
    with MyPal do
      Colors[Random(Size)] := Random(Size + 1);
    SetAllPalette(MyPal);
  until KeyPressed;

  SetAllPalette(OldPal);        { restore original palette }
  ClearDevice;
  OutTextXY(10, 10, 'Press <Return>...');
  Readln;
  Closegraph;
end.
