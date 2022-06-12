uses
  Graph;
var
  Gd, Gm : integer;
  ViewPort : ViewPortType;
begin
  Gd := Detect;
  InitGraph(Gd, Gm, '');
  if GraphResult <> grOk then
    Halt(1);
  GetViewSettings(ViewPort);
  with ViewPort do
  begin
    Rectangle(0, 0, x2-x1, y2-y1);
    if Clip then
      OutText('Clipping is active.')
    else
      OutText('No clipping today.');
  end;
  Readln;
  CloseGraph;
end.
