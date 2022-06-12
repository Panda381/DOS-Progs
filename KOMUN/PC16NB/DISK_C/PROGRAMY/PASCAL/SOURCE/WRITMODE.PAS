{ example for SetWriteMode }

uses
  Crt, Graph;
var
  Driver, Mode,
  i : Integer;
  x1, y1, dx, dy : Integer;
  FillInfo : FillSettingsType;
begin
  DirectVideo := false;                   { turn off screen write }
  Randomize;
  Driver := Detect;                        { Put in graphics mode }
  InitGraph(Driver, Mode, '');
  if GraphResult < 0 then
    Halt(1);

  { Fill screen with background pattern }
  GetFillSettings(FillInfo);               { get current settings }
  SetFillStyle(WideDotFill, FillInfo.Color);
  Bar(0, 0, GetMaxX, GetMaxY);

  dx := GetMaxX div 4;         { determine rectangle's dimensions }
  dy := GetMaxY div 4;

  SetLineStyle(SolidLn, 0, ThickWidth);
  SetWriteMode(XORput);                  { XOR mode for rectangle }
  repeat                            { draw until a key is pressed }
    x1 := Random(GetMaxX - dx);
    y1 := Random(GetMaxY - dy);
    Rectangle(x1, y1, x1 + dx, y1 + dy);                { draw it }
    Delay(10);                                    { pause briefly }
    Rectangle(x1, y1, x1 + dx, y1 + dy);               { erase it }
  until KeyPressed;

  Readln;
  Closegraph;
end.
