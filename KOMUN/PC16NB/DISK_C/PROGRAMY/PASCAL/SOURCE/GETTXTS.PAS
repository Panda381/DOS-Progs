uses
  Graph;
var
  Gd, Gm   : integer;
  OldStyle : TextSettingsType;
begin
  Gd := Detect;
  InitGraph(Gd, Gm, '');
  if GraphResult <> grOk then
    Halt(1);
  GetTextSettings(OldStyle);
  OutTextXY(0, 0, 'Old text style');
  SetTextJustify(LeftText, CenterText);
  SetTextStyle(TriplexFont, VertDir, 4);
  OutTextXY(GetMaxX div 2, GetMaxY div 2, 'New Style');
  with OldStyle do
  begin                        { restore old text style }
    SetTextJustify(Horiz, Vert);
    SetTextStyle(Font, Direction, CharSize);
  end;
  OutTextXY(0, TextHeight('H'), 'Old style again');
  Readln;
  CloseGraph;
end.