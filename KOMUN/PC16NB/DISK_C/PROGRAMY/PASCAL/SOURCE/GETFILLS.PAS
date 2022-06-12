uses
  Graph;
var
  Gd, Gm   : integer;
  FillInfo : FillSettingsType;

begin
  Gd := Detect;
  InitGraph(Gd, Gm, '');
  if GraphResult <> grOk then
    Halt(1);
  GetFillSettings(FillInfo);   { save fill style and color }
  Bar(0, 0, 50, 50);
  SetFillStyle(XHatchFill, GetMaxColor);       { new style }
  Bar(50, 0, 100, 50);
  with FillInfo do
    SetFillStyle(Pattern, Color); { restore old fill style }
  Bar(100, 0, 150, 50);
  Readln;
  CloseGraph;
end.
